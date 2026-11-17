# Liouville–Goldbach audit (`lg-v0.2.0`)

This directory contains the Lean 4 evidence for the paper *刘维尔--哥德巴赫定理的严格证明与二元哥德巴赫猜想的逻辑边界* (v0.2.0, 2026-11-17).

## Provenance

The nine modules under `LiouvilleGoldbach/` and the umbrella `LiouvilleGoldbach.lean` are a source-level copy of the upstream project accompanying the 16 September 2026 manuscript *A Goldbach theorem for the Liouville function* by `CaptainSude`:

- <https://github.com/CaptainSude/Liouville-Goldbach>

They are Apache-2.0 and retain their upstream notices. This repository ports them into the `songminlhy/goldbach-lean` working copy only to rebuild and audit them; no authorship of the upstream modules is claimed.

The following files are added by this audit (Apache-2.0):

| File | Purpose |
|---|---|
| `GapCertificate.lean` | `GC ⇒ LG`, the witness `20 = 8 + 12`, and `GC ⇔ LG_{Ω≤2}` |
| `GapAudit.lean` | re-states the gap certificate and prints axiom sets |
| `LiouvilleAudit.lean` | audits the main LG theorem and intermediate lemmas |
| `run_lg.ps1` | convenience launcher for `lean LiouvilleGoldbach/Main.lean` |

`lakefile.toml` gains one `[[lean_lib]]` entry for `LiouvilleGoldbach`.

## Build and check

Toolchain: Lean `4.33.0-rc1`; Mathlib commit `e4c91783ca8e6a7c693ae624ade32fd22d4e43c1`.

```bash
lake build LiouvilleGoldbach          # 2851 jobs in the audit build
lake env lean GapCertificate.lean     # rc 0
lake env lean LiouvilleAudit.lean     # rc 0
```

`#print axioms` lists only `propext`, `Classical.choice`, `Quot.sound` for the main theorem `LiouvilleGoldbach.liouville_goldbach`.

## Scope

The Lean statements formalize LG, not binary Goldbach. The paper proves `GC ⇔ LG_{Ω≤2}`; no theorem here concludes `BinaryGoldbach`. The upstream manuscript's prose is not kernel-checked; the formalization covers the listed statements only.

## Links

- Evidence pack (Zenodo preprint v0.2.0): DOI `10.5281/zenodo.24302032`
- Paper: `paper_boundary/paper.pdf` in the evidence pack
