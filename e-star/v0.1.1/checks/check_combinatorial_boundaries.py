"""Finite construction checks; not a proof of an asymptotic theorem.

Standard library only.  Writes solely in this review directory.  This does not
execute or overwrite the previous verification script or its JSON output.
"""

from collections import Counter
from itertools import combinations, combinations_with_replacement
from pathlib import Path
import hashlib
import json
import platform


def pairs_at(A, g):
    return [(u, 2 * g - u) for u in sorted(A) if u < g and 2 * g - u in A]


def distinctify(A, G, m, initial):
    """Construct the strengthened multiset conclusion, including h=0."""
    current = list(initial)
    h, target = len(current), sum(current)
    steps = 0
    while len(current) != len(set(current)):
        counts = Counter(current)
        g = min(x for x, c in counts.items() if c >= 2)
        assert g in G
        residual = list(current)
        residual.remove(g)
        residual.remove(g)
        occupied = set(residual)
        family = pairs_at(A, g)
        assert len(family) >= m >= h
        assert len(occupied) <= h - 2
        blocked = [p for p in family if occupied.intersection(p)]
        assert len(blocked) <= len(occupied)
        u, v = next(p for p in family if not occupied.intersection(p))
        assert u < g < v and u + v == 2 * g
        before = h - len(set(current))
        current = residual + [u, v]
        assert len(current) == h and sum(current) == target
        assert set(current) <= A
        assert all(c == 1 or x in G for x, c in Counter(current).items())
        after = h - len(set(current))
        assert after < before
        assert before - after in (1, 2)
        steps += 1
    return current, steps


def all_invariant_multisets(Emax=8, mmax=4):
    states = transitions = empty_states = pair_families = 0
    for E in range(1, Emax + 1):
        for mask in range(1, 1 << E):
            A = {x for x in range(1, E + 1) if mask >> (x - 1) & 1}
            for g in A:
                endpoints = [x for p in pairs_at(A, g) for x in p]
                assert len(endpoints) == len(set(endpoints))
                assert g not in endpoints
                pair_families += 1
            for m in range(1, mmax + 1):
                G = {g for g in A if len(pairs_at(A, g)) >= m}
                for h in range(m + 1):
                    expected = {sum(t) for t in combinations(sorted(A), h)}
                    for initial in combinations_with_replacement(sorted(A), h):
                        counts = Counter(initial)
                        if any(c >= 2 and x not in G for x, c in counts.items()):
                            continue
                        final, steps = distinctify(A, G, m, initial)
                        assert len(final) == len(set(final)) == h
                        assert sum(final) == sum(initial) in expected
                        states += 1
                        transitions += steps
                        empty_states += h == 0
    return {
        "Emax": Emax,
        "mmax": mmax,
        "invariant_multisets_checked": states,
        "replacement_steps_checked": transitions,
        "empty_multisets_checked": empty_states,
        "pair_families_checked": pair_families,
    }


def central_constructive(Dmax=12, jmax=7):
    counts = {"low": 0, "high": 0, "middle_a": 0, "middle_a_plus_D": 0}
    middle_max_terms_before_zero_padding = 0
    for D in range(1, Dmax + 1):
        for mask in range(1 << (D - 1)):
            C = {0, D} | {x for x in range(1, D) if mask >> (x - 1) & 1}
            if D > 2 * len(C) - 4:
                continue
            gamma = 2 * D + 2 - 2 * len(C)
            assert 0 <= gamma <= D - 2
            Cprime = C - {D}
            for j in range(2, jmax + 1):
                for z in range(gamma, j * D - gamma + 1):
                    if z <= 2 * D - gamma:
                        u, v = next((u, v) for u in sorted(C) for v in sorted(C) if u + v == z)
                        representation = [u, v] + [0] * (j - 2)
                        counts["low"] += 1
                    elif z >= (j - 2) * D + gamma:
                        z2 = z - (j - 2) * D
                        u, v = next((u, v) for u in sorted(C) for v in sorted(C) if u + v == z2)
                        representation = [u, v] + [D] * (j - 2)
                        counts["high"] += 1
                    else:
                        k, a = divmod(z, D)
                        assert 1 <= k <= j - 2
                        u, v = next((u, v) for u in sorted(Cprime) for v in sorted(Cprime) if (u + v) % D == a)
                        carry = (u + v - a) // D
                        assert carry in (0, 1)
                        nD = k - carry
                        assert nD >= 0
                        representation = [u, v] + [D] * nD
                        assert len(representation) <= j
                        middle_max_terms_before_zero_padding = max(middle_max_terms_before_zero_padding, len(representation))
                        counts["middle_a" if carry == 0 else "middle_a_plus_D"] += 1
                        representation += [0] * (j - len(representation))
                    assert len(representation) == j
                    assert set(representation) <= C and sum(representation) == z
    return {
        "Dmax": Dmax,
        "jmax": jmax,
        "targets_by_branch": counts,
        "middle_max_terms_before_zero_padding": middle_max_terms_before_zero_padding,
    }


def empty_counterexample():
    A, G, m, initial = {1, 2, 3}, {2}, 1, ()
    sigma_nonempty = {sum(t) for h in range(1, len(A) + 1) for t in combinations(A, h)}
    assert G <= A and all(len(pairs_at(A, g)) >= m for g in G)
    assert len(initial) <= m and sum(initial) == 0
    assert 0 not in sigma_nonempty
    final, _ = distinctify(A, G, m, initial)
    assert final == []
    return {
        "A": sorted(A), "G": sorted(G), "m": m, "h": 0, "t": 0,
        "nonempty_sigma": sorted(sigma_nonempty),
        "original_conclusion_if_h_zero_is_allowed": False,
        "strengthened_multiset_conclusion": True,
    }


def main():
    result = {
        "kind": "finite-construction-checks-not-universal-proof",
        "python": platform.python_version(),
        "script_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "empty_boundary": empty_counterexample(),
        "multiset_algorithm": all_invariant_multisets(),
        "central_constructive": central_constructive(),
        "status": "all assertions passed; expected empty-boundary counterexample reproduced",
    }
    output = Path(__file__).with_name("review_check_results.json")
    output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
