import EStarFiniteMain
import EStarRothCore

/-!
# The asymptotic inverse theorem relative to a precise additive-basis input

The sole unproved mathematical input is `GeneralBasisInput q`: an ordinary
interval-covering theorem for normalized finite sets of density at least 1/q.
Roth smallness, good-core extraction, gcd normalization, uniform choice of T0,
target placement, zero-padding removal and distinctification are proved.
This is a CONDITIONAL theorem, not an unconditional end-to-end formalization.
-/

namespace EStarConditionalMain

open EStarTransfer EStarFiniteMain

/-- The exact remaining additive-basis interface. It is not the inverse theorem:
it concerns normalized repeated sums, not distinct subsets of an arbitrary A. -/
def GeneralBasisInput (q : ℕ) : Prop :=
  ∀ (B : Finset ℕ) (L K : ℕ), q ≤ L → B ⊆ Finset.Icc 0 L →
    0 ∈ B → L ∈ B → B.gcd id = 1 →
    (L : ℝ) / q + 2 ≤ (B.card : ℝ) →
    BoundedBasis B ((q - 1) * (K + 1)) (q - 1) L K

/-- All normalization hypotheses refer to the actual quotient-image finite set. -/
theorem normalized_facts (G : Finset ℕ) (hGne : G.Nonempty)
    (hpos : ∀ g ∈ G, 0 < g) :
    let d := G.gcd id
    let L := G.sup id / d
    let B := normalized G d
    B.card = G.card + 1 ∧ B ⊆ Finset.Icc 0 L ∧
      0 ∈ B ∧ L ∈ B ∧ B.gcd id = 1 ∧ G.card ≤ L := by
  classical
  dsimp only
  let d := G.gcd id
  let L := G.sup id / d
  let D := G.image (fun g => g / d)
  obtain ⟨g, hg⟩ := hGne
  have hdiv : ∀ a ∈ G, d ∣ a := fun a ha => Finset.gcd_dvd ha
  have hd : 0 < d := by
    by_contra h
    have hd0 : d = 0 := by omega
    have hg0 : g = 0 := (Finset.gcd_eq_zero_iff.mp hd0) g hg
    have := hpos g hg
    omega
  have hinj : Set.InjOn (fun a : ℕ => a / d) G := by
    intro a ha b hb hab
    change a / d = b / d at hab
    have haeq := Nat.mul_div_cancel' (hdiv a ha)
    have hbeq := Nat.mul_div_cancel' (hdiv b hb)
    calc
      a = d * (a / d) := haeq.symm
      _ = d * (b / d) := by rw [hab]
      _ = b := hbeq
  have hDcard : D.card = G.card := Finset.card_image_of_injOn hinj
  have hDsub : D ⊆ Finset.Icc 1 L := by
    intro a ha
    obtain ⟨b, hb, rfl⟩ := Finset.mem_image.mp ha
    refine Finset.mem_Icc.mpr ⟨?_, ?_⟩
    · exact Nat.div_pos (Nat.le_of_dvd (hpos b hb) (hdiv b hb)) hd
    · exact Nat.div_le_div_right (Finset.le_sup (f := id) hb)
  have h0D : 0 ∉ D := by
    intro h0
    have := Finset.mem_Icc.mp (hDsub h0)
    omega
  have hmaxMem : G.sup id ∈ G := by
    simpa using (Finset.sup_mem_of_nonempty (f := id) (show G.Nonempty from ⟨g, hg⟩))
  have hLD : L ∈ D := Finset.mem_image.mpr ⟨_, hmaxMem, rfl⟩
  have hBcard : (insert 0 D).card = G.card + 1 := by
    rw [Finset.card_insert_of_notMem h0D, hDcard]
  have hBsub : insert 0 D ⊆ Finset.Icc 0 L := by
    intro a ha
    rcases Finset.mem_insert.mp ha with rfl | ha
    · simp
    · have := Finset.mem_Icc.mp (hDsub ha)
      exact Finset.mem_Icc.mpr ⟨Nat.zero_le _, this.2⟩
  have hgn : G.gcd (fun a => a / d) = 1 :=
    Finset.gcd_div_id_eq_one hg (Nat.ne_of_gt (hpos g hg))
  have hBdvd : (insert 0 D).gcd id ∣ G.gcd (fun a => a / d) := by
    apply Finset.dvd_gcd
    intro a ha
    exact Finset.gcd_dvd (Finset.mem_insert_of_mem (Finset.mem_image.mpr ⟨a, ha, rfl⟩))
  have hBgcd : (insert 0 D).gcd id = 1 := by
    rw [hgn] at hBdvd
    exact Nat.eq_one_of_dvd_one hBdvd
  have hGL : G.card ≤ L := by
    have hc := Finset.card_le_card hDsub
    rw [hDcard] at hc
    simpa using hc
  exact ⟨hBcard, hBsub, Finset.mem_insert_self _ _,
    Finset.mem_insert_of_mem hLD, hBgcd, hGL⟩

