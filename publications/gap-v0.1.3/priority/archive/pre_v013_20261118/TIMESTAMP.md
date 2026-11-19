# Seal record

| field | value |
|---|---|
| sealed at (UTC) | 2026-11-16 23:56:44 |
| manifest | `priority/MANIFEST.sha256` (68 files) |
| manifest sha256 | `77df12642d7eb2210280ab09e398d101052e6158040033289074080d79ee8860` |
| token sha256 | `26bfee4ad63c585324459af9484a6d5407baf637f523d6515f75ceab1ed2209c` |
| TSA | FreeTSA <https://freetsa.org/tsr> |
| token status | Granted |
| token genTime | Nov 16 23:56:45 2026 GMT |
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
