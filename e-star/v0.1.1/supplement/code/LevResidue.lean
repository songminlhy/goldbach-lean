import EStarBasisFromLev
import Mathlib.Combinatorics.Additive.CauchyDavenport

/-!
# Unconditional integer-to-residue lifting in Lev's growth proof

Every residue reached by the next repeated sumset contributes a genuinely new
integer above the previous sumset's maximal representative in that residue.
This proves the full-residue and sufficiently-large-residue branches of Lev.
The prime-diameter branch is then discharged by Mathlib's Cauchy--Davenport.
The nontrivial proper-period branch for composite diameters remains separate.
-/

namespace LevResidue

open scoped Pointwise
open EStarBasisFromLev

def residues (L : ℕ) (S : Finset ℕ) : Finset (ZMod L) :=
  S.image (fun n : Nat => (n : ZMod L))

/-- With endpoints 0 and L, exactly one cardinality is lost mod L. -/
theorem residue_card (B : Finset ℕ) (L : ℕ) (hL : 0 < L)
    (hB : B ⊆ Finset.Icc 0 L) (h0 : 0 ∈ B) (hLB : L ∈ B) :
    (residues L B).card + 1 = B.card := by
  classical
  have hlt : ∀ a ∈ B.erase L, a < L := by
    intro a ha
    have hab := (Finset.mem_erase.mp ha).2
    have hane := (Finset.mem_erase.mp ha).1
    have hle := (Finset.mem_Icc.mp (hB hab)).2
    omega
  have hinj : Set.InjOn (fun n : ℕ => (n : ZMod L)) (B.erase L) := by
    intro a ha b hb hab
    have heq : a % L = b % L := (ZMod.natCast_eq_natCast_iff a b L).mp hab
    simpa [Nat.mod_eq_of_lt (hlt a ha), Nat.mod_eq_of_lt (hlt b hb)] using heq
  have himage : residues L B = residues L (B.erase L) := by
    ext c
    constructor
    · intro hc
      obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hc
      by_cases haL : a = L
      · subst a
        exact Finset.mem_image.mpr ⟨0, Finset.mem_erase.mpr ⟨by omega, h0⟩, by simp⟩
      · exact Finset.mem_image.mpr ⟨a, Finset.mem_erase.mpr ⟨haL, ha⟩, rfl⟩
    · intro hc
      obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hc
      exact Finset.mem_image.mpr ⟨a, Finset.mem_of_mem_erase ha, rfl⟩
  rw [himage]
  have hcard := Finset.card_image_of_injOn hinj
  have herase := Finset.card_erase_of_mem hLB
  have hpos : 0 < B.card := Finset.card_pos.mpr ⟨0, h0⟩
  dsimp [residues]
  omega

/-- A finite set and its L-shift together contain one new representative for
every residue present in the larger set R. This is an actual finite-set fact. -/
theorem new_representative_per_residue
    (P R : Finset ℕ) (L : ℕ) (hL : 0 < L)
    (hPR : P ⊆ R) (hshift : ∀ a ∈ P, a + L ∈ R) :
    P.card + (residues L R).card ≤ R.card := by
  classical
  have hres : residues L R ⊆ residues L (R \ P) := by
    intro c hc
    obtain ⟨a, ha, hac⟩ := Finset.mem_image.mp hc
    let F := P.filter (fun n : Nat => (n : ZMod L) = c)
    by_cases hF : F.Nonempty
    · let m := F.max' hF
      have hmF : m ∈ F := F.max'_mem hF
      obtain ⟨hmP, hmc⟩ := Finset.mem_filter.mp hmF
      have hmLR : m + L ∈ R := hshift m hmP
      have hcast : ((m + L : ℕ) : ZMod L) = c := by
        simpa only [Nat.cast_add, ZMod.natCast_self, add_zero] using hmc
      have hmLP : m + L ∉ P := by
        intro hmLP
        have hmLF : m + L ∈ F := Finset.mem_filter.mpr ⟨hmLP, hcast⟩
        have hmax : m + L ≤ m := F.le_max' _ hmLF
        omega
      exact Finset.mem_image.mpr ⟨m + L, Finset.mem_sdiff.mpr ⟨hmLR, hmLP⟩, hcast⟩
    · have haP : a ∉ P := by
        intro haP
        exact hF ⟨a, Finset.mem_filter.mpr ⟨haP, hac⟩⟩
      exact Finset.mem_image.mpr ⟨a, Finset.mem_sdiff.mpr ⟨ha, haP⟩, hac⟩
  have hc := Finset.card_le_card hres
  have hi : (residues L (R \ P)).card ≤ (R \ P).card := Finset.card_image_le
  have hbound : (residues L R).card ≤ (R \ P).card := hc.trans hi
  have hp := Finset.card_sdiff_add_card_eq_card hPR
  omega

