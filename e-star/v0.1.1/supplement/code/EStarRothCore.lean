/- Adapted from matejasevick/erdos361, commit 27f45e7f84894993c1471e952608319aebc53eee.
Copyright (c) 2026 Mateo Matijasevick. MIT License; see upstream/LICENSE.
This copy is compiled independently against the host Lean 4.33.0-rc1 cache. -/
import UpstreamGoodCore
open Finset Filter Topology
open scoped Classical
namespace EStarRothCore
/-- Good/bad split with threshold `ℓ` (generalises `good_core_split`, which is the case `ℓ = 10`):
the elements of `A ⊆ [1,E]` that are midpoints of at most `ℓ` three-term progressions of `A` number
at most `(36ℓ+2)·r₃(E+1)`. -/
lemma roth_core_split (E : ℕ) (A : Finset ℕ) (hA : A ⊆ Finset.Icc 1 E) (ℓ : ℕ) (hℓ : 1 ≤ ℓ) :
    (A.filter (fun a => (A.filter (fun x => x < a ∧ 2 * a - x ∈ A)).card ≤ ℓ)).card
      ≤ (36 * ℓ + 2) * rothNumberNat (E + 1) := by
  set C : Finset ℕ := A.filter (fun a => (A.filter (fun x => x < a ∧ 2 * a - x ∈ A)).card ≤ ℓ)
    with hCdef
  have hCA : C ⊆ A := Finset.filter_subset _ _
  set D : Finset (Finset ℕ) :=
    C.biUnion (fun y => (C.filter (fun x => x < y ∧ 2 * y - x ∈ C)).image
      (fun x => ({x, y, 2 * y - x} : Finset ℕ))) with hDdef
  have hd3 : ∀ e ∈ D, e ⊆ C ∧ e.card = 3 := by
    intro e he
    rw [hDdef, Finset.mem_biUnion] at he
    obtain ⟨y, hyC, he⟩ := he
    rw [Finset.mem_image] at he
    obtain ⟨x, hx, rfl⟩ := he
    rw [Finset.mem_filter] at hx
    obtain ⟨hxC, hxy, hzC⟩ := hx
    refine ⟨?_, ?_⟩
    · intro a ha
      simp only [Finset.mem_insert, Finset.mem_singleton] at ha
      rcases ha with rfl | rfl | rfl
      · exact hxC
      · exact hyC
      · exact hzC
    · rw [Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_singleton]
      · simp only [Finset.mem_singleton]; omega
      · simp only [Finset.mem_insert, Finset.mem_singleton]; omega
  have hDcard : D.card ≤ ℓ * C.card := by
    calc D.card ≤ ∑ y ∈ C, ((C.filter (fun x => x < y ∧ 2 * y - x ∈ C)).image
              (fun x => ({x, y, 2 * y - x} : Finset ℕ))).card := Finset.card_biUnion_le
      _ ≤ ∑ y ∈ C, (C.filter (fun x => x < y ∧ 2 * y - x ∈ C)).card :=
            Finset.sum_le_sum (fun y _ => Finset.card_image_le)
      _ ≤ ∑ y ∈ C, ℓ := by
            refine Finset.sum_le_sum (fun y hyC => ?_)
            have hsub : C.filter (fun x => x < y ∧ 2 * y - x ∈ C)
                ⊆ A.filter (fun x => x < y ∧ 2 * y - x ∈ A) := by
              intro x hx
              rw [Finset.mem_filter] at hx ⊢
              exact ⟨hCA hx.1, hx.2.1, hCA hx.2.2⟩
            have hle := Finset.card_le_card hsub
            have hℓy := (Finset.mem_filter.mp hyC).2
            omega
      _ = ℓ * C.card := by rw [Finset.sum_const, smul_eq_mul, mul_comm]
  obtain ⟨I, hIC, hIind, hIcard⟩ := hypergraph_indep C D ℓ hℓ hd3 hDcard
  have hIfree : ThreeAPFree (I : Set ℕ) := by
    rw [threeAPFree_iff_eq_right]
    intro a ha b hb c hc habc
    by_contra hac
    have hkey : ∀ x z : ℕ, x ∈ I → z ∈ I → x < z → x + z = b + b → False := by
      intro x z hx hz hxz hxz2
      have hzeq : 2 * b - x = z := by omega
      have hmem : ({x, b, z} : Finset ℕ) ∈ D := by
        rw [hDdef, Finset.mem_biUnion]
        refine ⟨b, hIC hb, ?_⟩
        rw [Finset.mem_image]
        exact ⟨x, Finset.mem_filter.mpr ⟨hIC hx, by omega, by rw [hzeq]; exact hIC hz⟩, by rw [hzeq]⟩
      have hsub : ({x, b, z} : Finset ℕ) ⊆ I := by
        intro w hw; simp only [Finset.mem_insert, Finset.mem_singleton] at hw
        rcases hw with rfl | rfl | rfl
        exacts [hx, hb, hz]
      exact hIind _ hmem hsub
    rcases lt_or_gt_of_ne hac with h | h
    · exact hkey a c ha hc h habc
    · exact hkey c a hc ha h (by omega)
  have hIlt : ∀ x ∈ I, x < E + 1 := by
    intro x hx
    have := hA (hCA (hIC hx))
    rw [Finset.mem_Icc] at this; omega
  have hIroth : I.card ≤ rothNumberNat (E + 1) :=
    ThreeAPFree.le_rothNumberNat I hIfree hIlt rfl
  calc C.card ≤ (36 * ℓ + 2) * I.card := hIcard
    _ ≤ (36 * ℓ + 2) * rothNumberNat (E + 1) := Nat.mul_le_mul_left _ hIroth

