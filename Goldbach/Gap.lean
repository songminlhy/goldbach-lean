import Goldbach.Statement
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# The 1+1 gap, formally

This module makes the difference between the headline endpoints of this
development and the binary Goldbach conjecture a machine-checked object.

* `BinaryGoldbach` is the strong (binary) Goldbach statement: every sufficiently
  large even natural number is a sum of two primes.
* `OnePlusOneNineShape` and `OnePlusOne8938Shape` transcribe the literal types of
  the Li-Liu 1+1.9 and Wu 1+1.8938 endpoints. The Li-Liu shape is the type printed
  for `Goldbach.one_plus_one_nine` in `goldbach/logs/audit_liliu_check.log`; see
  `docs/GAP.md` for the transcription and the re-enableable definitional check.
* `binaryGoldbach_implies_chen`, `binaryGoldbach_implies_onePlusOneNine` and
  `binaryGoldbach_implies_onePlusOne8938` prove that all three endpoints are
  *consequences* of binary Goldbach: substitute the second multiplier `r = 1`.
  No converse is proved here (and none can be: Chen's theorem is already proved,
  so a converse would settle Goldbach).
* `goldbachCount` counts ordered prime pairs, and `goldbachCount_pos_iff`
  identifies positivity of that count with an actual representation.
* `PaperTheorem` is the statement of Theorem 1.1 of
  `A_Simple_Proof_of_Goldbach_Conjecture.tex` under the paper's own definition of
  `O` (a limit ratio equal to a nonzero constant).
  `paperTheorem_implies_binaryGoldbach` proves that this statement already
  implies binary Goldbach. This is the machine-checked form of the circularity
  in Section 3.1 of `AUDIT_2026-11-15.md`: the paper's `O` is not the standard
  upper-bound notation, and its theorem is not weaker than the conjecture.
-/

namespace Goldbach

/-! ## The target statement -/

/-- Binary (strong) Goldbach: every sufficiently large even natural number is a
sum of two primes. The threshold is existential, exactly as in `ChenTheorem`. -/
def BinaryGoldbach : Prop :=
  ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N → Even N →
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N = p + q

/-! ## The three headline endpoints, in their literal shapes -/

/-- The literal type of `Goldbach.one_plus_one_nine`: `N = p + r * q` with `r = 1`
or `r` prime and `r ^ 10 ≤ q ^ 9`. -/
def OnePlusOneNineShape : Prop :=
  ∃ K : ℕ, 4 ≤ K ∧ ∀ N ≥ K, Even N → ∃ p r q : ℕ,
    p ≤ N ∧ p.Prime ∧ (r = 1 ∨ r.Prime) ∧ q.Prime ∧
      N = p + r * q ∧ r ^ 10 ≤ q ^ 9

/-- The literal type of `WuPaper.ClassicalSlots.one8938`:
`N = p + r * q` with `r = 1` or `r` prime and `r ^ 5000 ≤ q ^ 4469`. -/
def OnePlusOne8938Shape : Prop :=
  ∃ T : ℕ, T ≥ 512 ∧ ∀ N ≥ T, Even N → ∃ p r q : ℕ,
    p.Prime ∧ (r = 1 ∨ r.Prime) ∧ q.Prime ∧
      N = p + r * q ∧ r ^ 5000 ≤ q ^ 4469

/-! ## 1+1 implies every headline endpoint -/

/-- Binary Goldbach implies Chen's 1+2 endpoint: a prime second summand is also
a prime or a product of two primes. -/
theorem binaryGoldbach_implies_chen (h : BinaryGoldbach) : ChenTheorem := by
  unfold BinaryGoldbach at h
  obtain ⟨N₀, hN₀⟩ := h
  unfold ChenTheorem
  refine ⟨N₀, ?_⟩
  intro N hN hEven
  obtain ⟨p, q, hp, hq, hsum⟩ := hN₀ N hN hEven
  exact ⟨p, q, hp, Or.inl hq, hsum⟩

/-- Binary Goldbach implies the Li-Liu 1+1.9 endpoint: take `r = 1`. -/
theorem binaryGoldbach_implies_onePlusOneNine (h : BinaryGoldbach) : OnePlusOneNineShape := by
  unfold BinaryGoldbach at h
  obtain ⟨N₀, hN₀⟩ := h
  refine ⟨max N₀ 4, le_max_right _ _, ?_⟩
  intro N hN hEven
  have hN₀' : N₀ ≤ N := le_trans (le_max_left _ _) hN
  obtain ⟨p, q, hp, hq, hsum⟩ := hN₀ N hN₀' hEven
  refine ⟨p, 1, q, ?_, hp, Or.inl rfl, hq, ?_, ?_⟩
  · omega
  · simpa using hsum
  · have hq0 : 0 < q := hq.pos
    simpa using Nat.one_le_pow 9 q hq0

