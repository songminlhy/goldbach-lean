"""Fresh, standard-library-only finite checks for the prereview proof audit.

This file is independent of the earlier verification scripts. Finite checks do
not establish Roth, Lev, a uniform asymptotic threshold, or either main theorem.
All outputs are confined to this file's directory.
"""

from collections import Counter
from fractions import Fraction
from itertools import combinations_with_replacement
from math import ceil, gcd
from pathlib import Path
import hashlib
import json
import platform
import sys
import time


HERE = Path(__file__).resolve().parent
SOURCES = [Path(__file__).resolve()]


def hashes():
    return {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in SOURCES}


def endpoint_sets(L):
    for mask in range(1 << (L - 1)):
        yield (0,) + tuple(x for x in range(1, L) if mask >> (x - 1) & 1) + (L,)


def sumset(B, h):
    C = {0}
    for _ in range(h):
        C = {x + b for x in C for b in B}
    return C


def two_rep(C, z):
    return next((u, z - u) for u in C if z - u in C)


def central_rep(C, D, j, z):
    gamma = 2 * D + 2 - 2 * len(C)
    if z <= 2 * D - gamma:
        return (*two_rep(C, z), *((0,) * (j - 2))), "left"
    if z >= (j - 2) * D + gamma:
        return (*two_rep(C, z - (j - 2) * D), *((D,) * (j - 2))), "right"
    k, a = divmod(z, D)
    assert 1 <= k <= j - 2
    Cp = set(C) - {D}
    u, v = next((u, v) for u in Cp for v in Cp if (u + v) % D == a)
    if u + v == a:
        ds, branch = k, "middle_residue_a"
    else:
        assert u + v == a + D
        ds, branch = k - 1, "middle_residue_a_plus_D"
    rep = (u, v) + (D,) * ds
    assert len(rep) <= j
    return rep + (0,) * (j - len(rep)), branch


def check_central():
    counts = Counter()
    for D in range(1, 13):
        for C in endpoint_sets(D):
            if D > 2 * len(C) - 4:
                continue
            counts["sets"] += 1
            gamma = 2 * D + 2 - 2 * len(C)
            assert 0 <= gamma <= D - 2
            for j in range(2, 9):
                for z in range(gamma, j * D - gamma + 1):
                    rep, branch = central_rep(C, D, j, z)
                    assert len(rep) == j and sum(rep) == z and set(rep) <= set(C)
                    counts["exact_length_targets"] += 1
                    counts[branch] += 1
    return dict(counts)


def check_growth_basis():
    counts = Counter()
    min_growth_slack = None
    for L in range(2, 13):
        for B in endpoint_sets(L):
            if gcd(*B) != 1:
                continue
            for q in range(2, L + 1):
                if q * len(B) < L + 2 * q:
                    continue
                r = q - 1
                counts["growth_cases"] += 1
                C = sumset(B, r)
                slack = Fraction(len(C)) - Fraction(r * L, 2) - q
                assert slack >= 0
                min_growth_slack = slack if min_growth_slack is None else min(min_growth_slack, slack)
                for K in (Fraction(2 * r - 1, 2), Fraction(r), Fraction(2 * r + 1, 2), Fraction(r + 2)):
                    J = ceil(K) + 1
                    H = r * J
                    top = K.numerator * L // K.denominator
                    if top < r * L:
                        counts["basis_empty_windows"] += 1
                        continue
                    # Truncated bitset convolution, preserving exact H terms;
                    # 0 in B makes the padding operation visible and valid.
                    cap = (1 << (top + 1)) - 1
                    bits = 1
                    for _ in range(H):
                        bits = (sum_shift_or(bits, B)) & cap
                    for y in range(r * L, top + 1):
                        assert (bits >> y) & 1, (B, q, K, H, y)
                        counts["basis_nonempty_target_hits"] += 1
    return {**dict(counts), "minimum_growth_slack": str(min_growth_slack)}


def sum_shift_or(bits, B):
    result = 0
    for b in B:
        result |= bits << b
    return result


