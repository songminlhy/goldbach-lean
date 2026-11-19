import UpstreamDenseCovering
import EStarConditionalMain

/-!
# The exact remaining external input reduced to Lev's growth theorem

`LevGrowthInput` is a full, genuine repeated-sumset cardinality theorem.
It is not an interval-covering or inverse theorem in disguise. The proof below
uses it to derive the q-1 half-density bound, then proves the actual central
coverage and flattening needed by GeneralBasisInput.
-/

namespace EStarBasisFromLev

open scoped Pointwise
open Erdos361Covering EStarFiniteMain EStarConditionalMain

/-- A computable finite set of all exactly h-fold sums, allowing repetition. -/
def sums (B : Finset ℕ) : ℕ → Finset ℕ
  | 0 => {0}
  | h + 1 => B + sums B h

theorem mem_sums_iff (B : Finset ℕ) (h x : ℕ) :
    x ∈ sums B h ↔ hfold B h x := by
  induction h generalizing x with
  | zero =>
    constructor
    · intro hx
      have hx0 : x = 0 := by simpa [sums] using hx
      rw [hx0]
      exact hfold_zero B
    · rintro ⟨f, hf, hs⟩
      have hx0 : x = 0 := by simpa using hs.symm
      simp [sums, hx0]
  | succ n ih =>
    constructor
    · intro hx
      obtain ⟨b, hb, y, hy, hby⟩ := Finset.mem_add.mp hx
      rw [← hby]
      exact hfold_cons hb ((ih y).mp hy)
    · intro hx
      obtain ⟨b, hb, y, hy, hby⟩ := hfold_uncons hx
      exact Finset.mem_add.mpr ⟨b, hb, y, (ih y).mpr hy, hby⟩

theorem sums_one (B : Finset ℕ) : sums B 1 = B := by
  ext x
  simp [sums, Finset.mem_add]

/-- All actual h-fold sums lie in the geometrically correct interval. -/
theorem sums_subset (B : Finset ℕ) (L h : ℕ) (hB : B ⊆ Finset.Icc 0 L) :
    sums B h ⊆ Finset.Icc 0 (h * L) := by
  intro x hx
  obtain ⟨f, hf, rfl⟩ := (mem_sums_iff B h x).mp hx
  refine Finset.mem_Icc.mpr ⟨Nat.zero_le _, ?_⟩
  calc
    (∑ i, f i) ≤ ∑ _i : Fin h, L := Finset.sum_le_sum (fun i _ => (Finset.mem_Icc.mp (hB (hf i))).2)
    _ = h * L := by simp

theorem zero_mem_sums (B : Finset ℕ) (h : ℕ) (h0 : 0 ∈ B) :
    0 ∈ sums B h := by
  apply (mem_sums_iff B h 0).mpr
  exact ⟨fun _ => 0, fun _ => h0, by simp⟩

theorem top_mem_sums (B : Finset ℕ) (L h : ℕ) (hL : L ∈ B) :
    h * L ∈ sums B h := by
  apply (mem_sums_iff B h (h * L)).mpr
  exact ⟨fun _ => L, fun _ => hL, by simp⟩

/-- Genuine Lev 1996 growth interface; all cardinals are actual finite sumsets.
This proposition remains an explicit mathematical parameter, not an axiom. -/
def LevGrowthInput : Prop :=
  ∀ (B : Finset ℕ) (L : ℕ), 1 ≤ L → B ⊆ Finset.Icc 0 L →
    0 ∈ B → L ∈ B → B.gcd id = 1 →
    ∀ j : ℕ, 2 ≤ j →
      ((sums B (j - 1)).card : ℝ) +
        min (L : ℝ) ((j : ℝ) * ((B.card : ℝ) - 2) + 1) ≤
          ((sums B j).card : ℝ)

