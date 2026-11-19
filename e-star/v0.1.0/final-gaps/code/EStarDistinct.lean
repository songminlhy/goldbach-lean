import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Multiset.AddSub
import Mathlib.Tactic.Push
import Mathlib.Tactic.ByContra
import Lean.Elab.Tactic.Omega

/-!
# E-star: eliminating repetitions by center pairs

This file formalizes the purely finite combinatorial `lem:distinct` bridge.
No Lev theorem, Roth theorem, asymptotic claim, or analytic input is assumed.
The result preserves the exact number of summands; zero summands are allowed
in the general statement. The nonempty corollary explicitly assumes positive
cardinality. Natural numbers may include zero: positivity of A is unnecessary.
-/

namespace EStarDistinct

/-- Lower endpoints of the nontrivial A-pairs centered at g. -/
def centerLowers (A : Finset ℕ) (g : ℕ) : Finset ℕ :=
  A.filter (fun u => u < g ∧ 2 * g - u ∈ A)

/-- A value can block at most one centered pair: fold it to the lower endpoint. -/
def foldCenter (g x : ℕ) : ℕ := min x (2 * g - x)

/-- More centered pairs than occupied values yields a pair avoiding both ends. -/
theorem fresh_pair (A S : Finset ℕ) (g : ℕ)
    (h : S.card < (centerLowers A g).card) :
    ∃ u, u ∈ A ∧ 2 * g - u ∈ A ∧ u < g ∧
      u ∉ S ∧ 2 * g - u ∉ S := by
  classical
  have hcard : (S.image (foldCenter g)).card < (centerLowers A g).card :=
    lt_of_le_of_lt Finset.card_image_le h
  obtain ⟨u, hu, hfree⟩ := Finset.exists_mem_notMem_of_card_lt_card hcard
  obtain ⟨huA, hult, hvA⟩ := Finset.mem_filter.mp hu
  have hlo : foldCenter g u = u := by unfold foldCenter; omega
  have hhi : foldCenter g (2 * g - u) = u := by unfold foldCenter; omega
  refine ⟨u, huA, hvA, hult, ?_, ?_⟩
  · intro huS
    exact hfree (Finset.mem_image.mpr ⟨u, huS, hlo⟩)
  · intro hvS
    exact hfree (Finset.mem_image.mpr ⟨2 * g - u, hvS, hhi⟩)

/-- Replacing two copies of a center with fresh endpoints strictly grows support. -/
theorem support_increases (R : Multiset ℕ) (g u v : ℕ)
    (hu : u ∉ R) (hv : v ∉ R) (huv : u ≠ v) :
    (g ::ₘ g ::ₘ R).toFinset.card < (u ::ₘ v ::ₘ R).toFinset.card := by
  classical
  have hbefore : (g ::ₘ g ::ₘ R).toFinset.card ≤ R.toFinset.card + 1 := by
    simpa only [Multiset.toFinset_cons, Finset.insert_idem] using
      (Finset.card_insert_le g R.toFinset)
  have hafter : (u ::ₘ v ::ₘ R).toFinset.card = R.toFinset.card + 2 := by
    simp only [Multiset.toFinset_cons]
    have huInsert : u ∉ insert v R.toFinset := by simp [huv, hu]
    rw [Finset.card_insert_of_notMem huInsert,
      Finset.card_insert_of_notMem (show v ∉ R.toFinset by simpa using hv)]
  omega

