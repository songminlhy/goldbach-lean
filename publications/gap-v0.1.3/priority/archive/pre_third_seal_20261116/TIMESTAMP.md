# Seal record

| field | value |
|---|---|
| sealed at (UTC) | 2026-11-16 02:12:04 |
| manifest | `priority/MANIFEST.sha256` (33 files) |
| manifest sha256 | `8b7a1e1a9cbe6732bda6dbe0e84925cfe9b5974645d9daec6751bb4d1ea94a75` |
| token sha256 | `ca37a16b36ac3d1c72209a31ab4b5feba195c5fa8a8daf095be7d4bf91815259` |
| TSA | FreeTSA <https://freetsa.org/tsr> |
| token status | Granted |
| token genTime | Nov 16 02:12:06 2026 GMT |
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
