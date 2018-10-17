#!/usr/bin/env bash

if [ "${1}" == "--update-translations" ]; then
    tx pull -fl he,ar &&\
    for LANG in he ar; do
        msgfmt -o ckan/i18n/${LANG}/LC_MESSAGES/ckan.mo ckan/i18n/${LANG}/LC_MESSAGES/ckan.po
    done


else
    VERSION_LABEL="${1}"

    [ "${VERSION_LABEL}" == "" ] \
        && echo Missing version label \
        && echo current hasadna-VERSION.txt = $(cat hasadna-VERSION.txt) \
        && exit 1

    if [ "${VERSION_LABEL}" == "--travis" ]; then
        VERSION_LABEL=$(echo "${TRAVIS_COMMIT_MESSAGE}" | python -c "import sys; print([r for r in sys.stdin.read().split() if r.startswith('--release=')][0].split('=')[1])" 2>/dev/null)
        if [ "${VERSION_LABEL}" == "" ]; then
            echo "To ship a release include --release=version_label in the commit message"
            exit 0
        fi
      TRAVIS_RELEASE=yes
    else
      TRAVIS_RELEASE=
    fi

    echo "${VERSION_LABEL}" > hasadna-VERSION.txt &&\
    docker build --cache-from uumpa/hasadna-ckan:latest \
                 -t uumpa/hasadna-ckan:v${VERSION_LABEL} . &&\
    docker push uumpa/hasadna-ckan:v${VERSION_LABEL}
    [ "$?" != "0" ] && echo failed docker build push && exit 1

    if [ "${TRAVIS_RELEASE}" == "yes" ]; then
        travis_ci_operator.sh github-update self "${TRAVIS_BRANCH}" "echo ${VERSION_LABEL} > hasadna-VERSION.txt; git add hasadna-VERSION.txt" "Publish v${VERSION_LABEL} --no-deploy"
        [ "$?" != "0" ] && echo failed to commit version && exit 1
    fi

    echo docker: uumpa/hasadna-ckan:v${VERSION_LABEL}
    echo Great Success
    exit 0

fi
