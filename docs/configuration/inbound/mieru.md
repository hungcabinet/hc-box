---
icon: material/new-box
---

### Structure

```json
{
  "type": "mieru",
  "tag": "mieru-in",

  ... // Listen Fields

  "transport": "TCP",
  "users": [
    {
      "name": "asdf",
      "password": "hjkl"
    }
  ],
  "traffic_pattern": "GgQIARAK",
}
```

### Listen Fields

See [Listen Fields](/configuration/shared/listen/) for details.

### Fields

#### transport

==Required==

Transmission protocol. Allowed values are `TCP` and `UDP`.

#### users

==Required==

A list of mieru user name and password.

#### traffic_pattern

A base64 string to fine tune network behavior.
