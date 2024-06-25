#!/bin/bash

export GPG_TTY=$(tty)
PREFIX=~/.password-store
GPG=gpg

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 YYYY-MM-DD"
    exit 1
fi

# Convert the given date to the format required by macOS
given_date=$(date -j -f "%Y-%m-%d" "$1" "+%s")
if [[ $? -ne 0 ]]; then
    echo "Invalid date format. Use YYYY-MM-DD"
    exit 1
fi

printf "The following passwords have not been rotated since before $1\n"
printf "* All entries in $PREFIX/SSL/* are ignored as they are rotated as they expire\n"

while read -r -d "" passfile; do
    grepresults="$($GPG -d "$passfile" 2>/dev/null | grep --color=always -i "last set date:" | awk 'NF==1 {print $0; next} {print $NF}')"
    if [[ $? -ne 0 ]]; then
        echo "Decryption failed for $passfile. Possible reasons: missing key, incorrect passphrase, corrupted file, or permission issues." >&2
        continue
    fi

    passfile="${passfile%.gpg}"
    passfile="${passfile#$PREFIX/}"

    arr=$(printf "$grepresults")
    for item in $arr; do
        lastset=$(date -j -f "%Y-%m-%d" "$item" "+%s")
        if [[ $lastset -le $given_date ]]; then
            printf "\e[94m%s\e[0m\n" "$passfile"
        fi
    done
done < <(find -L "$PREFIX" -path '*/.git' -prune -o -iname '*.gpg' ! -path "$PREFIX/SSL/*" -print0)

