# amiga-dev

Reproducible OCI development environment for classic Amiga software projects.

`amiga-dev` provides Ploos-AS projects with one shared, versioned environment for host-side checks, cross compilation, packaging, and qualification helpers.

## Current status

M0 container foundation and M1 Bebbo/amiga-gcc toolchain are qualified. M1 qualification passed in GitHub Actions CI run #18 (`35215431305`) on 2026-09-17 using the full Bebbo `make all` build, followed by smoke, toolchain, minimal 68000 compile/link and target-verification probes.

The expensive full toolchain build is deliberately retained. GitHub CI uses BuildKit layer caching so unchanged toolchain layers can be reused. This caching is provider-specific acceleration only; the image and command contract remain usable with ordinary Docker/Podman and Forgejo Actions. The longer-term CI model is for consumer projects to pull a qualified prebuilt `amiga-dev` image rather than rebuild Bebbo for every project.

## Build

```sh
docker build -t amiga-dev:m1 .
```

or:

```sh
podman build -t amiga-dev:m1 .
```

## Smoke test

```sh
docker run --rm amiga-dev:m1 amiga-dev-smoke
```

## Interactive use

```sh
docker run --rm -it -v "$PWD:/workspace" amiga-dev:m1
```

## Toolchain policy

Only software and SDK material whose licenses permit redistribution may be embedded in published images. Proprietary Amiga ROM images, Workbench disks, AmigaOS installations, keys, and similar artifacts must never be committed to this repository or embedded in the image.

Runtime qualification requiring user-owned system files must receive them externally at runtime.

See [ROADMAP.md](ROADMAP.md) for planned milestones and [docs/CI_PORTABILITY.md](docs/CI_PORTABILITY.md) for the GitHub/Forgejo/local portability contract.

## License

MIT. Third-party components retain their respective licenses.
