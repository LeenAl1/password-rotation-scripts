#!/bin/bash

export GPG_TTY=$(tty)
PREFIX=~/.password-store
GPG=gpg

while read -r -d "" passfile; do
    grepresults="$($GPG -d "$passfile" 2>/dev/null | grep --color=always -i "last set date:")"
    if [[ $? -ne 0 ]]; then
        echo "Decryption failed for $passfile. Possible reasons: missing key, incorrect passphrase, corrupted file, or permission issues." >&2
        continue
    fi

    passfile="${passfile%.gpg}"
    passfile="${passfile#$PREFIX/}"
    printf "\e[94m%s\e[0m\n" "$passfile"
    echo "$grepresults"
done < <(find -L "$PREFIX" -path '*/.git' -prune -o -iname '*.gpg' ! -path "$PREFIX/SSL/*" -print0)

