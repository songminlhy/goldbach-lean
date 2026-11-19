import Mathlib

/-!
Finite modular obstruction behind the sharpness constructions.

This file proves statements about actual multisets and finite sets of naturals.
It does not assume avoidance as a premise. It does not encode density estimates,
the existence of suitable arbitrarily large T, or an asymptotic theta constant.
-/

namespace EStarSharpness

/-- Every summand has residue 0 or -1. Adding the number of -1 summands makes
the sum divisible by m. Multiplicity is retained by the multiset filter. -/
theorem sum_add_special_count_mod (m : ℕ) (hm : 2 ≤ m) (S : Multiset ℕ) :
    (∀ a ∈ S, a % m = 0 ∨ a % m = m - 1) →
    (S.sum + (S.filter fun a => a % m = m - 1).card) % m = 0 := by
  induction S using Multiset.induction_on with
  | empty => simp
  | @cons a S ih =>
      intro hres
      have ha := hres a (by simp)
      have hrest : ∀ b ∈ S, b % m = 0 ∨ b % m = m - 1 := by
        intro b hb
        exact hres b (by simp [hb])
      have hih := ih hrest
      rcases ha with ha | ha
      · have hnot : ¬a % m = m - 1 := by omega
        rw [Multiset.sum_cons,
          Multiset.filter_cons_of_neg (p := fun b : ℕ => b % m = m - 1) S hnot]
        calc
          (a + S.sum + (S.filter fun b => b % m = m - 1).card) % m =
              (a + (S.sum + (S.filter fun b => b % m = m - 1).card)) % m := by
                congr 1; omega
          _ = 0 := by rw [Nat.add_mod, ha, hih]; simp
      · have haone : (a + 1) % m = 0 := by
          rw [Nat.add_mod, ha, Nat.mod_eq_of_lt (show 1 < m by omega)]
          have hmone : m - 1 + 1 = m := by omega
          simp [hmone]
        rw [Multiset.sum_cons,
          Multiset.filter_cons_of_pos (p := fun b : ℕ => b % m = m - 1) S ha,
          Multiset.card_cons]
        calc
          (a + S.sum + ((S.filter fun b => b % m = m - 1).card + 1)) % m =
              ((a + 1) + (S.sum + (S.filter fun b => b % m = m - 1).card)) % m := by
                congr 1; omega
          _ = 0 := by rw [Nat.add_mod, haone, hih]; simp

/-- A putative target sum with residue 1 requires at least m-1 summands
of residue -1. This conclusion counts multiplicity. -/
theorem special_count_ge (m t : ℕ) (hm : 2 ≤ m) (ht : t % m = 1)
    (S : Multiset ℕ)
    (hres : ∀ a ∈ S, a % m = 0 ∨ a % m = m - 1)
    (hsum : S.sum = t) :
    m - 1 ≤ (S.filter fun a => a % m = m - 1).card := by
  have hz := sum_add_special_count_mod m hm S hres
  rw [hsum] at hz
  by_contra hsmall
  have hk : (S.filter fun a => a % m = m - 1).card < m - 1 := by omega
  rw [Nat.add_mod, ht,
    Nat.mod_eq_of_lt (show (S.filter fun a => a % m = m - 1).card < m by omega),
    Nat.mod_eq_of_lt (show 1 + (S.filter fun a => a % m = m - 1).card < m by omega)] at hz
  omega

private theorem filter_sum_le (S : Multiset ℕ) (p : ℕ → Prop) [DecidablePred p] :
    (S.filter p).sum ≤ S.sum := by
  induction S using Multiset.induction_on with
  | empty => simp
  | cons a S ih =>
      by_cases ha : p a
      · simpa only [Multiset.filter_cons_of_pos S ha, Multiset.sum_cons] using
          Nat.add_le_add_left ih a
      · rw [Multiset.filter_cons_of_neg S ha, Multiset.sum_cons]
        omega

/-- An actual finite multiset of natural numbers cannot sum to t if each
entry is either divisible by m, or has residue -1 and is strictly above t/(m-1).
The conclusion also covers the empty multiset. -/
theorem multiset_sum_ne_target (m t : ℕ) (hm : 2 ≤ m) (ht : t % m = 1)
    (S : Multiset ℕ)
    (hentry : ∀ a ∈ S,
      a % m = 0 ∨ (a % m = m - 1 ∧ t < (m - 1) * a)) :
    S.sum ≠ t := by
  intro hsum
  have hres : ∀ a ∈ S, a % m = 0 ∨ a % m = m - 1 := by
    intro a ha
    exact (hentry a ha).imp_right And.left
  have hcard := special_count_ge m t hm ht S hres hsum
  let U := S.filter fun a => a % m = m - 1
  have hcardU : m - 1 ≤ U.card := hcard
  have hposU : 0 < U.card := by omega
  obtain ⟨a, ha⟩ := Multiset.card_pos_iff_exists_mem.mp hposU
  have hbig : ∀ b ∈ U, t < (m - 1) * b := by
    intro b hb
    have hmem := Multiset.mem_filter.mp hb
    rcases hentry b hmem.1 with hz | hlarge
    · omega
    · exact hlarge.2
  have hstrict :
      (U.map fun _ : ℕ => t).sum < (U.map fun b => (m - 1) * b).sum :=
    Multiset.sum_lt_sum
      (by intro b hb; exact le_of_lt (hbig b hb))
      ⟨a, ha, hbig a ha⟩
  have hweighted : U.card * t < (m - 1) * U.sum := by
    have hmap : (U.map fun b => (m - 1) * b).sum = (m - 1) * U.sum := by
      simpa only [id_eq, Multiset.map_id, Multiset.map_id'] using
        (Multiset.sum_map_mul_left (s := U) (a := m - 1) (f := id))
    rw [hmap] at hstrict
    simpa using hstrict
  have hfilter : U.sum ≤ S.sum := filter_sum_le S _
  have hupper : (m - 1) * U.sum ≤ (m - 1) * t := by
    exact Nat.mul_le_mul_left (m - 1) (hsum ▸ hfilter)
  have hlower : (m - 1) * t ≤ U.card * t := Nat.mul_le_mul_right t hcardU
  omega

/-- The multiset result specialized to a finite set, hence to distinct terms. -/
theorem finset_sum_ne_target (m t : ℕ) (hm : 2 ≤ m) (ht : t % m = 1)
    (S : Finset ℕ)
    (hentry : ∀ a ∈ S,
      a % m = 0 ∨ (a % m = m - 1 ∧ t < (m - 1) * a)) :
    S.sum id ≠ t := by
  have h := multiset_sum_ne_target m t hm ht S.val (by simpa using hentry)
  simpa only [Finset.sum_val] using h

/-- An ambient finite set with the modular/size property avoids the target
in every one of its finite subsets; no nonemptiness guard is needed. -/
theorem every_subset_sum_ne_target (m t : ℕ) (hm : 2 ≤ m) (ht : t % m = 1)
    (A : Finset ℕ)
    (hentry : ∀ a ∈ A,
      a % m = 0 ∨ (a % m = m - 1 ∧ t < (m - 1) * a)) :
    ∀ S ⊆ A, S.sum id ≠ t := by
  intro S hS
  exact finset_sum_ne_target m t hm ht S (by
    intro a ha
    exact hentry a (hS ha))

end EStarSharpness

#print axioms EStarSharpness.sum_add_special_count_mod
#print axioms EStarSharpness.special_count_ge
#print axioms EStarSharpness.multiset_sum_ne_target
#print axioms EStarSharpness.finset_sum_ne_target
#print axioms EStarSharpness.every_subset_sum_ne_target
