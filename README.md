# portway-agent

The local agent binary for [Portway](https://portway.online) — connects a
service running on your own machine to a tunnel you created on the
dashboard.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/coderbenny/portway-agent/main/install.sh | sh
```

Installs to `~/.local/bin` (or `/usr/local/bin` as a fallback). Supports
Linux and macOS, amd64 and arm64. Windows users: download the `.zip` for
your architecture from the [latest release](https://github.com/coderbenny/portway-agent/releases/latest)
directly.

## Run

Generate an agent token for your tunnel from the Portway dashboard (tunnel
detail page → Connect), then:

```sh
portway-agent -relay=agent.portway.online:9443 -tls=true -token=<token>
```

The agent dials out to Portway's relay, authenticates with the token, and
forwards traffic to whatever `local_target` the tunnel was configured with
— nothing needs to be typed in twice.

## Flags

| Flag | Default | Description |
|---|---|---|
| `-relay` | `localhost:9000` | Relay agent-listener address. Use `agent.portway.online:9443` for production. |
| `-token` | *(required)* | Agent token issued from the dashboard for this tunnel. |
| `-tls` | `false` | Connect over TLS. Required for `agent.portway.online:9443`. |
| `-version` | — | Print the version and exit. |

## Verify a download

Every release includes a `checksums.txt`:

```sh
curl -fsSL -o checksums.txt https://github.com/coderbenny/portway-agent/releases/latest/download/checksums.txt
sha256sum -c checksums.txt --ignore-missing
```
