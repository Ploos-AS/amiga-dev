# M8.2 consumer migration and qualification

This is the standard migration path for Ploos-AS Amiga repositories adopting the qualified `amiga-dev` infrastructure.

## Migration

1. Keep the project's existing source tree and normal build system.
2. Add an `amiga-dev` CI job using the GitHub or Forgejo template in `templates/consumer/`.
3. Select the project's CPU profile explicitly. Use `68000` unless the project deliberately requires a later CPU.
4. Run `amiga-check` before the project build.
5. Execute the normal project build inside the image. Prefer `amiga-build` as the stable entry point.
6. Preserve the project's own AmigaOS/API compatibility baseline; adopting `amiga-dev` must not silently raise it.
7. Pin an immutable `sha-*` image tag, semantic qualified release, or OCI digest for release/reproducibility qualification. `edge` is only an integration channel.
8. Keep proprietary Kickstart, Workbench and AmigaOS material outside the repository and `amiga-dev` image.
9. Delegate actual Amiga runtime claims to `amiga-runtime`.

## Consumer qualification evidence

A migrated project should record:

- consumer repository and commit;
- exact `amiga-dev` image reference and, when available, OCI digest;
- selected CPU profile;
- compiler target (`m68k-amigaos`);
- project build/check command and result;
- generated artifact identity/checksum when applicable;
- CI provider and run/job identifier;
- runtime qualification reference when runtime compatibility is claimed.

## GitHub and Forgejo

The templates intentionally use Docker/OCI plus the public `amiga-*` commands as the portable contract. Provider-specific workflow syntax may differ, but projects should not depend on undocumented paths or GitHub-only behavior inside the development image.

The Forgejo template's `runs-on` label is an example and must match the local runner configuration. This repository does not claim a Forgejo run has passed until such a run is actually executed and recorded.

## Qualification boundary

Compilation/linking success demonstrates development-toolchain compatibility. It does not demonstrate that an artifact boots, launches or behaves correctly on AmigaOS or a particular emulator. Those claims require `amiga-runtime` evidence.