/-- Roth's theorem yields an actual core with arbitrarily small linear loss.
The threshold is fixed before E and A; it may depend on H and delta only. -/
theorem good_core_small_loss (H : ℕ) (hH : 1 ≤ H) (δ : ℝ) (hδ : 0 < δ) :
    ∃ E₀ : ℕ, ∀ E : ℕ, E₀ ≤ E → ∀ A : Finset ℕ,
      A ⊆ Finset.Icc 1 E →
      ∃ G ⊆ A, (∀ g ∈ G, H ≤ (EStarDistinct.centerLowers A g).card) ∧
        (A.card : ℝ) - (G.card : ℝ) ≤ δ * E := by
  classical
  obtain ⟨E₀, hE₀⟩ := roth_small_nat (36 * H + 2) (2 * δ) (by positivity)
  refine ⟨E₀, fun E hE A hA => ?_⟩
  let G := A.filter (fun g => H + 1 ≤ (EStarDistinct.centerLowers A g).card)
  let C := A.filter (fun g => (EStarDistinct.centerLowers A g).card ≤ H)
  have hsplit : C.card ≤ (36 * H + 2) * rothNumberNat (E + 1) :=
    EStarRothCore.roth_core_split E A hA H hH
  have hCeq : C = A.filter (fun g => ¬ (H + 1 ≤ (EStarDistinct.centerLowers A g).card)) := by
    apply Finset.filter_congr
    intro g _
    omega
  have hGC : G.card + C.card = A.card := by
    rw [hCeq]
    exact Finset.card_filter_add_card_filter_not _
  have hGC' : (G.card : ℝ) + (C.card : ℝ) = (A.card : ℝ) := by exact_mod_cast hGC
  have hsplit' : (C.card : ℝ) ≤ ((36 * H + 2 : ℕ) : ℝ) * rothNumberNat (E + 1) := by
    exact_mod_cast hsplit
  have hsmall := hE₀ E hE
  refine ⟨G, Finset.filter_subset _ _, ?_, ?_⟩
  · intro g hg
    have := (Finset.mem_filter.mp hg).2
    omega
  · nlinarith

