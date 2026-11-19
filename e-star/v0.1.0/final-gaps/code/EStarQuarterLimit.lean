import EStarBasisFromLev
import Mathlib

/-!
Actual extremal function and quarter-limit relative to LevGrowthInput.
The definitions of Avoids/Avoiders/F agree with the original paper's finite
avoider model. No limit or extremal bound is assumed as an input.
-/

namespace EStarQuarterLimit
open Finset Filter Topology
open scoped Classical

def Avoids (A : Finset ℕ) (n : ℕ) : Prop :=
  ∀ X ⊆ A, X.sum id = n → X = ∅

noncomputable def Avoiders (M n : ℕ) : Finset (Finset ℕ) :=
  ((Finset.Icc 1 M).powerset).filter fun A => Avoids A n

noncomputable def F (M n : ℕ) : ℕ := (Avoiders M n).sup Finset.card

theorem F_ge_card {M n : ℕ} (A : Finset ℕ)
    (hA : A ⊆ Finset.Icc 1 M) (hav : Avoids A n) : A.card ≤ F M n := by
  apply Finset.le_sup (f := Finset.card)
  simp only [Avoiders, Finset.mem_filter, Finset.mem_powerset]
  exact ⟨hA, hav⟩

theorem F_le_of_bound (M n : ℕ) (b : ℝ)
    (_hb0 : 0 ≤ b)
    (hbound : ∀ A : Finset ℕ, A ⊆ Finset.Icc 1 M → Avoids A n →
      (A.card : ℝ) ≤ b) : (F M n : ℝ) ≤ b := by
  classical
  have hne : (Avoiders M n).Nonempty := by
    refine ⟨∅, ?_⟩
    simp only [Avoiders, Finset.mem_filter, Finset.mem_powerset]
    exact ⟨Finset.empty_subset _, fun X hX _ => Finset.subset_empty.mp hX⟩
  obtain ⟨A,hA,heq⟩ := Finset.exists_mem_eq_sup (Avoiders M n) hne Finset.card
  obtain ⟨hsub,hav⟩ := Finset.mem_filter.mp hA
  rw [F,heq]
  exact hbound A (Finset.mem_powerset.mp hsub) hav

theorem avoids_mono {A B : Finset ℕ} {n : ℕ} (hav : Avoids A n) (hBA : B ⊆ A) :
    Avoids B n := by
  intro X hX hs
  exact hav X (hX.trans hBA) hs

theorem high_card_bound (T : ℕ) (A : Finset ℕ)
    (hA : A ⊆ Finset.Icc (2*T) (4*T)) (hav : Avoids A (6*T)) :
    A.card ≤ T+1 := by
  let fold := fun x : ℕ => min x (6*T-x)
  have hpair : ∀ x ∈ A, ∀ y ∈ A, x ≠ y → x+y ≠ 6*T := by
    intro x hx y hy hne hs
    have hp : ({x,y} : Finset ℕ) ⊆ A := by simp [Finset.insert_subset_iff, hx, hy]
    have he := hav {x,y} hp (by simpa [Finset.sum_pair hne] using hs)
    have : x ∈ (∅ : Finset ℕ) := he ▸ (by simp)
    simp at this
  have hinj : Set.InjOn fold A := by
    intro x hx y hy he
    have hxI := Finset.mem_Icc.mp (hA hx)
    have hyI := Finset.mem_Icc.mp (hA hy)
    change min x (6*T-x) = min y (6*T-y) at he
    by_contra hne
    have hn := hpair x hx y hy hne
    omega
  have hsub : A.image fold ⊆ Finset.Icc (2*T) (3*T) := by
    intro x hx
    obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hx
    have hai := Finset.mem_Icc.mp (hA ha)
    dsimp [fold]
    apply Finset.mem_Icc.mpr
    omega
  have hc := Finset.card_le_card hsub
  rw [Finset.card_image_of_injOn hinj] at hc
  simp only [Nat.card_Icc] at hc
  omega

def multiples4 (T : ℕ) : Finset ℕ := (Finset.range T).image fun i => 4*(i+1)

def upperOdds (k : ℕ) : Finset ℕ :=
  (Finset.range (k+1)).image fun i => 3*(2*k+1)+2*i

def construction (k : ℕ) : Finset ℕ := multiples4 (2*k+1) ∪ upperOdds k