/-- The full finite iteration for every q, using actual repeated-sumset sizes. -/
theorem half_density_from_lev (hLev : LevGrowthInput)
    (B : Finset ℕ) (q L : ℕ) (hq : 2 ≤ q) (hL : q ≤ L)
    (hB : B ⊆ Finset.Icc 0 L) (h0 : 0 ∈ B) (hLB : L ∈ B)
    (hgcd : B.gcd id = 1) (hN : (L : ℝ) / q + 2 ≤ (B.card : ℝ)) :
    (q - 1 : ℕ) * L + 2 * q ≤ 2 * (sums B (q - 1)).card := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast (show 0 < q by omega)
  have hL0 : (0 : ℝ) ≤ L := by positivity
  have hLq : (q : ℝ) ≤ L := by exact_mod_cast hL
  have hNmul : (L : ℝ) + 2 * q ≤ q * (B.card : ℝ) := by
    have h := (div_le_iff₀ hq0).mp (show (L : ℝ) / q ≤ (B.card : ℝ) - 2 by linarith)
    nlinarith
  have hstep : ∀ j : ℕ, 2 ≤ j → j < q →
      (j : ℝ) * L + q ≤ q *
        min (L : ℝ) ((j : ℝ) * ((B.card : ℝ) - 2) + 1) := by
    intro j hj2 hjq
    have hjq' : (j : ℝ) + 1 ≤ q := by exact_mod_cast hjq
    have hj0 : (0 : ℝ) ≤ j := by positivity
    have hleft : (j : ℝ) * L + q ≤ q * (L : ℝ) := by nlinarith
    have hright : (j : ℝ) * L + q ≤ q * ((j : ℝ) * ((B.card : ℝ) - 2) + 1) := by
      have h := mul_le_mul_of_nonneg_left hNmul hj0
      nlinarith
    rw [mul_min_of_nonneg _ _ (le_of_lt hq0)]
    exact le_min hleft hright
  have hiter : ∀ k : ℕ, 1 ≤ k → k < q →
      (k : ℝ) * (k + 1) * L + 2 * q * (k + 1) ≤
        2 * q * ((sums B k).card : ℝ) := by
    intro k
    induction k with
    | zero => intro hk; omega
    | succ k ih =>
      intro hk hjq
      by_cases hk0 : k = 0
      · subst k
        norm_num [sums_one]
        nlinarith
      · have hk1 : 1 ≤ k := by omega
        have hkq : k < q := by omega
        have hprev := ih hk1 hkq
        have hgrowth := hLev B L (by omega) hB h0 hLB hgcd (k + 1) (by omega)
        simp only [Nat.add_sub_cancel] at hgrowth
        have hinc := hstep (k + 1) (by omega) hjq
        push_cast at hgrowth hinc ⊢
        have hmul := mul_le_mul_of_nonneg_left hgrowth (show (0 : ℝ) ≤ 2 * q by positivity)
        nlinarith
  have hrq : q - 1 < q := by omega
  have hr1 : 1 ≤ q - 1 := by omega
  have hfinal := hiter (q - 1) hr1 hrq
  have hrplus : ((q - 1 : ℕ) : ℝ) + 1 = q := by exact_mod_cast (show q - 1 + 1 = q by omega)
  rw [hrplus] at hfinal
  have hreal : ((q - 1 : ℕ) : ℝ) * L + 2 * q ≤ 2 * ((sums B (q - 1)).card : ℝ) := by
    nlinarith
  exact_mod_cast hreal

/-- Flatten an h-fold sum of actual r-fold sums into an (r*h)-fold sum. -/
theorem hfold_flatten (B : Finset ℕ) (r h x : ℕ)
    (hx : hfold (sums B r) h x) : hfold B (r * h) x := by
  induction h generalizing x with
  | zero =>
    obtain ⟨f, hf, hs⟩ := hx
    have hx0 : x = 0 := by simpa using hs.symm
    simpa [hx0] using hfold_zero B
  | succ n ih =>
    obtain ⟨c, hc, y, hy, hcy⟩ := hfold_uncons hx
    have hfirst := (mem_sums_iff B r c).mp hc
    have hrest := ih y hy
    have hall := hfold_add hfirst hrest
    exact hfold_congr (by ring) hcy hall

