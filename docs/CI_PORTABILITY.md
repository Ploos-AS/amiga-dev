# CI portability requirements

`amiga-dev` is an OCI development environment and MUST remain independent of any single CI provider.

## Required environments

The published image and its documented interfaces MUST support:

- local Docker or Podman execution;
- GitHub Actions on a compatible container runner;
- Forgejo Actions using a Forgejo Runner with OCI/container execution.

## Stable container contract

CI workflows MUST interact with the image through its documented container interface rather than GitHub-specific environment variables or APIs. `/workspace` remains the project workspace contract.

Provider-specific workflow glue MAY exist, but build, test, packaging, and qualification helper logic MUST remain runnable from an ordinary shell inside the image.

## Build caching

The full Bebbo `make all` toolchain build is part of the qualified image and MUST NOT be reduced merely to shorten CI time. Instead, OCI/BuildKit layers should be cached when their inputs are unchanged.

GitHub Actions may use the GitHub Actions BuildKit cache backend as provider-specific acceleration. Local Docker/Podman and Forgejo runners may use local or registry-backed BuildKit caches. Cache choice MUST NOT change the Dockerfile semantics, `/workspace` contract, qualification commands, or resulting toolchain contents.

A cold-cache build remains the authoritative proof that the image is reproducible from source. Cache hits are an optimization, not a substitute for qualification. Consumer repositories should prefer a qualified versioned `amiga-dev` image once publishing is implemented, avoiding repeated full toolchain builds across the Ploos-AS project fleet.

## Private local qualification

The public image MUST NOT contain Kickstart ROMs, Workbench/AmigaOS media, license keys, or other proprietary material. A self-hosted Forgejo Runner MAY mount user-owned licensed material at runtime when a downstream qualification workflow requires it. Such paths and credentials MUST remain outside Git and outside published OCI layers.

## Acceptance criterion

A milestone that changes the container entry points, workspace contract, toolchain invocation, or CI helpers is not complete until the same documented command path remains usable locally, in GitHub Actions, and from a Forgejo Actions runner.