/-- The paper's main quantifier pattern and exact length H, conditional only
on the explicitly stated general normalized-basis theorem. -/
theorem main_inverse_relative_to_basis
    (s q : ℕ) (hs : 0 < s) (hq2 : 2 ≤ q)
    (hq : ∀ a : ℕ, 0 < a → a < q → a ∣ s)
    (hBasis : GeneralBasisInput q) (ε : ℝ) (hε : 0 < ε) :
    ∃ T₀ : ℕ, ∀ T : ℕ, T₀ ≤ T → ∀ E : ℕ, 1 ≤ E →
      ∀ A : Finset ℕ, A ⊆ Finset.Icc 1 E →
        (q - 1) * E ≤ s * T → (E : ℝ) / q + ε * T ≤ (A.card : ℝ) →
        ∃ X : Finset ℕ, X.Nonempty ∧ X ⊆ A ∧
          X.card ≤ (q - 1) * (⌈2 * (s : ℝ) / ε⌉₊ + 1) ∧
          (∑ x ∈ X, x) = s * T := by
  classical
  let r := q - 1
  let K := ⌈2 * (s : ℝ) / ε⌉₊
  let H := r * (K + 1)
  have hr : 1 ≤ r := by dsimp [r]; omega
  have hH : 1 ≤ H := by dsimp [H]; nlinarith
  have hs' : (0 : ℝ) < s := by exact_mod_cast hs
  have hq' : (0 : ℝ) < q := by exact_mod_cast (show 0 < q by omega)
  have hr' : (0 : ℝ) < r := by exact_mod_cast (show 0 < r by omega)
  let δ : ℝ := ε * r / s
  have hδ : 0 < δ := by dsimp [δ]; positivity
  obtain ⟨E₀, hcore⟩ := good_core_small_loss H hH (δ / 2) (by positivity)
  let T₀ := max 1 (max ⌈(E₀ : ℝ) / ε⌉₊ ⌈2 * (q : ℝ) / ε⌉₊)
  refine ⟨T₀, fun T hT E hE A hA hrange hden => ?_⟩
  have hT1 : 1 ≤ T := le_trans (le_max_left _ _) hT
  have hTcast : (0 : ℝ) ≤ T := by positivity
  have hTlarge : (E₀ : ℝ) ≤ ε * T := by
    have htc : ⌈(E₀ : ℝ) / ε⌉₊ ≤ T :=
      le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) hT
    have hreal : (E₀ : ℝ) / ε ≤ (T : ℝ) :=
      le_trans (Nat.le_ceil _) (by exact_mod_cast htc)
    have := (div_le_iff₀ hε).mp hreal
    nlinarith
  have hmargin : (q : ℝ) ≤ ε * T / 2 := by
    have htc : ⌈2 * (q : ℝ) / ε⌉₊ ≤ T :=
      le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) hT
    have hreal : 2 * (q : ℝ) / ε ≤ (T : ℝ) :=
      le_trans (Nat.le_ceil _) (by exact_mod_cast htc)
    have := (div_le_iff₀ hε).mp hreal
    linarith
  have hAcap : A.card ≤ E := by simpa using Finset.card_le_card hA
  have hAcap' : (A.card : ℝ) ≤ E := by exact_mod_cast hAcap
  have hEq : (0 : ℝ) ≤ (E : ℝ) / q := by positivity
  have hElarge : E₀ ≤ E := by
    have : (E₀ : ℝ) ≤ E := by linarith
    exact_mod_cast this
  obtain ⟨G, hGA, hpairs, hloss⟩ := hcore E hElarge A hA
  have hrange' : (r : ℝ) * E ≤ (s : ℝ) * T := by exact_mod_cast hrange
  have hscaledRange : δ * E ≤ ε * T := by
    dsimp [δ]
    rw [div_mul_eq_mul_div]
    have h := mul_le_mul_of_nonneg_left hrange' (le_of_lt hε)
    apply (div_le_iff₀ hs').mpr
    nlinarith
  have hGsize : (E : ℝ) / q + ε * T / 2 ≤ (G.card : ℝ) := by
    nlinarith
  have hGdense : E < q * G.card := by
    have hstrict : (E : ℝ) / q < (G.card : ℝ) := by
      have : (0 : ℝ) < ε * T / 2 := by positivity
      linarith
    have hmul := (div_lt_iff₀ hq').mp hstrict
    exact_mod_cast (show (E : ℝ) < q * (G.card : ℝ) by nlinarith)
  have hGne : G.Nonempty := by
    apply Finset.card_pos.mp
    by_contra h
    have hc : G.card = 0 := by omega
    simp [hc] at hGdense
  have hGpos : ∀ g ∈ G, 0 < g := by
    intro g hg
    have := (Finset.mem_Icc.mp (hA (hGA hg))).1
    omega
  have hGbound : ∀ g ∈ G, g ≤ E := fun g hg => (Finset.mem_Icc.mp (hA (hGA hg))).2
  obtain ⟨hBcard, hBsub, hBzero, hBL, hBgcd, hGL⟩ := normalized_facts G hGne hGpos
  let d := G.gcd id
  let L := G.sup id / d
  have hLE : L ≤ E := (Nat.div_le_self _ _).trans (Finset.sup_le hGbound)
  have hqL : q ≤ L := by
    have : (q : ℝ) ≤ G.card := by linarith
    have hqG : q ≤ G.card := by exact_mod_cast this
    exact hqG.trans hGL
  have hBden : (L : ℝ) / q + 2 ≤ ((normalized G d).card : ℝ) := by
    have hLE' : (L : ℝ) ≤ E := by exact_mod_cast hLE
    have hdivle : (L : ℝ) / q ≤ (E : ℝ) / q :=
      div_le_div_of_nonneg_right hLE' (le_of_lt hq')
    have hc : ((normalized G d).card : ℝ) = G.card + 1 := by exact_mod_cast hBcard
    have hqone : (1 : ℝ) ≤ q := by exact_mod_cast (show 1 ≤ q by omega)
    linarith
  have hbasisActual : BoundedBasis (normalized G d) H r L K :=
    hBasis (normalized G d) L K hqL hBsub hBzero hBL hBgcd hBden
  have hGmax : G.card ≤ G.sup id := hGL.trans (Nat.div_le_self _ _)
  have hGmax' : (G.card : ℝ) ≤ ((G.sup id : ℕ) : ℝ) := by exact_mod_cast hGmax
  have hK : 2 * (s : ℝ) / ε ≤ (K : ℝ) := Nat.le_ceil _
  have hKε : 2 * (s : ℝ) ≤ (K : ℝ) * ε := (div_le_iff₀ hε).mp hK
  have hKεT := mul_le_mul_of_nonneg_right hKε hTcast
  have hcoremax : ε * T / 2 ≤ ((G.sup id : ℕ) : ℝ) := by linarith
  have hKmax := mul_le_mul_of_nonneg_left hcoremax (Nat.cast_nonneg K)
  have hupper : s * T ≤ K * G.sup id := by
    have : (s : ℝ) * T ≤ (K : ℝ) * ((G.sup id : ℕ) : ℝ) := by nlinarith
    exact_mod_cast this
  have htarget : 0 < s * T := Nat.mul_pos hs (by omega)
  exact finite_inverse_from_basis_and_good_core A G E q s T r K H hGA
    hGpos hGbound hGdense hq hpairs htarget hrange hupper hbasisActual

#print axioms normalized_facts
#print axioms good_core_small_loss
#print axioms main_inverse_relative_to_basis

end EStarConditionalMain
