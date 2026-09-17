# Base image policy

`amiga-dev` pins its Debian base image by immutable OCI index digest. Both the toolchain builder and the final runtime/development stage use the same qualified base.

## Qualified base

- image: `debian:bookworm-20260824-slim`
- OCI index digest: `sha256:88200866dfff7ea7f5cbcb6ec7c8a701889efe6fe859fe64d6990e4b07ea4171`
- selected for M7.2: 2026-09-17

The dated tag is retained next to the digest for human readability. The digest is authoritative.

## Why the index digest is pinned

The published `amiga-dev` image is OCI infrastructure and may be built for more than one architecture over time. Pinning the multi-platform index rather than a single architecture manifest keeps the Dockerfile portable while still preventing the base from moving silently.

## Refresh procedure

A base refresh is deliberate. Do not replace the digest merely because the floating `bookworm-slim` tag changed.

1. Identify the intended Debian slim snapshot and its official OCI index digest.
2. Update `DEBIAN_BASE` in `Dockerfile`, keeping a dated tag plus the exact digest.
3. Build the complete toolchain image from the new base.
4. Run the full M1–M6 regression suite and M6.4 CPU matrix.
5. Publish the candidate through the normal M7 supply-chain workflow so SBOM and provenance are generated.
6. Confirm the GHCR publication and build-provenance attestation succeed.
7. Record the successful CI/publish runs in `ROADMAP.md` before treating the base as qualified.

A failed qualification means the previous digest remains the stable reference until the failure is understood and fixed.

## Scope and remaining reproducibility work

Digest pinning makes the base filesystem immutable. It does not freeze packages subsequently resolved by `apt-get update`, nor every Python dependency resolved by pip. Those are separate M7.3 concerns and must not be represented as solved by M7.2.
