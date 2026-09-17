# Compatibility policy

This document defines the compatibility contract for qualified `amiga-dev` images.

## Toolchain baseline

Stable images use an explicitly qualified Bebbo/amiga-gcc snapshot. The top-level revision, transitive Git repositories, later-stage Git inputs, and downloaded build inputs are locked by the M6 provenance mechanism. A toolchain update is not considered compatible merely because upstream moved forward: the complete image qualification suite must pass again before the new snapshot becomes the stable baseline.

## Target baseline

The portable project baseline is Motorola 68000 code generated for the `m68k-amigaos` target. Projects that need the broadest classic-Amiga compatibility should use the 68000 profile unless they intentionally require a later CPU.

The qualified compile/link profiles are:

- 68000 — baseline and default
- 68020
- 68030
- 68040
- 68060

Qualification of a CPU profile means that the container toolchain can compile, link and inspect a representative executable for that CPU. It does not by itself claim runtime compatibility with every Amiga model, accelerator, Kickstart release, AmigaOS release, emulator, or hardware configuration.

## AmigaOS and runtime boundary

`amiga-dev` is a development/build image. It does not distribute or require proprietary Kickstart ROMs, Workbench media, commercial AmigaOS installations, or license keys.

Runtime compatibility is qualified separately by `Ploos-AS/amiga-runtime`. Emulator-specific and operating-system-specific behaviour must not be inferred from a successful `amiga-dev` compile test.

Projects may declare a stricter AmigaOS baseline, such as AmigaOS 2.04+, in their own documentation and runtime qualification. The development image must not silently raise a consumer project's documented runtime baseline.

## Image channels and versioning

- `edge` tracks the latest qualified default-branch image and may change as development proceeds.
- `sha-*` tags identify immutable source revisions and are preferred when a consumer requires repeatable CI.
- semantic `v*` tags identify stable releases.
- stable releases must satisfy the complete M6 qualification contract for their selected toolchain snapshot.

Consumers that require reproducibility should pin an immutable `sha-*` tag or a stable semantic version rather than `edge`.

## CI provider compatibility

The portable contract is Docker/OCI plus the commands installed in the image. GitHub Actions integration is provided for convenience, but consumer builds must not depend on GitHub-only behaviour inside the image.

Forgejo/self-hosted runners may consume the same OCI image and may use registry-backed or local BuildKit caching. GitHub-specific cache actions are provider glue, not part of the image compatibility contract. A successful GitHub qualification does not claim that a particular private Forgejo installation has been runtime-qualified unless that installation has actually executed the qualification workflow.

## Compatibility changes

A change requires requalification when it changes any of the following:

- Bebbo/amiga-gcc revision or locked transitive source
- downloaded build input or checksum
- compiler/binutils behaviour relevant to supported profiles
- installed development utility versions or command contract
- default CPU profile
- packaging behaviour
- OCI base or build environment in a way that can affect generated artifacts

Breaking changes to documented commands, defaults, image paths, or stable compatibility guarantees require a new major semantic version once stable semantic releases are in use. Additive backwards-compatible functionality may use a minor version; compatible fixes may use a patch version.

## Upgrade policy

Toolchain and dependency upgrades are deliberate, not floating. An upgrade should:

1. select the intended upstream revision/version;
2. refresh locks/checksums and provenance;
3. rebuild the complete image;
4. run the full regression and CPU qualification matrix;
5. record qualification evidence before promoting the image as stable.

`edge` may be used to qualify an upgrade before a stable tag is created.
