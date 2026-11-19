/- Adapted from matejasevick/erdos361, commit 27f45e7f84894993c1471e952608319aebc53eee.
Copyright (c) 2026 matejasevick. MIT License; preserve the upstream license in distributions.
Only the elementary center-covering section is included; no Freiman or Lev input. -/
import Mathlib
set_option maxHeartbeats 1000000
open Finset
open scoped Pointwise

/-!
# Elementary dense repeated-sumset covering

Extracted from the cited original author's covering module. This file contains
hfold representation operations, the holes pigeonhole argument, modular pair
coverage and the proved arbitrary-h central-interval theorem lemma2_dense.
No Freiman or Lev theorem is an input to these declarations. The subsequent
EStarBasisFromLev module supplies its separate explicit Lev-growth parameter.
-/

namespace Erdos361Covering

/-- **Lemma 1** (holes give a two-fold central interval). If `X ⊆ [0,M]` has `q = M+1-|X|` holes,
then every `z ∈ [2q, 2M-2q]` is a sum of two elements of `X`. Unified pigeonhole over the window
`U' = [z-M, min M z]` (no reflection sub-case): the "left-bad" `{u ∈ U' : u ∉ X}` and "right-bad"
`{u ∈ U' : z-u ∉ X}` each have `≤ q` elements (both inject into the `q` holes), and `|U'| ≥ 2q+1`,
so some `u ∈ U'` has `u ∈ X` and `z-u ∈ X`. -/
lemma lemma1_holes (X : Finset ℕ) (M : ℕ) (hXM : X ⊆ Finset.Icc 0 M) :
    ∀ z, 2 * (M + 1 - X.card) ≤ z → z ≤ 2 * M - 2 * (M + 1 - X.card) →
      ∃ u ∈ X, ∃ v ∈ X, u + v = z := by
  set q := M + 1 - X.card with hq
  intro z hzlo hzhi
  -- the hole set and its cardinality
  set hole := (Finset.Icc 0 M) \ X with hhole
  have hXcardle : X.card ≤ M + 1 := by
    have := Finset.card_le_card hXM
    simpa [Nat.card_Icc] using this
  have hholecard : hole.card = q := by
    rw [hhole, Finset.card_sdiff_of_subset hXM]
    simp [Nat.card_Icc, hq]
  -- the window U'
  set lo := z - M with hlo
  set hi := min M z with hhi
  set U := Finset.Icc lo hi with hU
  -- membership facts on U
  have hUsub : U ⊆ Finset.Icc 0 M := by
    intro u hu
    rw [hU, Finset.mem_Icc] at hu
    rw [Finset.mem_Icc]
    exact ⟨Nat.zero_le _, le_trans hu.2 (min_le_left _ _)⟩
  have huz : ∀ u ∈ U, u ≤ z := by
    intro u hu; rw [hU, Finset.mem_Icc] at hu
    exact le_trans hu.2 (min_le_right _ _)
  have huge : ∀ u ∈ U, z - M ≤ u := by
    intro u hu; rw [hU, Finset.mem_Icc] at hu; exact hu.1
  -- |U| = hi + 1 - lo ≥ 2q + 1
  have hUcard : (2 * q + 1) ≤ U.card := by
    rw [hU, Nat.card_Icc]
    -- hi + 1 - lo ≥ 2q+1, with hhi : hi = min M z, hlo : lo = z - M (omega handles min/-)
    omega
  -- left-bad set injects into holes
  set badL := U.filter (fun u => u ∉ X) with hbadL
  have hbadLcard : badL.card ≤ q := by
    rw [← hholecard]
    apply Finset.card_le_card
    intro u hu
    rw [hbadL, Finset.mem_filter] at hu
    rw [hhole, Finset.mem_sdiff]
    exact ⟨hUsub hu.1, hu.2⟩
  -- right-bad set injects into holes via u ↦ z - u
  set badR := U.filter (fun u => z - u ∉ X) with hbadR
  have hbadRcard : badR.card ≤ q := by
    rw [← hholecard]
    apply Finset.card_le_card_of_injOn (fun u => z - u)
    · intro u hu
      simp only [hbadR, Finset.mem_coe, Finset.mem_filter] at hu
      simp only [hhole, Finset.mem_coe, Finset.mem_sdiff, Finset.mem_Icc]
      have hle : u ≤ z := huz u hu.1
      have hge : z - M ≤ u := huge u hu.1
      refine ⟨⟨Nat.zero_le _, ?_⟩, hu.2⟩
      omega
    · intro a ha b hb hab
      simp only [hbadR, Finset.mem_coe, Finset.mem_filter] at ha hb
      have hale : a ≤ z := huz a ha.1
      have hble : b ≤ z := huz b hb.1
      have hab' : z - a = z - b := hab
      omega
  -- pigeonhole: badL ∪ badR ⊊ U
  have hcup : (badL ∪ badR).card < U.card := by
    calc (badL ∪ badR).card ≤ badL.card + badR.card := Finset.card_union_le _ _
      _ ≤ q + q := Nat.add_le_add hbadLcard hbadRcard
      _ = 2 * q := by ring
      _ < 2 * q + 1 := Nat.lt_succ_self _
      _ ≤ U.card := hUcard
  have hsub : badL ∪ badR ⊆ U :=
    Finset.union_subset (Finset.filter_subset _ _) (Finset.filter_subset _ _)
  have hne : badL ∪ badR ≠ U := fun h => absurd hcup (by rw [h]; exact lt_irrefl _)
  obtain ⟨u, huU, hunotin⟩ := Finset.exists_of_ssubset (lt_of_le_of_ne hsub hne)
  -- u ∈ U, u ∉ badL ∪ badR  ⟹  u ∈ X and z - u ∈ X
  rw [Finset.mem_union] at hunotin
  push Not at hunotin
  have huX : u ∈ X := by
    by_contra h
    exact hunotin.1 (by rw [hbadL, Finset.mem_filter]; exact ⟨huU, h⟩)
  have hvX : z - u ∈ X := by
    by_contra h
    exact hunotin.2 (by rw [hbadR, Finset.mem_filter]; exact ⟨huU, h⟩)
  refine ⟨u, huX, z - u, hvX, ?_⟩
  have : u ≤ z := huz u huU
  omega

