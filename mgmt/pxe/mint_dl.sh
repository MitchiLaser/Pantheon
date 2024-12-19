#!/bin/bash

# This scripts fetches the latest Linux Mint ISO file with Cinnamon desktop for 64bit systems
# and stores the iso file in a temporary file. The script also checks the sha256 checksum of the
# downloaded file and returns the path to the file if the checksum is correct. Otherwise the
# script returns an error code.
#
# To get the newest version of Linux Mint, the script fetches the content of the download page of a local mirrot
# and extracts the version numbers from the links to get the highest version number.

# URL to fetch
URL="https://ftp.fau.de/mint/iso/stable/"

# Fetch the page content
content=$(curl -s "$URL")

# Extract the content between <a> tags and store in an array
# This will also strip away the slash `/` at the end of the link text
#links=($(echo "$content" | grep -oP '(?<=<a[^>]*>)(.*?)(?=</a>)'))  # This shit does not work, because: grep: length of lookbehind assertion is not limited.
# Seems like the lookbehinds are poorly implemented in grep, i had to switch to the sucker 'sed' !
links=($(echo "$content" | sed -n 's/.*<a[^>]*>\(.*\)\/<\/a>.*/\1/p'))

# in case some of the links do not contain floating point numbers:
# purge the list
numbers=()  # occupy array name
for link in "${links[@]}"
do
  extracted_number=$(echo "$link" | grep -oP '\d+(\.\d+)?')
  if [[ ! -z ${extracted_number} ]]
  then
    numbers+=(${extracted_number})
  fi
done
# sort by version number, take latest as highest number
highest_number=$(printf "%s\n" "${numbers[@]}" | sort -V | tail -n 1)

# perfect, we have the link with the highest version number. Now look what iso files for ix86_64 with cinnamon desktop are available in this directory
# start the whole game again
content=$(curl -s "${URL}${highest_number}/")
links=($(echo "$content" | sed -n 's/.*<a[^>]*>\(.*\)<\/a>.*/\1/p'))
for link in "${links[@]}"
do
  if [[ $link == *"cinnamon"* && $link == *"64bit"* ]]
  then
  download_link="${URL}${highest_number}/${link}"
  fi
done

# download file to current_mint.iso
TEMPFILE_ISO=$(mktemp -p /tmp/ -t XXXXXX.current_mint.iso)
wget -o /dev/null -O ${TEMPFILE_ISO} ${download_link}

# check if there is a file providing the checksums
for link in "${links[@]}"
do
  if [[ $link == *"sha256"* && $link == *".txt" ]]
  then
  checksums_URL="${URL}${highest_number}/${link}"
  fi
done

checksum=$(curl -s "${checksums_URL}" | grep "cinnamon" | grep "64bit" | cut -d " " -f1)
compute_checksum=$(sha256sum ${TEMPFILE_ISO} | cut -d " " -f1)
if [[ $checksum == $compute_checksum ]]
then
  echo ${TEMPFILE_ISO}
  exit 0
else
  rm ${TEMPFILE_ISO}
  exit 1
fi
