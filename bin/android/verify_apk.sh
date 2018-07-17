#!/bin/sh

jarsigner -verify -verbose -certs $*
