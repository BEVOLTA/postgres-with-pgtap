ARG POSTGRES_VERSION="14-alpine"
ARG PGTAP_VERSION="v1.3.3"
ARG PGTAP_RUNNER_VERSION="3.37"

FROM postgres:${POSTGRES_VERSION}

ARG PGTAP_VERSION
ARG PGTAP_RUNNER_VERSION

COPY init-pgtap-extension.sql /docker-entrypoint-initdb.d/


RUN set -ex && \
    apk add --no-cache perl && \
    apk add --no-cache --virtual .build-dependencies \
    cmake make musl-dev gcc gettext-dev libintl perl-app-cpanminus \
    postgresql \
    postgresql-contrib \
    build-base \
    patch \
    diffutils \
    git \
    perl && \
    git config --global --add safe.directory '*' && \
    git clone --branch ${PGTAP_VERSION} --depth 1 https://github.com/theory/pgtap.git && \
        chown -R postgres:postgres pgtap/ && \
        cd pgtap/ && \
        make && make install && \
        cpanm --notest --mirror https://cpan.metacpan.org --mirror-only \
          TAP::Parser::SourceHandler::pgTAP@${PGTAP_RUNNER_VERSION} && \
    apk del .build-dependencies
