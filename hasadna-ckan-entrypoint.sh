#!/usr/bin/env bash

source $CKAN_K8S_SECRETS &&\
rm -f $CKAN_CONFIG/*.ini &&\
cp -f $CKAN_K8S_TEMPLATES/who.ini $CKAN_CONFIG/who.ini &&\
bash /templater.sh $CKAN_K8S_TEMPLATES/production.ini.template > $CKAN_CONFIG/production.ini &&\
ckan-paster --plugin=ckan db init -c "${CKAN_CONFIG}/production.ini"
INIT_RES=$?

[ "${INIT_RES}" != "0" ] && echo ERROR: Initialization failed

if [ "$*" == "" ]; then
    [ "${INIT_RES}" != "0" ] && exit 1
    exec ${CKAN_VENV}/bin/gunicorn --paste ${CKAN_CONFIG}/production.ini --workers ${GUNICORN_WORKERS}
else
    exec "$@"
fi