theorem construction_mem (k x : ℕ) (hx : x ∈ construction k) :
    (0 < x ∧ x ≤ 4*(2*k+1)) ∧
      (4 ∣ x ∨ (3*(2*k+1) ≤ x ∧ x % 2 = 1)) := by
  rcases Finset.mem_union.mp hx with hx | hx
  · obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp hx
    have hi' := Finset.mem_range.mp hi
    refine ⟨⟨by omega, by omega⟩, Or.inl ?_⟩
    exact dvd_mul_right 4 (i+1)
  · obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp hx
    have hi' := Finset.mem_range.mp hi
    exact ⟨⟨by omega, by omega⟩, Or.inr ⟨by omega, by omega⟩⟩

theorem construction_card (k : ℕ) : (construction k).card = 3*k+2 := by
  have hQ : (multiples4 (2*k+1)).card = 2*k+1 := by
    unfold multiples4
    rw [Finset.card_image_of_injective _ (by intro i j h; dsimp at h; omega), Finset.card_range]
  have hU : (upperOdds k).card = k+1 := by
    unfold upperOdds
    rw [Finset.card_image_of_injective _ (by intro i j h; dsimp at h; omega), Finset.card_range]
  have hdisj : Disjoint (multiples4 (2*k+1)) (upperOdds k) := by
    rw [Finset.disjoint_left]
    intro x hxQ hxU
    obtain ⟨i, hi, hix⟩ := Finset.mem_image.mp hxQ
    obtain ⟨j, hj, hjx⟩ := Finset.mem_image.mp hxU
    omega
  rw [construction, Finset.card_union_of_disjoint hdisj, hQ, hU]
  omega

theorem construction_avoids (k : ℕ) : Avoids (construction k) (6*(2*k+1)) := by
  intro X hX hsum
  have hx : ∀ x ∈ X, 4 ∣ x ∨ (3*(2*k+1) ≤ x ∧ x % 2 = 1) := by
    intro x hx
    exact (construction_mem k x (hX hx)).2
  by_cases hex : ∃ x ∈ X, ¬4 ∣ x
  · obtain ⟨x, hxX, hx4⟩ := hex
    have hxb := (hx x hxX).resolve_left hx4
    by_cases hex2 : ∃ y ∈ X, y ≠ x ∧ ¬4 ∣ y
    · obtain ⟨y, hyX, hyx, hy4⟩ := hex2
      have hyb := (hx y hyX).resolve_left hy4
      have hpair : ({x,y} : Finset ℕ) ⊆ X := by simp [Finset.insert_subset_iff, hxX, hyX]
      have hle : x+y ≤ X.sum id := by
        have h : ({x,y} : Finset ℕ).sum id ≤ X.sum id :=
          Finset.sum_le_sum_of_subset hpair
        simpa only [Finset.sum_pair (Ne.symm hyx), id_eq] using h
      omega
    · have hrest : ∀ y ∈ X.erase x, 2 ∣ y := by
        intro y hy
        obtain ⟨hyne, hyX⟩ := Finset.mem_erase.mp hy
        have hy4 : 4 ∣ y := by
          by_contra hy4
          exact hex2 ⟨y,hyX,hyne,hy4⟩
        exact dvd_trans (by decide : 2 ∣ 4) hy4
      have hd : 2 ∣ (X.erase x).sum id := by
        simpa only [id_eq] using (Finset.dvd_sum hrest)
      have hsplit : x + (X.erase x).sum id = X.sum id := Finset.add_sum_erase X id hxX
      obtain ⟨a, ha⟩ := hd
      omega
  · have hdiv : ∀ x ∈ X, 4 ∣ x := by
      intro x hxX
      by_contra hx4
      exact hex ⟨x,hxX,hx4⟩
    have hd : 4 ∣ X.sum id := by
      simpa only [id_eq] using (Finset.dvd_sum hdiv)
    rw [hsum] at hd
    omega

theorem quarter_lower (k : ℕ) : 3*k+2 ≤ F (4*(2*k+1)) (6*(2*k+1)) := by
  have h := F_ge_card (construction k) (by
    intro x hx
    exact Finset.mem_Icc.mpr (construction_mem k x hx).1) (construction_avoids k)
  rwa [construction_card] at h

#print axioms F_ge_card
#print axioms F_le_of_bound
#print axioms high_card_bound
#print axioms construction_card
#print axioms construction_avoids
#print axioms quarter_lower

end EStarQuarterLimit
