# 1+2 Is Not 1+1: A Machine-Checked Note on the Goldbach Gap and a Circularity in arXiv:2611.09007v1

**Subtitle: Eight Lean 4 theorems, their axiom sets, and what they do—and do not—prove**

> **Replace before publishing:** `{{REPO_URL}}`, `10.5281/zenodo.24270135`, `{{AUTHOR}}`, `{{DATE}}`.  
> The full evidence package is under `goldbach/priority/`; every line number, hash, and verification command below can be checked independently.

## 0. Summary

The binary Goldbach conjecture is still open. This note does not prove it.

What it does is turn two statements that are usually left informal into kernel-checked Lean 4 theorems:

1. **Chen's 1+2, Li–Liu's 1+1.9, and Wu's 1+1.8938 are consequences of 1+1**, not “almost 1+1”. Set the second multiplier to `1` (or, in Chen's case, take the second summand to be prime), and each endpoint follows immediately from `BinaryGoldbach`.
2. **A preprint from November 2026, under its own definition of big-O, has a Theorem 1.1 that already implies 1+1.** Its proof opens at line 180 by listing `G(2n)` itself—the current case—among the things we may assume, and also lists “the positivity of `G(2n-2)`” as an input; under that definition, the latter is already contained in the induction hypothesis. Read literally, the step assumes the conclusion.

The evidence is **eight Lean 4 theorems**. They depend only on `Goldbach.Statement` and Mathlib—not on the 1,800-module sieve development upstream—and `leanchecker` replays them with axioms contained in `{propext, Classical.choice, Quot.sound}`.

**But keep the boundaries in view:**

- We do not prove Goldbach. No unconditional theorem here concludes `BinaryGoldbach`.
- We do not prove that the endpoints cannot imply 1+1. That would need a metamathematical argument; the witness theorems only show that the representation predicates are wider.
- We do not claim to be first. The queries and their dates are in `PRIOR_ART.md`; they show only that we did not find a predecessor.

## 1. The three endpoints: weaker than 1+1, not “close” to it

Write 1+1 as the binary Goldbach statement for large even numbers:

```lean
def BinaryGoldbach : Prop :=
  ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N → Even N →
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N = p + q
```

There is a threshold beyond which every even number is a sum of two primes.

The headline endpoints have these shapes:

| Endpoint | Shape | Difference from 1+1 |
|---|---|---|
| Chen 1+2 | `N = p + q`, `q` prime or a product of two primes | second summand may be composite |
| Li–Liu 1+1.9 | `N = p + r·q`, `r = 1` or `r` prime, `r¹⁰ ≤ q⁹` | multiplier may be prime |
| Wu 1+1.8938 | `N = p + r·q`, `r = 1` or `r` prime, `r⁵⁰⁰⁰ ≤ q⁴⁴⁶⁹` | multiplier may be prime |

The direction is **1+1 ⇒ endpoint**. Setting `r = 1` makes `N = p + q` a sum of two primes. In Chen's case, taking `q` prime is enough. The three Lean theorems are:

```lean
binaryGoldbach_implies_chen
binaryGoldbach_implies_onePlusOneNine
binaryGoldbach_implies_onePlusOne8938
```

They show that the endpoints are **weaker** than 1+1. This is not a rhetorical quibble about “how close” 1+2 is; it is a question of logical direction.

A natural objection: Chen's 1+2 is already a theorem, so why not run the implication backwards? Because that implication is exactly the gap. If `ChenTheorem → BinaryGoldbach` were available, Goldbach would be solved. No such converse is proved here, and none is expected from the existing material.

## 2. Where the representation gap lives

“Weaker” should not remain a slogan. Three machine-checked witnesses show that the endpoint predicates admit **representations** that a 1+1 representation does not allow. They are representation-level statements, not number-level ones:

- **Chen:** `4 = 2 · 2`. The second summand `q = 4` is composite, yet it satisfies “prime or a product of two primes”. The representation with `q = 4` is not a 1+1 representation; `4` itself is `2 + 2`.
- **Li–Liu:** `18 = 3 + 3 · 5`, with `r = 3 ≠ 1` and `3¹⁰ ≤ 5⁹`. This is not a 1+1 representation; `18 = 5 + 13 = 7 + 11`, so `18` itself is a sum of two primes.
- **Wu:** `13 = 7 + 2 · 3`, with `r = 2 ≠ 1` and `2⁵⁰⁰⁰ ≤ 3⁴⁴⁶⁹`. This is not a 1+1 representation either; `13 = 2 + 11`, so `13` itself is a sum of two primes.

The Lean theorems are:

```lean
chen_second_summand_class_includes_composite
liu_multiplier_class_includes_nontrivial
wu_multiplier_class_includes_nontrivial
```

