import Goldbach.Gap

/-!
# The endpoint hierarchy

`Goldbach.Gap` proves that binary Goldbach implies each of the three headline
endpoints (Chen 1+2, Li-Liu 1+1.9, Wu 1+1.8938).  This module proves the
implications *between* the endpoints themselves:

```text
BinaryGoldbach  ->  OnePlusOne8938Shape  ->  OnePlusOneNineShape  ->  ChenTheorem
```

The first arrow is `binaryGoldbach_implies_onePlusOne8938` (in `Goldbach.Gap`).
The two new arrows are proved here.

The only arithmetic input is that the Wu exponent pair `(5000, 4469)` is
pointwise at least as strong as the Li-Liu pair `(10, 9)`:

```text
r ^ 5000 <= q ^ 4469  ->  (r ^ 10) ^ 500 <= (q ^ 9) ^ 500  ->  r ^ 10 <= q ^ 9,
```

where the middle step uses `q ^ 4469 <= q ^ 4500` for `q >= 1`.  The final step
from Li-Liu to Chen reads `N = p + r * q` as `N = p + q'` with `q' = r * q`;
when `r` is prime, `q'` is a product of two primes.

The converses are not proved, and cannot be obtained from these materials: Wu
and Li-Liu are already theorems, so a converse from either of them to binary
Goldbach would prove binary Goldbach itself.
-/

namespace Goldbach

/-- A sufficient exponent-comparison criterion for constraints of the form
`r ^ a ≤ q ^ b`: if `b * c ≤ a * d`, then the `(a, b)` constraint implies the
`(c, d)` constraint.  The proof raises the hypothesis to the power `c`, compares
`q ^ (b * c)` with `q ^ (a * d)`, and cancels the common exponent `a`. -/
theorem pow_le_pow_of_mul_le_mul {r q a b c d : ℕ}
    (ha : 0 < a) (hq : 1 ≤ q) (hbc : b * c ≤ a * d)
    (h : r ^ a ≤ q ^ b) : r ^ c ≤ q ^ d := by
  have h1 : (r ^ a) ^ c ≤ (q ^ b) ^ c := Nat.pow_le_pow_left h c
  have h2 : q ^ (b * c) ≤ q ^ (a * d) := Nat.pow_le_pow_right hq hbc
  have h3 : (r ^ c) ^ a ≤ (q ^ d) ^ a := by
    calc
      (r ^ c) ^ a = (r ^ a) ^ c := by
        rw [← pow_mul, Nat.mul_comm, pow_mul]
      _ ≤ (q ^ b) ^ c := h1
      _ = q ^ (b * c) := by rw [pow_mul]
      _ ≤ q ^ (a * d) := h2
      _ = (q ^ d) ^ a := by rw [Nat.mul_comm, pow_mul]
  exact (Nat.pow_le_pow_iff_left ha.ne').mp h3

set_option exponentiation.threshold 5000 in
/-- Wu's exponent pair `(5000, 4469)` is at least as strong as Li-Liu's
`(10, 9)`, because `4469 * 10 ≤ 5000 * 9`.  This is an instance of
`pow_le_pow_of_mul_le_mul`. -/
theorem wu_exponent_implies_liu_exponent {r q : ℕ} (hq : 1 ≤ q)
    (h : r ^ 5000 ≤ q ^ 4469) : r ^ 10 ≤ q ^ 9 :=
  pow_le_pow_of_mul_le_mul (a := 5000) (b := 4469) (c := 10) (d := 9)
    (by norm_num) hq (by norm_num) h

/-- The Wu 1+1.8938 endpoint implies the Li-Liu 1+1.9 endpoint. -/
theorem onePlusOne8938Shape_implies_onePlusOneNineShape
    (h : OnePlusOne8938Shape) : OnePlusOneNineShape := by
  obtain ⟨T, hT, hN⟩ := h
  refine ⟨T, le_trans (by norm_num) hT, ?_⟩
  intro N hTN hEven
  obtain ⟨p, r, q, hp, hr, hq, hsum, hpow⟩ := hN N hTN hEven
  refine ⟨p, r, q, ?_, hp, hr, hq, hsum, ?_⟩
  · calc
      p ≤ p + r * q := Nat.le_add_right p (r * q)
      _ = N := hsum.symm
  · exact wu_exponent_implies_liu_exponent hq.one_le hpow

/-- The Li-Liu 1+1.9 endpoint implies Chen's 1+2 endpoint: the second summand
`r * q` is prime when `r = 1`, and a product of two primes when `r` is prime. -/
theorem onePlusOneNineShape_implies_chen (h : OnePlusOneNineShape) : ChenTheorem := by
  obtain ⟨K, _hK, hN⟩ := h
  refine ⟨K, ?_⟩
  intro N hKN hEven
  obtain ⟨p, r, q, _hpN, hp, hr, hq, hsum, _hpow⟩ := hN N hKN hEven
  refine ⟨p, r * q, hp, ?_, hsum⟩
  rcases hr with rfl | hr
  · simpa using Or.inl hq
  · exact Or.inr ⟨r, q, hr, hq, rfl⟩

/-- The Wu endpoint implies Chen's endpoint, through Li-Liu. -/
theorem onePlusOne8938Shape_implies_chen (h : OnePlusOne8938Shape) : ChenTheorem :=
  onePlusOneNineShape_implies_chen (onePlusOne8938Shape_implies_onePlusOneNineShape h)

/-- The full chain in one statement: binary Goldbach implies Wu, Wu implies
Li-Liu, and Li-Liu implies Chen. -/
theorem binaryGoldbach_implies_endpoint_chain (h : BinaryGoldbach) :
    OnePlusOne8938Shape ∧ OnePlusOneNineShape ∧ ChenTheorem :=
  let hWu := binaryGoldbach_implies_onePlusOne8938 h
  let hLiu := onePlusOne8938Shape_implies_onePlusOneNineShape hWu
  ⟨hWu, hLiu, onePlusOneNineShape_implies_chen hLiu⟩

end Goldbach
