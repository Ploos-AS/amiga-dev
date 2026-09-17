# Stable release promotion and rollback

This document defines the M7.5 stable-release procedure for `amiga-dev`.

## Release channels

`amiga-dev` uses three complementary OCI references:

- `edge` tracks the latest successful default-branch publication and is not a stable contract.
- `sha-<commit>` is the immutable build reference used for qualification, investigation and rollback.
- `vX.Y.Z` is the stable semantic release reference created only after qualification.

Consumers that require reproducibility should prefer an immutable digest or `sha-<commit>`. Stable consumers may use a fully qualified `vX.Y.Z` tag. Do not use `edge` as a reproducibility boundary.

## Stable promotion gate

A commit may be promoted to a stable `vX.Y.Z` release only when all of the following are true:

1. `main` is clean and the intended commit is known exactly.
2. The normal CI workflow passes for that exact commit, including the complete M1-M6 regression suite and CPU qualification matrix.
3. The OCI publish workflow passes for that exact commit.
4. The published digest has a successful GitHub build-provenance attestation verification.
5. BuildKit SBOM and provenance metadata are present for that exact published digest.
6. The qualified Bebbo/toolchain revisions, downloaded build inputs, Debian base digest, Debian package inventories and Python package inventory are recorded by the image contract.
7. No proprietary Kickstart, Workbench, AmigaOS, license key or other non-redistributable material has entered the repository or image.
8. Any compatibility-impacting change has been reviewed against `docs/COMPATIBILITY.md`.

Promotion is performed by creating a `vX.Y.Z` tag at the already-qualified commit. The tag-triggered publish workflow must then complete successfully. Promotion does not rebuild from an unqualified source revision.

## Release evidence

For every stable release, record at minimum:

- semantic version/tag
- Git commit SHA
- published OCI digest
- CI workflow run ID and result
- publish workflow run ID and result
- attestation verification result
- SBOM/provenance verification result
- qualification date

The immutable OCI digest is the authoritative released artifact identity. Tags are convenient references to that identity.

## Rollback

Rollback never rewrites an existing semantic release tag to point at different content.

If a stable release must be withdrawn:

1. Identify the last known-good qualified release and its OCI digest.
2. Verify its recorded provenance/qualification evidence before recommending it to consumers.
3. Tell consumers to pin the known-good digest or its existing semantic version.
4. Fix the defect on `main` and run the complete qualification path again.
5. Publish a new semantic patch/minor/major version as appropriate. Never move or reuse the withdrawn version tag.

`edge` may advance as development continues; it is not used as the rollback target. Rollback always names a previously qualified immutable digest or semantic release.

## Registry/tag loss

If a mutable convenience tag is lost or incorrect, recover it only from a verified immutable digest and documented release evidence. Do not infer a release from a locally cached image or rebuild an old source tree and assume byte-equivalence.

If the immutable artifact itself is unavailable, rebuilds are treated as new artifacts and must pass qualification again before publication.

## Forgejo and other registries

The stable-release contract is provider-neutral: commit, OCI digest, SBOM/provenance, package/toolchain manifests and qualification evidence remain the important identities. GitHub's hosted attestation is additional GitHub publication evidence. A Forgejo/self-hosted mirror must not claim that GitHub-hosted attestation was independently reproduced unless that verification actually ran there.

## Versioning

Use semantic versions:

- patch: compatible fixes, packaging corrections and dependency refreshes that preserve the documented contract
- minor: backwards-compatible capability additions or materially expanded tooling
- major: intentional incompatible changes to the image/tooling/consumer contract

Every dependency/toolchain/base-image refresh still requires complete requalification even when the resulting release is only a patch version.
