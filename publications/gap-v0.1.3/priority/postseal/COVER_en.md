# To the co-authors: machine-checked 1+1 gap (pre-submission draft)

Dear all,

This is the circulation package for our current round of work. Three things below: what to read, what we need you to confirm, and what must not be claimed.

## 1. Contents

- `INDEX.html` — entry page; open it and click through every PDF
- `pdf/EXPLAINER.pdf` — 6-page visual explainer (A4)
- `explainer/EXPLAINER.html` — same explainer, responsive for screen
- `pdf/GOLDBACH_GAP.pdf` — 9-page combined paper (eight theorems in one table)
- `pdf/01_chen.pdf`, `pdf/02_liu.pdf`, `pdf/03_wu.pdf`, `pdf/04_paper.pdf` — four notes, two theorems each
- `GOLDBACH_GAP.tex`, `papers/*.tex` — LaTeX sources (pdfLaTeX + CJKutf8)
- `CIRCULATION.md` — citable values, boundaries, rebuild commands
- `ARTICLE.zh.md`, `ARTICLE.en.md` — long-form articles (replace placeholders before publishing)
- `SHA256SUMS.txt` — SHA-256 for the 25 files in this package (verification recipe in `CIRCULATION.md` §0.2)
- Two companion packages: `gap-v0.1.2-draft.tar.gz` (evidence archive — the 60-file sealed pack, the four new Lean files, the audit and kernel logs, and the arXiv v1 source being checked) and `gap-v0.1.2-history-20261116.zip` (pre-seal working drafts from 2026-11-14; provenance only, **do not forward**)

## 2. What the work says

1. In Lean 4 + Mathlib, the headline endpoints — Chen's 1+2, Li–Liu's 1+1.9, Wu's 1+1.8938 — are logical consequences of binary Goldbach: set the multiplier `r = 1`. Eight theorems, all replayed by `leanchecker`.
2. Three witnesses show the representation predicates are genuinely wider: `4 = 2·2`, `18 = 3 + 3·5`, `13 = 7 + 2·3`.
3. Under arXiv:2611.09007v1's own definition of big-`O`, its Theorem 1.1 already implies binary Goldbach; line 180 lists the current case `G(2n)` among the things "we can assume", so the argument is circular. The first is a kernel-checked implication; the second is a literal textual comparison.

## 3. Please confirm

1. **Authors and order**: 宋敏、宋瑷成、宋奥菲、范钧睿、胡安、涂源 — same order in every PDF, `CITATION.cff`, `zenodo.json`. Check romanized display names, affiliations, ORCIDs.
2. **Corresponding author and contacts**: `IDENTITY.json` currently has only the first author's email and GitHub handle; the rest are empty.
3. **Split**: currently 4 notes x 2 theorems (grouped by endpoint, each implication paired with its own witness). We can regroup to 2 notes or one paper.
4. **Venue**: undecided — four separate submissions, or the combined paper as an arXiv preprint.

## 4. Boundaries that must travel with the package

- **We do not prove Goldbach.** No unconditional theorem here concludes binary Goldbach.
- **No priority claim.** The prior-art record shows only that we did not find a predecessor, with queries and dates; it is not an exhaustive search.
- **Wu's endpoint is a transcription**, not kernel-replayed in this work.
- **The witnesses are not independence results.** They show wider predicates; `4`, `18`, `13` are themselves sums of two primes.
- **Upstream work is not ours.** Chen / Li–Liu / Wu belong to `subfish-zhou/goldbach-lean`; we add four files and modify two.

## 5. Citable values

- Evidence pack: 68 files, manifest SHA-256 `77df12642d7eb2210280ab09e398d101052e6158040033289074080d79ee8860`
- RFC 3161 token genTime `Nov 16 23:56:45 2026 GMT`, signature check `OK`
- Code: public repository `https://github.com/songminlhy/goldbach-lean`, tag `gap-v0.1.2`, commit `c73fce1`; the four new Lean files and the two upstream patches are inside the evidence archive
- Download: `https://github.com/songminlhy/goldbach-lean/releases/tag/gap-v0.1.2`, asset `gap-v0.1.2-draft.tar.gz` together with its `.sha256`
- Upstream: `subfish-zhou/goldbach-lean`, `main` at `9d4c3a4`, Apache-2.0

## 6. Opening the files

Double-click `INDEX.html` after extracting. If the browser blocks `file://`, paste the full path of `INDEX.html` into the Explorer address bar, or serve locally: `py -m http.server 8765 --bind 127.0.0.1 --directory .` then open `http://127.0.0.1:8765/INDEX.html`.

Rebuild: `pdflatex -interaction=nonstopmode -output-directory=paper-build GOLDBACH_GAP.tex` (twice); the four notes are compiled the same way under `papers/`.

If any reading looks wrong — especially the passage at line 180 — please point to the line and we will re-check against v1.

— 宋敏 (corresponding author)
16 November 2026
