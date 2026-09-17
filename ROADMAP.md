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

Caching policy: the full Bebbo build is intentionally retained. CI should reuse BuildKit layers whenever the Dockerfile/toolchain inputs are unchanged. GitHub may use its native BuildKit cache backend as provider-specific glue; Forgejo/local builds remain free to use a registry or local BuildKit cache. Consumer projects should consume a qualified prebuilt `amiga-dev` image instead of rebuilding the toolchain for every project run.

The current M1 build follows Bebbo upstream at build time. Immutable upstream selection and complete transitive toolchain provenance are M6 requirements; earlier documentation incorrectly claimed an `AMIGA_GCC_REF` build argument already existed.

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

Status: **QUALIFIED**

- `amiga-package` provides one packaging entry point for staged release trees
- normalize staged timestamps using `SOURCE_DATE_EPOCH` before archive construction
- deterministic-path ZIP packaging with metadata stripping
- LHA packaging through the Debian `jlha-utils` compatible `lha` command
- optional FFS ADF construction using `xdftool`, followed by `xdfscan` verification
- SHA-256 sidecars for generated ZIP, LHA and ADF artifacts
- sorted per-file SHA-256 release manifests
- CI builds a real 68000 executable and qualifies manifest, ZIP, LHA and ADF outputs

Qualification evidence: GitHub Actions CI run #40 (`35225713793`) completed successfully on 2026-09-17 for commit `cd066a2fe7f1ec3069cb814b2dc3e6089237fda4`. The full M1–M3 regression suite passed together with the M4 packaging qualification, including manifest, ZIP, LHA and ADF generation and verification.

M4 packaging operates only on caller-provided redistributable staging trees; it does not add proprietary AmigaOS or Kickstart material.

## M5 — CI integration

Status: **QUALIFIED**

- publish versioned OCI images
- GHCR integration: `ghcr.io/ploos-as/amiga-dev`
- default-branch pushes publish `edge` plus immutable `sha-*` tags
- `v*` tags publish semantic-version tags
- publishing reuses the qualified BuildKit cache and uses only the repository-scoped `GITHUB_TOKEN`
- reusable GitHub Actions workflow with configurable image and consumer command
- provider-neutral Docker/OCI consumer contract documented for GitHub and Forgejo/self-hosted runners
- consumer-project qualification
- registry-backed BuildKit cache at `ghcr.io/ploos-as/amiga-dev:buildcache` for Forgejo/self-hosted runners

M5.1 qualification evidence: publish run `35226848474` completed successfully on 2026-09-17 for commit `ecfd191b99c5176a18c068d13bd13f9b408ec99b`. The resulting `ghcr.io/ploos-as/amiga-dev:edge` image was then pulled by independent consumer-smoke run `35226911972`; smoke, compiler target, developer command inventory and `amiga-check` passed.

M5.2 qualification evidence: reusable consumer run `35227661381` completed successfully on 2026-09-17 for commit `8c18a80e8e660da13b89a7a2b3a55edeae45f2f7`. It invoked the reusable workflow, consumed the published image, ran `amiga-check`, compiled a real `-m68000` executable and inspected the result. Follow-up GHCR consumer smoke `35227698015` also passed.

M5.3 qualification evidence: registry-backed BuildKit cache publishing was added to the OCI publication path, with Forgejo/self-hosted usage documented in `docs/FORGEJO_CACHE.md`. Subsequent GHCR consumer smoke run `35235352901` completed successfully on 2026-09-17, confirming normal published-image consumption remained healthy after the cache integration.

## M6 — Reproducibility and qualification

Status: **IN PROGRESS — M6.1 STARTED**

- immutable top-level Bebbo/amiga-gcc revision selection
- capture the top-level Bebbo commit used by every image
- capture transitive repository revisions populated by Bebbo `make update`
- install a machine-readable toolchain manifest in the image
- expose provenance through `amiga-toolchain-info`
- image qualification matrix
- compatibility policy

M6 stable-release rule: a stable image must not depend on an unrecorded floating toolchain state. Pinning only the top-level Bebbo repository is insufficient unless the revisions fetched by its update process are also captured and reported.

## Non-goals / legal boundary

The repository and published images do not distribute Kickstart ROMs, Workbench media, commercial AmigaOS installations, license keys, or other proprietary artifacts that cannot legally be redistributed.
