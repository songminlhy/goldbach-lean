"""Independent finite verification of the lemma statements in the E* paper.

Scope.  Every check below is a *finite*, *exhaustive over the stated ranges*
test of the statements as they appear in the paper.  Nothing here proves an
asymptotic theorem: Lev's theorem and Roth's theorem are external inputs and
are not proved here (Lev's increment inequality is additionally tested as a
finite statement on small normalised sets, which only tests the transcription,
not the theorem).  The script aborts with AssertionError on the first failure.

Run:  python verify_estar_lemmas.py
Out:  verify_estar_lemmas.json  (alongside the script)
"""

import hashlib
import itertools
import json
import math
import platform
from fractions import Fraction
from pathlib import Path

HERE = Path(__file__).resolve().parent

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------


def layer_bitsets(values, hmax):
    """layers[h] is a bitset: bit i set iff i is a sum of exactly h values."""
    layers = [1]
    cur = 1
    for _ in range(hmax):
        nxt = 0
        for v in values:
            nxt |= cur << v
        layers.append(nxt)
        cur = nxt
    return layers


def covers(bits, lo, hi):
    """True iff every integer in [lo, hi] is represented (empty range: True)."""
    if hi < lo:
        return True
    mask = ((1 << (hi - lo + 1)) - 1) << lo
    return bits & mask == mask


def normalized_sets(L):
    """All B subseteq [0,L] with 0,L in B and gcd(B) = 1."""
    for mask in range(1 << (L - 1)):
        vals = [0] + [v for v in range(1, L) if mask >> (v - 1) & 1] + [L]
        if math.gcd(*vals) != 1:
            continue
        yield vals


def subsets_no_empty(upper):
    """All non-empty subsets of [1, upper] as sorted lists."""
    for mask in range(1, 1 << upper):
        yield [v for v in range(1, upper + 1) if mask >> (v - 1) & 1]


# --------------------------------------------------------------------------
# (A) Lev increment inequality (2.1) on small normalised sets -- transcription
#     test only; the paper uses the theorem as an external input.
# (B) Lemma 2.2 (growth): |rB| >= rL/2 + q
# --------------------------------------------------------------------------

def checks_lev_and_growth(maxL=14, maxq=9):
    lev_instances = 0
    growth_instances = 0
    growth_margins = []
    for L in range(2, maxL + 1):
        hmax = min(maxq - 1, 2 * L)
        for vals in normalized_sets(L):
            N = len(vals)
            layers = layer_bitsets(vals, hmax)
            cards = [b.bit_count() for b in layers]
            for h in range(2, hmax + 1):
                rhs = cards[h - 1] + min(L, h * (N - 2) + 1)
                assert cards[h] >= rhs, ("Lev increment (2.1) fails", L, vals, h)
                lev_instances += 1
            for q in range(2, min(L, maxq) + 1):
                if Fraction(N) < Fraction(L, q) + 2:
                    continue
                r = q - 1
                bound = Fraction(r * L, 2) + q
                assert cards[r] >= bound, ("Lemma 2.2 (2.2) fails", L, vals, q)
                growth_instances += 1
                growth_margins.append(cards[r] - bound)
    return {
        "lev_increment_instances": lev_instances,
        "growth_instances": growth_instances,
        "growth_min_margin": str(min(growth_margins)) if growth_margins else None,
        "growth_max_margin": str(max(growth_margins)) if growth_margins else None,
    }


# --------------------------------------------------------------------------
# (C) Lemma 3.2 (central interval): [gamma, jD - gamma] subseteq jC
# --------------------------------------------------------------------------

def check_central_lemma(Dmax=13, jmax=8):
    instances = 0
    for D in range(1, Dmax + 1):
        for mask in range(1 << (D - 1)):
            C = [0] + [v for v in range(1, D) if mask >> (v - 1) & 1] + [D]
            N = len(C)
            if D > 2 * N - 4:
                continue
            gamma = 2 * D + 2 - 2 * N
            assert 0 <= gamma, ("gamma < 0", D, C)
            assert gamma <= D - 2, ("gamma > D-2", D, C)
            layers = layer_bitsets(C, jmax)
            for j in range(2, jmax + 1):
                assert covers(layers[j], gamma, j * D - gamma), \
                    ("Lemma 3.2 (3.1) fails", D, C, j)
                instances += 1
    return {"central_interval_instances": instances}


# --------------------------------------------------------------------------
# (D) Lemma 3.3 (bounded additive basis): y in H*B for (q-1)L <= y <= K L
# --------------------------------------------------------------------------

