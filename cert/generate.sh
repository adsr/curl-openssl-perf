#!/bin/bash
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out test.crt -keyout test.key -subj "/CN=localhost"
