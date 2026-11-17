import LiouvilleGoldbach
import Mathlib.NumberTheory.ArithmeticFunction.Misc

/-!
# A machine-checked certificate for the logical gap

This file records elementary facts that delimit the September 2026
Liouville--Goldbach theorem:

1. Binary Goldbach implies Liouville--Goldbach (the easy direction).
2. The predicate `liouville n = -1` does not imply `n` is prime: `8` is a
   counterexample, and `20 = 8 + 12` is a Liouville--Goldbach witness whose
   two summands are both composite.
3. Binary Goldbach is equivalent to the strengthened Liouville--Goldbach
   statement in which both summands have at most two prime factors.  The
   missing ingredient in the September theorem is exactly this Omega-bound.

Nothing here asserts the unstrengthened converse.  The file is a formal
description of the missing step, not a proof of binary Goldbach.
-/

namespace LiouvilleGoldbach

open Final

/-- The binary Goldbach conjecture, as a proposition. -/
def BinaryGoldbach : Prop :=
  ∀ N : ℕ, Even N → 2 < N →
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p + q = N

/-- Binary Goldbach implies the Liouville--Goldbach theorem. -/
theorem binary_goldbach_implies_liouville_goldbach (h : BinaryGoldbach) :
    ∀ N : ℕ, Even N → 2 < N →
      ∃ a b : ℕ, 0 < a ∧ 0 < b ∧ a + b = N ∧
        ArithmeticFunction.liouville a = -1 ∧
        ArithmeticFunction.liouville b = -1 := by
  intro N hEven hN
  rcases h N hEven hN with ⟨p, q, hp, hq, hpq⟩
  exact ⟨p, q, hp.pos, hq.pos, hpq, liouville_prime hp, liouville_prime hq⟩

/-- `8` has Liouville value `-1` but is not prime. -/
theorem liouville_negative_not_prime :
    ¬ ∀ n : ℕ, ArithmeticFunction.liouville n = -1 → n.Prime := by
  intro h
  have h2 : ArithmeticFunction.liouville 2 = -1 := liouville_prime Nat.prime_two
  have h4 : ArithmeticFunction.liouville 4 = 1 := by
    rw [show 4 = 2 * 2 by norm_num,
      ArithmeticFunction.liouville_apply_mul, h2]
    norm_num
  have h8 : ArithmeticFunction.liouville 8 = -1 := by
    rw [show 8 = 2 * 4 by norm_num,
      ArithmeticFunction.liouville_apply_mul, h2, h4]
    norm_num
  have hp8 : Nat.Prime 8 := h 8 h8
  exact (by decide : ¬ Nat.Prime 8) hp8

/-- A Liouville--Goldbach witness can consist of two composite numbers. -/
theorem liouville_witness_can_be_composite :
    ∃ N a b : ℕ, 0 < a ∧ 0 < b ∧ a + b = N ∧
      ArithmeticFunction.liouville a = -1 ∧
      ArithmeticFunction.liouville b = -1 ∧
      ¬ a.Prime ∧ ¬ b.Prime := by
  have h2 : ArithmeticFunction.liouville 2 = -1 := liouville_prime Nat.prime_two
  have h3 : ArithmeticFunction.liouville 3 = -1 := liouville_prime Nat.prime_three
  have h4 : ArithmeticFunction.liouville 4 = 1 := by
    rw [show 4 = 2 * 2 by norm_num,
      ArithmeticFunction.liouville_apply_mul, h2]
    norm_num
  have h8 : ArithmeticFunction.liouville 8 = -1 := by
    rw [show 8 = 2 * 4 by norm_num,
      ArithmeticFunction.liouville_apply_mul, h2, h4]
    norm_num
  have h12 : ArithmeticFunction.liouville 12 = -1 := by
    rw [show 12 = 3 * 4 by norm_num,
      ArithmeticFunction.liouville_apply_mul, h3, h4]
    norm_num
  refine ⟨20, 8, 12, by norm_num, by norm_num, by norm_num, h8, h12, ?_, ?_⟩
  · exact (by decide : ¬ Nat.Prime 8)
  · exact (by decide : ¬ Nat.Prime 12)

/-- The `p = 7` case of the positive-positive pair theorem: `14 = 4 + 10`. -/
theorem positive_prime_pairs_seven :
    ∃ a b : ℕ, 0 < a ∧ 0 < b ∧ a + b = 14 ∧
      ArithmeticFunction.liouville a = 1 ∧ ArithmeticFunction.liouville b = 1 := by
  have h2 : ArithmeticFunction.liouville 2 = -1 := liouville_prime Nat.prime_two
  have h5 : ArithmeticFunction.liouville 5 = -1 := liouville_prime (by decide : Nat.Prime 5)
  have h4 : ArithmeticFunction.liouville 4 = 1 := by
    rw [show 4 = 2 * 2 by norm_num,
      ArithmeticFunction.liouville_apply_mul, h2]
    norm_num
  have h10 : ArithmeticFunction.liouville 10 = 1 := by
    rw [show 10 = 2 * 5 by norm_num,
      ArithmeticFunction.liouville_apply_mul, h2, h5]
    norm_num
  exact ⟨4, 10, by norm_num, by norm_num, by norm_num, h4, h10⟩

