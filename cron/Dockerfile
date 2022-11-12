FROM docker.io/library/alpine:latest

RUN apk update && apk upgrade \
	&& apk add bash tzdata exiftool

COPY cron/entrypoint.sh /entrypoint.sh
COPY scripts/* /usr/local/bin/

ENTRYPOINT ["/entrypoint.sh"]

