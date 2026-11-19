"""Independent finite seam/negative-control audit, using only the stdlib.

No old checker, review report or stored PASS result is imported.  Passing these
checks cannot prove an unspecified T0, Roth, Lev, or the asymptotic main result.
"""

from fractions import Fraction
from math import ceil, gcd
from pathlib import Path
import hashlib
import json
import platform
import sys
import time


HERE = Path(__file__).resolve().parent
TEX = HERE / "E_star_anonymous.tex"


def source_hash():
    return hashlib.sha256(TEX.read_bytes()).hexdigest() if TEX.exists() else "PAPER_SOURCE_NOT_BUNDLED"


def exact_repeat_bits(B, h, upper):
    bits = 1
    cap = (1 << (upper + 1)) - 1
    for _ in range(h):
        out = 0
        for b in B:
            out |= bits << b
        bits = out & cap
    return bits


def distinct_has(A, target):
    bits = 1
    cap = (1 << (target + 1)) - 1
    for a in A:
        bits = (bits | bits << a) & cap
    return bool((bits >> target) & 1)


def smallest_nondivisor(s):
    q = 2
    while s % q == 0:
        q += 1
    return q


def parameter_seams():
    cases = div_cases = dense_cases = k_cases = 0
    for L in range(2, 81):
        for N in range(3, L + 2):
            a = N - 2
            k = (L - 1) // a
            rho = (k + 1) * a + 2 - L
            assert k >= 1 and k * a + 1 <= L <= (k + 1) * a + 1 and rho >= 1
            for q in range(2, L + 1):
                if q * N < L + 2 * q:
                    continue
                r = q - 1
                cases += 1
                div_cases += (L - 1) % a == 0
                dense_cases += N == L + 1
                assert 1 <= k <= r
                G = 2 * k * L - k * (k + 1) * N + 2 * k * k
                assert G == k * (L - rho) == k * (2 * L - 2 - (k + 1) * a)
                assert G <= r * L - 2 * k
                for K in (Fraction(1, 3), Fraction(r), Fraction(3 * r + 2, 3)):
                    H = r * (ceil(K) + 1)
                    nu = H - 2 * k
                    assert nu >= 0 and H * L - G >= K * L
                    assert nu * L + k * (k + 1) * N - 2 * k * k == H * L - G
                    k_cases += 1
    return dict(parameter_cases=cases, division_boundary_cases=div_cases,
                full_interval_cases=dense_cases, K_cases=k_cases)


def small_actual_basis():
    sets = growth_steps = targets = empty = 0
    min_slack = None
    for L in range(2, 13):
        for mask in range(1 << (L - 1)):
            B = [0] + [b for b in range(1, L) if mask & (1 << (b - 1))] + [L]
            if gcd(*B) != 1:
                continue
            N = len(B)
            for q in range(2, min(7, L + 1)):
                if q * N < L + 2 * q:
                    continue
                sets += 1
                r = q - 1
                C = set(B)
                for j in range(2, r + 1):
                    D = {c + b for c in C for b in B}
                    assert len(D) - len(C) >= min(L, j * (N - 2) + 1)
                    C = D
                    growth_steps += 1
                slack = Fraction(len(C)) - Fraction(r * L, 2) - q
                assert slack >= 0
                min_slack = slack if min_slack is None else min(slack, min_slack)
                for K in (Fraction(1, 3), Fraction(r), Fraction(3 * r + 2, 3)):
                    upper = K.numerator * L // K.denominator
                    if upper < r * L:
                        empty += 1
                        continue
                    H = r * (ceil(K) + 1)
                    bits = exact_repeat_bits(B, H, upper)
                    for y in range(r * L, upper + 1):
                        assert (bits >> y) & 1, (L, B, q, K, H, y)
                        targets += 1
    return dict(normalized_density_cases=sets, actual_Lev_increment_steps=growth_steps,
                basis_target_hits=targets, empty_windows_excluded=empty,
                minimum_growth_slack=str(min_slack))


