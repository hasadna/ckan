# See CKAN docs on installation from Docker Compose on usage
FROM debian:jessie

# Install required system packages
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
        python-dev \
        python-pip \
        python-virtualenv \
        python-wheel \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
        libgeos-dev \
        libssl-dev \
        libffi-dev \
        postgresql-client \
        build-essential \
        git-core \
        vim \
        wget \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*

# Define environment variables
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_VENV $CKAN_HOME/venv
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_STORAGE_PATH=/var/lib/ckan

# Create ckan user
RUN useradd -r -u 900 -m -c "ckan account" -d $CKAN_HOME -s /bin/false ckan

# Setup virtual environment for CKAN
RUN mkdir -p $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH && \
    virtualenv $CKAN_VENV && \
    ln -s $CKAN_VENV/bin/pip /usr/local/bin/ckan-pip &&\
    ln -s $CKAN_VENV/bin/paster /usr/local/bin/ckan-paster

# Setup CKAN
RUN ckan-pip install -U pip &&\
    chown -R ckan:ckan $CKAN_HOME $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH

USER ckan

COPY requirement-setuptools.txt $CKAN_VENV/src/ckan/
RUN ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirement-setuptools.txt

COPY requirements.txt $CKAN_VENV/src/ckan/
RUN ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirements.txt

ADD . $CKAN_VENV/src/ckan/

USER root

RUN chown -R ckan:ckan $CKAN_VENV/src &&\
    ln -s $CKAN_VENV/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini

USER ckan

RUN ckan-pip install -e $CKAN_VENV/src/ckan/

COPY hasadna-requirements.txt /tmp/hasadna-requirements.txt
RUN ckan-pip install -r /tmp/hasadna-requirements.txt

COPY hasadna-ckan-entrypoint.sh /ckan-entrypoint.sh
COPY hasadna-templater.sh /templater.sh

ENTRYPOINT ["/ckan-entrypoint.sh"]

EXPOSE 5000

ENV GUNICORN_WORKERS=4
