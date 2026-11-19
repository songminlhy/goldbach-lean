# E* main-theorem audit supplement

Anonymous · CC BY 4.0 · 2026-11-19

Read [中文核验报告](REPORT.zh-CN.md) for claims, assumptions and unresolved questions. This supplement does not replace the original [e-star-v0.1.0 paper and package](https://doi.org/10.5281/zenodo.24342987).

The strongest asymptotic Lean theorem is **conditional on `LevGrowthInput`**, the precise classical Lev 1996 growth theorem for actual finite repeated sumsets. The general normalized basis theorem is now derived from this input, rather than merely assumed. A successful build and standard axiom report do not remove a theorem parameter. No external peer review or historical novelty certification is claimed.

## Python checks

Requires Python 3.12; standard library only:

```text
python code/verify_main_constructions.py
python code/check_modular_sharpness.py
python code/adversarial_seams.py
```

Each script writes its output JSON in `code/`. Published baseline results are in `results/`. Finite samples and exact finite maxima do not establish asymptotic statements.

`adversarial_seams.py` may optionally hash a copy of `E_star_anonymous.tex` placed beside it; the original paper source is not re-bundled here. Without that optional file it reports `PAPER_SOURCE_NOT_BUNDLED` while still performing all finite checks. This does not claim a new paper-identity verification.

## Lean checks

Pinned toolchain: Lean 4.33.0-rc1. Existing Mathlib cache used by the publisher: revision `e4c91783ca8e6a7c693ae624ade32fd22d4e43c1`. Use compatible package libraries, with paths separated by the operating system path separator (`;` on Windows, `:` on Unix).

```text
python code/verify_lean.py --lean <absolute-lean-executable> --library-path <existing-compatible-library-directories> --checker <matching-leanchecker-executable>
```

The checker argument is optional. The runner does not install dependencies or change global settings. It compiles every delivered module in order and writes all new artifacts below `code/results/`; its axiom audit rejects nonstandard axioms or missing expected reports. When a checker is supplied it replays these delivered modules, while reusing imported dependency caches. It does not replay or rebuild the full imported dependency closure.

Read the actual definitions and theorem signatures in addition to the success summary. `GeneralBasisInput q` is an intermediate interface proved by `general_basis_from_lev`. The remaining unproved input is the classical cardinality-growth theorem `LevGrowthInput`; real interval coverage, membership and distinct representations are subsequently proved.

## Attribution and limits

Good-core/Roth code is adapted from [Mateo Matijasevick's erdos361 repository](https://github.com/matejasevick/erdos361/tree/27f45e7f84894993c1471e952608319aebc53eee), under MIT; the original copyright and license are preserved in `code/UPSTREAM_LICENSE.txt`. Compatibility edits and the weaker formal bad-center constant are documented in the report.

The modular construction mechanism is already public in [StijnC's forum post of 17 October 2025](https://www.erdosproblems.com/forum/thread/361#post-1164). The report distinguishes the construction, its parameterized corollaries, and the separate upper bound. No first-construction or priority claim is made.

No third-party paper PDF, private conversation, credential, personal path or unreviewed failed proof is included. The fixed paper, original archive, tag and DOI assets remain unchanged.
