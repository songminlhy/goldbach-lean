# English announcement (draft — replace `{{...}}` before posting)

## Title

**The 1+1 gap, machine-checked — with a kernel-checked note on arXiv:2611.09007v1**

## Body

The binary Goldbach conjecture is still open. What we did is not a proof of it: we turned two
statements that are usually left informal into kernel-checked Lean 4 theorems.

**1. The three headline endpoints are consequences of 1+1, not approximations to it.**
Chen's 1+2 has the shape `N = p + q` with `q` prime or a product of two primes; Li–Liu's 1+1.9
and Wu's 1+1.8938 have the shape `N = p + r·q` with `r = 1` or `r` prime. Each contains "a sum
of two primes" as the special case `r = 1`, `q` prime, so each follows from binary Goldbach:

```
binaryGoldbach_implies_chen
binaryGoldbach_implies_onePlusOneNine
binaryGoldbach_implies_onePlusOne8938
```

They are *weaker* than 1+1. Three further witness theorems show that the endpoint predicates
genuinely admit what 1+1 forbids (Chen: `4 = 2·2`; Li–Liu: `18 = 3 + 3·5`; Wu: `13 = 7 + 2·3`).

**2. A recent preprint's Theorem 1.1 already implies 1+1 under its own definition.**
[arXiv:2611.09007v1](https://arxiv.org/abs/2611.09007) (6 Nov 2026) defines `f = O(g)` on
line 111 as `lim f(n)/g(n) = c ≠ 0`. Under that definition its Theorem 1.1
(`G(2n)·log²(2n)/n → c`) forces `c > 0`, hence a Goldbach representation for every sufficiently
large even number. We formalized exactly this as

```
paperTheorem_implies_binaryGoldbach
```

So the induction step on line 180 lists the current case `G(2n)` among the objects it may assume,
which is circular; the same sentence takes "the positivity of `G(2n-2)`" as an input, which under
the literal definition already presupposes the required positivity and under the standard reading
lacks a basis. This is not a miscomputed inequality; the stated theorem already contains the
conjecture.

**Eight theorems, axioms ⊆ `{propext, Classical.choice, Quot.sound}`, replayed with
`leanchecker`.** Repository: {{REPO_URL}} — archive DOI: {{DOI}} — timestamp and verification
steps under `priority/`.

## What we are not saying

- **We do not prove Goldbach.** No unconditional theorem here concludes `BinaryGoldbach`.
- **We do not prove that the endpoints cannot imply 1+1.** That needs a metamathematical
  argument; the witness theorems only show the predicates are wider.
- **We do not claim to be first.** The queries and their date are in `PRIOR_ART.md`; they show
  only that we did not find a predecessor.
- The upstream [`goldbach-lean`](https://github.com/subfish-zhou/goldbach-lean) development is
  [subfish-zhou](https://github.com/subfish-zhou)'s work (Apache-2.0). We added four files and
  patched two; the rest is theirs.
- If the authors of the preprint think we misread line 111, we would like to know: the quotation
  is literal and the formalization is line-by-line, so a correction is cheap.

## One-line version

> In Lean 4: Chen 1+2, Li–Liu 1+1.9 and Wu 1+1.8938 are all consequences of 1+1; and
> arXiv:2611.09007v1's Theorem 1.1 already implies 1+1 under its own big-O definition —
> its induction hypothesis states the conclusion. Eight kernel-checked theorems.
> Goldbach remains open, and we make no priority claim.
