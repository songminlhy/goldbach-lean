# Authorship and division of labour

This document records **who contributed what** to this working copy, so that
neither the upstream results nor the local increments are misattributed.
It complements [PROVENANCE.md](PROVENANCE.md), which records *where the sources
come from*; this file records *who is responsible for which layer*.

It is a provenance record, not a legal authorship determination.

## Layers

| Layer | Attribution | Where it lives |
| --- | --- | --- |
| Mathematics of Chen's 1+2 | Chen Jingrun (1973), with Pan–Ding–Wang (1975), Jurkat–Richert (1965), Richert (1969), Wang (1962) | `Goldbach/`, `MathlibNt/ChensTheorem/`, `docs/CHEN_*` |
| Mathematics of Li–Liu 1+1.9 | Jiamin Li and Jianya Liu, *Theorem (1+1.9) on the Goldbach Conjecture*, arXiv:2606.05224 | `MathlibNt/SieveTheory/LiLiu*`, `docs/LILIU_*` |
| Mathematics of Wu04/Wu08 (1+1.8938) | The Wu 2004 / 2008 sources collected under `research/wu2008/` | `research/wu2008/` |
| Chen formalization base | [UyNewNas/chen-theorem-lean](https://github.com/UyNewNas/chen-theorem-lean) | `Goldbach/`, `MathlibNt/` foundations |
| Prime-number-theorem source closure | [AlexKontorovich/PrimeNumberTheoremAnd](https://github.com/AlexKontorovich/PrimeNumberTheoremAnd) | `PrimeNumberTheoremAnd/` |
| General library | The Mathlib Community (`mathlib4`) | `lake-manifest.json` dependency |
| Integration, release engineering and proof completion on top of the above | [subfish-zhou/goldbach-lean](https://github.com/subfish-zhou/goldbach-lean) | The whole tree as inherited |
| Increments in this working copy | 宋敏 (GitHub: [songminlhy](https://github.com/songminlhy)) | Commit `09e1185` and later |

Nothing in this copy claims authorship of the mathematical theorems, of the
upstream formalization base, or of the upstream integration work.

## Why `git log` cannot answer this

The inherited history does not name human authors. `git shortlog -sne HEAD`
before the local commit reported:

```
50  Release Preparation <release@localhost>
 2  Ubuntu <azureuser@ai4m-mathub...cloudapp.net>
```

That is, every inherited commit carries a build-machine identity, and the
earliest commit already reads "Prepare Chen 1+2 v1.0.0-rc1 for review". The
upstream history was therefore squashed before publication, and per-commit
authorship cannot be recovered from this repository.

Consequences, stated plainly:

- Absence of a human name in `git log` is **not** evidence that no human wrote
  the inherited code; it only means the names were not preserved.
- Conversely, presence of code in this repository is **not** evidence that the
  owner of this copy wrote it.
- This file, plus [NOTICE](../NOTICE) and [PROVENANCE.md](PROVENANCE.md), is the
  substitute for the missing commit-level attribution.

History was deliberately **not** rewritten. Rewriting it would change every
commit SHA, break the published tags `v1.0.0-rc1` and `1plus1.9-v1.0.0`, and
destroy the ability to diff this copy against upstream.

## Increments in this working copy

Commit `09e1185` — "feat: formalize the 1+1 gap and record upstream provenance":

| File | Status | Content |
| --- | --- | --- |
| `Goldbach/Gap.lean` | added | Kernel-checked statements quantifying the distance between the repository's headline endpoints (`N = p + r*q`, `r^10 ≤ q^9`) and binary Goldbach, on top of `Goldbach.Statement` |
| `Goldbach/GapChecks.lean` | added | Restates the gap theorems and prints their axiom sets |
| `Goldbach/GapLiveChecks.lean` | added | Live variant of the same checks |
| `docs/GAP.md` | added | Exposition of what `Goldbach/Gap.lean` does and does not establish |
| `MathlibNt/SieveTheory/LiLiuGoldbachG12FlexibleWF.lean` | modified | In `labels_test`, a single `simp` step is replaced by an explicit `sum_congr` argument. Marked in-file per Apache-2.0 §4(b) |
| `scripts/check.py` | modified | Module names derived with POSIX separators so the static checks behave identically on Windows. Marked in-file per §4(b) |
| `NOTICE` | added | Apache-2.0 derivative notice and upstream list |
| `README.md` | modified | Provenance paragraph at the top |

`docs/GAP.md` records the scope limit explicitly: the gap theorems are about the
*statements* formalized here, not a new result toward binary Goldbach itself.

## Scope of responsibility

- **Mathematics.** Owned by the cited authors. This copy implements and audits,
  it does not prove new number theory.
- **Upstream formalization and integration.** Owned by the upstream projects
  listed above, under Apache-2.0.
- **Local increments.** Owned by 宋敏 (songminlhy), limited to the files in the
  table above and any later commits authored under that identity.
- **Correctness of inherited proofs.** Carried by the upstream projects. The
  `scripts/check.py` gate and `CONTRIBUTING.md` rules describe what *this copy*
  verifies before accepting a change, not a re-audit of everything inherited.

## Verifying the split

```bash
git shortlog -sne HEAD                    # who committed here
git log --author=宋敏 --name-status       # files touched by this copy's owner
git log --author=宋敏 --format=%H         # SHA list of local commits
git diff subfish-zhou/main..HEAD          # divergence from upstream, if fetched
```

To inspect the inherited tree without local changes, `git log 9d4c3a4` is the
last inherited commit.