/-- A residue block absent from P contributes all of its integer multiplicity,
in addition to the one-new-representative bound outside that block. This is
the finite counting bridge needed in Lev's proper-period branch. -/
theorem heavy_residue_block_lift
    (P R : Finset ℕ) (L : ℕ) (hL : 0 < L)
    (hPR : P ⊆ R) (hshift : ∀ a ∈ P, a + L ∈ R)
    (C : Finset (ZMod L)) (hdisj : Disjoint C (residues L P)) :
    P.card + (residues L R).card + (R.filter (fun a : Nat => (a : ZMod L) ∈ C)).card ≤
      R.card + C.card := by
  classical
  let Q := R.filter (fun a : Nat => (a : ZMod L) ∈ C)
  have hQ : Q ⊆ R := Finset.filter_subset _ _
  have hPfree : ∀ a ∈ P, (a : ZMod L) ∉ C := by
    intro a ha haC
    exact Finset.disjoint_left.mp hdisj haC (Finset.mem_image.mpr ⟨a, ha, rfl⟩)
  have hPrest : P ⊆ R \ Q := by
    intro a ha
    refine Finset.mem_sdiff.mpr ⟨hPR ha, ?_⟩
    intro haQ
    exact hPfree a ha (Finset.mem_filter.mp haQ).2
  have hshiftRest : ∀ a ∈ P, a + L ∈ R \ Q := by
    intro a ha
    refine Finset.mem_sdiff.mpr ⟨hshift a ha, ?_⟩
    intro haQ
    have hcast := (Finset.mem_filter.mp haQ).2
    exact hPfree a ha (by simpa only [Nat.cast_add, ZMod.natCast_self, add_zero] using hcast)
  have hlift := new_representative_per_residue P (R \ Q) L hL hPrest hshiftRest
  have hres : residues L R ⊆ C ∪ residues L (R \ Q) := by
    intro c hc
    obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hc
    by_cases haC : (a : ZMod L) ∈ C
    · exact Finset.mem_union_left _ haC
    · exact Finset.mem_union_right _ (Finset.mem_image.mpr ⟨a,
        Finset.mem_sdiff.mpr ⟨ha, by simp [Q, haC]⟩, rfl⟩)
  have hcard := (Finset.card_le_card hres).trans (Finset.card_union_le _ _)
  have hsplit := Finset.card_sdiff_add_card_eq_card hQ
  dsimp [Q] at *
  omega

/-- The honest Lev lifting inequality; no primality or gcd hypothesis needed. -/
theorem residue_lift_growth (B : Finset ℕ) (L j : ℕ)
    (hL : 0 < L) (hj : 1 ≤ j) (h0 : 0 ∈ B) (hLB : L ∈ B) :
    (sums B (j - 1)).card + (residues L (sums B j)).card ≤ (sums B j).card := by
  have hsucc : j - 1 + 1 = j := by omega
  apply new_representative_per_residue _ _ L hL
  · intro x hx
    rw [← hsucc]
    exact Finset.mem_add.mpr ⟨0, h0, x, hx, by simp⟩
  · intro x hx
    rw [← hsucc]
    exact Finset.mem_add.mpr ⟨L, hLB, x, hx, by omega⟩

/-- Hence a large cyclic image proves the whole desired integer growth step. -/
theorem lev_step_of_residue_card
    (B : Finset ℕ) (L j : ℕ) (hL : 0 < L) (hj : 2 ≤ j)
    (h0 : 0 ∈ B) (hLB : L ∈ B)
    (hres : min L (j * (B.card - 2) + 1) ≤ (residues L (sums B j)).card) :
    ((sums B (j - 1)).card : ℝ) +
      min (L : ℝ) ((j : ℝ) * ((B.card : ℝ) - 2) + 1) ≤
        ((sums B j).card : ℝ) := by
  have hB2 : 2 ≤ B.card := by
    have hsub : ({0, L} : Finset ℕ) ⊆ B := by
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl
      · exact h0
      · exact hLB
    have h := Finset.card_le_card hsub
    have h0L : (0 : ℕ) ≠ L := by omega
    simpa [h0L] using h
  have hlift := residue_lift_growth B L j hL (by omega) h0 hLB
  have hnat : (sums B (j - 1)).card + min L (j * (B.card - 2) + 1) ≤ (sums B j).card := by omega
  exact_mod_cast hnat