/-- If `n > 1`, `lambda n = -1`, and `Omega n <= 2`, then `n` is prime.
The only odd value of `Omega n` below two is one. -/
theorem prime_of_liouville_negative_of_cardFactors_le_two
    {n : ℕ} (hn : 1 < n)
    (hlam : ArithmeticFunction.liouville n = -1)
    (hOm : ArithmeticFunction.cardFactors n ≤ 2) : n.Prime := by
  have hpos : 0 < ArithmeticFunction.cardFactors n :=
    ArithmeticFunction.cardFactors_pos_iff_one_lt.mpr hn
  have hne2 : ArithmeticFunction.cardFactors n ≠ 2 := by
    intro h2
    rw [ArithmeticFunction.liouville_apply (by omega : n ≠ 0), h2] at hlam
    norm_num at hlam
  have h1 : ArithmeticFunction.cardFactors n = 1 := by omega
  exact ArithmeticFunction.cardFactors_eq_one_iff_prime.mp h1

/-- The strengthened Liouville--Goldbach statement with an Omega-bound of two. -/
def LiouvilleGoldbachOmegaTwo : Prop :=
  ∀ N : ℕ, Even N → 2 < N →
    ∃ a b : ℕ, 0 < a ∧ 0 < b ∧ a + b = N ∧
      ArithmeticFunction.liouville a = -1 ∧
      ArithmeticFunction.liouville b = -1 ∧
      ArithmeticFunction.cardFactors a ≤ 2 ∧
      ArithmeticFunction.cardFactors b ≤ 2

/-- The `Omega <= k` strengthening of Liouville--Goldbach. -/
def LiouvilleGoldbachOmegaLe (k : ℕ) : Prop :=
  ∀ N : ℕ, Even N → 2 < N →
    ∃ a b : ℕ, 0 < a ∧ 0 < b ∧ a + b = N ∧
      ArithmeticFunction.liouville a = -1 ∧
      ArithmeticFunction.liouville b = -1 ∧
      ArithmeticFunction.cardFactors a ≤ k ∧
      ArithmeticFunction.cardFactors b ≤ k

/-- Binary Goldbach implies the `Omega <= k` strengthening for every `k >= 2`. -/
theorem binary_goldbach_implies_omega_le (k : ℕ) (hk : 2 ≤ k) :
    BinaryGoldbach → LiouvilleGoldbachOmegaLe k := by
  intro h N hEven hN
  rcases h N hEven hN with ⟨p, q, hp, hq, hpq⟩
  refine ⟨p, q, hp.pos, hq.pos, hpq, liouville_prime hp, liouville_prime hq, ?_, ?_⟩
  · rw [ArithmeticFunction.cardFactors_apply_prime hp]
    omega
  · rw [ArithmeticFunction.cardFactors_apply_prime hq]
    omega

/-- Binary Goldbach is equivalent to the Omega-two strengthening of
Liouville--Goldbach.  The unstrengthened theorem omits exactly this bound. -/
theorem binary_goldbach_iff_liouville_omega_two :
    BinaryGoldbach ↔ LiouvilleGoldbachOmegaTwo := by
  constructor
  · intro h N hEven hN
    rcases h N hEven hN with ⟨p, q, hp, hq, hpq⟩
    refine ⟨p, q, hp.pos, hq.pos, hpq, liouville_prime hp, liouville_prime hq, ?_, ?_⟩
    · rw [ArithmeticFunction.cardFactors_apply_prime hp]
      norm_num
    · rw [ArithmeticFunction.cardFactors_apply_prime hq]
      norm_num
  · intro h N hEven hN
    rcases h N hEven hN with ⟨a, b, ha, hb, hab, hlama, hlamb, hOma, hOmb⟩
    have ha1 : 1 < a := by
      by_contra hlt
      have haeq : a = 1 := by omega
      subst a
      norm_num [ArithmeticFunction.liouville_apply_one] at hlama
    have hb1 : 1 < b := by
      by_contra hlt
      have hbeq : b = 1 := by omega
      subst b
      norm_num [ArithmeticFunction.liouville_apply_one] at hlamb
    exact ⟨a, b, prime_of_liouville_negative_of_cardFactors_le_two ha1 hlama hOma,
      prime_of_liouville_negative_of_cardFactors_le_two hb1 hlamb hOmb, hab⟩

end LiouvilleGoldbach

/-! ## Audit output -/
#check LiouvilleGoldbach.BinaryGoldbach
#check LiouvilleGoldbach.binary_goldbach_implies_liouville_goldbach
#check LiouvilleGoldbach.liouville_negative_not_prime
#check LiouvilleGoldbach.liouville_witness_can_be_composite
#check LiouvilleGoldbach.prime_of_liouville_negative_of_cardFactors_le_two
#check LiouvilleGoldbach.binary_goldbach_iff_liouville_omega_two
#print axioms LiouvilleGoldbach.binary_goldbach_implies_liouville_goldbach
#print axioms LiouvilleGoldbach.liouville_negative_not_prime
#print axioms LiouvilleGoldbach.liouville_witness_can_be_composite
#print axioms LiouvilleGoldbach.prime_of_liouville_negative_of_cardFactors_le_two
#print axioms LiouvilleGoldbach.binary_goldbach_iff_liouville_omega_two
#check LiouvilleGoldbach.positive_prime_pairs_seven
#check LiouvilleGoldbach.LiouvilleGoldbachOmegaLe
#check LiouvilleGoldbach.binary_goldbach_implies_omega_le
#print axioms LiouvilleGoldbach.positive_prime_pairs_seven
#print axioms LiouvilleGoldbach.binary_goldbach_implies_omega_le