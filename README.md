# amiga-dev

Reproducible OCI development environment for classic Amiga software projects.

`amiga-dev` provides Ploos-AS projects with one shared, versioned environment for host-side checks, cross compilation, packaging, and qualification helpers.

## M0 scope

M0 establishes the repository and container foundation:

- Debian-based OCI image
- common build and inspection utilities
- non-root development user
- `/workspace` working directory
- explicit Bebbo/amiga-gcc toolchain boundary
- smoke-test tooling
- GitHub Actions container-build validation
- no Kickstart ROMs, Workbench media, or other proprietary AmigaOS files

M0 does **not** claim that the Bebbo toolchain is installed or qualified yet. That is M1.

## Build

```sh
docker build -t amiga-dev:m0 .
```

or:

```sh
podman build -t amiga-dev:m0 .
```

## Smoke test

```sh
docker run --rm amiga-dev:m0 amiga-dev-smoke
```

## Interactive use

```sh
docker run --rm -it -v "$PWD:/workspace" amiga-dev:m0
```

## Toolchain policy

Only software and SDK material whose licenses permit redistribution may be embedded in published images. Proprietary Amiga ROM images, Workbench disks, AmigaOS installations, keys, and similar artifacts must never be committed to this repository or embedded in the image.

Runtime qualification requiring user-owned system files must receive them externally at runtime.

See [ROADMAP.md](ROADMAP.md) for planned milestones.

## License

MIT. Third-party components retain their respective licenses.
