# M6.4 image qualification matrix

M6.4 defines the image-level qualification contract for `amiga-dev`. It complements the locked toolchain inputs from M6.1–M6.3 by verifying that the resulting OCI image exposes the expected development environment across representative compile profiles.

## Matrix

| Profile | Compiler flags | Required result |
| --- | --- | --- |
| 68000 baseline | `-m68000` | compile/link succeeds and output is inspectable |
| 68020 | `-m68020` | compile/link succeeds and output is inspectable |
| 68030 | `-m68030` | compile/link succeeds and output is inspectable |
| 68040 | `-m68040` | compile/link succeeds and output is inspectable |
| 68060 | `-m68060` | compile/link succeeds and output is inspectable |

Every matrix entry runs against the exact image built by the normal CI job. The qualification does not require Kickstart ROMs, Workbench media, AmigaOS installations, or any other proprietary runtime material.

## Required image contract

Before the CPU matrix runs, the normal CI job must continue to qualify:

- `amiga-dev-smoke`
- `amiga-toolchain-info` and locked provenance
- compiler target `m68k-amigaos`
- M2 utility inventory
- M3 developer commands and the default 68000 profile
- M4 manifest/ZIP/LHA/ADF packaging

The CPU matrix is a compile/link qualification, not an AmigaOS runtime qualification. Runtime execution belongs in `Ploos-AS/amiga-runtime`, where emulator-specific behaviour can be tested separately.

## CI implementation

The matrix is intentionally executed inside one CI step after the full image has been built. This avoids rebuilding the expensive Bebbo toolchain once per CPU profile while still testing each profile against the same qualified image. A failure in any profile fails the CI job.

M6.4 is **IMPLEMENTED / PENDING QUALIFICATION** until a GitHub Actions run containing this matrix completes successfully. The successful run ID, job ID, commit and date must be recorded in `ROADMAP.md` before M6.4 is marked QUALIFIED.
