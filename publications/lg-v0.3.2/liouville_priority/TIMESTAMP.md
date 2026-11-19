# Seal record

| field | value |
|---|---|
| sealed at (UTC) | 2026-11-18 01:17:35 |
| manifest | `liouville_priority/MANIFEST.sha256` (104 files) |
| manifest sha256 | `5c01d3e13c47aca4c8901031b685aec3b00c98e6f2abca368feea41ea7779d76` |
| token sha256 | `60d1b59c4eb7c034f72c7772e910bc023ba09aacff237e6a615733ee704f7f97` |
| TSA | FreeTSA <https://freetsa.org/tsr> |
| token status | Granted |
| token genTime | Nov 18 01:17:37 2026 GMT |
| signature check | OK |
| openssl | OpenSSL 3.5.7 9 Jun 2026 (Library: OpenSSL 3.5.7 9 Jun 2026) |

This token signs **MANIFEST.sha256 only**; the manifest binds every file listed in
`files.txt` by SHA-256. A token proves that those bytes existed at
`token genTime`; it does not prove authorship, correctness, or novelty.

Re-verify (offline, certificate chain pinned under `tsa/`):

```
openssl ts -verify -data liouville_priority/MANIFEST.sha256 -in liouville_priority/MANIFEST.tsr ^
  -CAfile liouville_priority/tsa/cacert.pem -untrusted liouville_priority/tsa/tsa.crt
```
