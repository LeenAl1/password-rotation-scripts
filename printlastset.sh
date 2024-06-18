#!/bin/bash

PREFIX=~/.password-store
GPG=gpg

while read -r -d "" passfile; do
    echo "$passfile:"
    grepresults="$($GPG -d "$passfile" | grep --color=always -i "last set date:")"
    [[ $? -ne 0 ]] && continue

    passfile="${passfile%.gpg}"
    passfile="${passfile#$PREFIX/}"
    passfile_dir="${passfile%/*}/"
    [[ $passfile_dir == "${passfile}/" ]] && passfile_dir=""

    printf "\e[94m%s\e[1m%s\e[0m:\n" "$passfile_dir" "$passfile"
    echo "$grepresults"
done < <(find -L "$PREFIX" -path '*/.git' -prune -o -iname '*.gpg' ! -path "$PREFIX/SSL/*" -print0)

