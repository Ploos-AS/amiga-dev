# AROS toolchain targets

amiga-dev treats AROS as three first-class application targets:

- `aros-m68k` -> `m68k-aros`
- `aros-x86_64` -> `x86_64-aros`
- `aros-ppc` -> `powerpc-aros`

The AROS source revision used for qualification is pinned in `toolchain/aros.lock`.

The implementation is deliberately staged. A target remains `planned-toolchain` in
`targets.json` until the container contains its compiler/SDK and CI has compiled and
linked the qualification program for that target.

AROS is built from the official AROS source/build system. We do not claim that a
compiler prefix alone constitutes a qualified SDK: headers, startup objects, libraries
and sysroot must be present and validated too.

## Qualification

For each architecture:

1. compiler probe and exact target tuple;
2. compile/link `tests/hello.c`;
3. inspect output architecture;
4. record AROS source revision and compiler version;
5. only then promote the target status to `qualified`.

Runtime qualification is delegated to Ploos-AS/amiga-runtime.

## CI qualification policy

The main container CI validates the pinned source provenance and target registry on every change. Architecture-specific AROS builds run in dedicated workflows because building a complete AROS SDK/toolchain is substantially heavier than the classic amiga-dev smoke suite.
