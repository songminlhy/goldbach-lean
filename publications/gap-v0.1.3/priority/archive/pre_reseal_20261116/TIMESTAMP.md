# Seal record

| field | value |
|---|---|
| sealed at (UTC) | 2026-11-15 15:59:25 |
| manifest | `priority/MANIFEST.sha256` (33 files) |
| manifest sha256 | `5920890003ab3cfa97190780555a53b5f04d70c0e3d10508b34fbf2089b172e3` |
| token sha256 | `bd8e81f6a130090c6d43319cafe225057733aeee13b6099df6e04dca5725381e` |
| TSA | FreeTSA <https://freetsa.org/tsr> |
| token status | Granted |
| token genTime | Nov 15 15:59:25 2026 GMT |
| signature check | OK |
| openssl | OpenSSL 3.5.7 9 Jun 2026 (Library: OpenSSL 3.5.7 9 Jun 2026) |

This token signs **MANIFEST.sha256 only**; the manifest binds every file listed in
`files.txt` by SHA-256. A token proves that those bytes existed at
`token genTime`; it does not prove authorship, correctness, or novelty.

Re-verify (offline, certificate chain pinned under `tsa/`):

```
openssl ts -verify -data priority/MANIFEST.sha256 -in priority/MANIFEST.tsr ^
  -CAfile priority/tsa/cacert.pem -untrusted priority/tsa/tsa.crt
```
