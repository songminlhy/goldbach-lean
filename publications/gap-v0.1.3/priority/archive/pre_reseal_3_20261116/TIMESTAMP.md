# Seal record

| field | value |
|---|---|
| sealed at (UTC) | 2026-11-16 23:50:07 |
| manifest | `priority/MANIFEST.sha256` (68 files) |
| manifest sha256 | `38eaa9dbe8b7f53d0abc1d2a7d9f4a6b974263a833c2cbb0a47b43e4a610bfc1` |
| token sha256 | `9378fb244c8dfca850f4bca3003b005887ba8e8d600605bfc4623eab2f6ddd0f` |
| TSA | FreeTSA <https://freetsa.org/tsr> |
| token status | Granted |
| token genTime | Nov 16 23:50:08 2026 GMT |
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
