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

The historical M1 build followed Bebbo upstream at build time. Immutable selection is introduced by M6.

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

Status: **QUALIFIED**

- immutable top-level Bebbo/amiga-gcc revision selection
- capture the top-level Bebbo commit used by every image
- capture transitive repository revisions populated by Bebbo `make update`
- install a machine-readable toolchain manifest in the image
- expose provenance through `amiga-toolchain-info`
- lock qualified transitive repository revisions before building
- lock or checksum remaining later-stage Git/download build inputs
- image qualification matrix
- compatibility policy

M6.1 qualification evidence: GitHub Actions CI run #53 (`35237303095`) completed successfully on 2026-09-17 for commit `c8cb609fb625755427c10bd97fb9d2461af2f914`. The image reported manifest schema 1, resolved Bebbo/amiga-gcc commit `926bf10f1ff0bb0e72d99d49b69b22828988761c`, and the revisions/origins of the Git repositories populated by the update stage through `amiga-toolchain-info`; all M1–M4 regression probes passed.

M6.2 pins the default top-level Bebbo revision to `926bf10f1ff0bb0e72d99d49b69b22828988761c` and records the qualified update-stage repositories in `toolchain/bebbo.lock`. The container build verifies each locked origin, checks out its exact commit after `make update`, verifies the resulting HEAD, and installs the lock alongside the generated provenance manifest.

M6.2 qualification evidence: GitHub Actions CI run #56 (`35240713777`) completed successfully on 2026-09-17 for commit `09910edcdd61459b4011f9810db25a3c9527a45d`, job `105268122297`. The locked full image build completed successfully and the baseline smoke test, toolchain/provenance report, minimal 68000 compile, compiler-target verification, M2 utility inventory, M3 developer commands/build profile, and M4 packaging regression probes all passed.

M6.3 closes the remaining toolchain-input reproducibility gap. Later-stage Git input `projects/vasm` is pinned to commit `bb048d9d3cf54d5e38c643182a0ff55b552f65be`, while network-derived non-Git archives are recorded in `toolchain/build-inputs.lock` with SHA-256 checksums. Inputs available after `make update` are checked before the full build; the complete locked inventory is required to exist and match its recorded checksum after `make all`. The resulting manifests expose both Git provenance and the qualified downloaded-input inventory.

M6.3 qualification evidence: GitHub Actions CI run #64 (`35249502087`) completed successfully on 2026-09-17 for commit `36fa632a00243323e33f0b029571ec180ee05ab1`, job `105298049622`. The locked full Bebbo build completed successfully, all recorded downloaded build inputs passed SHA-256 verification, the later-stage vasm revision matched its pinned commit, and the baseline smoke, toolchain/provenance report, minimal 68000 compile, compiler-target verification, M2 utility inventory, M3 developer commands/build profile, and M4 packaging regression probes all passed.

M6.4 defines the explicit image qualification matrix in `docs/M6_4_QUALIFICATION_MATRIX.md`. CI compile/links and inspects representative executables for 68000, 68020, 68030, 68040 and 68060 against the same fully built image, in addition to the existing M1–M4 regression contract. Runtime execution remains the responsibility of `amiga-runtime`.

M6.4 qualification evidence: GitHub Actions CI run #68 (`35253840041`) completed successfully on 2026-09-17 for commit `27614ab0f60dd08ad4eeeb576131799d76edc123`, job `105312668829`. The full image build and all existing regression probes passed, followed by successful compile/link and inspection for every M6.4 CPU profile: 68000, 68020, 68030, 68040 and 68060.

M6.5 defines the compatibility and upgrade contract in `docs/COMPATIBILITY.md`: the 68000 default baseline, qualified later CPU profiles, separation of development and runtime qualification, immutable/stable image consumption guidance, provider-neutral OCI behaviour, semantic-version compatibility expectations, and deliberate requalification of toolchain/dependency upgrades.

