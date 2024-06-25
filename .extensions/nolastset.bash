#!/bin/bash

export GPG_TTY=$(tty)
PREFIX=~/.password-store
GPG=gpg

printf "The following passwords do not have a last set date\n"
printf "* All entries in $PREFIX/SSL/* are ignored as they are rotated as they expire\n"

while read -r -d "" passfile; do
    echo "Processing: $passfile"  # Debugging line
    grepresults="$($GPG -d "$passfile" 2>&1 | tee /tmp/gpg_output.txt | grep --color=always -i "last set date:")"
    gpg_exit_code=$?
    
    if [[ $gpg_exit_code -ne 0 ]]; then
        echo "Decryption failed for $passfile. Possible reasons: missing key, incorrect passphrase, corrupted file, or permission issues." >&2
        echo "GPG output:" >&2
        cat /tmp/gpg_output.txt >&2
        continue
    fi

    if [[ -z "$grepresults" ]]; then
        passfile="${passfile%.gpg}"
        passfile="${passfile#$PREFIX/}"
        printf "\e[94m%s\e[0m\n" "$passfile"
    else
        echo "Last set date found: $grepresults"  # Debugging line
    fi
done < <(find -L "$PREFIX" -path '*/.git' -prune -o -iname '*.gpg' ! -path "$PREFIX/SSL/*" -print0)

