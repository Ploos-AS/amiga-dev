# Consumer CI integration

`amiga-dev` is intended to be consumed as a qualified OCI image rather than rebuilt by every Amiga project.

## Portable container contract

The provider-neutral contract is simply an OCI runtime plus the published image:

```sh
docker pull ghcr.io/ploos-as/amiga-dev:edge
docker run --rm -v "$PWD:/workspace" -w /workspace \
  ghcr.io/ploos-as/amiga-dev:edge amiga-check
```

A project with a normal Makefile can build with:

```sh
docker run --rm -v "$PWD:/workspace" -w /workspace \
  ghcr.io/ploos-as/amiga-dev:edge amiga-build
```

Host-side tests can use `amiga-test`. Runtime/emulator qualification belongs in `amiga-runtime`.

This contract works with Docker-compatible GitHub runners and Forgejo/self-hosted runners. Provider-specific workflow syntax is only glue around the same image and commands.

## Reusable GitHub Actions workflow

A GitHub-hosted consumer can call the workflow in this repository:

```yaml
name: Amiga build

on:
  push:
  pull_request:

permissions:
  contents: read
  packages: read

jobs:
  amiga:
    uses: Ploos-AS/amiga-dev/.github/workflows/reusable-amiga-dev.yml@main
    with:
      image: ghcr.io/ploos-as/amiga-dev:edge
      command: amiga-check && amiga-build && amiga-test
```

For stable releases, consumers should replace `@main` and `:edge` with a qualified version tag once versioned releases are published.

## Forgejo Actions

Do not depend on GitHub reusable-workflow syntax for portability. A Forgejo job should pull the same qualified image and invoke the same commands directly. Registry credentials are only needed if the selected image is not publicly readable.

Example job body:

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Pull amiga-dev
    run: docker pull ghcr.io/ploos-as/amiga-dev:edge
  - name: Build
    run: |
      docker run --rm \
        -v "$PWD:/workspace" \
        -w /workspace \
        ghcr.io/ploos-as/amiga-dev:edge \
        sh -ec 'amiga-check && amiga-build && amiga-test'
```

## Legal boundary

The image does not provide Kickstart ROMs, Workbench media, commercial AmigaOS installations, license keys, or other proprietary runtime material. Projects that require runtime qualification must provide legally obtained material outside the repository and image.
