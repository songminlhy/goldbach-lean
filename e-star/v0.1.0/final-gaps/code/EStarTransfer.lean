import EStarDistinct
import Mathlib.Algebra.BigOperators.Ring.Multiset
import Mathlib.Data.Finset.Interval
import Mathlib.Tactic

/-!
# Finite transfer from normalized repeated sums to distinct sums

This module fills an actual representation interface in the paper: erase zero
padding in a normalized multiset, multiply the remaining summands back by d,
and invoke the proved finite distinctification bridge.  It also checks the
density/divisibility step that forces a common divisor below q.

It does not prove Lev, Roth, extraction of a good core, or an asymptotic
threshold. In particular a normalized representation is an explicit input,
not a theorem derived here merely from a numerical interval inequality.
-/

namespace EStarTransfer

/-- The actual normalized finite set used in the manuscript. -/
def normalized (G : Finset ℕ) (d : ℕ) : Finset ℕ :=
  insert 0 (G.image (fun g => g / d))

/-- Erasing zero padding preserves the sum. -/
theorem sum_filter_nonzero (s : Multiset ℕ) :
    (s.filter (fun x => x ≠ 0)).sum = s.sum := by
  induction s using Multiset.induction_on with
  | empty => simp
  | @cons a s ih =>
    by_cases ha : a = 0
    · simp [ha, ih]
    · simp [ha, ih]

