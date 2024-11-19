# Secrets

This directory contains files that are not meant to be exposed to the public.
This includes passwords, SSH keys and other information only meant for the system administrators.
All files are explicitly listed in the `.gitignore` file to prevent them from being added to the repository.
To replicate the setup, these files are passed around manually between the people involved in the setup.

## SSH-Key

This directory contains an ED-25519 SSH key pair that is used to authenticate when connecting to the server for the first time.
The server is not going to accept the authentication of the user via password, so the key pair is necessary.

# Root-Password

The fle `passowrd.txt` contains the root/admin password and its hash.
A hash can be generated with the following command: `printf "r00tpassw0rd" | mkpasswd -s -m md5`.
You need the `mkpasswd` utility from the `whois` package to generate the password hash.
