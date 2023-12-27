#!/usr/bin/env bash

# USAGE: ./gpg-helper.sh [encrypt|decrypt] OLD_NAME NEW_NAME
# Currently, this will encrypt/decrypt for a hardcoded gpg key.

GPG_BIN=gpg

gpg_decrypt() {
  "$GPG_BIN" --decrypt --output "$2" "$1"
}

gpg_encrypt() {
  local hardcoded_email="me@mattjmcnaughton.com"

  "$GPG_BIN" --encrypt --recipient="$hardcoded_email" --output "$2" "$1"
}

fail() {
  >&2 echo "$1"
  exit 1
}

case "$1" in
e*)
  if [ "$#" == 2 ]; then
    gpg_encrypt "$2" "$2.gpg"
  elif [ "$#" == 3 ]; then
    gpg_encrypt "$2" "$3"
  else
    fail "encrypt requires either 2 or 3 arguments"
  fi
  ;;
d*)
  if [ "$#" == 2 ]; then
    # Strip the .gpg if we don't specify a value.
    gpg_decrypt "$2" "${2::-4}"
  elif [ "$#" == 3 ]; then
    gpg_decrypt "$2" "$3"
  else
    fail "decrypt requires either 2 or 3 arguments"
  fi
  ;;
*)
  echo "Usage: ./gpg-helper.sh [encrypt|decrypt]"
  exit 1
esac