def check_basis_lemma(Lmax=12, qmax=8):
    Ks = [Fraction(1, 2), Fraction(1), Fraction(3, 2), Fraction(2),
          Fraction(5, 2), Fraction(3)]
    instances = 0
    vacuous = 0
    for L in range(2, Lmax + 1):
        for vals in normalized_sets(L):
            N = len(vals)
            for q in range(2, min(L, qmax) + 1):
                if Fraction(N) < Fraction(L, q) + 2:
                    continue
                r = q - 1
                for K in Ks:
                    J = math.ceil(K) + 1
                    H = r * J
                    lo = r * L
                    hi = math.floor(K * L)
                    if hi < lo:
                        vacuous += 1
                        continue
                    bits = layer_bitsets(vals, H)[H]
                    for y in range(lo, hi + 1):
                        assert (bits >> y) & 1, ("Lemma 3.3 fails", L, vals, q, K, y)
                        instances += 1
    return {"basis_hits": instances, "basis_vacuous_ranges": vacuous}


# --------------------------------------------------------------------------
# (E) Lemma 4.1 (distinctification)
# --------------------------------------------------------------------------

def min_distinct_counts(A):
    """sum -> least number of distinct elements of A summing to it."""
    best = {0: 0}
    for a in A:
        nxt = dict(best)
        for s, c in best.items():
            key = s + a
            if key not in nxt or nxt[key] > c + 1:
                nxt[key] = c + 1
        best = nxt
    return best


def check_distinct_lemma(Emax=10, mmax=5):
    instances = 0
    for E in range(1, Emax + 1):
        for A in subsets_no_empty(E):
            Aset = set(A)
            best = min_distinct_counts(A)
            sigma = {s: c for s, c in best.items() if s != 0}
            nu = {g: sum(1 for u in A if u < g and (2 * g - u) in Aset) for g in A}
            for m in range(1, mmax + 1):
                G = [g for g in A if nu[g] >= m]
                if not G:
                    continue
                for h in range(1, m + 1):
                    for tup in itertools.combinations_with_replacement(G, h):
                        t = sum(tup)
                        assert t in sigma, ("distinctification: target not in Sigma(A)", A, m, tup)
                        assert sigma[t] <= h, ("distinctification: count bound fails", A, m, tup)
                        instances += 1
    return {"distinctification_instances": instances}


# --------------------------------------------------------------------------
# (F) Lemma 4.2 (few bad centres): |C_m(A)| <= 2 sqrt(2m) r_3(E)
# --------------------------------------------------------------------------

def has_nontrivial_ap(values):
    S = set(values)
    for g in sorted(S):
        for u in sorted(S):
            if u < g and (2 * g - u) in S:
                return True
    return False


def r3_table(Emax):
    table = {}
    for E in range(1, Emax + 1):
        best = 0
        for mask in range(1 << E):
            vals = [v + 1 for v in range(E) if mask >> v & 1]
            if len(vals) <= best:
                continue
            if not has_nontrivial_ap(vals):
                best = len(vals)
        table[E] = best
    return table


def check_bad_centres(Emax=11, mmax=4):
    r3 = r3_table(Emax)
    instances = 0
    tight = []
    for E in range(1, Emax + 1):
        for A in subsets_no_empty(E):
            Aset = set(A)
            nu = {g: sum(1 for u in A if u < g and (2 * g - u) in Aset) for g in A}
            for m in range(1, mmax + 1):
                v = sum(1 for g in A if nu[g] < m)
                # exact comparison |C_m| <= 2 sqrt(2m) r_3  <=>  v^2 <= 8 m r_3^2
                assert v * v <= 8 * m * r3[E] * r3[E], ("Lemma 4.2 fails", E, A, m)
                instances += 1
                if r3[E] > 0:
                    tight.append(Fraction(v, 2 * r3[E]))
    return {
        "bad_centre_instances": instances,
        "r3_table_1_to_%d" % Emax: [r3[E] for E in range(1, Emax + 1)],
        "max_ratio_v_over_2r3": str(max(tight)) if tight else None,
    }


# --------------------------------------------------------------------------
# (G) Theorem 2 (q = 4, c = 2/3): construction avoids 6T, size (3T+1)/2,
#     and the upper-bound pair partition of [2T, 4T]
# --------------------------------------------------------------------------

def check_application(Tmax=33):
    instances = 0
    ratios_low = []
    for T in range(1, Tmax + 1, 2):
        n = 6 * T
        M = 4 * T
        Q = [4 * k for k in range(1, T + 1)]
        U = [x for x in range(3 * T, 4 * T + 1) if x % 2 == 1]
        A = Q + U
        bits = 1
        for a in A:
            bits |= bits << a
        assert ((bits >> n) & 1) == 0, ("construction fails to avoid 6T", T)
        assert len(Q) == T
        assert len(U) == (T + 1) // 2
        assert len(A) == (3 * T + 1) // 2
        assert n % 4 == 2 and (T % 2 == 1)
        # every subset of Q sums to 0 mod 4, one U element is odd, two are > n
        assert all(q % 4 == 0 for q in Q)
        assert all(u % 2 == 1 for u in U) and min(U) >= 3 * T
        sorted_odd = sorted(u for u in U)
        assert sorted_odd[0] + sorted_odd[1] > n if len(sorted_odd) > 1 else True
        # upper bound: [2T,4T] is T complementary pairs plus the centre 3T
        pairs = [(x, n - x) for x in range(2 * T, 3 * T)]
        covered = set()
        for x, y in pairs:
            assert x < y and y <= M and y - x == n - 2 * x
            covered.update((x, y))
        assert covered | {3 * T} == set(range(2 * T, M + 1)), ("pair partition fails", T)
        assert len(pairs) == T
        ratios_low.append(Fraction(len(A), n))
        instances += 1
    return {
        "application_instances": instances,
        "min_lower_ratio": str(min(ratios_low)),
        "max_lower_ratio": str(max(ratios_low)),
        "lower_ratio_at_Tmax": str(ratios_low[-1]),
    }