/-- Binary Goldbach implies the Wu 1+1.8938 endpoint: take `r = 1`. -/
theorem binaryGoldbach_implies_onePlusOne8938 (h : BinaryGoldbach) : OnePlusOne8938Shape := by
  unfold BinaryGoldbach at h
  obtain ⟨N₀, hN₀⟩ := h
  refine ⟨max N₀ 512, le_max_right _ _, ?_⟩
  intro N hN hEven
  have hN₀' : N₀ ≤ N := le_trans (le_max_left _ _) hN
  obtain ⟨p, q, hp, hq, hsum⟩ := hN₀ N hN₀' hEven
  refine ⟨p, 1, q, hp, Or.inl rfl, hq, ?_, ?_⟩
  · simpa using hsum
  · have hq0 : 0 < q := hq.pos
    simpa using Nat.one_le_pow 4469 q hq0

/-! ## The gap is inhabited: the endpoint predicates admit what 1+1 forbids -/

/-- Chen's second summand is allowed to be composite: `4 = 2 * 2` is admitted by
the `q.Prime ∨ ∃ r s, ...` clause, while `4` is not prime. -/
theorem chen_second_summand_class_includes_composite :
    ∃ q : ℕ, (q.Prime ∨ ∃ r s : ℕ, r.Prime ∧ s.Prime ∧ q = r * s) ∧ ¬ q.Prime :=
  ⟨4, Or.inr ⟨2, 2, by decide, by decide, rfl⟩, by decide⟩

/-- The Li-Liu multiplier `r` is allowed to be a prime other than `1`:
`18 = 3 + 3 * 5` with `3 ^ 10 ≤ 5 ^ 9`. This is not a 1+1 representation. -/
theorem liu_multiplier_class_includes_nontrivial :
    ∃ N p r q : ℕ, p.Prime ∧ (r = 1 ∨ r.Prime) ∧ q.Prime ∧
      N = p + r * q ∧ r ^ 10 ≤ q ^ 9 ∧ r ≠ 1 :=
  ⟨18, 3, 3, 5, by decide, Or.inr (by decide), by decide,
    by norm_num, by norm_num, by norm_num⟩

/-- The Wu multiplier `r` is likewise allowed to be `2 ≠ 1`: `13 = 7 + 2 * 3`
with `2 ^ 5000 ≤ 3 ^ 4469`. -/
theorem wu_multiplier_class_includes_nontrivial :
    ∃ N p r q : ℕ, p.Prime ∧ (r = 1 ∨ r.Prime) ∧ q.Prime ∧
      N = p + r * q ∧ r ^ 5000 ≤ q ^ 4469 ∧ r ≠ 1 := by
  have hpow : 2 ^ 5000 ≤ 3 ^ 4469 := by
    have h32 : (2 : ℕ) ^ 5000 = 32 ^ 1000 := by
      rw [show (32 : ℕ) = 2 ^ 5 by norm_num, ← pow_mul]
    have hlt : (32 : ℕ) ^ 1000 < 81 ^ 1000 :=
      Nat.pow_lt_pow_left (by omega) (by omega)
    have hle : (81 : ℕ) ^ 1000 ≤ 3 ^ 4469 := by
      rw [show (81 : ℕ) = 3 ^ 4 by norm_num, ← pow_mul]
      exact Nat.pow_le_pow_right (by norm_num) (by norm_num)
    rw [h32]
    exact le_trans (le_of_lt hlt) hle
  exact ⟨13, 7, 2, 3, by decide, Or.inr (by decide), by decide,
    by norm_num, hpow, by norm_num⟩

/-! ## The paper's Theorem 1.1 already implies 1+1 -/

/-- The number of ordered representations of `N` as a sum of two primes. This is
the paper's `G` with a range that also admits `p = 2`; the two counts differ only
at small arguments and have the same asymptotic behaviour. -/
def goldbachCount (N : ℕ) : ℕ :=
  ((Finset.range (N + 1)).filter (fun p : ℕ => p.Prime ∧ (N - p).Prime)).card

