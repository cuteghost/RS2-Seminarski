#!/bin/bash

set -x

host="$1"
shift
cmd="$@"

until curl -s "$host" > /dev/null; do
  >&2 echo "$host is unavailable - sleeping"
  sleep 1
done

>&2 echo "$host is up - executing command"
exec sh -c "$cmd"