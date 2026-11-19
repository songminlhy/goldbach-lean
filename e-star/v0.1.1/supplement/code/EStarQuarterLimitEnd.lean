import EStarQuarterLimit

namespace EStarQuarterLimit
open Finset Filter Topology
open scoped Classical

theorem quarter_upper_relative_to_lev
    (hLev : EStarBasisFromLev.LevGrowthInput) (ε : ℝ) (hε : 0 < ε) :
    ∃ T₀ : ℕ, ∀ T : ℕ, T₀ ≤ T →
      (F (4*T) (6*T) : ℝ) ≤ (3/2+ε)*T+1 := by
  have hq : ∀ a : ℕ, 0 < a → a < 4 → a ∣ 6 := by
    intro a ha ha4
    interval_cases a <;> norm_num
  obtain ⟨T₁, hinv⟩ := EStarBasisFromLev.main_inverse_relative_to_lev
    hLev 6 4 (by norm_num) (by norm_num) hq ε hε
  refine ⟨max 1 T₁, fun T hT => ?_⟩
  have hTpos : 0 < T := by omega
  have hT1 : T₁ ≤ T := le_trans (le_max_right _ _) hT
  apply F_le_of_bound (4*T) (6*T) ((3/2+ε)*T+1) (by positivity)
  intro A hA hav
  let low := A.filter fun x => x < 2*T
  let high := A.filter fun x => ¬x < 2*T
  have hlowA : low ⊆ A := Finset.filter_subset _ _
  have hhighA : high ⊆ A := Finset.filter_subset _ _
  have hlowI : low ⊆ Finset.Icc 1 (2*T-1) := by
    intro x hx
    obtain ⟨hxA,hx2⟩ := Finset.mem_filter.mp hx
    have hxI := Finset.mem_Icc.mp (hA hxA)
    apply Finset.mem_Icc.mpr
    omega
  have hhighI : high ⊆ Finset.Icc (2*T) (4*T) := by
    intro x hx
    obtain ⟨hxA,hx2⟩ := Finset.mem_filter.mp hx
    have hxI := Finset.mem_Icc.mp (hA hxA)
    apply Finset.mem_Icc.mpr
    omega
  have hlowden : (low.card : ℝ) < ((2*T-1 : ℕ) : ℝ)/4+ε*T := by
    by_contra! hden
    obtain ⟨X,hXne,hXlow,hXcard,hXsum⟩ := hinv T hT1 (2*T-1) (by omega)
      low hlowI (by norm_num; omega) hden
    have he := hav X (hXlow.trans hlowA) hXsum
    exact hXne.ne_empty he
  have hhi := high_card_bound T high hhighI (avoids_mono hav hhighA)
  have hhiR : (high.card : ℝ) ≤ T+1 := by exact_mod_cast hhi
  have hcards : low.card + high.card = A.card := Finset.card_filter_add_card_filter_not _
  have hcardsR : (low.card : ℝ)+(high.card : ℝ)=(A.card : ℝ) := by exact_mod_cast hcards
  have hE : ((2*T-1 : ℕ) : ℝ) ≤ 2*(T : ℝ) := by
    exact_mod_cast (show 2*T-1 ≤ 2*T by omega)
  nlinarith

theorem quarter_limit_relative_to_lev (hLev : EStarBasisFromLev.LevGrowthInput) :
    Tendsto (fun k : ℕ =>
      (F (4*(2*k+1)) (6*(2*k+1)) : ℝ) / (6*(2*k+1) : ℕ))
      atTop (𝓝 (1/4 : ℝ)) := by
  rw [tendsto_order]
  constructor
  · intro b hb
    filter_upwards [] with k
    have hlow := quarter_lower k
    have hlowR : (3*(k : ℝ)+2) ≤ (F (4*(2*k+1)) (6*(2*k+1)) : ℝ) := by
      exact_mod_cast hlow
    have hpos : (0 : ℝ) < (6*(2*k+1) : ℕ) := by positivity
    rw [lt_div_iff₀ hpos]
    have hmul := mul_lt_mul_of_pos_right hb hpos
    have hweak : (1/4 : ℝ)*(6*(2*k+1) : ℕ) ≤ 3*(k : ℝ)+2 := by
      push_cast
      linarith
    exact (hmul.trans_le hweak).trans_le hlowR
  · intro b hb
    let δ : ℝ := b-1/4
    have hδ : 0 < δ := by dsimp [δ]; linarith
    obtain ⟨T₀,hupper⟩ := quarter_upper_relative_to_lev hLev (3*δ) (by positivity)
    obtain ⟨N,hN⟩ := exists_nat_gt (1/(3*δ))
    filter_upwards [eventually_ge_atTop (max T₀ N)] with k hk
    have hkt : T₀ ≤ 2*k+1 := by omega
    have hup := hupper (2*k+1) hkt
    have hkN : (N : ℝ) ≤ (k : ℝ) := by exact_mod_cast (show N ≤ k by omega)
    have hlarge : 1 < 3*δ*(2*(k : ℝ)+1) := by
      have hNk : 1/(3*δ) < (k : ℝ) := hN.trans_le hkN
      have hm := (div_lt_iff₀ (show 0 < 3*δ by positivity)).mp hNk
      nlinarith
    have hpos : (0 : ℝ) < (6*(2*k+1) : ℕ) := by positivity
    rw [div_lt_iff₀ hpos]
    have hup' : (F (4*(2*k+1)) (6*(2*k+1)) : ℝ) ≤
        (3/2+3*δ)*(2*(k : ℝ)+1)+1 := by
      simpa only [Nat.cast_add,Nat.cast_mul,Nat.cast_one, Nat.cast_ofNat] using hup
    have hgap : (3/2+3*δ)*(2*(k : ℝ)+1)+1 < b*(6*(2*k+1) : ℕ) := by
      push_cast
      dsimp [δ] at hlarge ⊢
      nlinarith only [hlarge]
    exact hup'.trans_lt hgap

