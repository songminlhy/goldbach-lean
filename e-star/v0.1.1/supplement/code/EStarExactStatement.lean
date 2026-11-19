import EStarBasisFromLev
import Mathlib.Data.Nat.Find

/-!
The paper's actual least-positive-nondivisor parameter, with an exact wrapper
around the previously checked conditional inverse theorem. No new mathematical
assumption is introduced, and LevGrowthInput remains explicit.
-/

namespace EStarExactStatement

theorem positive_nondivisor_exists (s : ℕ) (hs : 0 < s) :
    ∃ q : ℕ, 0 < q ∧ ¬ q ∣ s := by
  refine ⟨s + 1, by omega, ?_⟩
  exact Nat.not_dvd_of_pos_of_lt hs (by omega)

/-- The least positive natural number that does not divide the positive s. -/
noncomputable def leastNondivisor (s : ℕ) (hs : 0 < s) : ℕ :=
  Nat.find (positive_nondivisor_exists s hs)

theorem leastNondivisor_spec (s : ℕ) (hs : 0 < s) :
    0 < leastNondivisor s hs ∧ ¬ leastNondivisor s hs ∣ s ∧
      ∀ a : ℕ, 0 < a → a < leastNondivisor s hs → a ∣ s := by
  have hspec := Nat.find_spec (positive_nondivisor_exists s hs)
  refine ⟨hspec.1, hspec.2, ?_⟩
  intro a ha hlt
  by_contra hnot
  have hle : leastNondivisor s hs ≤ a :=
    Nat.find_min' (positive_nondivisor_exists s hs) ⟨ha, hnot⟩
  omega

theorem leastNondivisor_ge_two (s : ℕ) (hs : 0 < s) :
    2 ≤ leastNondivisor s hs := by
  obtain ⟨hpos, hnot, _⟩ := leastNondivisor_spec s hs
  by_contra h
  have hq : leastNondivisor s hs = 1 := by omega
  exact hnot (by simp [hq])

/-- Useful for exact identification without evaluating an abstract Nat.find. -/
theorem leastNondivisor_eq_of_spec (s : ℕ) (hs : 0 < s) (q : ℕ)
    (hq : 0 < q) (hqnot : ¬ q ∣ s)
    (hsmall : ∀ a : ℕ, 0 < a → a < q → a ∣ s) :
    leastNondivisor s hs = q := by
  apply Nat.le_antisymm
  · exact Nat.find_min' (positive_nondivisor_exists s hs) ⟨hq, hqnot⟩
  · obtain ⟨hpos, hnot, _⟩ := leastNondivisor_spec s hs
    by_contra h
    exact hnot (hsmall _ hpos (by omega))

/-- Exactly the paper's q=snd(s), uniform T0, distinct nonempty subset and H.
Lev's classical growth theorem is still an explicit parameter. -/
theorem main_inverse_at_leastNondivisor
    (hLev : EStarBasisFromLev.LevGrowthInput)
    (s : ℕ) (hs : 0 < s) (ε : ℝ) (hε : 0 < ε) :
    let q := leastNondivisor s hs
    ∃ T₀ : ℕ, ∀ T : ℕ, T₀ ≤ T → ∀ E : ℕ, 1 ≤ E →
      ∀ A : Finset ℕ, A ⊆ Finset.Icc 1 E →
        (q - 1) * E ≤ s * T → (E : ℝ) / q + ε * T ≤ (A.card : ℝ) →
        ∃ X : Finset ℕ, X.Nonempty ∧ X ⊆ A ∧
          X.card ≤ (q - 1) * (⌈2 * (s : ℝ) / ε⌉₊ + 1) ∧
          (∑ x ∈ X, x) = s * T := by
  dsimp only
  exact EStarBasisFromLev.main_inverse_relative_to_lev hLev s
    (leastNondivisor s hs) hs (leastNondivisor_ge_two s hs)
    (leastNondivisor_spec s hs).2.2 ε hε

theorem leastNondivisor_six : leastNondivisor 6 (by norm_num) = 4 := by
  apply leastNondivisor_eq_of_spec 6 (by norm_num) 4 (by norm_num) (by norm_num)
  intro a ha hlt
  interval_cases a <;> norm_num

#print axioms positive_nondivisor_exists
#print axioms leastNondivisor_spec
#print axioms leastNondivisor_ge_two
#print axioms leastNondivisor_eq_of_spec
#print axioms main_inverse_at_leastNondivisor
#print axioms leastNondivisor_six

end EStarExactStatement
