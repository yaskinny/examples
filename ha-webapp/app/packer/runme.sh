#!/usr/bin/env bash

set -euo pipefail

if (( ${#} < 2 )); then
  printf >&2 '%s\n' "two arguments are needed"
  exit 1
fi

# subnet is first arg
# vpc is second arg
subnet="${1#*.}"
vpc="${2#*.}"

cat vars.sample | sed "s/SEDME-vpc/\"${vpc}\"/;s/SEDME-subnet/\"${subnet}\"/"  > all.auto.pkrvars.hcl

if ! packer validate . ; then
  printf >&2 '%s\n' "Packer can not validate this build"
  exit 1
fi

packer build .