# --------------------------------------------------------------------------
# (H) parameter chain and constant bookkeeping of Theorem 1 / Corollary 5.2
# --------------------------------------------------------------------------

def snd(s):
    q = 1
    while s % q == 0:
        q += 1
    return q


def check_parameters(smax=60, epsilons=(Fraction(1, 2), Fraction(1, 3),
                                        Fraction(1, 5), Fraction(1, 10),
                                        Fraction(1, 100))):
    instances = 0
    for s in range(1, smax + 1):
        q = snd(s)
        r = q - 1
        assert all(s % d == 0 for d in range(1, q))
        assert r <= 2 ** (q - 2) if q >= 2 else True
        for eps in epsilons:
            K = Fraction(2 * s) / eps
            J = math.ceil(K) + 1
            H = r * J
            assert J >= 2 and H >= 1
            assert H == r * (math.ceil(Fraction(2 * s) / eps) + 1)
            # (q-1)E <= sT  =>  r <= sT/E
            for T in (10, 101, 1000):
                E = (s * T) // r if r else 0
                if E >= 1:
                    assert Fraction(r) <= Fraction(s * T, E)
            instances += 1
    # theta_q window for q >= 4: max{2, q-2+1/q} <= q-1 <= 2^(q-2)
    theta = 0
    for q in range(4, 41):
        lower = max(Fraction(2), Fraction(q - 2) + Fraction(1, q))
        assert lower <= q - 1 <= 2 ** (q - 2)
        theta += 1
    # the step-size inequality used in Lemma 2.2: jL/q + 1 <= L for 2<=j<=q-1, L>=q
    steps = 0
    for L in range(2, 121):
        for q in range(2, min(L, 30) + 1):
            for j in range(2, q):
                assert Fraction(j * L, q) + 1 <= L, ("step inequality fails", L, q, j)
                steps += 1
    # q - 1 <= 2^(q-2) for all q >= 2
    doubling = sum(1 for q in range(2, 60) if q - 1 <= 2 ** (q - 2))
    return {
        "parameter_instances": instances,
        "theta_windows_checked": theta,
        "growth_step_instances": steps,
        "doubling_instances": doubling,
    }


# --------------------------------------------------------------------------
# (I) negative controls: the hypotheses really are needed
# --------------------------------------------------------------------------

def negative_controls():
    # without gcd(B) = 1: B = {0,2,4,6,8}, L = 8, q = 4
    B = [0, 2, 4, 6, 8]
    L, q = 8, 4
    assert len(B) >= Fraction(L, q) + 2
    bits = layer_bitsets(B, 3)[3].bit_count()
    assert bits < Fraction(3 * L, 2) + 4, bits
    gcd_failure = bits
    # with +2 weakened to +1: B = {0,1,8}, L = 8, q = 4
    B2 = [0, 1, 8]
    bits2 = layer_bitsets(B2, 3)[3].bit_count()
    assert len(B2) == math.floor(Fraction(L, q)) + 1
    assert bits2 < Fraction(3 * L, 2) + 4, bits2
    # sanity of the AP predicate used in Lemma 4.2
    assert not has_nontrivial_ap([1, 2, 4, 5])
    assert has_nontrivial_ap([1, 2, 3])
    return {
        "gcd_control_3B_size": gcd_failure,
        "density_control_3B_size": bits2,
        "controls": ["gcd condition removed: fails as intended",
                     "density margin +2 reduced to +1: fails as intended"],
    }


def main():
    result = {
        "kind": "finite-exhaustive-checks-of-stated-lemmas-not-a-proof",
        "python": platform.python_version(),
        "script_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "sections": {},
    }
    result["sections"]["lev_and_growth"] = checks_lev_and_growth()
    result["sections"]["central_interval"] = check_central_lemma()
    result["sections"]["basis"] = check_basis_lemma()
    result["sections"]["distinctification"] = check_distinct_lemma()
    result["sections"]["bad_centres"] = check_bad_centres()
    result["sections"]["application_q4"] = check_application()
    result["sections"]["parameters"] = check_parameters()
    result["sections"]["negative_controls"] = negative_controls()
    result["status"] = "all assertions passed"
    (HERE / "verify_estar_lemmas.json").write_text(
        json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
