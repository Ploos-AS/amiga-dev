# Roadmap

## M0 — Container foundation

Status: **IMPLEMENTED**

Detailed M0–M7 qualification history remains established by the repository history and qualification documentation.

## M8 — Consumer adoption and stable operations

Status: **IN PROGRESS**

- M8.1 **QUALIFIED** — define a machine-readable consumer contract for Ploos-AS Amiga repositories
- M8.2 **QUALIFIED** — provide a migration/qualification template for consumers moving to the qualified `amiga-dev` image
- M8.3 **IN PROGRESS** — validate the contract with representative real Ploos-AS Amiga projects
- M8.4 document coordinated `amiga-dev` + `amiga-runtime` usage for compile/link versus runtime qualification
- M8.5 define upgrade waves and compatibility reporting for organization-wide adoption

M8.1 qualification evidence: GitHub Actions CI run #86 (`35266683926`) and Publish OCI image run #45 (`35266683693`) completed successfully on 2026-09-17 for commit `f65007f9ab8f6a12816ac4a83fc4efcc6098384a`.

M8.2 qualification evidence: GitHub Actions CI run #90 (`35267825353`) and Publish OCI image run #49 (`35267825383`) completed successfully on 2026-09-17 for commit `efd7a397838b20338279a55bb422b186e1d93d40`.

### M8.3 Wave 1 — Ploos-AS Amiga infrastructure adoption

M8.3 is the first organization migration wave. Development/build qualification moves to `amiga-dev`; actual m68k Amiga runtime qualification moves to `amiga-runtime`.

Wave 1 consumers, in migration order:

1. AmiNTP — network/CLI/ARexx application; first reference consumer
2. AmiWeather — application/network consumer
3. AmiGuard — security/low-level consumer
4. AmiShell — larger application/tooling consumer
5. AmTLS — library and CLI consumer

AmiDiag follows as a separate ROM/low-level consumer case rather than being treated as a normal application consumer.

For every Wave 1 project:

- retain the project's declared AmigaOS/API compatibility baseline;
- use the qualified `amiga-dev` OCI command contract for compile/link/check/package work;
- select the CPU profile explicitly, with 68000 as the default unless the project deliberately requires another profile;
- record the exact consumer commit and CI run used as evidence;
- pin an immutable `sha-*`, semantic release, or OCI digest before release/reproducibility qualification;
- keep Kickstart, Workbench, commercial AmigaOS material and license keys outside Git;
- delegate actual m68k runtime claims to `amiga-runtime`;
- use m68k ARexx runtime qualification where applicable across supported emulator backends (FS-UAE, Amiberry and later FellowNG); AROS/i386 is not a substitute for this runtime qualification.

AmiNTP migration started with consumer commit `a9204563dafa5aaff52a0b9665e36e8531215389`, adding an `amiga-dev` GitHub Actions workflow that runs `amiga-check`, the existing static checks, and the native Bebbo build through the stable `amiga-build` interface. This is migration evidence only until the corresponding workflow run succeeds; runtime qualification remains separate.

M8 must preserve the provider-neutral OCI contract: GitHub Actions and Forgejo Actions are orchestration layers, while the qualified image and its commands remain the reusable development interface. Forgejo compatibility is part of the contract, but a private/local Forgejo qualification must not be claimed until an actual Forgejo runner execution is recorded.

## Non-goals / legal boundary

The repository and published images do not distribute Kickstart ROMs, Workbench media, commercial AmigaOS installations, license keys, or other proprietary artifacts that cannot legally be redistributed.