def negative_controls():
    varied_eps = fake_q = sharpness = 0
    # Fixed epsilon cannot be weakened to epsilon(T)>0 without a uniform margin.
    for T in range(1, 202, 2):
        E, t, q = 2 * T, 6 * T, smallest_nondivisor(6)
        A = list(range(4, E + 1, 4)) + [1]
        eps_T = Fraction(1, 2 * T)
        assert q == 4 and 3 * E == t
        assert len(A) == Fraction(E, q) + eps_T * T
        assert not distinct_has(A, t)
        varied_eps += 1
    # Arbitrary q in place of snd(s) breaks the common-divisor argument.
    for u in range(1, 102):
        s, q, T, E = 1, 3, 4 * u + 1, 2 * u
        A = list(range(2, E + 1, 2))
        eps = Fraction(1, 24)
        assert q != smallest_nondivisor(s)
        assert (q - 1) * E <= s * T and len(A) >= Fraction(E, q) + eps * T
        assert not distinct_has(A, s * T)
        fake_q += 1
    # Removing gcd=1 from the basis statement keeps all sums even.
    B = list(range(0, 13, 2))
    assert len(B) >= Fraction(12, 4) + 2 and 3 * 12 <= 37 <= 4 * 12
    assert not (exact_repeat_bits(B, 15, 48) >> 37) & 1
    # The length guard and positive-length guard are substantive.
    assert not distinct_has([1, 2, 3], 8)  # 2+2+2+2=8 but only one pair at 2.
    assert not any(sum(X) == 0 for X in ([1],))
    # Without the eventual T threshold, the main theorem is false at T=1.
    assert len([1, 2]) >= Fraction(2, 4) + 1 and 3 * 2 <= 6
    assert not distinct_has([1, 2], 6)
    # Even T does not support the lower construction in the limit application.
    assert distinct_has([4, 7, 8], 12)
    # Sharpness of the general (not arithmetic-target) basis lower endpoint.
    for q in range(2, 12):
        for b in range(2, 41):
            L, r = q * b, q - 1
            B = list(range(0, L + 1, q)) + [L - 1]
            y = r * (L - 2) - 1
            assert y > 0 and len(B) == Fraction(L, q) + 2 and gcd(*B) == 1
            # An independent unbounded-coin DP tests the entire generated
            # semigroup up to y rather than only one prescribed hB.
            reachable = bytearray(y + 1)
            reachable[0] = 1
            for coin in sorted(set(B) - {0}):
                for v in range(coin, y + 1):
                    if reachable[v - coin]:
                        reachable[v] = 1
            assert not reachable[y]
            sharpness += 1
    return dict(varying_epsilon_countermodels=varied_eps,
                wrong_q_countermodels=fake_q,
                missing_gcd_countermodel=1, missing_h_bound_countermodel=1,
                empty_sum_guard=1, missing_T0_countermodel=1,
                even_T_lower_construction_failure=1,
                general_basis_semigroup_obstructions=sharpness)


def modulus_five_lower_bound_examples():
    """Finite examples of the new lower-bound derivation, not main counterexamples.

    Infinite-family proof and quantifiers are in MODULAR_LOWER_BOUND_NOTE.md.
    These examples do NOT satisfy 3E<=6T, so do not contradict the actual paper.
    """
    examples = []
    for theta in (Fraction(2), Fraction(5, 2), Fraction(29, 10), Fraction(299, 100)):
        alpha = (theta + 3) / 2
        eps = 3 * (3 - alpha) / (20 * alpha)
        bound = ceil(2 / eps)
        T = 10 * ceil(Fraction(bound - 1, 10)) + 1
        target = 6 * T
        E = ceil(Fraction(target) / alpha)
        Q = list(range(5, E + 1, 5))
        U = [x for x in range(target // 4 + 1, E + 1) if x % 5 == 4]
        A = sorted(Q + U)
        assert T % 10 == 1 and target % 5 == 1 and smallest_nondivisor(target) == 4
        assert theta * E <= target and 3 * E > target
        assert len(A) >= Fraction(E, 4) + eps * T
        assert len(A) >= Fraction(E, 4) + Fraction(3 * E - target, 20) - 2
        assert sum(U[:4]) > target and not distinct_has(A, target)
        examples.append(dict(theta=str(theta), alpha=str(alpha), epsilon=str(eps),
                             T=T, E=E, target=target, cardinality=len(A),
                             density_threshold=str(Fraction(E, 4) + eps * T),
                             smallest_four_U_sum=sum(U[:4]), target_avoided=True))
    return examples


def main():
    start = time.perf_counter()
    before = source_hash()
    result = dict(scope="Finite adversarial seam audit, not proof of either asymptotic theorem.",
                  python=sys.version, platform=platform.platform(),
                  optional_source=TEX.name, source_sha256_before=before,
                  scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    for name, check in (("parameter_seams", parameter_seams),
                        ("small_actual_basis", small_actual_basis),
                        ("expected_failure_negative_controls", negative_controls),
                        ("modulus_five_lower_bound_examples", modulus_five_lower_bound_examples)):
        result[name] = check()
        print(name + ": " + json.dumps(result[name], ensure_ascii=False), flush=True)
    result["source_sha256_after"] = source_hash()
    assert result["source_sha256_after"] == before
    result["status"] = "passed"
    result["elapsed_seconds"] = round(time.perf_counter() - start, 3)
    (HERE / "adversarial_seams.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("status=passed; elapsed_seconds=" + str(result["elapsed_seconds"]), flush=True)


if __name__ == "__main__":
    main()
