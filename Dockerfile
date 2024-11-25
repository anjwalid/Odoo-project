FROM ubuntu:22.04
MAINTAINER Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Générer les locales nécessaires
ENV LANG en_US.UTF-8

# Installer les dépendances, wkhtmltopdf et PostgreSQL client
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        postgresql-client \
        && rm -rf /var/lib/apt/lists/*

# Installer rtlcss (pour la prise en charge RTL)
RUN npm install -g rtlcss

# Installer Odoo
ENV ODOO_VERSION 16.0
RUN curl -o odoo.deb -sSL https://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.latest_all.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./odoo.deb && \
    rm -rf /var/lib/apt/lists/* odoo.deb

# Configurer les fichiers nécessaires
COPY ./entrypoint.sh /entrypoint.sh
COPY ./odoo.conf /etc/odoo/
COPY ./wait-for-psql.py /usr/local/bin/wait-for-psql.py

RUN chmod +x /entrypoint.sh /usr/local/bin/wait-for-psql.py

# Définir les permissions
RUN mkdir -p /mnt/extra-addons && \
    chown -R odoo:odoo /etc/odoo /mnt/extra-addons

# Exposer les ports
EXPOSE 8069 8071 8072

# Définir l'utilisateur et le point d'entrée
USER odoo
ENV ODOO_RC /etc/odoo/odoo.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
