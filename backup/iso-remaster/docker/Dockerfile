FROM alpine

RUN apk add --update darkhttpd dnsmasq
ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
