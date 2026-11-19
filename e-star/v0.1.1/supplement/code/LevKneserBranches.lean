import LevResidue

/-!
# Exact Kneser interface and the already-dischargeable branches

The proper nontrivial-period case of Lev's proof remains open here. This module
does NOT rename that remaining fiber-counting argument as Kneser's theorem.
-/

namespace LevKneserBranches

open scoped Pointwise
open EStarBasisFromLev LevResidue

def cyclicSums {L : ℕ} (A : Finset (ZMod L)) : ℕ → Finset (ZMod L)
  | 0 => {0}
  | h + 1 => A + cyclicSums A h

/-- The actual period set of a finite cyclic sumset. -/
def periods {L : ℕ} [NeZero L] (C : Finset (ZMod L)) : Finset (ZMod L) :=
  Finset.univ.filter (fun t => C.image (fun x => x + t) = C)

theorem zero_mem_periods {L : ℕ} [NeZero L] (C : Finset (ZMod L)) :
    0 ∈ periods C := by
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _, ?_⟩
  ext x
  constructor
  · intro hx
    obtain ⟨y, hy, hyx⟩ := Finset.mem_image.mp hx
    have heq : y = x := by simpa only [add_zero] using hyx
    exact heq ▸ hy
  · intro hx
    exact Finset.mem_image.mpr ⟨x, hx, add_zero x⟩

/-- Classical multi-summand Kneser, with actual h-fold sums and their period.
This proposition is an unproved parameter, not an axiom. It has no integers
from [0,L], no gcd, and no Lev growth conclusion in its statement. -/
def CyclicKneserInput : Prop :=
  ∀ (L : ℕ) [NeZero L] (A : Finset (ZMod L)), A.Nonempty →
    ∀ h : ℕ, 1 ≤ h →
      h * (A + periods (cyclicSums A h)).card ≤
        (cyclicSums A h).card + (h - 1) * (periods (cyclicSums A h)).card

theorem quotient_sums_eq (B : Finset ℕ) (L h : ℕ) :
    residues L (sums B h) = cyclicSums (residues L B) h := by
  induction h with
  | zero => simp [sums, residues, cyclicSums]
  | succ h ih => rw [residues_succ, cyclicSums, ih]

theorem periods_card_one_eq {L : ℕ} [NeZero L] (C : Finset (ZMod L))
    (hcard : (periods C).card = 1) : periods C = {0} := by
  obtain ⟨a, ha⟩ := Finset.card_eq_one.mp hcard
  have h0 := zero_mem_periods C
  rw [ha, Finset.mem_singleton] at h0
  simpa [← h0] using ha

/-- Kneser discharges the aperiodic cyclic-image branch of the actual Lev step. -/
theorem lev_step_aperiodic (hKneser : CyclicKneserInput)
    (B : Finset ℕ) (L j : ℕ) (hL : 0 < L)
    (hB : B ⊆ Finset.Icc 0 L) (h0 : 0 ∈ B) (hLB : L ∈ B)
    (hj : 2 ≤ j)
    (hperiod : letI : NeZero L := ⟨by omega⟩
      (periods (residues L (sums B j))).card = 1) :
    ((sums B (j - 1)).card : ℝ) +
      min (L : ℝ) ((j : ℝ) * ((B.card : ℝ) - 2) + 1) ≤
        ((sums B j).card : ℝ) := by
  classical
  have : NeZero L := ⟨by omega⟩
  have hBne : (residues L B).Nonempty :=
    ⟨0, Finset.mem_image.mpr ⟨0, h0, by simp⟩⟩
  have hc := residue_card B L hL hB h0 hLB
  have hp : periods (cyclicSums (residues L B) j) = {0} := by
    apply periods_card_one_eq
    simpa [← quotient_sums_eq] using hperiod
  have hK := hKneser L (residues L B) hBne j (by omega)
  rw [hp] at hK
  have hadd : residues L B + {0} = residues L B := by
    ext x
    simp [Finset.mem_add]
  rw [hadd, Finset.card_singleton, mul_one, ← quotient_sums_eq] at hK
  have hNpos : 1 ≤ (residues L B).card := Finset.card_pos.mpr hBne
  have hn : j * (B.card - 2) + j = j * (residues L B).card := by
    have heq : B.card - 2 + 1 = (residues L B).card := by omega
    nlinarith
  have hres : j * (B.card - 2) + 1 ≤ (residues L (sums B j)).card := by omega
  exact lev_step_of_residue_card B L j hL hj h0 hLB ((min_le_right _ _).trans hres)