def dedup(A, G, rep, m):
    mu = Counter(rep)
    h, target = len(rep), sum(rep)
    steps = 0
    while max(mu.values(), default=0) > 1:
        support_before = len(mu)
        g = next(g for g, count in mu.items() if count >= 2)
        assert g in G
        mu[g] -= 2
        if mu[g] == 0:
            del mu[g]
        free = next((u, 2 * g - u) for u in A if u < g and 2 * g - u in A and u not in mu and 2 * g - u not in mu)
        mu.update(free)
        assert len(mu) > support_before
        assert all(count == 1 or value in G for value, count in mu.items())
        assert sum(mu.values()) == h and sum(x * n for x, n in mu.items()) == target
        steps += 1
    assert len(mu) == h and set(mu) <= set(A) and h >= 1
    return steps


def check_distinct():
    counts = Counter()
    for E in range(1, 13):
        for mask in range(1, 1 << E):
            A = tuple(x for x in range(1, E + 1) if mask >> (x - 1) & 1)
            for m in range(1, 6):
                G = tuple(g for g in A if sum(u < g and 2 * g - u in A for u in A) >= m)
                if not G:
                    continue
                counts["nonempty_good_core_cases"] += 1
                for h in range(1, m + 1):
                    for rep in combinations_with_replacement(G, h):
                        counts["nonempty_representations"] += 1
                        counts["replacement_steps"] += dedup(A, G, rep, m)
    # Explicitly record why h >= 1 is needed for the nonempty-sum corollary.
    assert sum(()) == 0 and not any(sum(X) == 0 for X in ((1,),))
    counts["empty_sum_boundary_checks"] = 1
    return dict(counts)


def check_q4():
    counts = Counter()
    for T in range(1, 202, 2):
        Q = set(range(4, 4 * T + 1, 4))
        U = {x for x in range(3 * T, 4 * T + 1) if x % 2}
        A = Q | U
        assert not Q & U and len(A) == (3 * T + 1) // 2
        bits, cap = 1, (1 << (6 * T + 1)) - 1
        for a in sorted(A):
            bits = (bits | bits << a) & cap
        assert not (bits >> (6 * T)) & 1
        pairs = [{x, 6 * T - x} for x in range(2 * T, 3 * T)]
        assert len(pairs) == T and all(len(p) == 2 for p in pairs)
        cover = {3 * T}
        for p in pairs:
            assert not cover & p
            cover |= p
        assert cover == set(range(2 * T, 4 * T + 1))
        counts["odd_T_lower_constructions"] += 1
        counts["pair_partitions"] += 1
    # A deliberately excluded boundary: when T is even, the Q-only residue
    # obstruction need not hold. T=2 has 12=4+8 inside the displayed Q.
    assert 4 + 8 == 6 * 2
    counts["even_T_negative_control"] = 1
    return dict(counts)


def check_gcd_normalization():
    counts = Counter()
    for E in range(1, 13):
        for mask in range(1, 1 << E):
            G = tuple(x for x in range(1, E + 1) if mask >> (x - 1) & 1)
            d = gcd(*G)
            L = max(G) // d
            B = (0,) + tuple(g // d for g in G)
            assert gcd(*B) == 1 and L >= len(G) and len(B) == len(G) + 1
            for q in range(2, 13):
                if q * len(G) <= E:
                    continue
                assert d < q
                counts["density_implies_d_lt_q"] += 1
                if d > 1:
                    counts["nontrivial_d_cases"] += 1
    return dict(counts)


def main():
    start = time.time()
    before = hashes()
    result = {
        "scope": "Fresh finite checks; no proof of the asymptotic main theorem or of external inputs.",
        "python": sys.version,
        "executable": sys.executable,
        "platform": platform.platform(),
        "source_hashes_before": before,
    }
    for label, check in (("central_exact_lengths", check_central), ("growth_and_basis", check_growth_basis), ("distinctness", check_distinct), ("gcd_normalization", check_gcd_normalization), ("q4_limit_ingredients", check_q4)):
        result[label] = check()
        print(label + ": " + json.dumps(result[label], ensure_ascii=False), flush=True)
    result["source_hashes_after"] = hashes()
    assert before == result["source_hashes_after"]
    result["elapsed_seconds"] = round(time.time() - start, 3)
    result["status"] = "passed"
    (HERE / "fresh_proof_checks.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("passed; elapsed_seconds=" + str(result["elapsed_seconds"]), flush=True)


if __name__ == "__main__":
    main()
