#!/bin/sh

is_root() {
  [ "$(id -u)" = 0 ]
}
