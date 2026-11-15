import Goldbach.Gap

/-! # Literal checks for the 1+1 gap module

The gap module is self-contained: it imports only `Goldbach.Statement` and
Mathlib, so its kernel check does not depend on the large sieve development.
`OnePlusOneNineShape` and `OnePlusOne8938Shape` are transcribed verbatim from
`Goldbach/OnePlusOneNine.lean` and `research/wu2008/src/WR2ClassicalCertificate.lean`.
The definitional-equality check against the live Li-Liu endpoint is kept in a
comment below; it can be enabled once the full olean build of the sieve
development is available again.

The new theorems are printed with their axiom sets at the end of the file.
-/

namespace Goldbach.GapChecks

/- The live-endpoint definitional check now lives in
   `Goldbach/GapLiveChecks.lean`. It is kept separate on purpose: this file stays
   independent of the large sieve build. -/

/-- The paper's own hypothesis yields binary Goldbach. -/
example : PaperTheorem → BinaryGoldbach := paperTheorem_implies_binaryGoldbach

/-- Binary Goldbach yields the literal Li-Liu shape. -/
example : BinaryGoldbach → OnePlusOneNineShape := binaryGoldbach_implies_onePlusOneNine

/-- Binary Goldbach yields the literal Wu shape. -/
example : BinaryGoldbach → OnePlusOne8938Shape := binaryGoldbach_implies_onePlusOne8938

end Goldbach.GapChecks

#check @Goldbach.ChenTheorem
#check @Goldbach.BinaryGoldbach
#check @Goldbach.OnePlusOneNineShape
#check @Goldbach.OnePlusOne8938Shape
#check @Goldbach.binaryGoldbach_implies_chen
#check @Goldbach.binaryGoldbach_implies_onePlusOneNine
#check @Goldbach.binaryGoldbach_implies_onePlusOne8938
#check @Goldbach.chen_second_summand_class_includes_composite
#check @Goldbach.liu_multiplier_class_includes_nontrivial
#check @Goldbach.wu_multiplier_class_includes_nontrivial
#check @Goldbach.goldbachCount_pos_iff
#check @Goldbach.paperTheorem_implies_binaryGoldbach

#print axioms Goldbach.binaryGoldbach_implies_chen
#print axioms Goldbach.binaryGoldbach_implies_onePlusOneNine
#print axioms Goldbach.binaryGoldbach_implies_onePlusOne8938
#print axioms Goldbach.chen_second_summand_class_includes_composite
#print axioms Goldbach.liu_multiplier_class_includes_nontrivial
#print axioms Goldbach.wu_multiplier_class_includes_nontrivial
#print axioms Goldbach.goldbachCount_pos_iff
#print axioms Goldbach.paperTheorem_implies_binaryGoldbach