/-- Large good core with threshold `ℓ+1`: for every `α`, a set `A ⊆ [1,E]` of size `≥ (α+ε)E`
contains `G` of size `≥ (α+ε/2)E` all of whose elements are midpoints of `≥ ℓ+1` three-term
progressions of `A` (for all large `E`). -/
lemma roth_core_exists (α ε : ℝ) (hε : 0 < ε) (ℓ : ℕ) (hℓ : 1 ≤ ℓ) :
    ∃ E₀ : ℕ, ∀ E : ℕ, E₀ ≤ E → ∀ A : Finset ℕ, A ⊆ Finset.Icc 1 E →
      (α + ε) * E ≤ (A.card : ℝ) →
      ∃ G ⊆ A, (∀ g ∈ G, ℓ + 1 ≤ (A.filter (fun x => x < g ∧ 2 * g - x ∈ A)).card)
        ∧ (α + ε / 2) * E ≤ (G.card : ℝ) := by
  obtain ⟨K, hK⟩ : ∃ K : ℕ, K = 36 * ℓ + 2 := ⟨_, rfl⟩
  obtain ⟨E₀, hE₀⟩ := roth_small_nat K ε hε
  refine ⟨E₀, fun E hE A hA hden => ?_⟩
  set G : Finset ℕ :=
    A.filter (fun a => ℓ + 1 ≤ (A.filter (fun x => x < a ∧ 2 * a - x ∈ A)).card) with hG
  set C : Finset ℕ :=
    A.filter (fun a => (A.filter (fun x => x < a ∧ 2 * a - x ∈ A)).card ≤ ℓ) with hC
  have hsplit : C.card ≤ K * rothNumberNat (E + 1) := by
    rw [hK]; exact roth_core_split E A hA ℓ hℓ
  have hCeq : C = A.filter
      (fun a => ¬ (ℓ + 1 ≤ (A.filter (fun x => x < a ∧ 2 * a - x ∈ A)).card)) := by
    rw [hC]; apply Finset.filter_congr; intro a _; constructor <;> intro h <;> omega
  have hGC : G.card + C.card = A.card := by
    rw [hG, hCeq]; exact Finset.card_filter_add_card_filter_not _
  have hCle : (C.card : ℝ) ≤ (K : ℝ) * (rothNumberNat (E + 1) : ℝ) := by exact_mod_cast hsplit
  have hroth := hE₀ E hE
  refine ⟨G, Finset.filter_subset _ _, fun g hg => (Finset.mem_filter.mp hg).2, ?_⟩
  have hGCr : (G.card : ℝ) + (C.card : ℝ) = (A.card : ℝ) := by exact_mod_cast hGC
  linarith [hden, hCle, hroth, hGCr]
#print axioms roth_core_split
#print axioms roth_core_exists
end EStarRothCore