#print axioms lemma1_holes

/-- `x` is a sum of exactly `h` elements of `B`, repetitions allowed (the `h`-fold sumset `hB`).
Identical to `Erdos361InverseGlue.RepWithRep`. -/
def hfold (B : Finset ℕ) (h x : ℕ) : Prop :=
  ∃ f : Fin h → ℕ, (∀ i, f i ∈ B) ∧ (∑ i, f i) = x

/-- The empty sum: `0 ∈ 0·B`. -/
lemma hfold_zero (B : Finset ℕ) : hfold B 0 0 :=
  ⟨Fin.elim0, fun i => i.elim0, by simp⟩

/-- Prepend one element `b ∈ B` to an `h`-fold representation. -/
lemma hfold_cons {B : Finset ℕ} {h x b : ℕ} (hb : b ∈ B) (hx : hfold B h x) :
    hfold B (h + 1) (b + x) := by
  obtain ⟨f, hf, hsum⟩ := hx
  refine ⟨Fin.cons b f, ?_, ?_⟩
  · intro i
    refine Fin.cases ?_ ?_ i
    · simpa using hb
    · intro j; simpa using hf j
  · rw [Fin.sum_cons, hsum]

/-- Append `k` copies of an element `b ∈ B`. -/
lemma hfold_add_copies {B : Finset ℕ} {h x : ℕ} (b : ℕ) (hb : b ∈ B) (k : ℕ)
    (hx : hfold B h x) : hfold B (h + k) (x + k * b) := by
  induction k with
  | zero => simpa using hx
  | succ n ih =>
      have hstep := hfold_cons hb ih
      have e1 : h + (n + 1) = (h + n) + 1 := by ring
      have e2 : x + (n + 1) * b = b + (x + n * b) := by ring
      rw [e1, e2]; exact hstep

