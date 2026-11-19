# lg-v0.3.2 — Liouville–Goldbach: complete proof and the logical boundary with Goldbach

**Preprint v0.3.2, not peer reviewed. Proves LG; does not prove GC.**

> v0.2.0 was the first public version; it withdrew the v1 audit claim about the "multiples of four" manuscript. v0.3.0 added the prior independent audit, a Lean certificate for the \(p=7\) case, an \(\Omega\)-hierarchy theorem, and an "indirect value" section. v0.3.1 adds `IntervalLemma.lean`, which kernel-checks that the interval \((p/6,p/4)\) is non-empty for every prime \(p\ge11\); the sealed manifest grows from 103 to 104 files and the paper from 28 to 29 pages. v0.3.2 is a text-only correction and prior-art completion with no new mathematical claims: it fixes the conditional-bridge quantifier, qualifies the Mangerel threshold, cites the stronger 25 September 2026 MathOverflow result, and states the AI-provenance position; the sealed manifest remains 104 files and the paper is now 30 pages. v0.3.0 stays unchanged and independently verifiable at DOI `10.5281/zenodo.24306341`. v1 was never sealed or published.

This file records v0.3.2 and retains the v0.3.1 record below. The v0.3.2 archive is prepared locally; the GitHub tag/Release and the Zenodo version are external actions still pending.

