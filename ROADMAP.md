# Roadmap

## M0 — Container foundation

Status: **IMPLEMENTED**

See repository history for M0–M7 qualification details. M1 through M7 are qualified; their qualification evidence remains preserved in the Git history preceding M8.

## M8 — Consumer adoption and stable operations

Status: **IN PROGRESS**

- M8.1 **QUALIFIED** — define a machine-readable consumer contract for Ploos-AS Amiga repositories
- M8.2 **QUALIFIED** — provide a migration/qualification template for consumers moving to the qualified `amiga-dev` image
- M8.3 validate the contract with representative real Ploos-AS Amiga projects
- M8.4 document coordinated `amiga-dev` + `amiga-runtime` usage for compile/link versus runtime qualification
- M8.5 define upgrade waves and compatibility reporting for organization-wide adoption

M8.1 defines `consumer-contract.json` and `docs/CONSUMER_CONTRACT.md` as the machine-readable and human-readable consumer boundary. CI validates the image identity, `m68k-amigaos` target, supported CPU profiles, stable `amiga-*` commands, runtime delegation and redistribution constraints.

M8.1 qualification evidence: GitHub Actions CI run #86 (`35266683926`) and Publish OCI image run #45 (`35266683693`) completed successfully on 2026-09-17 for commit `f65007f9ab8f6a12816ac4a83fc4efcc6098384a`. The consumer-contract validation and complete existing image qualification suite passed, followed by successful OCI publication.

M8.2 provides migration templates in `templates/consumer/` for GitHub Actions and Forgejo Actions plus `docs/M8_2_CONSUMER_MIGRATION.md`. The templates use the provider-neutral Docker/OCI interface, explicit CPU profile selection, `amiga-check`, `amiga-build`, `/workspace`, and an explicit transition from the integration `edge` channel to an immutable or qualified release reference for reproducible qualification.

M8.2 qualification evidence: GitHub Actions CI run #90 (`35267825353`) and Publish OCI image run #49 (`35267825383`) completed successfully on 2026-09-17 for commit `efd7a397838b20338279a55bb422b186e1d93d40`. CI validated both consumer templates and the migration documentation together with the full existing image regression and CPU qualification suite; OCI publication also passed.

M8 must preserve the provider-neutral OCI contract: GitHub Actions and Forgejo Actions are orchestration layers, while the qualified image and its commands remain the reusable development interface. Forgejo compatibility is a design and interface requirement; an actual Forgejo qualification claim requires recorded execution on a Forgejo runner.

## Non-goals / legal boundary

The repository and published images do not distribute Kickstart ROMs, Workbench media, commercial AmigaOS installations, license keys, or other proprietary artifacts that cannot legally be redistributed.