/-- A two-element sum `u + v` with `u, v ∈ B` is a `2`-fold representation. -/
lemma hfold_two {B : Finset ℕ} {u v : ℕ} (hu : u ∈ B) (hv : v ∈ B) : hfold B 2 (u + v) := by
  have h1 : hfold B 1 (v + 0) := hfold_cons hv (hfold_zero B)
  have h2 : hfold B 2 (u + (v + 0)) := hfold_cons hu h1
  simpa using h2

/-- Rewrite the parameters of an `hfold` along equalities. -/
lemma hfold_congr {B : Finset ℕ} {h h' x x' : ℕ} (hh : h = h') (hx : x = x')
    (H : hfold B h x) : hfold B h' x' := by rw [← hh, ← hx]; exact H

/-- Concatenate two representations (`Fin.append`). -/
lemma hfold_add {B : Finset ℕ} {a b x y : ℕ} (Hx : hfold B a x) (Hy : hfold B b y) :
    hfold B (a + b) (x + y) := by
  obtain ⟨f, hf, hfs⟩ := Hx
  obtain ⟨g, hg, hgs⟩ := Hy
  refine ⟨Fin.append f g, ?_, ?_⟩
  · refine Fin.addCases (fun j => ?_) (fun j => ?_)
    · rw [Fin.append_left]; exact hf j
    · rw [Fin.append_right]; exact hg j
  · rw [Fin.sum_univ_add]
    simp only [Fin.append_left, Fin.append_right]
    rw [hfs, hgs]

/-- Peel the first element off an `(n+1)`-fold representation. -/
lemma hfold_uncons {C : Finset ℕ} {n x : ℕ} (H : hfold C (n + 1) x) :
    ∃ c ∈ C, ∃ x', hfold C n x' ∧ c + x' = x := by
  obtain ⟨f, hf, hfs⟩ := H
  refine ⟨f 0, hf 0, ∑ i : Fin n, f i.succ, ⟨fun i => f i.succ, fun i => hf _, rfl⟩, ?_⟩
  rw [← hfs, Fin.sum_univ_succ]

/-- **Sumset bridge**: a `q`-fold sum of elements of `B+B` is a `2q`-fold sum of elements of `B`. -/
lemma hfold_sumset {B : Finset ℕ} : ∀ {q x : ℕ}, hfold (B + B) q x → hfold B (2 * q) x := by
  intro q
  induction q with
  | zero =>
      intro x H
      obtain ⟨f, hf, hfs⟩ := H
      have hx0 : x = 0 := by rw [← hfs]; simp
      rw [hx0]; simpa using hfold_zero B
  | succ n ih =>
      intro x H
      obtain ⟨c, hc, x', Hx', hcx⟩ := hfold_uncons H
      rw [Finset.mem_add] at hc
      obtain ⟨u, hu, v, hv, huv⟩ := hc
      have h2 : hfold B 2 c := by rw [← huv]; exact hfold_two hu hv
      have hrec : hfold B (2 * n) x' := ih Hx'
      have hcomb := hfold_add h2 hrec
      rw [hcx] at hcomb
      exact hfold_congr (by ring) rfl hcomb

/-- **Affine pullback** `hG = ha + d·hB`. If every normalized element `b ∈ B` lifts to
`a + d·b ∈ G`, then an `h`-fold representation `y ∈ hB` lifts to `(ha + d·y) ∈ hG`. No injectivity
or divisibility needed — just the forward lift. -/
lemma hfold_pullback {G B : Finset ℕ} {a d h y : ℕ}
    (hBG : ∀ b ∈ B, a + d * b ∈ G) (H : hfold B h y) :
    hfold G h (h * a + d * y) := by
  obtain ⟨f, hf, hfs⟩ := H
  refine ⟨fun i => a + d * f i, fun i => hBG _ (hf i), ?_⟩
  rw [Finset.sum_add_distrib]
  congr 1
  · simp [Finset.sum_const, Finset.card_univ, smul_eq_mul, mul_comm]
  · rw [← Finset.mul_sum, hfs]

