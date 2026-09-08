---
icon: material/new-box
---

AmneziaWG 3.1 endpoint. WireGuard-compatible when obfuscation is left at defaults.

See [AmneziaWG](https://docs.amnezia.org/documentation/amnezia-wg/). Requires build tag `with_awg`.

### Structure

```json
{
  "type": "awg",
  "tag": "awg-ep",

  "useIntegratedTun": false,
  "mtu": 1408,
  "address": [
    "10.8.0.2/32"
  ],
  "private_key": "",
  "listen_port": 51820,

  "jc": 4,
  "jmin": 40,
  "jmax": 70,
  "s1": 0,
  "s2": 0,
  "s3": 0,
  "s4": 0,
  "h1": "1",
  "h2": "2",
  "h3": "3",
  "h4": "4",
  "i1": "",
  "i2": "",
  "i3": "",
  "i4": "",
  "i5": "",

  "header_protection_key": "",
  "content_padding_addition": "0",
  "rekey_after_time": "",
  "rekey_timeout": "",
  "reject_after_time": "",
  "keepalive_timeout": "",
  "max_handshake_attempts": "",
  "random_trailers": false,
  "disable_cookies": false,

  "peers": [
    {
      "address": "127.0.0.1",
      "port": 51820,
      "public_key": "",
      "preshared_key": "",
      "allowed_ips": [
        "0.0.0.0/0",
        "::/0"
      ],
      "persistent_keepalive_interval": 25
    }
  ],

  ... // Dial Fields
}
```

`0`, `off`, empty, or range `0-0` disables an obfuscation mechanism and falls back to WireGuard.

### Fields

#### useIntegratedTun

Use a system TUN (`true`) instead of gVisor netstack (`false`, default).

#### mtu

Interface MTU.

`1408` is used by default.

#### address

==Required==

IP prefixes assigned to the interface.

#### private_key

==Required==

Base64 WireGuard private key. Generate with `wg genkey` or `sing-box generate wg-keypair`.

#### listen_port

UDP listen port. `0` lets the OS pick one.

#### jc / jmin / jmax

Junk-train after I-packets: count and size range in bytes.

#### s1 / s2 / s3 / s4

Random prefixes for Init / Response / Cookie / Data, in bytes.

#### h1 / h2 / h3 / h4

Message type identifiers. String: a single `uint32` or a range `"a-b"`. Ranges must not overlap.

Compatibility (mechanism off): `h1=1`, `h2=2`, `h3=3`, `h4=4`.

#### i1 / i2 / i3 / i4 / i5

CPS junk packets sent before the handshake. Tag format is documented by [AmneziaWG](https://docs.amnezia.org/documentation/amnezia-wg/). Do not copy sample signatures from the docs.

#### header_protection_key

Base64 32-byte key. Hides unencrypted WireGuard headers (AWG 3.1).

Requires `s1`–`s4` ≥ 12. Leave `h1`–`h4` at `1`/`2`/`3`/`4`.

#### content_padding_addition

Random extra bytes on transport payloads. String: `"n"` or `"min-max"`.

#### rekey_after_time / rekey_timeout / reject_after_time / keepalive_timeout / max_handshake_attempts

Timer ranges (`"n"` or `"min-max"`). A value is drawn from the range each time the timer is armed.

#### random_trailers

Add random trailers to packets (AWG 3.1). Both peers must run 3.1; a 3.0 peer drops the packets. Prefer identical `s1`–`s4` when enabled.

#### disable_cookies

Do not send Handshake Cookie Reply. Incoming cookies still work.

#### peers

==Required==

#### peers.address / peers.port

Peer host (IP or domain) and UDP port. Domains are re-resolved on each handshake.

#### peers.public_key

==Required==

Base64 peer public key.

#### peers.preshared_key

Optional base64 pre-shared key.

#### peers.allowed_ips

==Required==

Allowed IPs for this peer.

#### peers.persistent_keepalive_interval

Keepalive in seconds. JSON number (`25`) or range string (`"20-30"`). Disabled when omitted or `0`.

### Dial Fields

See [Dial Fields](/configuration/shared/dial/) for details.
