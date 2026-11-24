import LiouvilleGoldbach

/-!
# BarrierLemma: 刘维尔符号只控制 `Ω` 的奇偶，不控制大小

哥德巴赫猜想与 LG 的差别不在“符号”，而在 `Ω` 的大小：
`LG` 只保证每个偶数有 `λ(a) = λ(b) = -1` 的分解，而 `λ(n) = -1` 只等价于
`Ω(n)` 为奇数（含 `Ω(8) = 3`、`Ω(12) = 3` 这类合数）。

本文件把这条“屏障”的最小形式做成内核事实：

* `exists_liouville_neg_omega_eq`：对每个**奇数** `k`，都有 `λ(n) = -1` 且 `Ω(n) = k` 的 `n`（取 `n = 3^k`）；
* `lambda_neg_omega_unbounded`：因此 `λ = -1` 不给出 `Ω` 的任何常数上界；
* `liouville_eight_omega_three`：最小见证 `8`，`λ(8) = -1`、`Ω(8) = 3`。

这些不是对 GC 的进展，而是把“为什么只看 `λ` 推不出素数”写成可复核的定理。
-/

namespace LiouvilleGoldbach

/-- 对每个奇数 `k`，存在 `n` 使 `λ(n) = -1` 且 `Ω(n) = k`（取 `n = 3^k`）。 -/
theorem exists_liouville_neg_omega_eq (k : ℕ) (hk : Odd k) :
    ∃ n : ℕ, ArithmeticFunction.liouville n = -1 ∧ ArithmeticFunction.cardFactors n = k := by
  refine ⟨3 ^ k, ?_, ?_⟩
  · rw [ArithmeticFunction.liouville_apply (pow_ne_zero k (by norm_num))]
    rw [ArithmeticFunction.cardFactors_apply_prime_pow (show Nat.Prime 3 by decide)]
    exact hk.neg_one_pow
  · rw [ArithmeticFunction.cardFactors_apply_prime_pow (show Nat.Prime 3 by decide)]

/-- `λ = -1` 不给出 `Ω` 的常数上界：每个奇数下界 `k` 都能被某个 `λ = -1` 的数达到。 -/
theorem lambda_neg_omega_unbounded (k : ℕ) (hk : Odd k) :
    ∃ n : ℕ, ArithmeticFunction.liouville n = -1 ∧ k ≤ ArithmeticFunction.cardFactors n := by
  obtain ⟨n, hlam, homega⟩ := exists_liouville_neg_omega_eq k hk
  exact ⟨n, hlam, by omega⟩

/-- 最小见证：`8` 满足 `λ(8) = -1` 且 `Ω(8) = 3`（`8 = 2^3`）。 -/
theorem liouville_eight_omega_three :
    ArithmeticFunction.liouville 8 = -1 ∧ ArithmeticFunction.cardFactors 8 = 3 := by
  have h8 : (8 : ℕ) = 2 ^ 3 := by norm_num
  constructor
  · rw [h8, ArithmeticFunction.liouville_apply (pow_ne_zero 3 (by norm_num)),
      ArithmeticFunction.cardFactors_apply_prime_pow (show Nat.Prime 2 by decide)]
    norm_num
  · rw [h8, ArithmeticFunction.cardFactors_apply_prime_pow (show Nat.Prime 2 by decide)]

end LiouvilleGoldbach

#check LiouvilleGoldbach.exists_liouville_neg_omega_eq
#check LiouvilleGoldbach.lambda_neg_omega_unbounded
#check LiouvilleGoldbach.liouville_eight_omega_three
#print axioms LiouvilleGoldbach.exists_liouville_neg_omega_eq
#print axioms LiouvilleGoldbach.lambda_neg_omega_unbounded
#print axioms LiouvilleGoldbach.liouville_eight_omega_three
