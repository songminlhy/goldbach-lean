import Mathlib.Tactic

/-!
Local algebraic checks of the proposed assembly.  These theorems take the
cardinality inequalities as hypotheses. They do not formalize Lev's theorem,
Roth's theorem, distinctification, or the final asymptotic limit.
-/

namespace EStarAssembly

theorem scaled_increment
    (L n q h : ℝ) (hq : 1 ≤ q) (hL : q ≤ L)
    (hh : 0 ≤ h) (hhq : h + 1 ≤ q) (hdensity : L ≤ q * (n - 2)) :
    h * L + q ≤ q * min L (h * (n - 2) + 1) := by
  by_cases hm : L ≤ h * (n - 2) + 1
  · rw [min_eq_left hm]
    have hprod : 0 ≤ (q - h - 1) * L :=
      mul_nonneg (by linarith) (by linarith)
    nlinarith
  · rw [min_eq_right (le_of_not_ge hm)]
    have hprod : 0 ≤ h * (q * (n - 2) - L) :=
      mul_nonneg hh (by linarith)
    nlinarith

theorem triple_sumset_card_bound
    (L n n₂ n₃ : ℝ) (hL : 4 ≤ L) (hdensity : L / 4 + 2 ≤ n)
    (h₂ : n + min L (2 * n - 3) ≤ n₂)
    (h₃ : n₂ + min L (3 * n - 5) ≤ n₃) :
    3 * L / 2 + 4 ≤ n₃ := by
  have hi₂ : L / 2 + 1 ≤ min L (2 * n - 3) :=
    le_min (by linarith) (by linarith)
  have hi₃ : 3 * L / 4 + 1 ≤ min L (3 * n - 5) :=
    le_min (by linarith) (by linarith)
  linarith

theorem triple_central_radius
    (L n₃ : ℝ) (hcard : 3 * L / 2 + 4 ≤ n₃) :
    6 * L + 2 - 2 * n₃ ≤ 3 * L - 6 := by
  linarith

#print axioms scaled_increment
#print axioms triple_sumset_card_bound
#print axioms triple_central_radius

end EStarAssembly
