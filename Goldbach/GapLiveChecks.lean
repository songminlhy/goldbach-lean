import Goldbach.Gap
import Goldbach.OnePlusOneNine

/-!
# Live-endpoint check for the transcribed 1+1.9 shape

`Goldbach.Gap` transcribes the Li-Liu endpoint as `OnePlusOneNineShape` without
importing the large sieve development, so the gap theorems stay independently
kernel-checkable. This file is the other half of that claim: with the full olean
closure of `Goldbach.OnePlusOneNine` restored, it checks that the live endpoint
proves the transcribed shape by definitional unfolding.

It is deliberately separate from `Goldbach/GapChecks.lean`: the self-contained
check must not acquire a dependency on the sieve build.
-/

namespace Goldbach.GapLiveChecks

/-- The live Li-Liu endpoint is a proof of the transcribed shape. The `def`
`OnePlusOneNineShape` unfolds definitionally to the type of
`Goldbach.one_plus_one_nine`, so this is a definitional-equality check, not a
new mathematical assumption. -/
theorem live_one_plus_one_nine_has_shape : OnePlusOneNineShape :=
  Goldbach.one_plus_one_nine

end Goldbach.GapLiveChecks

#print axioms Goldbach.GapLiveChecks.live_one_plus_one_nine_has_shape
