import EStarTransfer
import Mathlib.Algebra.GCDMonoid.Finset
import Mathlib.Data.Finset.Lattice.Fold

/-!
# Conditional finite assembly of the main inverse argument

The input `hBasis` is precisely the unformalized additive-basis interface:
every integer in the stated interval has a bounded repeated representation
over the actual normalized finite set. It is NOT proved here from Lev.
The input good core is also explicit.  All other finite operations below
(gcd positivity, d<q, d|sT, normalization, target placement, zero deletion,
rescaling and distinctification) are checked in this module and its imports.
-/

namespace EStarFiniteMain

/-- Exact finite interval coverage, stated with actual multisets over B. -/
def BoundedBasis (B : Finset ℕ) (H r L K : ℕ) : Prop :=
  ∀ y : ℕ, r * L ≤ y → y ≤ K * L →
    ∃ u : Multiset ℕ, (∀ x ∈ u, x ∈ B) ∧ u.card ≤ H ∧ u.sum = y

/-- Finite inverse assembly.  The two numerical target bounds are the paper's
range condition and its upper-window condition, after choosing a good core.
The least-nondivisor property of q is stated directly, without a hidden
assumption about divisibility of the target by the gcd. -/
theorem finite_inverse_from_basis_and_good_core
    (A G : Finset ℕ) (E q s T r K H : ℕ)
    (hGA : G ⊆ A)
    (hpos : ∀ g ∈ G, 0 < g) (hbound : ∀ g ∈ G, g ≤ E)
    (hdense : E < q * G.card)
    (hq : ∀ a : ℕ, 0 < a → a < q → a ∣ s)
    (hpairs : ∀ g ∈ G, H ≤ (EStarDistinct.centerLowers A g).card)
    (htarget : 0 < s * T)
    (hrange : r * E ≤ s * T)
    (hupper : s * T ≤ K * G.sup id)
    (hBasis : BoundedBasis (EStarTransfer.normalized G (G.gcd id)) H r
      (G.sup id / G.gcd id) K) :
    ∃ X : Finset ℕ, X.Nonempty ∧ X ⊆ A ∧ X.card ≤ H ∧
      (∑ x ∈ X, x) = s * T := by
  classical
  have hGne : G.Nonempty := by
    apply Finset.card_pos.mp
    by_contra h
    have hc : G.card = 0 := by omega
    simp [hc] at hdense
  obtain ⟨g, hg⟩ := hGne
  let d := G.gcd id
  have hdiv : ∀ a ∈ G, d ∣ a := fun a ha => Finset.gcd_dvd ha
  have hd : 0 < d := by
    by_contra h
    have hd0 : d = 0 := by omega
    have hg0 : g = 0 := (Finset.gcd_eq_zero_iff.mp hd0) g hg
    have := hpos g hg
    omega
  have hds : d ∣ s :=
    EStarTransfer.common_divisor_dvd_parameter G E d q s hd hpos hbound hdiv hdense hq
  have hdt : d ∣ s * T := dvd_mul_of_dvd_left hds T
  let y := s * T / d
  let L := G.sup id / d
  have hy : d * y = s * T := Nat.mul_div_cancel' hdt
  have hmaxMem : G.sup id ∈ G := by
    simpa using (Finset.sup_mem_of_nonempty (f := id) (show G.Nonempty from ⟨g, hg⟩))
  have hL : d * L = G.sup id := Nat.mul_div_cancel' (hdiv _ hmaxMem)
  have hmaxE : G.sup id ≤ E := Finset.sup_le hbound
  have hylo : r * L ≤ y := by
    apply Nat.le_of_mul_le_mul_left (c := d) ?_ hd
    calc
      d * (r * L) = r * (d * L) := by ring
      _ = r * G.sup id := by rw [hL]
      _ ≤ r * E := Nat.mul_le_mul_left r hmaxE
      _ ≤ s * T := hrange
      _ = d * y := hy.symm
  have hyhi : y ≤ K * L := by
    apply Nat.le_of_mul_le_mul_left (c := d) ?_ hd
    calc
      d * y = s * T := hy
      _ ≤ K * G.sup id := hupper
      _ = K * (d * L) := by rw [hL]
      _ = d * (K * L) := by ring
  obtain ⟨u, huB, hucard, husum⟩ := hBasis y hylo hyhi
  apply EStarTransfer.normalized_representation_to_distinct A G d H (s * T)
    hGA hpairs hdiv htarget u huB hucard
  rw [husum]
  exact hy

#print axioms finite_inverse_from_basis_and_good_core

end EStarFiniteMain