M6.5 qualification evidence: GitHub Actions CI run #70 (`35254387772`) completed successfully on 2026-09-17 for commit `e6c10cc747f7df4197ef9018ebf48d3c00e59b44`, job `105314427294`. The complete qualified image suite passed: full image build, provenance report, baseline 68000 compile, compiler target, M2 utilities, M3 developer commands/build profile, M4 packaging, and the M6.4 CPU image matrix.

M6 stable-release rule: a stable image must not depend on an unrecorded floating toolchain state. Pinning only the top-level Bebbo repository is insufficient unless the revisions fetched by its update process are also captured and locked. Downloaded non-Git inputs and repositories cloned only during later build targets are covered by M6.3. Toolchain or dependency upgrades must follow `docs/COMPATIBILITY.md` and pass the complete qualification suite before stable promotion.

## M7 — Supply-chain and release hardening

Status: **IN PROGRESS — M7.1–M7.3 QUALIFIED, M7.4 STARTED**

- M7.1 publish OCI SBOM and build provenance alongside each published image
- M7.1 attach GitHub artifact attestation to the exact published image digest
- M7.2 pin the Debian base image by digest and document the controlled refresh procedure
- M7.3 tighten host package/Python dependency reproducibility where practical
- M7.4 verify published attestations and SBOM as part of release qualification
- M7.5 document stable release promotion and rollback procedure

M7.1 enables BuildKit SBOM generation and maximum provenance for the GHCR publication build. The publish workflow captures the pushed image digest and uses GitHub's build-provenance attestation flow with OIDC, binding the attestation to `ghcr.io/ploos-as/amiga-dev` at that exact digest.

M7.1 qualification evidence: Publish OCI image run #32 (`35255239252`) completed successfully on 2026-09-17 for commit `2d2af28fc7a94a1ce93ca83b3f32aac176ee35d0`, job `105317212418`. The OCI build/publish step and the digest-bound `Attest published image` step both passed. CI run #73 (`35255239247`) also passed the complete existing regression suite for the same commit.

M7.2 pins both Dockerfile stages to the official dated Debian `bookworm-20260824-slim` OCI index digest `sha256:88200866dfff7ea7f5cbcb6ec7c8a701889efe6fe859fe64d6990e4b07ea4171`. `docs/BASE_IMAGE.md` defines the controlled refresh and requalification procedure. The digest is authoritative; the dated tag is retained for readability.

M7.2 qualification evidence: GitHub Actions CI run #76 (`35255802282`) and Publish OCI image run #35 (`35255801396`), job `105319164197`, completed successfully on 2026-09-17 for commit `9162fae01ebbb22d9f97b077e981b75fef1327f2`. The complete image qualification suite passed, followed by successful OCI publication and digest-bound attestation with the pinned Debian base.

M7.3 records the installed Debian package inventories for both the toolchain and runtime stages, exposes them through the image metadata contract, and installs host-side Python requirements from `python/requirements.lock`. The resulting full Python environment is captured in `python-packages.lock` inside the image and is also represented by the published SBOM. This deliberately avoids brittle Debian package-version pins while preserving the exact qualified image inventory.

M7.3 qualification evidence: GitHub Actions CI run #78 (`35256475181`) and Publish OCI image run #37 (`35256475222`) completed successfully on 2026-09-17 for commit `9f48d1de3d0a2a5c67245a8ae63f7e4b87bd00e3`. The complete image qualification suite and OCI publication path both passed with the Python dependency lock and captured Debian/Python package inventories.

M7.4 adds release-path verification of the exact published digest. Qualification must verify the GitHub build-provenance attestation and confirm that the OCI image index contains both SBOM and provenance attestations generated by BuildKit. This remains pending until the verification workflow itself passes against a newly published image.

M7 portability rule: SBOM and OCI provenance are image-level standards and remain useful to Forgejo/self-hosted consumers. GitHub's hosted attestation service is additional publication metadata, not a requirement for building or consuming the image outside GitHub.

## Non-goals / legal boundary

The repository and published images do not distribute Kickstart ROMs, Workbench media, commercial AmigaOS installations, license keys, or other proprietary artifacts that cannot legally be redistributed.
