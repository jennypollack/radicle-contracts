# Developer Manual

## Tasks

* `yarn run build` Build the contracts, client bindings and compile with
  typescript.
* `yarn run test` Rebuild the contract and client bindings and run all tests.
* `yarn run lint` Check with `prettier` and `solhint`. The tasks `lint:solhint`
  and `lint:prettier` are also available.

## Changelog and versioning

The project follows [Semantic Versioning] with regard to
its JavaScript and TypeScript bindings' APIs and the Ethereum ABI.
Any changes visible through any of these interfaces must be noted
in the changelog and reflected in the version number when a new release is made.
The changelog is manually updated in every commit that makes a change
and it follows the [Keep a Changelog] convention.
Each released version has a git tag and a GitHub release
named after its version with a `v` prefix, e.g. `v0.0.1`, `v1.0.0` or `v1.2.3`.

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
