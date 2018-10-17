#!/usr/bin/env bash

if [ "${1}" == "--update-translations" ]; then
    tx pull -fl he,ar &&\
    msgfmt -o ckan/i18n/ar/LC_MESSAGES/ckan.mo ckan/i18n/ar/LC_MESSAGES/ckan.po &&\
    msgfmt -o ckan/i18n/he/LC_MESSAGES/ckan.mo ckan/i18n/ar/LC_MESSAGES/ckan.po

else
    VERSION_LABEL="${1}"

    [ "${VERSION_LABEL}" == "" ] \
        && echo Missing version label \
        && echo current hasadna-VERSION.txt = $(cat hasadna-VERSION.txt) \
        && exit 1

    echo "${VERSION_LABEL}" > hasadna-VERSION.txt &&\
    docker build -t uumpa/hasadna-ckan:v${VERSION_LABEL} . &&\
    docker push uumpa/hasadna-ckan:v${VERSION_LABEL} &&\
    echo docker: uumpa/hasadna-ckan:v${VERSION_LABEL} &&\
    echo Great Success &&\
    exit 0

    exit 1

fi