/-- Images under the quotient map commute with repeated-sumset recursion. -/
theorem residues_succ (B : Finset ℕ) (L j : ℕ) :
    residues L (sums B (j + 1)) = residues L B + residues L (sums B j) := by
  classical
  ext c
  constructor
  · intro hc
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hc
    obtain ⟨a, ha, b, hb, hab⟩ := Finset.mem_add.mp hx
    exact Finset.mem_add.mpr ⟨(a : ZMod L), Finset.mem_image.mpr ⟨a, ha, rfl⟩,
      (b : ZMod L), Finset.mem_image.mpr ⟨b, hb, rfl⟩, by rw [← Nat.cast_add, hab]⟩
  · intro hc
    obtain ⟨a, ha, b, hb, hab⟩ := Finset.mem_add.mp hc
    obtain ⟨x, hx, hxa⟩ := Finset.mem_image.mp ha
    obtain ⟨y, hy, hyb⟩ := Finset.mem_image.mp hb
    exact Finset.mem_image.mpr ⟨x + y, Finset.mem_add.mpr ⟨x, hx, y, hy, rfl⟩,
      by push_cast; rw [hxa, hyb]; exact hab⟩

/-- Prime cyclic images have the required repeated growth by the existing
Mathlib Cauchy--Davenport theorem; no new classical theorem parameter. -/
theorem prime_residue_growth (B : Finset ℕ) (L j : ℕ) (hL : L.Prime)
    (h0 : 0 ∈ B) (hj : 1 ≤ j) :
    min L (j * ((residues L B).card - 1) + 1) ≤
      (residues L (sums B j)).card := by
  have hNpos : 1 ≤ (residues L B).card := by
    apply Finset.card_pos.mpr
    exact ⟨0, Finset.mem_image.mpr ⟨0, h0, by simp⟩⟩
  induction j with
  | zero => omega
  | succ k ih =>
    by_cases hk0 : k = 0
    · subst k
      rw [sums_one]
      have hn : (residues L B).card - 1 + 1 = (residues L B).card := by omega
      simpa only [Nat.zero_add, Nat.one_mul, hn] using (min_le_right L (residues L B).card)
    · have hk : 1 ≤ k := by omega
      have hind := ih hk
      have hBne : (residues L B).Nonempty := Finset.card_pos.mp (by omega)
      have hSne : (residues L (sums B k)).Nonempty := by
        exact ⟨0, Finset.mem_image.mpr ⟨0, zero_mem_sums B k h0, by simp⟩⟩
      have hcd := ZMod.cauchy_davenport hL hBne hSne
      rw [← residues_succ] at hcd
      have hexp : (k + 1) * ((residues L B).card - 1) + 1 =
          k * ((residues L B).card - 1) + 1 + ((residues L B).card - 1) := by ring
      rw [hexp]
      by_cases hsaturated : L ≤ k * ((residues L B).card - 1) + 1
      · rw [min_eq_left hsaturated] at hind
        have hsum : L ≤ (residues L B).card + (residues L (sums B k)).card - 1 := by omega
        rw [min_eq_left hsum] at hcd
        exact (min_le_left _ _).trans hcd
      · rw [min_eq_right (by omega)] at hind
        apply le_trans (min_le_min_left L (show
          k * ((residues L B).card - 1) + 1 + ((residues L B).card - 1) ≤
          (residues L B).card + (residues L (sums B k)).card - 1 by omega)) hcd

/-- Complete unconditional Lev1996 growth for every prime diameter L.
The general composite-diameter theorem is not asserted. -/
theorem lev_growth_prime_diameter
    (B : Finset ℕ) (L : ℕ) (hL : L.Prime)
    (hB : B ⊆ Finset.Icc 0 L) (h0 : 0 ∈ B) (hLB : L ∈ B)
    (j : ℕ) (hj : 2 ≤ j) :
    ((sums B (j - 1)).card : ℝ) +
      min (L : ℝ) ((j : ℝ) * ((B.card : ℝ) - 2) + 1) ≤
        ((sums B j).card : ℝ) := by
  have hc := residue_card B L hL.pos hB h0 hLB
  have hres := prime_residue_growth B L j hL h0 (by omega)
  have hsub : (residues L B).card - 1 = B.card - 2 := by omega
  rw [hsub] at hres
  exact lev_step_of_residue_card B L j hL.pos hj h0 hLB hres

#print axioms residue_card
#print axioms new_representative_per_residue
#print axioms heavy_residue_block_lift
#print axioms residue_lift_growth
#print axioms lev_step_of_residue_card
#print axioms residues_succ
#print axioms prime_residue_growth
#print axioms lev_growth_prime_diameter

end LevResidue
