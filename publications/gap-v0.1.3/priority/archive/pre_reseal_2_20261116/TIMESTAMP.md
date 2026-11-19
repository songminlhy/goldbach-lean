# Seal record

| field | value |
|---|---|
| sealed at (UTC) | 2026-11-16 22:57:24 |
| manifest | `priority/MANIFEST.sha256` (67 files) |
| manifest sha256 | `96e27cc233cbeabba5b2eab6f13676b6402998c625bd53e84a24096082eca98a` |
| token sha256 | `c253d7dcf7bf521833651c53598566c6bb2d28104fb1e137b684784735ffe4ed` |
| TSA | FreeTSA <https://freetsa.org/tsr> |
| token status | Granted |
| token genTime | Nov 16 22:57:26 2026 GMT |
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
