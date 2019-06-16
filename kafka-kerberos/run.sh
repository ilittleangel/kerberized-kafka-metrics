#!/bin/bash

./config.sh

topic=topic1
group=consumer1

echo "run.sh -> topic=${topic} groupId=${group}"

echo "Executing kafka-metrics ..."

java -Djava.security.auth.login.config=/kafka-kerberos/jaas.conf \
-jar /kafka-kerberos/KafkaMetrics-*.jar ${group} ${topic}