/-- A positive `goldbachCount` is exactly an actual representation. -/
theorem goldbachCount_pos_iff {N : ℕ} :
    0 < goldbachCount N ↔ ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N = p + q := by
  constructor
  · intro h
    unfold goldbachCount at h
    obtain ⟨p, hp⟩ := Finset.card_pos.mp h
    rw [Finset.mem_filter] at hp
    obtain ⟨hp_range, hp_prime, hq_prime⟩ := hp
    rw [Finset.mem_range] at hp_range
    exact ⟨p, N - p, hp_prime, hq_prime, by omega⟩
  · rintro ⟨p, q, hp, hq, rfl⟩
    unfold goldbachCount
    rw [Finset.card_pos]
    refine ⟨p, ?_⟩
    rw [Finset.mem_filter, Finset.mem_range]
    have hsub : p + q - p = q := by omega
    exact ⟨by omega, hp, by simpa [hsub] using hq⟩

/-- Theorem 1.1 of the paper under its own definition of `O`: the ratio
`G(2n) * log(2n)^2 / n` tends to a nonzero constant. -/
def PaperTheorem : Prop :=
  ∃ c : ℝ, c ≠ 0 ∧
    Filter.Tendsto
      (fun n : ℕ => (goldbachCount (2 * n) : ℝ) * Real.log (2 * n : ℝ) ^ 2 / (n : ℝ))
      Filter.atTop (nhds c)

/-- Under the paper's `O`, Theorem 1.1 forces a positive count of Goldbach pairs
for every sufficiently large even number. So the paper's theorem already
contains binary Goldbach: the induction step that assumes `G(2n-2) > 0` assumes
the conclusion. -/
theorem paperTheorem_implies_binaryGoldbach (h : PaperTheorem) : BinaryGoldbach := by
  unfold PaperTheorem at h
  obtain ⟨c, hc0, hc⟩ := h
  have hnonneg : (fun _ : ℕ => (0 : ℝ)) ≤ᶠ[Filter.atTop]
      (fun n : ℕ => (goldbachCount (2 * n) : ℝ) * Real.log (2 * n : ℝ) ^ 2 / (n : ℝ)) := by
    filter_upwards with n
    have h1 : (0 : ℝ) ≤ (goldbachCount (2 * n) : ℝ) := by positivity
    have h2 : (0 : ℝ) ≤ Real.log (2 * n : ℝ) ^ 2 := sq_nonneg _
    have h3 : (0 : ℝ) ≤ (n : ℝ) := by positivity
    exact div_nonneg (mul_nonneg h1 h2) h3
  have hcge : 0 ≤ c := le_of_tendsto_of_tendsto tendsto_const_nhds hc hnonneg
  have hcpos : 0 < c := lt_of_le_of_ne hcge (Ne.symm hc0)
  have hpos : ∀ᶠ n : ℕ in Filter.atTop,
      0 < (goldbachCount (2 * n) : ℝ) * Real.log (2 * n : ℝ) ^ 2 / (n : ℝ) :=
    hc.eventually (Ioi_mem_nhds hcpos)
  obtain ⟨A, hA⟩ := Filter.eventually_atTop.mp hpos
  refine ⟨2 * max A 3, ?_⟩
  intro N hN hEven
  obtain ⟨k, rfl⟩ := even_iff_exists_two_mul.mp hEven
  have hk : max A 3 ≤ k := by omega
  have hk0 : (0 : ℝ) < (k : ℝ) := by exact_mod_cast (by omega : 0 < k)
  have hlog : 0 < Real.log (2 * k : ℝ) ^ 2 := by
    have h2k : (1 : ℝ) < (2 * k : ℝ) := by exact_mod_cast (by omega : 1 < 2 * k)
    exact pow_pos (Real.log_pos h2k) 2
  have hlt : 0 < (goldbachCount (2 * k) : ℝ) * Real.log (2 * k : ℝ) ^ 2 := by
    have h := hA k (le_trans (le_max_left _ _) hk)
    have hmul := mul_pos h hk0
    rwa [div_mul_cancel₀ _ (ne_of_gt hk0)] at hmul
  have hcount : 0 < goldbachCount (2 * k) := by
    have hcast : 0 < (goldbachCount (2 * k) : ℝ) :=
      pos_of_mul_pos_left hlt (le_of_lt hlog)
    exact_mod_cast hcast
  obtain ⟨p, q, hp, hq, hpq⟩ := goldbachCount_pos_iff.mp hcount
  exact ⟨p, q, hp, hq, hpq⟩

end Goldbach
