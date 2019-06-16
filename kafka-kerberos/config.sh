#!/usr/bin/env bash

echo "Adding entries to /etc/hosts ..."
echo "10.1.1.29 kerberos.example.com" >> /etc/hosts
echo "10.1.1.30 kafka2" >> /etc/hosts
echo "10.1.1.31 kafka1" >> /etc/hosts

echo "Creating 'krb5.conf' file ..."
cat /kafka-kerberos/krb5.conf > /etc/krb5.conf
