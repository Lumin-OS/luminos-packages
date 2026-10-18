# luminos-packages

Package sources for LuminOS's own packages, one folder per package.

| Package | What it is |
|---|---|
| `luminos-base` | The base system every LuminOS install has, with or without a desktop, usable from the command line alone |
| `luminos-keyring` | The key the repository is signed with |
| `luminos-desktop` | The Hyprland desktop on top of the base: the Quickshell bar, the greetd login screen, apps and fonts, and every new user's config from [dotfiles](https://github.com/Lumin-OS/dotfiles) |
| `luminos-dawn` | Dawn, the installer: GUI/backend, runtime branding and polkit integration |

Dawn's online install pacstraps `luminos-base` and `luminos-desktop`, and the
[LuminOS ISO](https://github.com/Lumin-OS/LuminOS) is built from the same
packages, so offline installs match online ones. The ISO's `luminos-live`
package isn't here: only the ISO uses it, so it lives and gets built there.

## Building

Build as an unprivileged user in the official Arch CI environment. These
packages' runtime dependencies are for the installed system; `--nodeps`
skips that check on the builder (build tools and libraries are still needed).
CI creates unsigned artifacts for signing locally:

```sh
cd luminos-base
makepkg --nodeps --nosign
```

The built packages go into
[luminos-repository](https://github.com/Lumin-OS/luminos-repository)'s
`x86_64/`, and its `dbupdate.sh` updates the database.

`luminos-desktop` takes the dotfiles at the commit its `source` pins. To
ship newer dotfiles, change that commit and run `updpkgsums`, which
checksums git sources too.

The repository key (`547F4761802A0904A0B10E5FAE527343BC3E39B3`, "LuminOS")
expires on 2029-10-17. `luminos-keyring/PKGBUILD` says what to do before
then.

`luminos-dawn` builds Rust binaries, so its build machine needs Rust, git,
fontconfig, libxcb, libxkbcommon and Wayland development libraries. The
PKGBUILD fetches locked Cargo dependencies in prepare(), then builds with
`--frozen`. It pins an immutable M5 source commit until a release tag exists.
Run Dawn's checks before publishing; its package check() runs the workspace
tests too. The default GUI backend is winit, independent of Qt on the host.

M6 merge order: Dawn's helper changes and these recipes first, then the ISO
workflow. Publish the replacement keyring and portable Dawn before running
M6 against the signed repository snapshot.

Build release binaries in the official Arch environment used by the ISO CI.
`luminos-dawn` explicitly targets baseline x86-64 for Rust and C/C++ code;
native CPU optimizations from a developer's makepkg configuration must not
leak into distributed packages. The previous 0.1.0-1 build from a native
optimized host crashes on other CPUs; distribute 0.1.0-2 or newer. The ISO
workflow uploads unsigned package artifacts for the user's signing step.

## Signing existing CI artifacts

Sign the downloaded archive locally without rebuilding it:

```sh
gpg --local-user 547F4761802A0904A0B10E5FAE527343BC3E39B3 \
  --detach-sign luminos-dawn-0.1.0-2-x86_64.pkg.tar.zst
```

This creates the adjacent `.pkg.tar.zst.sig`. Do the same for base, desktop
and keyring. Put each archive **and its signature** in luminos-repository's
`x86_64/` before running `dbupdate.sh`. `repo-add` records those package
signatures in the database; the script separately signs the database.
Running `dbupdate.sh` alone does not sign any package archives.
