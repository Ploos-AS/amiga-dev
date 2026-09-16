# Roadmap

## M0 — Container foundation

Status: **IMPLEMENTED**

- Debian-based OCI foundation
- baseline host development tools
- unprivileged runtime user
- `/workspace` and `/opt/amiga` conventions
- smoke test
- CI build validation
- redistribution/proprietary-files policy

M0 success criterion: the repository can build an OCI image and its baseline smoke test passes without requiring proprietary Amiga material.

## M1 — Bebbo/amiga-gcc toolchain

- reproducibly install/pin Bebbo's Amiga GCC toolchain
- expose `m68k-amigaos-*` tools through PATH
- compile and link a minimal 68000 Amiga executable
- record compiler/binutils versions
- add toolchain qualification checks

## M2 — Amiga development utilities

- vasm/vlink where useful and redistributable
- amitools and host-side Hunk inspection
- archive/package utilities
- ADF/HDF helpers
- binary inspection helpers

## M3 — Unified developer commands

- `amiga-build`
- `amiga-check`
- `amiga-test`
- `amiga-inspect`
- CPU profiles beginning with 68000

## M4 — Packaging

- reproducible release staging
- LHA/ZIP packaging
- optional ADF construction
- checksums and manifests

## M5 — CI integration

- publish versioned OCI images
- GHCR integration
- reusable GitHub Actions examples
- consumer-project qualification

## M6 — Reproducibility and qualification

- pinned toolchain manifests
- provenance/version reporting
- image qualification matrix
- compatibility policy

## Non-goals / legal boundary

The repository and published images do not distribute Kickstart ROMs, Workbench media, commercial AmigaOS installations, license keys, or other proprietary artifacts that cannot legally be redistributed.