/-- An actual h-fold representation gives the multiset interface used upstream. -/
theorem hfold_to_multiset (B : Finset ℕ) (h x : ℕ) (hx : hfold B h x) :
    ∃ u : Multiset ℕ, (∀ a ∈ u, a ∈ B) ∧ u.card ≤ h ∧ u.sum = x := by
  obtain ⟨f, hf, hsum⟩ := hx
  let u := (Finset.univ : Finset (Fin h)).val.map f
  refine ⟨u, ?_, ?_, ?_⟩
  · intro a ha
    obtain ⟨i, hi, rfl⟩ := Multiset.mem_map.mp ha
    exact hf i
  · simp [u]
  · simpa [u, Finset.sum] using hsum

/-- The full general additive basis theorem, with only Lev's external
cardinality-growth theorem left as a parameter. -/
theorem general_basis_from_lev (hLev : LevGrowthInput) (q : ℕ) (hq : 2 ≤ q) :
    GeneralBasisInput q := by
  intro B L K hL hB h0 hLB hgcd hN y hylo hyhi
  let r := q - 1
  let C := sums B r
  let D := r * L
  have hr : 1 ≤ r := by dsimp [r]; omega
  have hLD : L ≤ D := by dsimp [D]; nlinarith
  have hDpos : 0 < D := Nat.mul_pos (by omega) (by omega)
  have hCsub : C ⊆ Finset.Icc 0 D := sums_subset B L r hB
  have hC0 : 0 ∈ C := zero_mem_sums B r h0
  have hCD : D ∈ C := top_mem_sums B L r hLB
  have hhalf : D + 2 * q ≤ 2 * C.card := half_density_from_lev hLev B q L hq hL hB h0 hLB hgcd hN
  have hC3 : 3 ≤ C.card := by omega
  have hdense : D ≤ 2 * C.card - 4 := by omega
  have hClim : C.card ≤ D + 1 := by simpa using Finset.card_le_card hCsub
  have hgamma : 2 * D + 2 - 2 * C.card ≤ D := by omega
  have hK1 : 1 ≤ K := by
    by_contra h
    have hK0 : K = 0 := by omega
    simp [hK0] at hyhi
    dsimp [D, r] at hDpos
    omega
  have hlow : 2 * D + 2 - 2 * C.card ≤ y := by
    have : D ≤ y := hylo
    omega
  have hhigh : y ≤ (K + 1) * D - (2 * D + 2 - 2 * C.card) := by
    have hKLD := Nat.mul_le_mul_left K hLD
    have hbound : y + (2 * D + 2 - 2 * C.card) ≤ K * D + D := by omega
    have heq : (K + 1) * D = K * D + D := by ring
    omega
  have hcov := lemma2_dense C D hCsub hC0 hCD hC3 hdense (K + 1) (by omega) y hlow hhigh
  have hflat := hfold_flatten B r (K + 1) y hcov
  exact hfold_to_multiset B (r * (K + 1)) y hflat

/-- Conditional main theorem with the remaining input now reduced to Lev. -/
theorem main_inverse_relative_to_lev
    (hLev : LevGrowthInput) (s q : ℕ) (hs : 0 < s) (hq2 : 2 ≤ q)
    (hq : ∀ a : ℕ, 0 < a → a < q → a ∣ s)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ T₀ : ℕ, ∀ T : ℕ, T₀ ≤ T → ∀ E : ℕ, 1 ≤ E →
      ∀ A : Finset ℕ, A ⊆ Finset.Icc 1 E →
        (q - 1) * E ≤ s * T → (E : ℝ) / q + ε * T ≤ (A.card : ℝ) →
        ∃ X : Finset ℕ, X.Nonempty ∧ X ⊆ A ∧
          X.card ≤ (q - 1) * (⌈2 * (s : ℝ) / ε⌉₊ + 1) ∧
          (∑ x ∈ X, x) = s * T := by
  exact main_inverse_relative_to_basis s q hs hq2 hq
    (general_basis_from_lev hLev q hq2) ε hε

#print axioms mem_sums_iff
#print axioms sums_one
#print axioms sums_subset
#print axioms zero_mem_sums
#print axioms top_mem_sums
#print axioms half_density_from_lev
#print axioms hfold_flatten
#print axioms hfold_to_multiset
#print axioms general_basis_from_lev
#print axioms main_inverse_relative_to_lev

end EStarBasisFromLev