/-- Strengthened invariant: only values in G are allowed to be repeated.
The induction measure is cardinality minus support cardinality. -/
theorem eliminate_repetitions (A G : Finset ℕ) (m : ℕ)
    (hpairs : ∀ g ∈ G, m ≤ (centerLowers A g).card)
    (s : Multiset ℕ)
    (hsA : ∀ x ∈ s, x ∈ A)
    (hrepeat : ∀ x, 2 ≤ s.count x → x ∈ G)
    (hsize : s.card ≤ m) :
    ∃ t : Multiset ℕ, t.Nodup ∧ (∀ x ∈ t, x ∈ A) ∧
      t.card = s.card ∧ t.sum = s.sum := by
  classical
  have aux : ∀ n : ℕ, ∀ s : Multiset ℕ,
      s.card - s.toFinset.card = n →
      (∀ x ∈ s, x ∈ A) →
      (∀ x, 2 ≤ s.count x → x ∈ G) → s.card ≤ m →
      ∃ t : Multiset ℕ, t.Nodup ∧ (∀ x ∈ t, x ∈ A) ∧
        t.card = s.card ∧ t.sum = s.sum := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      intro s hn hsA hrepeat hsize
      by_cases hnodup : s.Nodup
      · exact ⟨s, hnodup, hsA, rfl, rfl⟩
      have hdup : ∃ g, 2 ≤ s.count g := by
        by_contra! h
        apply hnodup
        apply Multiset.nodup_iff_count_le_one.mpr
        intro g
        have := h g
        omega
      obtain ⟨g, hg2⟩ := hdup
      have hgG : g ∈ G := hrepeat g hg2
      have hgmem : g ∈ s := Multiset.count_pos.mp (by omega)
      obtain ⟨R₀, rfl⟩ := Multiset.exists_cons_of_mem hgmem
      have hgR₀ : g ∈ R₀ := by
        apply Multiset.count_pos.mp
        simpa only [Multiset.count_cons_self] using (show 0 < R₀.count g by
          simp only [Multiset.count_cons_self] at hg2
          omega)
      obtain ⟨R, rfl⟩ := Multiset.exists_cons_of_mem hgR₀
      have hRsmall : R.toFinset.card < (centerLowers A g).card := by
        have hRbound := R.toFinset_card_le
        have hpair := hpairs g hgG
        simp only [Multiset.card_cons] at hsize
        omega
      obtain ⟨u, huA, hvA, hult, hufree, hvfree⟩ :=
        fresh_pair A R.toFinset g hRsmall
      let v := 2 * g - u
      have huR : u ∉ R := by simpa using hufree
      have hvR : v ∉ R := by simpa [v] using hvfree
      have huv : u ≠ v := by dsimp [v]; omega
      have hsumuv : u + v = g + g := by dsimp [v]; omega
      have hnewA : ∀ x ∈ u ::ₘ v ::ₘ R, x ∈ A := by
        intro x hx
        simp only [Multiset.mem_cons] at hx
        rcases hx with rfl | rfl | hx
        · exact huA
        · exact hvA
        · exact hsA x (by simp [hx])
      have hnewrepeat : ∀ x, 2 ≤ (u ::ₘ v ::ₘ R).count x → x ∈ G := by
        intro x hx
        have hxu : x ≠ u := by
          intro heq
          subst x
          simp [huv, Multiset.count_eq_zero_of_notMem huR] at hx
        have hxv : x ≠ v := by
          intro heq
          subst x
          simp [huv.symm, Multiset.count_eq_zero_of_notMem hvR] at hx
        have hRx : 2 ≤ R.count x := by simpa [hxu, hxv] using hx
        apply hrepeat x
        by_cases hxg : x = g
        · subst x; simp only [Multiset.count_cons_self]; omega
        · simpa [hxg] using hRx
      have hnewcard : (u ::ₘ v ::ₘ R).card = (g ::ₘ g ::ₘ R).card := by simp
      have hnewsum : (u ::ₘ v ::ₘ R).sum = (g ::ₘ g ::ₘ R).sum := by
        simp only [Multiset.sum_cons]
        omega
      have hsupport := support_increases R g u v huR hvR huv
      have hnewbound := (u ::ₘ v ::ₘ R).toFinset_card_le
      have hdecrease : (u ::ₘ v ::ₘ R).card - (u ::ₘ v ::ₘ R).toFinset.card < n := by
        omega
      obtain ⟨t, ht, htA, htcard, htsum⟩ :=
        ih _ hdecrease (u ::ₘ v ::ₘ R) rfl hnewA hnewrepeat (by omega)
      exact ⟨t, ht, htA, htcard.trans hnewcard, htsum.trans hnewsum⟩
  exact aux _ s rfl hsA hrepeat hsize

/-- Exact-cardinality form of the manuscript's distinct-sum bridge. -/
theorem distinct_sum_exact (A G : Finset ℕ) (m : ℕ) (hGA : G ⊆ A)
    (hpairs : ∀ g ∈ G, m ≤ (centerLowers A g).card)
    (s : Multiset ℕ) (hsG : ∀ x ∈ s, x ∈ G) (hsize : s.card ≤ m) :
    ∃ B : Finset ℕ, B ⊆ A ∧ B.card = s.card ∧ (∑ x ∈ B, x) = s.sum := by
  classical
  obtain ⟨t, ht, htA, htcard, htsum⟩ := eliminate_repetitions A G m hpairs s
    (fun x hx => hGA (hsG x hx))
    (fun x hx => hsG x (Multiset.count_pos.mp (by omega))) hsize
  refine ⟨⟨t, ht⟩, ?_, ?_, ?_⟩
  · exact htA
  · exact htcard
  · simpa using htsum

/-- The nonempty subset-sum form needs an explicit positive summand count. -/
theorem distinct_sum_nonempty (A G : Finset ℕ) (m : ℕ) (hGA : G ⊆ A)
    (hpairs : ∀ g ∈ G, m ≤ (centerLowers A g).card)
    (s : Multiset ℕ) (hsG : ∀ x ∈ s, x ∈ G)
    (hpositive : 0 < s.card) (hsize : s.card ≤ m) :
    ∃ B : Finset ℕ, B.Nonempty ∧ B ⊆ A ∧ B.card = s.card ∧
      (∑ x ∈ B, x) = s.sum := by
  obtain ⟨B, hBA, hcard, hsum⟩ := distinct_sum_exact A G m hGA hpairs s hsG hsize
  exact ⟨B, Finset.card_pos.mp (by omega), hBA, hcard, hsum⟩

#print axioms fresh_pair
#print axioms support_increases
#print axioms eliminate_repetitions
#print axioms distinct_sum_exact
#print axioms distinct_sum_nonempty

end EStarDistinct
