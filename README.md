# hc-box

Fork of [sing-box](https://github.com/SagerNet/sing-box) with [AmneziaWG](https://docs.amnezia.org/documentation/amnezia-wg/) (AWG) support.

> This is a fork of a fork a fork: sing-box → [amnezia-vpn/sing-box](https://github.com/amnezia-vpn/sing-box) → [hoaxisr/amnezia-box](https://github.com/hoaxisr/amnezia-box) -> hc-box

This fork is made for personal purposes only! It just adds support for some additional build platforms and protocols.

## Features

- Full sing-box functionality
- AmneziaWG protocol support via [amneziawg-go](https://github.com/amnezia-vpn/amneziawg-go)
- Mieru protocol support via [mieru](https://github.com/enfein/mbox)

## Build

```bash
go build -tags "with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,with_clash_api,with_awg" ./cmd/sing-box
```

## Documentation

https://sing-box.sagernet.org

## License

```
Copyright (C) 2022 by nekohasekai <contact-sagernet@sekai.icu>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

In addition, no derivative work may use the name or imply association
with this application without prior consent.
```
