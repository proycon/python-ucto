FROM proycon/ucto
LABEL org.opencontainers.image.authors="Maarten van Gompel <proycon@anaproy.nl>"
LABEL description="Ucto, rule-based tokenizer, python binding"


COPY . /usr/src/python-ucto
RUN BUILD_PACKAGES="build-base libtool libtar-dev bzip2-dev icu-dev libxml2-dev libexttextcat-dev python3-dev" &&\
    mkdir -p /usr/src/python-ucto &&\
    apk add python3 py3-wheel py3-pip cython $BUILD_PACKAGES &&\
    cd /usr/src/python-ucto && pip install . && apk del $BUILD_PACKAGES

ENTRYPOINT [ "python3" ]
