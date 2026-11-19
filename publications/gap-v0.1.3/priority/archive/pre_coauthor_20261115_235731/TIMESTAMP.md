# Seal record

| field | value |
|---|---|
| sealed at (UTC) | 2026-11-15 08:33:55 |
| manifest | `priority/MANIFEST.sha256` (33 files) |
| manifest sha256 | `4eb38ade18f7c1768717f7d1b378bba36aa1f294626b4de8f8581e55998a1bc4` |
| token sha256 | `68f87daf2569e8709dba6fb8759b4d1f7b1a7f506568a70cf36df07006b26171` |
| TSA | FreeTSA <https://freetsa.org/tsr> |
| token status | Granted |
| token genTime | Nov 15 08:33:56 2026 GMT |
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
