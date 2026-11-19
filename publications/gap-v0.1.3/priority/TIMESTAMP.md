# Seal record

| field | value |
|---|---|
| sealed at (UTC) | 2026-11-18 00:41:29 |
| manifest | `priority/MANIFEST.sha256` (79 files) |
| manifest sha256 | `80467079b6827f3b20008f66332d11e143c9b990d0b97c29dcdbfb631475feff` |
| token sha256 | `7124e6ed1cafe4691c1c41ac7ccb92cc9eecc0dde1820473c59747b3fcbe6b9d` |
| TSA | FreeTSA <https://freetsa.org/tsr> |
| token status | Granted |
| token genTime | Nov 18 00:41:31 2026 GMT |
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
