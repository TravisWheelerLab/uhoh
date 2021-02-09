# Uhoh

A simple tool to create and maintain backups of your GitHub repositories.

## Use

Acquire a binary compiled for your platform (Mac and Linux are
supported at this time).

Create a GitHub
[personal access token](https://github.com/settings/tokens) with
the full "repo" permissions. Uhoh will be able to access any repo
that the user who owns the token can access.

When Uhoh is run, it will look for an environment variable called
`UHOH_AUTH_TOKEN`, which must be set to the token created above.
For example: `export UHOH_AUTH_TOKEN=<token>`.

Run it!

### Examples

Back up repos belonging to the "AcmeCo" organization, store the
backups under `/var/backups/github` (the user running Uhoh must
be able to write to this directory). Also note that the name of
the organization is case-sensitive.

```
uhoh --target /var/backups/github --organizations AcmeCo
```

If the `--target` is omitted, the current directory will be
assumed, so this would work as well:

```
cd /var/backups/github
uhoh -o AcmeCo
```

## Development

Uhoh is written in [Dart](https://dart.dev). Install the toolchain
here: <https://dart.dev/get-dart>. You will need at least version
2.7.0.

  - Fetch build dependencies: `make setup`
  - Build a native binary: `make binary`
  - Format the code (do this prior to making a PR): `make format`

Run `make` by itself to see the list of available targets.

### TODO

  - Add unit and functional test suites
