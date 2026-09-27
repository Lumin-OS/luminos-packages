# luminos-packages

Package sources for LuminOS's own packages, one folder per package.

| Package | What it is |
|---|---|
| `luminos-base` | The base system every LuminOS install has, with or without a desktop, usable from the command line alone |
| `luminos-keyring` | The key the repository is signed with (to come) |
| `luminos-desktop` | The Hyprland desktop on top of the base (to come) |
| `luminos-dawn` | Dawn, the installer (comes with Dawn's M5) |

Dawn's online install pacstraps `luminos-base` and `luminos-desktop`, and the
[LuminOS ISO](https://github.com/Lumin-OS/LuminOS) is built from the same
packages, so offline installs match online ones. The ISO's `luminos-live`
package isn't here: only the ISO uses it, so it lives and gets built there.

## Building

These packages' dependencies are for the systems they get installed on, not
for the machine that builds them, so build with `--nodeps`, and sign with the
repository's key:

```sh
cd luminos-base
GPGKEY=<the repository key's fingerprint> makepkg --nodeps --sign
```

The built packages go into
[luminos-repository](https://github.com/Lumin-OS/luminos-repository)'s
`x86_64/`, and its `dbupdate.sh` updates the database.
