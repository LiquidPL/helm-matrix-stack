# helm-matrix-stack

This Helm chart intends to deploy a fully featured, modern Matrix homeserver, with


## Available components

* [Synapse](https://github.com/element-hq/synapse) with [Matrix Authentication Service](https://github.com/element-hq/matrix-authentication-service).

Planned in the future:
* MatrixRTC-based voice/video call stack using [LiveKit](github.com/livekit/livekit).
* [Element Call](github.com/element-hq/element-call).
* ability to deploy various web clients.
* ability to choose a different homeserver.

## License attribution

This project uses the `matrix-tools` utility from Element's [ESS Community](https://github.com/element-hq/ess-helm) Helm chart for the purpose of generating Synapse/MAS secrets. Licensed under the GNU Affero General Public License, version v3.0.
