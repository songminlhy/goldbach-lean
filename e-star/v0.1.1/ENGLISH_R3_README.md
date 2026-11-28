# English r3 companion to Chinese E* v0.1.1

Added November 29, 2026 for public author and mathematical review.

- [English candidate PDF (r3, 9 pages)](E_star_English_r3_CANDIDATE.pdf)
- [English TeX source package (7 files)](E_star_arxiv_source_r3_CANDIDATE.zip)
- [English companion SHA256 checksums](ENGLISH_R3_SHA256SUMS.txt)
- [Original Chinese v0.1.1 PDF](E_star_named.pdf)
- [Original Chinese v0.1.1 source](E_star_named.tex)
- [Fixed Chinese release](https://github.com/songminlhy/goldbach-lean/releases/tag/e-star-v0.1.1)
- [Chinese version DOI](https://doi.org/10.5281/zenodo.24368074)

## Relationship to the Chinese baseline

The English r3 candidate faithfully translates the mathematical content of
Chinese v0.1.1, with limited proof clarifications and additional publication
disclosures. It preserves the theorem statements, quantifiers, parameter
ranges, representation-length bounds, proof route and 44 display-math blocks.
It introduces no new mathematical theorem.

The finite deletion argument now explicitly bounds the number of removed
vertices: process originally selected edges, delete one vertex only when an
edge is still intact, and skip edges already destroyed. The description of
the bounded-basis derivation explicitly retains its cited Lev input.
Version/availability and AI-use declarations were added for the English
preparation. The original author-reported tool label is retained rather than
converted into an independently authenticated model name.

Authors, in the supplied order: SongMin, SongAiCheng, SongAoFei, FanJunRui,
HuAn and TuYuan. The earlier reported collective English review covered r2;
this repository addition does not assert new collective approval of r3.

## Build and verification scope

Extract the source ZIP into an empty directory and compile `main.tex` with
XeLaTeX three times. It contains `main.tex`, `authors.tex`, `abstract.tex`,
`body.tex`, `disclosures.tex`, `references.tex`, and `00README.json`.
The supplied settings request XeLaTeX and TeX Live 2025.

The candidate and an isolated copy extracted from this ZIP each compiled
locally three times without final warnings; all nine pages were rendered and
visually checked, all fonts were embedded, and both builds had identical
page text and pixels. A bounded deletion-rule regression covered every
subset of [1,E] for E=1..6, 938 edge orders and 56,857 recursive states.
These checks do not replace the general cited theorems, certify novelty,
constitute external peer review, or establish an arXiv server compilation.
No new Lean execution is claimed by this English repository addition.

## Publication status and license

This is a repository companion, not an arXiv submission or journal acceptance.
No arXiv identifier has yet been assigned by this preparation workflow.
The DOI above identifies the original Chinese version, not a new English DOI.
Annals eligibility concerning that prior deposit remains unresolved.
The author selected CC BY 4.0 for the intended arXiv version; the prose
companion is shared consistently with the original CC BY 4.0 release:
https://creativecommons.org/licenses/by/4.0/ .

The original Chinese files, their historical manifests, the fixed v0.1.1 tag,
release assets and Zenodo record are preserved. The historical
`MANIFEST.sha256` still describes its original files; use the separate
English checksum file for these additions. Private coauthor administration,
account recovery details and the complete local preparation bundle are not
included in this public addition.