/-- **Modular representation** (the ℤ/L pigeonhole core of Lemma 2). If `C ⊆ ℕ` has all elements
`< L`, its residues are distinct (automatic), and `L < 2|C|`, then for every `r < L` there exist
`c₁, c₂ ∈ C` with `c₁ + c₂ = r` or `c₁ + c₂ = r + L`. -/
lemma modular_rep (C : Finset ℕ) (L : ℕ) (hL : 0 < L) (hClt : ∀ c ∈ C, c < L)
    (hcard : L < 2 * C.card) (r : ℕ) (hr : r < L) :
    ∃ c₁ ∈ C, ∃ c₂ ∈ C, c₁ + c₂ = r ∨ c₁ + c₂ = r + L := by
  have : NeZero L := ⟨hL.ne'⟩
  -- distinct naturals < L stay distinct mod L
  have castInj : ∀ a ∈ C, ∀ b ∈ C, (a : ZMod L) = (b : ZMod L) → a = b := by
    intro a ha b hb hab
    have hmod : a % L = b % L := (ZMod.natCast_eq_natCast_iff a b L).mp hab
    rwa [Nat.mod_eq_of_lt (hClt a ha), Nat.mod_eq_of_lt (hClt b hb)] at hmod
  -- images of C under (· : ZMod L) and (r - ·)
  set f1 : ℕ → ZMod L := fun c => (c : ZMod L) with hf1
  set f2 : ℕ → ZMod L := fun c => (r : ZMod L) - (c : ZMod L) with hf2
  have hinj1 : Set.InjOn f1 ↑C := by
    intro a ha b hb hab
    exact castInj a (by simpa using ha) b (by simpa using hb) hab
  have hinj2 : Set.InjOn f2 ↑C := by
    intro a ha b hb hab
    rw [hf2] at hab
    have : (a : ZMod L) = (b : ZMod L) := sub_right_inj.mp hab
    exact castInj a (by simpa using ha) b (by simpa using hb) this
  have hcard1 : (C.image f1).card = C.card := Finset.card_image_of_injOn hinj1
  have hcard2 : (C.image f2).card = C.card := Finset.card_image_of_injOn hinj2
  -- pigeonhole: the two images intersect
  have hinter : (C.image f1 ∩ C.image f2).Nonempty := by
    by_contra hemp
    rw [Finset.not_nonempty_iff_eq_empty] at hemp
    have hdisj : Disjoint (C.image f1) (C.image f2) :=
      Finset.disjoint_iff_inter_eq_empty.mpr hemp
    have hle : (C.image f1).card + (C.image f2).card ≤ (Finset.univ : Finset (ZMod L)).card := by
      rw [← Finset.card_union_of_disjoint hdisj]
      exact Finset.card_le_card (Finset.subset_univ _)
    rw [hcard1, hcard2, Finset.card_univ, ZMod.card] at hle
    omega
  obtain ⟨a, ha⟩ := hinter
  rw [Finset.mem_inter] at ha
  obtain ⟨c₁, hc₁C, hc₁⟩ := Finset.mem_image.mp ha.1
  obtain ⟨c₂, hc₂C, hc₂⟩ := Finset.mem_image.mp ha.2
  have hkey : (c₁ : ZMod L) = (r : ZMod L) - (c₂ : ZMod L) := by
    have e1 : (c₁ : ZMod L) = a := hc₁
    have e2 : (r : ZMod L) - (c₂ : ZMod L) = a := hc₂
    rw [e1, e2]
  have hsum : ((c₁ + c₂ : ℕ) : ZMod L) = (r : ZMod L) := by
    push_cast; rw [hkey]; ring
  have hmod : (c₁ + c₂) % L = r := by
    have := (ZMod.natCast_eq_natCast_iff (c₁ + c₂) r L).mp hsum
    rwa [Nat.ModEq, Nat.mod_eq_of_lt hr] at this
  have hc1l := hClt c₁ hc₁C
  have hc2l := hClt c₂ hc₂C
  refine ⟨c₁, hc₁C, c₂, hc₂C, ?_⟩
  -- c₁+c₂ = L·Q + r with Q < 2, so = r or r+L
  obtain ⟨Q, hQeq⟩ : ∃ Q, c₁ + c₂ = L * Q + r :=
    ⟨(c₁ + c₂) / L, by rw [← hmod]; exact (Nat.div_add_mod _ _).symm⟩
  have hQlt : Q < 2 := by
    by_contra h
    push Not at h
    have hmul : L * 2 ≤ L * Q := Nat.mul_le_mul_left L h
    omega
  interval_cases Q <;> omega