To be explicit: **these witnesses only show that the representation predicates are wider. They are not an independence proof, and they do not produce a number outside 1+1.** Proving that an endpoint cannot imply 1+1 would require a metamathematical argument; we do not give one and do not pretend to.

## 3. The preprint's Theorem 1.1 already implies 1+1 under its own definition

This is the substantive part of the note.

The preprint is Khaled Qazaqzeh and Aymen Rawashdeh, *An Elementary Proof of the Binary Goldbach Conjecture* ([arXiv:2611.09007v1](https://arxiv.org/abs/2611.09007), 6 November 2026, math.NT, 9 pages). All line numbers below refer to the **LaTeX source of v1** (`A_Simple_Proof_of_Goldbach_Conjecture.tex`), not to PDF page numbers. The source file has SHA-256:

```text
db1fa07154ae7430245d19ac377f6d22f02361608014498fe3449129c3765ffd
```

It is byte-identical to the source served by arXiv for v1 (checked on 15 November 2026). The hash pins the version, so the quotation can be checked without trusting us.

### 3.1 Definition 2.1 defines big-O as “ratio tends to a nonzero constant”

Line 111 (the first item of Definition 2.1) reads verbatim:

> “We say that $f$ is a big $\mathcal{O}$ of $g$, denoted by $\mathcal{O}(g)$, if $\lim\limits_{n\to \infty} \frac{f(n)}{g(n)} = c$ for some nonzero real number $c$.”

Standard big-O only requires an eventual upper bound `|f| ≤ C·g`. This definition requires the **ratio to converge to a nonzero constant**. It is not a loose upper bound; it is a much stronger two-sided asymptotic condition.

### 3.2 Under that definition, Theorem 1.1 forces 1+1

Theorem 1.1 says that the number `G(2n)` of ordered Goldbach pairs is `O(n / ln² n)`. Under the paper's own definition, this means

```text
lim_{n→∞} G(2n) · ln²(2n) / n = c ≠ 0.
```

(The theorem statement writes `ln² n`, while the proof at lines 182/184 uses `ln²(2n)`; the ratio `(ln(2n)/ln n)²` tends to 1, so the nonzero limit is unaffected. The formalization uses the form that appears in the proof.)

The argument has four steps:

1. `G(2n) ≥ 0`, so the ratio is eventually `≥ 0`; hence `c ≥ 0`.
2. `c ≠ 0`, so `c > 0`.
3. The ratio is eventually `> 0`; since `ln²(2n) > 0` and `n > 0`, `G(2n) > 0` eventually.
4. `G(2n) > 0` means there are primes `p, q` with `2n = p + q`. Hence every sufficiently large even number is a sum of two primes—1+1.

The formalization uses `goldbachCount`, which includes `p = 2` in its range. For `N ≥ 6`, `p = 2` forces `N - 2` to be an even number greater than 2, hence composite, so the count agrees with the paper's `G` in the relevant range. The boundary term does not affect the “sufficiently large” conclusion; `docs/GAP.md` records the detail.

We formalize “Theorem 1.1 under the paper's own O definition” as `PaperTheorem` and prove:

```lean
paperTheorem_implies_binaryGoldbach : PaperTheorem → BinaryGoldbach
```

This is theorem 8 below, and it is kernel-checked. It says: **under the paper's own definition, Theorem 1.1 is not weaker than the conjecture; it already implies it.**

### 3.3 Where the circularity is: line 180 takes the conclusion as an input

A strong theorem is not yet a circular proof. The circularity is in the proof.

Line 180 (the opening of the proof) reads (emphasis ours; `\ref` cross-references are rendered as numbers):

> “We proceed by induction on n to verify the claim of the theorem. Thus we can assume that $G(2n-2)$ and $G(2n)$ are $\mathcal{O}\left(\frac{n}{\ln^{2} n}\right)$ functions as a consequence of the result of Lemma (note). As a consequence of Equation (1), the induction hypothesis on the antidiagonals $I_{2n-2}$, **the positivity of $G(2n-2)$** and the result of Lemma (note), we conclude …”

Read literally, the first sentence lists **both** `G(2n-2)` and `G(2n)` as things we may assume. `G(2n)` is the very case being proved; an induction hypothesis should give only the `n-1` case (`G(2n-2)`). If the authors did not intend to assume the current case, they need an independent derivation of `G(2n)` from `G(2n-2)`; the paper does not give one.

The same sentence also lists `G(2n-2) > 0` as an input. But under the paper's own O definition, “`G(2n-2)` is `O(n/ln² n)`” already implies `G(2n-2) > 0` for large `n`. So that positivity is not independent information; the real issue is that `G(2n)` is listed among the assumptions.

The same passage (line 184) derives `α < 2` from “`G(2n-2)` is `O(n/ln² n)`”. If `G(2n-2) ~ c·n/ln² n`, then `α = 2 - c`; `α < 2` holds exactly when `c > 0`. That is the same positivity again.

So the precise statement has two parts:

- **Machine-checked:** under the paper's O definition, Theorem 1.1 ⇒ 1+1 (`paperTheorem_implies_binaryGoldbach`).
- **Textual comparison:** read literally, line 180 lists `G(2n)` itself (the current case) among the things we may assume, and lists `G(2n-2) > 0` as an input; under that definition, the latter is already part of the conclusion. Hence the proof is circular—not merely “an inequality is off by one”.

These two parts have different epistemic status, and this note keeps them separate.

### 3.4 If the authors think we misread line 111

We would like to know. The quotation is literal and the source hash is above; `PaperTheorem` captures the paper's O definition and the statement of Theorem 1.1, while the line-180 passage is a textual comparison. If the authors believe Definition 2.1 should be read differently, or if v2 changes it, please point to the specific line; we will re-check against v2 and mark the result as “against v1”.

## 4. What was machine-checked

The eight theorems live in `Goldbach/Gap.lean`; the `#check` and `#print axioms` commands are in `Goldbach/GapChecks.lean`. The list:

| # | Lean theorem | Statement |
|---|---|---|
| 1 | `binaryGoldbach_implies_chen` | 1+1 ⇒ Chen 1+2 |
| 2 | `binaryGoldbach_implies_onePlusOneNine` | 1+1 ⇒ Li–Liu 1+1.9 |
| 3 | `binaryGoldbach_implies_onePlusOne8938` | 1+1 ⇒ Wu 1+1.8938 |
| 4 | `chen_second_summand_class_includes_composite` | Chen's predicate admits a composite second summand (`4 = 2·2`) |
| 5 | `liu_multiplier_class_includes_nontrivial` | Li–Liu's predicate admits `r = 3 ≠ 1` (`18 = 3 + 3·5`) |
| 6 | `wu_multiplier_class_includes_nontrivial` | Wu's predicate admits `r = 2 ≠ 1` (`13 = 7 + 2·3`) |
| 7 | `goldbachCount_pos_iff` | `0 < goldbachCount N` iff `N` is a sum of two primes |
| 8 | `paperTheorem_implies_binaryGoldbach` | Theorem 1.1 (under its O definition) ⇒ 1+1 |

There is also one **definitional check**, not counted among the eight:

```lean
live_one_plus_one_nine_has_shape : OnePlusOneNineShape :=
  Goldbach.one_plus_one_nine
```

It shows that `OnePlusOneNineShape` is not a hand-copied shape from a log; it is definitionally equal to the live endpoint. The check lives in a separate `GapLiveChecks.lean`, so `Goldbach.Gap` still depends only on `Goldbach.Statement` and Mathlib.

**Results** (logs under `goldbach/logs/`):

- every `#print axioms` is contained in `{propext, Classical.choice, Quot.sound}`;
- no `sorry`, `admit`, custom `axiom`, or `native_decide`;
- `leanchecker.exe Goldbach.Gap` replays successfully, exit 0;
- static check: 1,806 source modules, `issues: []`.

**Not checked:** Wu's 1+1.8938 endpoint shape is a verbatim transcription; `research/wu2008/` is a separate subproject and was not built here, so the Wu shape was not replayed by the kernel. Do not describe it as “kernel-checked”.

## 5. What we do not claim

This section is not modesty; it is the instruction manual for the work.

| Do not write | Fact | Write instead |
|---|---|---|
| “We proved Goldbach.” | No unconditional theorem concludes `BinaryGoldbach`. | “We proved that the three endpoints are consequences of 1+1; we did not prove 1+1.” |
| “The first / the first ever.” | No exhaustive search was done. | “To our knowledge (queries and dates in `PRIOR_ART.md`), no public formalization was found.” |
| “Wu 1.8938 is kernel-checked.” | The Wu subproject was not built. | “Wu's endpoint is a verbatim transcription and was not kernel-replayed.” |
| “goldbach-lean is our work.” | Upstream is `subfish-zhou/goldbach-lean` (Apache-2.0). | “We added four files and modified two; the rest is upstream's work.” |
| “Every step of the paper is wrong.” | We make specific claims about specific lines. | “There are specific problems at line 111 (the definition), line 180 (the ‘may assume’ listing of `G(2n)` and the `G(2n-2)` input), and line 222 (the `R₁` assertion).” |
| “We proved the endpoints cannot imply 1+1.” | The witnesses only show wider predicates. | “The representation predicates are strictly wider; this is not an independence proof.” |

**The hard content is C2, not C1.** `1+1 ⇒ 1+2` is a one-line mathematical observation. What carries information is: “under this specific preprint's own O definition, its Theorem 1.1 already implies 1+1, and the input at line 180 is the conclusion.” When someone says “everyone knows 1+2 is weaker”, move the emphasis to C2.

## 6. What this is for

This is not another Goldbach explainer. It matters on three levels:

1. **It turns common knowledge into an inspectable object.** That 1+2 / 1+1.9 / 1+1.8938 are weaker than 1+1 is common knowledge; but common knowledge is easily carried away by “almost a proof” narratives. A machine-checked implication makes any “endpoint ⇒ 1+1” leap immediately visible.
2. **It turns the circularity in a specific text into a checkable interface.** `PaperTheorem` connects the paper's O definition, its Theorem 1.1, and 1+1. The quotation at line 180 locates the circular step. If the authors issue a v2, or someone else cites the paper, there is a precise place to check.
3. **It anchors trust in the kernel, not in the author.** `leanchecker` does not care who wrote the proof, or which model suggested it. The axioms and dependencies are in the logs.

## 7. Verify it yourself in three commands

You do not have to trust this note. Follow the three layers in `VERIFY.md`:

**Layer 1: hashes** (from `goldbach/`)

```bash
sha256sum -c priority/MANIFEST.sha256
```

Expected: all 68 files in the current manifest `OK` (after a final reseal, use the count recorded in `TIMESTAMP.md`).

**Layer 2: timestamp**

```bash
openssl ts -verify -data priority/MANIFEST.sha256 \
  -in priority/MANIFEST.tsr \
  -CAfile priority/tsa/cacert.pem -untrusted priority/tsa/tsa.crt
```

Expected: `Verification: OK`. The certificate chain is pinned under `tsa/` and works offline.

**Layer 3: Lean kernel**

```bat
cd goldbach\frontier
python kernel_verify.py --checks Goldbach\GapChecks.lean ^
    --target Goldbach.Gap --log ..\logs\audit_gap_check_rerun.log
```

Expected: `RESULT: PASS`, `leanchecker` exit 0.

> A timestamp proves that these bytes existed at a certain time. It does not prove authorship or priority. The citable version is the one with the DOI.

## 8. Closing: not the pearl, the ruler

The binary Goldbach conjecture is still open. This work does not prove it, and does not pretend to.

But if “1+2 is not 1+1” and “this preprint's proof is circular” stop being water-cooler opinions and become objects with theorem names, axiom sets, kernel logs, hashes, and timestamps, then at least we have a ruler—**a ruler that separates pearls from glass beads**.

Corrections are welcome. The judge of mathematics is proof; the judge of proof is the kernel.

---

## Appendix: evidence and versions

- **Paper:** Khaled Qazaqzeh, Aymen Rawashdeh, *An Elementary Proof of the Binary Goldbach Conjecture*, arXiv:2611.09007v1, 6 November 2026, math.NT, 9 pages. License: CC BY 4.0.
- **Paper source hash:** `db1fa07154ae7430245d19ac377f6d22f02361608014498fe3449129c3765ffd` (SHA-256, see §3).
- **Lean toolchain:** Lean 4.33.0-rc1 + Mathlib (fixed by `lean-toolchain` and `lake-manifest.json`).
- **Upstream:** `subfish-zhou/goldbach-lean`, `main` at `9d4c3a4` (28 October 2026), Apache-2.0.
- **Added here:** `Goldbach/Gap.lean`, `Goldbach/GapChecks.lean`, `Goldbach/GapLiveChecks.lean`, `docs/GAP.md`; modified `MathlibNt/SieveTheory/LiLiuGoldbachG12FlexibleWF.lean` and `scripts/check.py`.
- **Evidence logs:** `goldbach/logs/audit_gap_check_rerun.log`, `audit_live_shape_check.log`, `audit_chen_check_rerun.log`, `audit_liliu_check_rerun.log`, `static_check_2026-11-15.log`; the post-seal replay is in `reverify_2026-11-15_postseal.log` (not part of this seal; supplementary evidence).
- **Seal:** `goldbach/priority/`; RFC 3161 token sealed at 2026-11-16 23:56:44 UTC (token time 23:56:45 UTC); the manifest has 68 files.
- **Repository:** {{REPO_URL}}　**DOI:** 10.5281/zenodo.24270135
- **Authors:** 宋敏, 宋瑷成, 宋奥菲, 范钧睿, 胡安, 涂源　**Date:** {{DATE}}
- **AI disclosure:** The derivations, audit, and drafting in this workspace were performed by a local DeepSeek Harness (DSH) instance. The final criterion for the mathematical claims is the Lean 4 kernel, not any model's self-report.
