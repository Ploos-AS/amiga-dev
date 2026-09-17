# Consumer contract

`consumer-contract.json` is the machine-readable M8 contract for Ploos-AS Amiga projects consuming `amiga-dev`.

The contract identifies the OCI image, qualified CPU profiles, stable command interface, cross target, CI portability expectations and the boundary between development qualification and runtime qualification.

Consumer repositories should treat the container commands as the stable interface instead of depending on internal paths in the image. The default portable target is `m68k-amigaos` with the `68000` CPU profile. Projects may select a later qualified CPU profile when their own compatibility policy allows it.

For reproducible builds, consumers should pin an immutable image digest or immutable `sha-*` tag. `edge` is suitable for integration testing but not as a reproducibility boundary. A fully qualified semantic release may be used according to `docs/RELEASES.md`.

`amiga-dev` qualifies compilation, linking, packaging and host-side inspection. Claims that a binary actually runs on an Amiga model/OS/emulator belong to `Ploos-AS/amiga-runtime` qualification. Consumer projects must not convert a successful compile into a runtime compatibility claim.

The OCI contract is provider-neutral. GitHub Actions and Forgejo Actions may orchestrate it differently, but both should invoke the same image and command contract. GitHub-specific attestations are publication evidence and are not required to execute the consumer contract on Forgejo.

No consumer workflow may expect proprietary Kickstart ROMs, Workbench media, commercial AmigaOS installations or license keys to be present in `amiga-dev`.

## Adoption check

A migrated consumer is conformant when it can:

1. consume a qualified `amiga-dev` image reference;
2. run `amiga-check`;
3. build its normal artifact through `amiga-build` or an equivalent project build executed inside the image;
4. inspect/package artifacts using the documented commands where applicable;
5. declare its selected CPU profile and AmigaOS/runtime baseline separately;
6. delegate actual runtime qualification to `amiga-runtime` when runtime compatibility is claimed.