/-- Multiplication maps a normalized, nonzero summand back into G. -/
theorem denormalize_mem (G : Finset ℕ) (d x : ℕ)
    (hdiv : ∀ g ∈ G, d ∣ g)
    (hx : x ∈ normalized G d) (hx0 : x ≠ 0) : d * x ∈ G := by
  classical
  have hximage : x ∈ G.image (fun g => g / d) := by
    simpa [normalized, hx0] using hx
  obtain ⟨g, hgG, hgx⟩ := Finset.mem_image.mp hximage
  rw [← hgx, Nat.mul_div_cancel' (hdiv g hgG)]
  exact hgG

/-- Zero deletion and rescaling produce a positive-length G representation. -/
theorem lift_normalized_representation (G : Finset ℕ) (d H target : ℕ)
    (hdiv : ∀ g ∈ G, d ∣ g) (htarget : 0 < target)
    (s : Multiset ℕ) (hsB : ∀ x ∈ s, x ∈ normalized G d)
    (hsize : s.card ≤ H) (hsum : d * s.sum = target) :
    ∃ u : Multiset ℕ, (∀ x ∈ u, x ∈ G) ∧
      0 < u.card ∧ u.card ≤ H ∧ u.sum = target := by
  classical
  let z := s.filter (fun x => x ≠ 0)
  let u := z.map (fun x => d * x)
  have huG : ∀ x ∈ u, x ∈ G := by
    intro x hx
    obtain ⟨a, ha, rfl⟩ := Multiset.mem_map.mp hx
    obtain ⟨has, ha0⟩ := Multiset.mem_filter.mp ha
    exact denormalize_mem G d a hdiv (hsB a has) ha0
  have hucard : u.card ≤ H := by
    dsimp [u, z]
    rw [Multiset.card_map]
    exact (Multiset.card_le_card (Multiset.filter_le _ _)).trans hsize
  have husum : u.sum = target := by
    dsimp [u]
    have hscale : (z.map (fun x => d * x)).sum = d * z.sum := by
      simpa using (Multiset.sum_map_mul_left (s := z) (a := d) (f := id))
    rw [hscale]
    simpa [z, sum_filter_nonzero] using hsum
  have hupos : 0 < u.card := by
    by_contra h
    have hzero : u = 0 := Multiset.card_eq_zero.mp (by omega)
    simp [hzero] at husum
    omega
  exact ⟨u, huG, hupos, hucard, husum⟩

/-- Actual finite-set conclusion: a normalized repeated representation yields
a nonempty distinct A-subset with sum target and at most H elements. -/
theorem normalized_representation_to_distinct
    (A G : Finset ℕ) (d H target : ℕ) (hGA : G ⊆ A)
    (hpairs : ∀ g ∈ G, H ≤ (EStarDistinct.centerLowers A g).card)
    (hdiv : ∀ g ∈ G, d ∣ g) (htarget : 0 < target)
    (s : Multiset ℕ) (hsB : ∀ x ∈ s, x ∈ normalized G d)
    (hsize : s.card ≤ H) (hsum : d * s.sum = target) :
    ∃ X : Finset ℕ, X.Nonempty ∧ X ⊆ A ∧ X.card ≤ H ∧
      (∑ x ∈ X, x) = target := by
  obtain ⟨u, huG, hupos, hucard, husum⟩ :=
    lift_normalized_representation G d H target hdiv htarget s hsB hsize hsum
  obtain ⟨X, hXne, hXA, hXcard, hXsum⟩ :=
    EStarDistinct.distinct_sum_nonempty A G H hGA hpairs u huG hupos hucard
  exact ⟨X, hXne, hXA, hXcard.trans_le hucard, hXsum.trans husum⟩

/-- A positive common divisor of a dense positive finite set lies below q.
Density is written without division: E < q * |G|. -/
theorem common_divisor_lt_of_dense
    (G : Finset ℕ) (E d q : ℕ) (hd : 0 < d)
    (hpos : ∀ g ∈ G, 0 < g) (hbound : ∀ g ∈ G, g ≤ E)
    (hdiv : ∀ g ∈ G, d ∣ g) (hdense : E < q * G.card) : d < q := by
  classical
  have hinj : Set.InjOn (fun g : ℕ => g / d) G := by
    intro a ha b hb hab
    dsimp at hab
    have haeq := Nat.mul_div_cancel' (hdiv a ha)
    have hbeq := Nat.mul_div_cancel' (hdiv b hb)
    calc
      a = d * (a / d) := haeq.symm
      _ = d * (b / d) := by rw [hab]
      _ = b := hbeq
  have hsub : G.image (fun g => g / d) ⊆ Finset.Icc 1 (E / d) := by
    intro x hx
    obtain ⟨g, hg, rfl⟩ := Finset.mem_image.mp hx
    apply Finset.mem_Icc.mpr
    constructor
    · exact Nat.div_pos (Nat.le_of_dvd (hpos g hg) (hdiv g hg)) hd
    · exact Nat.div_le_div_right (hbound g hg)
  have hcard : G.card ≤ E / d := by
    have h := Finset.card_le_card hsub
    rw [Finset.card_image_of_injOn hinj] at h
    simpa using h
  have hmul : d * G.card ≤ E := by
    have h := (Nat.le_div_iff_mul_le hd).mp hcard
    simpa [Nat.mul_comm] using h
  by_contra h
  have hqd : q ≤ d := by omega
  have := Nat.mul_le_mul_right G.card hqd
  omega

/-- The defining property of q then makes that divisor divide s. -/
theorem common_divisor_dvd_parameter
    (G : Finset ℕ) (E d q s : ℕ) (hd : 0 < d)
    (hpos : ∀ g ∈ G, 0 < g) (hbound : ∀ g ∈ G, g ≤ E)
    (hdiv : ∀ g ∈ G, d ∣ g) (hdense : E < q * G.card)
    (hq : ∀ a : ℕ, 0 < a → a < q → a ∣ s) : d ∣ s := by
  exact hq d hd (common_divisor_lt_of_dense G E d q hd hpos hbound hdiv hdense)

#print axioms sum_filter_nonzero
#print axioms denormalize_mem
#print axioms lift_normalized_representation
#print axioms normalized_representation_to_distinct
#print axioms common_divisor_lt_of_dense
#print axioms common_divisor_dvd_parameter

end EStarTransfer
