FROM openjdk:8u181-jre-alpine

LABEL version=${version}

RUN apk --update add krb5-libs krb5 krb5-dev

COPY kafka-kerberos kafka-kerberos

WORKDIR kafka-kerberos

ENTRYPOINT sh run.sh