theorem quarter_limit_mod12_relative_to_lev (hLev : EStarBasisFromLev.LevGrowthInput) :
    Tendsto (fun k : ℕ => (F (8*k+4) (12*k+6) : ℝ) / (12*k+6 : ℕ))
      atTop (𝓝 (1/4 : ℝ)) := by
  have heq : (fun k : ℕ => (F (8*k+4) (12*k+6) : ℝ) / (12*k+6 : ℕ)) =
      (fun k : ℕ => (F (4*(2*k+1)) (6*(2*k+1)) : ℝ) / (6*(2*k+1) : ℕ)) := by
    funext k
    have h4 : 4*(2*k+1)=8*k+4 := by omega
    have h6 : 6*(2*k+1)=12*k+6 := by omega
    simp only [h4,h6]
  rw [heq]
  exact quarter_limit_relative_to_lev hLev

/-- The original floor-based quantity along all n congruent to 6 modulo 12,
not merely a numerical surrogate or an assumed subsequential limit. -/
theorem quarter_limit_filter_relative_to_lev (hLev : EStarBasisFromLev.LevGrowthInput) :
    Tendsto (fun n : ℕ => (F ⌊(2/3 : ℝ)*n⌋₊ n : ℝ)/(n : ℝ))
      (atTop ⊓ Filter.principal {n : ℕ | n % 12 = 6}) (𝓝 (1/4 : ℝ)) := by
  have hseq := quarter_limit_mod12_relative_to_lev hLev
  rw [tendsto_order] at hseq ⊢
  have hrepr : ∀ n : ℕ, n % 12 = 6 →
      n = 12*(n/12)+6 ∧ ⌊(2/3 : ℝ)*n⌋₊ = 8*(n/12)+4 := by
    intro n hn
    have heq : n = 12*(n/12)+6 := by omega
    refine ⟨heq, ?_⟩
    have hreal : (2/3 : ℝ)*(n : ℝ) = ((8*(n/12)+4 : ℕ) : ℝ) := by
      have hnreal : (n : ℝ) = 12*((n/12 : ℕ) : ℝ)+6 := by exact_mod_cast heq
      push_cast
      rw [hnreal]
      ring
    rw [hreal]
    exact Nat.floor_natCast _
  constructor
  · intro b hb
    obtain ⟨N,hN⟩ := Filter.eventually_atTop.mp (hseq.1 b hb)
    rw [Filter.eventually_inf_principal]
    filter_upwards [eventually_ge_atTop (12*N+6)] with n hn hnmod
    obtain ⟨hnrepr, hf⟩ := hrepr n hnmod
    have hk : N ≤ n/12 := by omega
    have h := hN (n/12) hk
    simpa only [hf, ←hnrepr] using h

  · intro b hb
    obtain ⟨N,hN⟩ := Filter.eventually_atTop.mp (hseq.2 b hb)
    rw [Filter.eventually_inf_principal]
    filter_upwards [eventually_ge_atTop (12*N+6)] with n hn hnmod
    obtain ⟨hnrepr, hf⟩ := hrepr n hnmod
    have hk : N ≤ n/12 := by omega
    have h := hN (n/12) hk
    simpa only [hf, ←hnrepr] using h

/-- The congruence-class filter is non-bottom: for every cutoff, 12k+6
provides a member above it. This prevents a vacuous filter-limit reading. -/
theorem mod12_filter_nontrivial :
    Filter.NeBot (atTop ⊓ Filter.principal {n : ℕ | n % 12 = 6}) := by
  apply Filter.frequently_iff_neBot.mp
  rw [Filter.frequently_atTop]
  intro N
  exact ⟨12*N+6, by omega, by omega⟩

#print axioms quarter_upper_relative_to_lev
#print axioms quarter_limit_relative_to_lev
#print axioms quarter_limit_mod12_relative_to_lev
#print axioms quarter_limit_filter_relative_to_lev
#print axioms mod12_filter_nontrivial

end EStarQuarterLimit
