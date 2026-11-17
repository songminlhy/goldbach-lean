import LiouvilleGoldbach

/-!
# v0.3.1: the `p ≥ 11` interval is non-empty

The paper's commuting-square step uses an integer `n` with
`p / 6 < n < p / 4`.  For `p = 7` the open interval is empty; the paper
handles it separately (`positive_prime_pairs_seven`).  For prime `p ≥ 11`,
`n = p / 4` lies strictly inside the interval.  This file records that
arithmetic fact as a standalone Lean theorem, so that the `p ≥ 11` side of
the written proof is also kernel-checked.

This file was added in v0.3.1: it is part of the sealed v0.3.1 manifest
(104 files).  It is **not** part of the sealed v0.3.0 manifest (103 files)
or of the `lg-v0.3.0` tag, so v0.3.0 stays exactly as published.
-/

namespace LiouvilleGoldbach

/-- For every prime `p ≥ 11`, the open interval `(p/6, p/4)` contains an
integer: `n = p / 4` satisfies `p < 6 * n` and `4 * n < p`. -/
theorem exists_nat_between_sixth_and_fourth {p : ℕ} (hp : p.Prime) (h11 : 11 ≤ p) :
    ∃ n : ℕ, p < 6 * n ∧ 4 * n < p := by
  refine ⟨p / 4, ?_, ?_⟩
  · have hq2 : 2 ≤ p / 4 := by
      rw [Nat.le_div_iff_mul_le (by norm_num : 0 < 4)]
      omega
    have hr : p % 4 < 4 := Nat.mod_lt _ (by norm_num)
    have hpdecomp : p = 4 * (p / 4) + p % 4 := (Nat.div_add_mod p 4).symm
    omega
  · have hq2 : 2 ≤ p / 4 := by
      rw [Nat.le_div_iff_mul_le (by norm_num : 0 < 4)]
      omega
    have hr : p % 4 < 4 := Nat.mod_lt _ (by norm_num)
    have hpdecomp : p = 4 * (p / 4) + p % 4 := (Nat.div_add_mod p 4).symm
    have hne : p % 4 ≠ 0 := by
      intro h0
      have h4dvd : 4 ∣ p := by
        use p / 4
        omega
      have h2dvd : 2 ∣ p := dvd_trans (by norm_num : 2 ∣ 4) h4dvd
      have hp2 : p = 2 := (hp.dvd_iff_eq (by norm_num : 2 ≠ 1)).mp h2dvd
      omega
    omega

end LiouvilleGoldbach

#check LiouvilleGoldbach.exists_nat_between_sixth_and_fourth
#print axioms LiouvilleGoldbach.exists_nat_between_sixth_and_fourth
