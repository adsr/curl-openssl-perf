#!/bin/bash

socat "ssl-l:8181,cert=cert/test.crt,key=cert/test.key,verify=0,fork,reuseaddr" SYSTEM:"echo HTTP/1.0 200; echo content-type\: text/plain; echo; echo 42"
