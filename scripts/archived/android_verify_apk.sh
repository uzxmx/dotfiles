#!/usr/bin/env bash

jarsigner -verify -verbose -certs "$@"
