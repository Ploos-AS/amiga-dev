# Forgejo Actions requirement

Forgejo Actions compatibility is a first-class project requirement.

`amiga-dev` MUST NOT require GitHub-hosted runners or GitHub-only APIs to perform its core development functions. A Forgejo Runner capable of running OCI containers must be able to use the published image with the same `/workspace` contract used locally.

Repository workflows should keep provider-specific orchestration thin and call scripts shipped by the repository/image for substantive work.