/-- **Lemma 2** (dense normalized interval theorem). If `B ⊆ [0,L]` with `0,L ∈ B`, `N = |B| ≥ 3`,
and `L ≤ 2N-4` (density `≥ ½`), then for every `h ≥ 2` the whole interval `[Γ₁, hL-Γ₁] ⊆ hB`, where
`Γ₁ = 2L-2N+2`. Proof: `lemma1_holes` gives `[Γ₁,2L-Γ₁] ⊆ 2B`; for `x` in the low part append
`0`'s, in the high part append `L`'s, and in the middle use `modular_rep` on `C = B \ {L}`. -/
lemma lemma2_dense (B : Finset ℕ) (L : ℕ) (hBsub : B ⊆ Finset.Icc 0 L)
    (h0 : 0 ∈ B) (hLB : L ∈ B) (hN3 : 3 ≤ B.card) (hdense : L ≤ 2 * B.card - 4) :
    ∀ h, 2 ≤ h → ∀ x, 2 * L + 2 - 2 * B.card ≤ x → x ≤ h * L - (2 * L + 2 - 2 * B.card) →
      hfold B h x := by
  set N := B.card with hN
  intro h hh2 x hxlo hxhi
  -- basic facts
  have hcardle : N ≤ L + 1 := by
    rw [hN]; have := Finset.card_le_card hBsub; simpa [Nat.card_Icc] using this
  have hLpos : 0 < L := by
    rcases Nat.eq_zero_or_pos L with hL0 | hLpos
    · exfalso
      have hsub : B ⊆ {0} := by
        intro b hb; have := hBsub hb; rw [Finset.mem_Icc] at this
        simp only [Finset.mem_singleton]; omega
      have := Finset.card_le_card hsub; rw [← hN] at this; simp at this; omega
    · exact hLpos
  have hG1le : 2 * L + 2 - 2 * N ≤ L - 2 := by omega
  -- Lemma 1: the 2-fold central interval  [Γ₁, 2N-2] = [Γ₁, 2L-Γ₁] ⊆ 2B
  have hL1 : ∀ z, 2 * L + 2 - 2 * N ≤ z → z ≤ 2 * N - 2 → ∃ u ∈ B, ∃ v ∈ B, u + v = z := by
    intro z hz1 hz2
    exact lemma1_holes B L hBsub z (by omega) (by omega)
  -- C = B \ {L}
  set C := B.erase L with hC
  have hCsub : C ⊆ B := Finset.erase_subset _ _
  have hCcard : C.card = N - 1 := by rw [hC, Finset.card_erase_of_mem hLB, ← hN]
  have hClt : ∀ c ∈ C, c < L := by
    intro c hc
    have hcB : c ∈ B := hCsub hc
    have hcL : c ≠ L := Finset.ne_of_mem_erase hc
    have := hBsub hcB; rw [Finset.mem_Icc] at this; omega
  have h2C : L < 2 * C.card := by rw [hCcard]; omega
  -- three cases on x's position
  rcases le_or_gt x (2 * N - 2) with hposA | hposA
  · -- Case A: x ≤ 2L-Γ₁, use 2B + (h-2) copies of 0
    obtain ⟨u, hu, v, hv, huv⟩ := hL1 x (by omega) hposA
    have base : hfold B 2 (u + v) := hfold_two hu hv
    have add0 := hfold_add_copies 0 h0 (h - 2) base
    exact hfold_congr (by omega) (by omega) add0
  · rcases le_or_gt ((h - 2) * L + (2 * L + 2 - 2 * N)) x with hposB | hposB
    · -- Case B: x ≥ (h-2)L+Γ₁, use 2B on w = x-(h-2)L + (h-2) copies of L
      set w := x - (h - 2) * L with hw
      have hwlo : 2 * L + 2 - 2 * N ≤ w := by rw [hw]; omega
      have hwhi : w ≤ 2 * N - 2 := by
        -- w = x - (h-2)L ≤ hL - Γ₁ - (h-2)L = 2L - Γ₁ = 2N-2
        have hexp : h * L = (h - 2) * L + 2 * L := by
          rw [← Nat.add_mul, Nat.sub_add_cancel hh2]
        rw [hw]; omega
      obtain ⟨u, hu, v, hv, huv⟩ := hL1 w hwlo hwhi
      have base : hfold B 2 (u + v) := hfold_two hu hv
      have addL := hfold_add_copies L hLB (h - 2) base
      refine hfold_congr (by omega) ?_ addL
      -- (u+v) + (h-2)*L = x, since u+v = w = x-(h-2)L
      rw [huv, hw]; omega
    · -- Case C (middle): 2L-Γ₁ < x < (h-2)L+Γ₁
      obtain ⟨k, r, hr, hxkr⟩ : ∃ k r, r < L ∧ x = L * k + r :=
        ⟨x / L, x % L, Nat.mod_lt x hLpos, (Nat.div_add_mod x L).symm⟩
      have hxgtL : L < x := by omega
      have hk1 : 1 ≤ k := by
        rcases Nat.eq_zero_or_pos k with rfl | hpos
        · simp only [Nat.mul_zero] at hxkr; omega
        · exact hpos
      have hk2 : k ≤ h - 2 := by
        have hexp : L * (h - 1) = L * (h - 2) + L := by
          have h' : h - 1 = (h - 2) + 1 := by omega
          rw [h']; ring
        have hxlt : x < L * (h - 2) + L := by
          have hcomm : (h - 2) * L = L * (h - 2) := Nat.mul_comm _ _
          omega
        have hbound : L * k < L * (h - 1) := by omega
        have := Nat.lt_of_mul_lt_mul_left hbound
        omega
      -- modular representation of r
      obtain ⟨c₁, hc₁, c₂, hc₂, hrep⟩ := modular_rep C L hLpos hClt h2C r hr
      have hc₁B : c₁ ∈ B := hCsub hc₁
      have hc₂B : c₂ ∈ B := hCsub hc₂
      have base : hfold B 2 (c₁ + c₂) := hfold_two hc₁B hc₂B
      rcases hrep with hj0 | hj1
      · -- c₁+c₂ = r: append k copies of L and (h-2-k) copies of 0
        have addL := hfold_add_copies L hLB k base
        have add0 := hfold_add_copies 0 h0 (h - 2 - k) addL
        refine hfold_congr (by omega) ?_ add0
        -- ((c₁+c₂) + k*L) + (h-2-k)*0 = x = L*k + r
        have hcomm : k * L = L * k := Nat.mul_comm _ _
        rw [hj0]; omega
      · -- c₁+c₂ = r+L: append (k-1) copies of L and (h-1-k) copies of 0
        have addL := hfold_add_copies L hLB (k - 1) base
        have add0 := hfold_add_copies 0 h0 (h - 1 - k) addL
        refine hfold_congr (by omega) ?_ add0
        -- ((c₁+c₂) + (k-1)*L) + (h-1-k)*0 = x, with c₁+c₂ = r+L
        have hcomm : (k - 1) * L = L * (k - 1) := Nat.mul_comm _ _
        have hexp : L * (k - 1) + L = L * k := by
          rw [← Nat.mul_succ, Nat.succ_eq_add_one, Nat.sub_add_cancel hk1]
        rw [hj1]; omega


#print axioms modular_rep
#print axioms lemma2_dense
end Erdos361Covering
