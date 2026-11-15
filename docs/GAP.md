# The 1+1 gap, machine-checked

`Goldbach/Gap.lean` turns the difference between the headline endpoints of this
repository and the binary Goldbach conjecture into kernel-checkable theorems.
`Goldbach/GapChecks.lean` restates them and prints their axiom sets.

## What is proved

| Declaration | Statement |
|---|---|
| `Goldbach.BinaryGoldbach` | every sufficiently large even `N` is `p + q` with `p`, `q` prime |
| `Goldbach.binaryGoldbach_implies_chen` | `BinaryGoldbach → ChenTheorem` |
| `Goldbach.binaryGoldbach_implies_onePlusOneNine` | `BinaryGoldbach → OnePlusOneNineShape` |
| `Goldbach.binaryGoldbach_implies_onePlusOne8938` | `BinaryGoldbach → OnePlusOne8938Shape` |
| `Goldbach.chen_second_summand_class_includes_composite` | the Chen predicate admits `q = 4 = 2 * 2`, which is not prime |
| `Goldbach.liu_multiplier_class_includes_nontrivial` | `18 = 3 + 3 * 5` is a Li-Liu representation with `r = 3 != 1` |
| `Goldbach.wu_multiplier_class_includes_nontrivial` | `13 = 7 + 2 * 3` is a Wu representation with `r = 2 != 1` |
| `Goldbach.goldbachCount_pos_iff` | `0 < goldbachCount N` iff `N` is a sum of two primes |
| `Goldbach.live_one_plus_one_nine_has_shape` | the live Li-Liu endpoint proves the transcribed `OnePlusOneNineShape` (definitional unfolding; in `GapLiveChecks.lean`) |
| `Goldbach.PaperTheorem` | Theorem 1.1 of `A_Simple_Proof_of_Goldbach_Conjecture.tex` under the paper's own `O` definition |
| `Goldbach.paperTheorem_implies_binaryGoldbach` | `PaperTheorem → BinaryGoldbach` |

The three implication theorems substitute `r = 1` (or `q` prime in Chen's case):
they show that the headline endpoints are *consequences* of 1+1. The three
witness theorems show that the endpoint predicates genuinely contain objects
that 1+1 forbids (a composite second summand, a nontrivial multiplier).

The theorem `paperTheorem_implies_binaryGoldbach` is the formal form of Section
3.1 of the audit: under the paper's definition of `O` (a limit ratio equal to a
nonzero constant), Theorem 1.1 already forces a positive number of Goldbach
pairs for every sufficiently large even number. The induction step that assumes
`G(2n-2) > 0` therefore assumes the conclusion, not a weaker hypothesis.

## What is not proved

The binary Goldbach conjecture itself is not proved here. No converse
(`ChenTheorem -> BinaryGoldbach` or `OnePlusOneNineShape -> BinaryGoldbach`) is
proved, and none should be expected: Chen's theorem is already a theorem, so
such a converse would settle Goldbach. The witness theorems are statements
about the representation predicates, not a formal independence proof.

The shapes `OnePlusOneNineShape` and `OnePlusOne8938Shape` are transcribed
verbatim from `Goldbach/OnePlusOneNine.lean` and
`research/wu2008/src/WR2ClassicalCertificate.lean`; the prior `#check` output in
`goldbach/logs/audit_liliu_check.log` shows the same Li-Liu type.

The Li-Liu transcription is now machine-checked against the live endpoint:
`Goldbach/GapLiveChecks.lean` proves `OnePlusOneNineShape` directly from
`Goldbach.one_plus_one_nine` by definitional unfolding, and its kernel replay
passes with axioms contained in `{propext, Classical.choice, Quot.sound}`; see
`goldbach/logs/audit_live_shape_check.log`. That file is deliberately separate
from `GapChecks.lean`, so the self-contained check keeps no dependency on the
sieve build. The Wu shape remains transcription-only: its subproject under
`research/wu2008/` has no `.olean` artifacts here and was not rebuilt.

## Reproduce

```text
# from goldbach/frontier/goldbach-lean
lake build Goldbach.Gap

# from goldbach/frontier
python build_local.py --target Goldbach.OnePlusOneNine --workers 4 --lean-threads 1
python kernel_verify.py --checks Goldbach/GapChecks.lean \
    --target Goldbach.Gap --log ../logs/audit_gap_check_rerun.log

# live-endpoint definitional check (needs the sieve closure from above)
python build_local.py --target Goldbach.GapLiveChecks --workers 4 --lean-threads 1
python kernel_verify.py --checks Goldbach/GapLiveChecks.lean \
    --target Goldbach.GapLiveChecks --log ../logs/audit_live_shape_check.log
```

`Goldbach.Gap` imports only `Goldbach.Statement` and Mathlib, so its kernel
check does not depend on the large sieve development. The checks recorded here
produced `RESULT: PASS` with axioms contained in
`{propext, Classical.choice, Quot.sound}`; see
`goldbach/logs/audit_gap_check_rerun.log` and
`goldbach/logs/audit_live_shape_check.log`.
