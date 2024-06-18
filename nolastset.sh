#!/bin/bash

PREFIX=~/.password-store
GPG=gpg

printf "The following passwords do not have a last set date\n"
printf "* All entries in $PREFIX/SSL/* are ignored as they are rotated as they expire\n"

while read -r -d "" passfile; do
    grepresults="$($GPG -d "$passfile" | grep --color=always -i "last set date:")"
    [[ $? -ne 0 ]] && continue

    passfile="${passfile%.gpg}"
    passfile="${passfile#$PREFIX/}"
    passfile_dir="${passfile%/*}/"
    [[ $passfile_dir == "${passfile}/" ]] && passfile_dir=""

    printf "\e[94m%s\e[1m%s\e[0m:\n" "$passfile_dir" "$passfile"
done < <(find -L "$PREFIX" -path '*/.git' -prune -o -iname '*.gpg' ! -path "$PREFIX/SSL/*" -print0)

