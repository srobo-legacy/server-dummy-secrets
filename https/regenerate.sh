#!/bin/sh -ex
openssl req -x509 -nodes -days 3650 -newkey rsa:3096 -keyout server.key -out server.crt < input.txt
