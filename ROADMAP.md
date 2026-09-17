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

Status: **QUALIFIED**

- build Bebbo's full Amiga GCC toolchain (`make all`) in a dedicated OCI build stage
- expose `m68k-amigaos-*` tools through PATH
- compile and link a minimal `-m68000` Amiga executable
- report compiler, assembler and linker versions
- verify the compiler target is `m68k-amigaos`
- keep proprietary Amiga material outside the image
- cache expensive OCI/BuildKit layers in CI without changing the portable container contract

Qualification evidence: GitHub Actions CI run #18 (`35215431305`) completed successfully on 2026-09-17 for commit `34bf552e4ec1ea586195c7b1acaa0d0239cb104c`. The full image build, baseline smoke test, toolchain report, minimal 68000 compile/link probe and compiler-target verification all passed.

Caching policy: the full Bebbo build is intentionally retained. CI should reuse BuildKit layers whenever the Dockerfile/toolchain inputs are unchanged. GitHub may use its native BuildKit cache backend as provider-specific glue; Forgejo/local builds remain free to use a registry or local BuildKit cache. Consumer projects should ultimately consume a qualified prebuilt `amiga-dev` image instead of rebuilding the toolchain for every project run.

Note: the build accepts `AMIGA_GCC_REF` so the toolchain can be pinned to a qualified upstream revision. A floating upstream ref is acceptable during bring-up but must be replaced by an immutable qualified revision before a stable image release.

## M2 — Amiga development utilities

Status: **QUALIFIED**

- retain vasm from the full Bebbo toolchain rather than installing a duplicate copy
- install pinned `amitools` 0.8.1 for host-side Hunk and filesystem tooling
- provide `hunktool`, `xdftool`, `xdfscan`, `rdbtool`, `romtool` and `fdtool`
- provide host binary inspection helpers including `file`, `readelf` and `xxd`
- retain ZIP/unzip and standard archive utilities
- qualify the utility inventory in the normal container CI

Qualification evidence: GitHub Actions CI run #27 (`35221347045`) completed successfully on 2026-09-17 for commit `0a8d4a5081b8e0b3c1dc861f0187867548755ab6`. The full cached container build, M1 regression probes and the M2 utility inventory all passed, including `vasmm68k_mot`, `hunktool`, `xdftool`, `xdfscan`, `rdbtool`, `romtool`, `fdtool`, `xxd`, `readelf` and the pinned `amitools` Python package.

M2 intentionally does not install or embed proprietary Kickstart ROMs, Workbench media, AmigaOS installations, or commercial SDK material.

## M3 — Unified developer commands

Status: **QUALIFIED**

- `amiga-build` provides a common build entry point and exports CPU-profile flags
- `amiga-check` validates the container/toolchain contract
- `amiga-test` provides a common host-side test entry point; emulator/runtime execution remains delegated to `amiga-runtime`
- `amiga-inspect` combines host file identification, Hunk inspection and a bounded hex preview
- CPU profiles begin with the portable `68000` baseline (`AMIGA_CPU_PROFILE=68000`, `AMIGA_CPU_FLAGS=-m68000`)
- CI qualifies the command inventory and uses `amiga-build` plus `amiga-inspect` on a real cross-compiled executable

Qualification evidence: GitHub Actions CI run #35 (`35225214509`) completed successfully on 2026-09-17 for commit `6aa30e72c7d5b87746b8d5fab9cd2c6fb1740cd9`. The full M1/M2 regression suite passed together with the M3 command inventory and the real 68000 `amiga-build`/`amiga-inspect` qualification probe.

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
- registry-backed BuildKit cache usable by Forgejo/self-hosted runners

## M6 — Reproducibility and qualification

- pinned toolchain manifests
- provenance/version reporting
- image qualification matrix
- compatibility policy

## Non-goals / legal boundary

The repository and published images do not distribute Kickstart ROMs, Workbench media, commercial AmigaOS installations, license keys, or other proprietary artifacts that cannot legally be redistributed.
