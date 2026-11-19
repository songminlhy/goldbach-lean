# Four papers, two theorems each

The eight kernel-checked theorems are split evenly into **four** papers. Four is the only
number in the requested 2--5 range that divides eight exactly and keeps each endpoint's
implication and witness together:

| Paper | File | Theorems | Count |
|---|---|---|---|
| 1. Chen | `01_chen.tex` | `binaryGoldbach_implies_chen`, `chen_second_summand_class_includes_composite` | 2 |
| 2. Li--Liu | `02_liu.tex` | `binaryGoldbach_implies_onePlusOneNine`, `liu_multiplier_class_includes_nontrivial` | 2 |
| 3. Wu | `03_wu.tex` | `binaryGoldbach_implies_onePlusOne8938`, `wu_multiplier_class_includes_nontrivial` | 2 |
| 4. Preprint | `04_paper.tex` | `goldbachCount_pos_iff`, `paperTheorem_implies_binaryGoldbach` | 2 |
| **Total** | | | **8** |

The combined draft is `../GOLDBACH_GAP.tex`; it is the unified version and is **not** one
of the four split papers.

## Why 4 x 2, not 2 x 4 or 3 x (3/3/2)

- 8 is divisible by 2 and 4, not by 3 or 5. Four papers of two theorems is the exact
  equal split inside 2--5.
- Grouping by endpoint keeps each paper coherent: the Chen implication and the Chen
  witness belong together; likewise Li--Liu and Wu. The fourth paper is the substantive
  preprint result (count bridge + `PaperTheorem => Binary Goldbach`).
- A 2 x 4 split would mix the preprint implication with endpoint witnesses; a 3-paper
  split would be 3/3/2, not equal.

## Important correction: the witnesses are representation-level

The three witnesses are about **representations**, not about numbers outside $1+1$:

- Chen: $4=2\cdot2$ is not a $1+1$ representation; $4$ itself is $2+2$.
- Li--Liu: $18=3+3\cdot5$ is not a $1+1$ representation; $18$ itself is $5+13=7+11$.
- Wu: $13=7+2\cdot3$ is not a $1+1$ representation; $13$ itself is $2+11$.

The witnesses show that the endpoint predicates are strictly wider as representation
predicates. They do **not** show that the endpoint sets contain a number outside $1+1$,
and they are not independence results. The split papers state this explicitly; the
earlier article's sentence that these numbers are "not a sum of two primes" was incorrect
and has been corrected in `../ARTICLE.zh.md` and `../ARTICLE.en.md`.

## Compile

From this directory:

```bash
pdflatex 01_chen.tex
pdflatex 02_liu.tex
pdflatex 03_wu.tex
pdflatex 04_paper.tex
```

Each paper `\input{preamble.tex}`; keep the two files together when submitting. The
author names use `CJKutf8`; if the CJK fonts are unavailable, replace `\PaperAuthors` in
`preamble.tex` with the romanization used by the authors. `XeLaTeX` also works.

## Status and boundaries

- These four papers are postseal publication material; they are **not** in the 60-file
  `priority/MANIFEST.sha256`. A final seal may add them after the DOI is known.
- They do not prove Goldbach; the only implication with conclusion `BinaryGoldbach` has
  the preprint's unproved Theorem 1.1 as its hypothesis.
- The Wu endpoint shape is a verbatim transcription; the upstream Wu proof was not
  kernel-replayed in this work. Do not describe the Wu endpoint itself as
  "kernel-checked".
- The code is at <https://github.com/songminlhy/goldbach-lean>, tag `gap-v0.1.2`
  (commit `c73fce1`). The evidence package is `goldbach/priority/`.
