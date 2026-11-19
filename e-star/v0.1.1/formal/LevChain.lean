import Mathlib.Tactic

/-!
Constant bookkeeping for the E* paper ("以 Lev 增长界改进禁用子集和逆定理的范围").

Every theorem below is a purely arithmetic step of the paper's proof: the
minimum truncation in Lev's increment (Lemma 2.2), the normalised density
margin (Theorem 1, step 3), the central-interval window (Lemma 3.3), the
range-constant window of Corollary 5.2, and the two ratio bounds used in
Theorem 2.  None of them formalizes Lev's theorem, Roth's theorem, the
distinctification bridge, or the asymptotic limits; those remain paper-level
arguments.
-/

namespace EStarChain

/-- Lemma 2.2, truncation step.  If `2 <= j`, `j + 1 <= q`, `q <= L` and
`L/q + 2 <= N`, then the minimum occurring in Lev's increment is at least
`j*L/q + 1`.  This is the step that uses both `j <= q-1` and `q <= L`. -/
theorem min_step (L N q j : ℝ) (hq : 1 ≤ q) (hL : q ≤ L)
    (hN : L / q + 2 ≤ N) (hj2 : 2 ≤ j) (hjq : j + 1 ≤ q) :
    j * L / q + 1 ≤ min L (j * (N - 2) + 1) := by
  have hq0 : (0:ℝ) < q := by linarith
  have hjL : j * L ≤ (q - 1) * L := by nlinarith
  have hleft : j * L / q + 1 ≤ L := by
    have hkey : j * L ≤ (L - 1) * q := by nlinarith
    have := (div_le_iff₀ hq0).mpr hkey
    linarith
  have hright : j * L / q + 1 ≤ j * (N - 2) + 1 := by
    have h1 : L / q ≤ N - 2 := by linarith
    have h2 : j * (L / q) ≤ j * (N - 2) := by nlinarith
    have h3 : j * L / q = j * (L / q) := by ring
    linarith
  exact le_min hleft hright

/-- Theorem 1, step 3: the `+2` in the normalised density hypothesis.
If `|G| >= E/q + eps*T/2`, `eps*T/2 >= q`, `L <= E` and `q >= 1`, then
`|B| = |G| + 1 >= L/q + 2`. -/
theorem normalized_density (Gcard E L T q eps : ℝ)
    (hq : 1 ≤ q) (h1 : E / q + eps * T / 2 ≤ Gcard)
    (h2 : q ≤ eps * T / 2) (h3 : L ≤ E) :
    L / q + 2 ≤ Gcard + 1 := by
  have hq0 : (0:ℝ) < q := by linarith
  have hLE : L / q ≤ E / q := by gcongr
  linarith

/-- Lemma 3.3, window step.  With `0 < K`, `K + 1 <= J`, `L <= D`, `0 <= L`,
`0 <= gamma <= D` and `D <= y <= K*L`, the integer `y` lies in
`[gamma, J*D - gamma]`. -/
theorem basis_window (L D K J gamma y : ℝ) (hK : 0 < K) (hJ : K + 1 ≤ J)
    (hL0 : 0 ≤ L) (hLD : L ≤ D) (hgD : gamma ≤ D)
    (hyD : D ≤ y) (hyK : y ≤ K * L) :
    gamma ≤ y ∧ y ≤ J * D - gamma := by
  constructor
  · linarith
  · have h1 : y ≤ (J - 1) * L := by nlinarith
    have h2 : (J - 1) * L ≤ (J - 1) * D := by nlinarith
    have h3 : (J - 1) * D = J * D - D := by ring
    linarith

/-- Corollary 5.2, range window: for `q >= 4` the known lower bound
`max{2, q-2+1/q}` does not exceed the new upper bound `q - 1`. -/
theorem theta_window (q : ℝ) (hq : 4 ≤ q) :
    max 2 (q - 2 + 1 / q) ≤ q - 1 := by
  have hq0 : (0:ℝ) < q := by linarith
  have h1 : 1 / q ≤ 1 := by
    have := (div_le_iff₀ hq0).mpr (by linarith : (1:ℝ) ≤ 1 * q)
    linarith
  exact max_le (by linarith) (by linarith)

/-- Theorem 2, upper bound: for `eps > 0` and `T >= 1/eps`,
`((3/2 + eps)T + 1)/(6T) <= 1/4 + eps/3`. -/
theorem ratio_upper (T eps : ℝ) (heps : 0 < eps) (hT : 1 / eps ≤ T) :
    ((3 / 2 + eps) * T + 1) / (6 * T) ≤ 1 / 4 + eps / 3 := by
  have hT0 : 0 < T := by
    have : 0 < 1 / eps := by positivity
    linarith
  have hTeps : 1 ≤ eps * T := by
    have h := mul_le_mul_of_nonneg_left hT (le_of_lt heps)
    have h' : eps * (1 / eps) = 1 := by
      field_simp
    rw [mul_comm] at h
    linarith
  rw [div_le_iff₀ (by positivity : (0:ℝ) < 6 * T)]
  nlinarith [hTeps]

/-- Theorem 2, lower bound: for `T > 0`, `(3T+1)/2 / (6T) >= 1/4`. -/
theorem ratio_lower (T : ℝ) (hT : 0 < T) :
    1 / 4 ≤ ((3 * T + 1) / 2) / (6 * T) := by
  rw [le_div_iff₀ (by positivity : (0:ℝ) < 6 * T)]
  nlinarith

#print axioms min_step
#print axioms normalized_density
#print axioms basis_window
#print axioms theta_window
#print axioms ratio_upper
#print axioms ratio_lower

end EStarChain
