# Forgejo and self-hosted BuildKit cache

`amiga-dev` publishes a portable BuildKit cache to the same GHCR package namespace as the qualified image:

```text
ghcr.io/ploos-as/amiga-dev:buildcache
```

This is intentionally independent of GitHub's Actions cache service. GitHub publishing currently writes both the GitHub-native cache and the registry cache; Forgejo and other self-hosted Buildx runners can consume the registry cache directly.

## Buildx example

Authenticate the runner to GHCR with package read/write access, then use:

```sh
docker buildx build \
  --cache-from type=registry,ref=ghcr.io/ploos-as/amiga-dev:buildcache \
  --cache-to type=registry,ref=ghcr.io/ploos-as/amiga-dev:buildcache,mode=max \
  -t amiga-dev:local \
  --load .
```

For read-only builds, omit `--cache-to`; only package read access is then required.

## Forgejo Actions example

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: docker/setup-buildx-action@v3
  - name: Login to GHCR
    run: echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
  - name: Build with shared cache
    run: |
      docker buildx build \
        --cache-from type=registry,ref=ghcr.io/ploos-as/amiga-dev:buildcache \
        --cache-to type=registry,ref=ghcr.io/ploos-as/amiga-dev:buildcache,mode=max \
        -t amiga-dev:forgejo \
        --load .
```

Store `GHCR_USER` and `GHCR_TOKEN` as Forgejo Actions secrets. Do not commit registry credentials.

Consumer projects normally should not rebuild `amiga-dev` at all: they should pull a qualified image. The registry-backed cache is primarily for `amiga-dev` maintenance, local Forgejo qualification, mirrors, and controlled infrastructure rebuilds.
