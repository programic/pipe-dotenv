FROM alpine:3.15

RUN apk add --no-cache jq bash curl \
    && wget -P / https://raw.githubusercontent.com/programic/bash-common/main/common.sh

COPY pipe /

RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]