/-- Full cyclic coverage is independent of Kneser. -/
theorem lev_step_full_residues
    (B : Finset ℕ) (L j : ℕ) (hL : 0 < L)
    (h0 : 0 ∈ B) (hLB : L ∈ B) (hj : 2 ≤ j)
    (hfull : letI : NeZero L := ⟨by omega⟩
      residues L (sums B j) = Finset.univ) :
    ((sums B (j - 1)).card : ℝ) +
      min (L : ℝ) ((j : ℝ) * ((B.card : ℝ) - 2) + 1) ≤
        ((sums B j).card : ℝ) := by
  have : NeZero L := ⟨by omega⟩
  apply lev_step_of_residue_card B L j hL hj h0 hLB
  rw [hfull]
  simpa only [Finset.card_univ, ZMod.card] using (min_le_left L (j * (B.card - 2) + 1))

/-- The remaining proper-period argument is isolated precisely: Kneser's actual
cyclic cardinal inequality plus a heavy integer fiber in a new residue block
give the complete Lev step. The heavy-fiber estimate is explicit and is NOT
claimed to follow merely by naming Kneser's theorem. -/
theorem lev_step_of_periodic_fiber_estimate
    (B : Finset ℕ) (L j : ℕ) (hL : 0 < L)
    (hB : B ⊆ Finset.Icc 0 L) (h0 : 0 ∈ B) (hLB : L ∈ B)
    (hj : 2 ≤ j) (C Aplus : Finset (ZMod L))
    (hdisj : Disjoint C (residues L (sums B (j - 1))))
    (hK : j * Aplus.card ≤ (residues L (sums B j)).card + (j - 1) * C.card)
    (hFiber : j * (residues L B).card + j * C.card ≤
      ((sums B j).filter (fun a : Nat => (a : ZMod L) ∈ C)).card +
        j * Aplus.card + (j - 1)) :
    ((sums B (j - 1)).card : ℝ) +
      min (L : ℝ) ((j : ℝ) * ((B.card : ℝ) - 2) + 1) ≤
        ((sums B j).card : ℝ) := by
  classical
  have hsucc : j - 1 + 1 = j := by omega
  have hPR : sums B (j - 1) ⊆ sums B j := by
    intro x hx
    rw [← hsucc]
    exact Finset.mem_add.mpr ⟨0, h0, x, hx, by simp⟩
  have hshift : ∀ a ∈ sums B (j - 1), a + L ∈ sums B j := by
    intro x hx
    rw [← hsucc]
    exact Finset.mem_add.mpr ⟨L, hLB, x, hx, by omega⟩
  have hLift := heavy_residue_block_lift (sums B (j - 1)) (sums B j) L hL hPR hshift C hdisj
  have hc := residue_card B L hL hB h0 hLB
  have hNpos : 1 ≤ (residues L B).card := by
    apply Finset.card_pos.mpr
    exact ⟨0, Finset.mem_image.mpr ⟨0, h0, by simp⟩⟩
  have hBn2 : 2 ≤ B.card := by omega
  have hNid : B.card - 2 + 1 = (residues L B).card := by omega
  have hjCid : (j - 1) * C.card + C.card = j * C.card := by
    calc
      (j - 1) * C.card + C.card = (j - 1 + 1) * C.card := by ring
      _ = j * C.card := by rw [hsucc]
  have hjNid : j * (B.card - 2) + j = j * (residues L B).card := by
    rw [← hNid, Nat.mul_add, Nat.mul_one]
  have hNat : (sums B (j - 1)).card + j * (B.card - 2) + 1 ≤ (sums B j).card := by
    omega
  have hMin : (sums B (j - 1)).card + min L (j * (B.card - 2) + 1) ≤ (sums B j).card := by
    have := min_le_right L (j * (B.card - 2) + 1)
    omega
  exact_mod_cast hMin

#print axioms zero_mem_periods
#print axioms quotient_sums_eq
#print axioms periods_card_one_eq
#print axioms lev_step_aperiodic
#print axioms lev_step_full_residues
#print axioms lev_step_of_periodic_fiber_estimate

end LevKneserBranches