- DOI: [10.5281/zenodo.24309847](https://doi.org/10.5281/zenodo.24309847) (v0.3.1 version DOI; the v0.3.2 version DOI is assigned on upload)
- Tag: `lg-v0.3.2` (to be created on upload; the Lean sources are unchanged from the v0.3.1 snapshot at commit `51eabc1bb9cd23ce9394d50f81ad431aa8c4e93f`)
- Paper: 30 pages, Chinese, with English abstract
- Evidence: 104-file SHA-256 manifest + FreeTSA RFC 3161 timestamp

## What this is

A self-contained elementary proof of the Liouville–Goldbach theorem (LG):

> every even \(N>2\) is a sum of two positive integers at which the Liouville function equals \(-1\),

together with an audit of the two September 2026 manuscripts and a machine-checked account of the logical boundary:

\[
  \mathrm{GC}\iff \mathrm{LG}_{\Omega\le2}.
\]

The proof does not use Mangerel's correlation bound and does not use GRH. We repair the \(p=7\) empty-interval boundary in the commuting-square step. We audit the 16 September general manuscript (main line correct; \(p=7\) is a written boundary, covered by the Lean cases) and the 15 September "multiples of four" manuscript.

## What is new in v0.3.1

1. **Interval non-emptiness is kernel-checked.** The new module `frontier/goldbach-lean/IntervalLemma.lean` proves

   ```
   LiouvilleGoldbach.exists_nat_between_sixth_and_fourth
     {p : ℕ} (hp : p.Prime) (h11 : 11 ≤ p) : ∃ n : ℕ, p < 6 * n ∧ 4 * n < p
   ```

   with `n = p / 4`. This is the \(p\ge11\) side of the commuting-square step; the \(p=7\) side was already the certificate `positive_prime_pairs_seven`. `lake env lean IntervalLemma.lean` returns 0 and the axiom set is `{propext, Classical.choice, Quot.sound}`.
2. **The paper states the result in five places.** §1.2 (contribution 2), §3.4 (the remark on the empty interval), §5.2 (Lean recheck), appendix A (the theorem type), appendix B (the raw `IL_RC=0` output) and appendix C (one checklist row). LG and GC claims are unchanged; the paper is now 29 pages.
3. **The seal grows to 104 files.** `files.txt` gains exactly one path, `frontier/goldbach-lean/IntervalLemma.lean`. The v0.3.0 seal (103 files, manifest `76f7bfd2…`, tag `lg-v0.3.0`) is not touched, so v0.3.0 remains independently verifiable exactly as published.

## What is new in v0.3.2

**Text-only corrections and prior-art completion; no new mathematical claims.**

1. **Conditional-bridge quantifier.** Proposition `prop:bridge` now reads: every even \(N>2\) has *one* LG representation whose two summands both satisfy \(\Omega\le2\); it no longer says that every representation has this property. The surrounding sentence now says the proposition does not supply such a representation.
2. **Mangerel version qualifier.** The Chinese and English abstracts and the conclusion now record that we checked only the published IMRN abstract (\(N\ge11\)), not the published body line by line, and that the ineffective arXiv-v2 \(N_0\) must not be substituted for the published threshold.
3. **Stronger prior result cited.** Section 1.2 now records the 25 September 2026 MathOverflow answer by L. Meng (answer 515534), which states unconditionally that for every \(N\notin\{2,3,4,5,6,9,10\}\) all four sign pairs occur in decompositions \(N=a+b\), and credits the even case (proof and Lean formalization) to an anonymous upstream author. The paper states that it does not address that stronger result, makes no priority claim, and did not check its proof line by line.
4. **AI-provenance position.** A new section "AI use and upstream attribution" records that the audit, drafting and packaging were done with a local DeepSeek Harness (DSH) instance, and that the audited upstream snapshots (checked 2026-11-18) contain no AI-tool disclosure; the paper draws no inference about upstream tooling and asserts no unverified third-party AI attribution.
5. **No new mathematics.** LG, the \(\mathrm{GC}\iff\mathrm{LG}_{\Omega\le2}\) equivalence and every Lean statement are unchanged. The sealed manifest remains 104 files; the v0.3.1 seal and tag are not rewritten. The paper is 30 pages.

## What is new in v0.3.0 (retained)

1. **Prior independent audit cited.** `sunnyspot114514/Liouville-Goldbach-audit` (2026-09-17) already performed an independent full Lean replay of upstream B v1.0.0 (2907 jobs, PASS, the three standard axioms, statement match, numeric 4..500). This paper does **not** claim to be the first independent replay; its increment is the \(p=7\) written patch, the \(\Omega\) certificate, and the public correction.
2. **Lean certificate for \(p=7\).** `positive_prime_pairs_seven` proves \(14=4+10\) with both Liouville values \(+1\), making the written patch a kernel-checked fact.
3. **\(\Omega\) hierarchy.** `binary_goldbach_implies_omega_le` proves \(\mathrm{GC}\Rightarrow\mathrm{LG}_{\Omega\le k}\) for every \(k\ge2\); the existing \(k=2\) equivalence is the special case.
4. **Indirect value.** A short section on research-integrity templates, formalization cost, teaching, and the v1\(\to\)v2 correction record. No quantitative economic claim is made.

## The v2 audit correction (retained)

The first version of the paper claimed that the "multiples of four" manuscript misquoted Mangerel's theorem by replacing \(\exists N_0\) with \(\forall m\ge11\). **That claim is withdrawn.**

- The manuscript cites the **published IMRN version** (DOI `10.1093/imrn/rnae149`), whose abstract states the bound **for all \(N\ge11\)** (Crossref, checked 2026-11-17).
- **arXiv v2** (`2404.12117v2`) states it only for **sufficiently large \(N\)**, with an ineffective \(N_0\).
- The manuscript's own `lean/SOURCE-AUDIT.md` already records this threshold. The two versions must not be conflated.
- The published full text was not obtained; only the Crossref abstract and the manuscript's source audit are used as version evidence.

## Machine and finite evidence

- Lean 4.33.0-rc1; Mathlib `e4c91783ca8e6a7c693ae624ade32fd22d4e43c1`.
- Upstream 9-module rebuild: 2851 jobs (`liouville_paper/verification/lean_general_build_v433.log`).
- `GapCertificate.lean`: rc 0; `positive_prime_pairs_seven` and `binary_goldbach_implies_omega_le` depend only on `propext`, `Classical.choice`, `Quot.sound`.
- `LiouvilleAudit.lean`: rc 0; main theorem `LiouvilleGoldbach.liouville_goldbach` depends only on the same three axioms.
- `IntervalLemma.lean` (v0.3.1): rc 0; `exists_nat_between_sixth_and_fourth` depends only on the same three axioms.
- Finite check to \(5\times10^6\): 2,499,999 even numbers, 1,250,000 multiples of four, 667 prime pairs, 250,000 multiplicativity pairs, 0 failures.

## Assets

| Asset | What it is |
|---|---|
| `lg-v0.3.1-draft.tar.gz` | Self-contained package: paper, verification, Lean sources, upstream snapshots, seal (104 files) |
| `lg-v0.3.1-draft.tar.gz.sha256` | SHA-256 of the package |

Additional review bundles (`lg-v0.3.1-circulation-20261117.zip`, `lg-v0.3.1-history-20261117.zip`) are in the Zenodo record and the local `postseal/release/` directory.

## Verify

```bash
sha256sum -c liouville_priority/MANIFEST.sha256
openssl ts -verify -data liouville_priority/MANIFEST.sha256 \
  -in liouville_priority/MANIFEST.tsr \
  -CAfile liouville_priority/tsa/cacert.pem -untrusted liouville_priority/tsa/tsa.crt
```

Expected: every listed file `OK`; `Verification: OK`.

## What is not claimed

- Does not prove binary Goldbach; GC remains open.
- No priority claim; the LG route and the Lean development come from the September 2026 upstream manuscripts.
- **Not the first independent Lean replay**: `sunnyspot114514/Liouville-Goldbach-audit` (2026-09-17) precedes this paper.
- "No gap found" is an audit conclusion, not peer review.
- The finite check is not a universal proof.
- The published Mangerel proof was not re-verified line by line; only its abstract was used for the version comparison.
- The interval lemma is an arithmetic fact about \((p/6,p/4)\), not a new proof of LG.

## License and AI disclosure

Prose and data: CC BY 4.0. Lean sources: Apache-2.0; upstream notices retained.

The audit, drafting, packaging and verification were performed with a local DeepSeek Harness (DSH) instance; the authors set the goals, provided the environment and decided to publish. The final criterion for the mathematical claims is the Lean 4 kernel and the cited published theorem.
