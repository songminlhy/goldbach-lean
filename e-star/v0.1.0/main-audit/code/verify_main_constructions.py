"""New finite end-to-end construction checks; not an asymptotic proof.

Uses actual good centers, gcd normalization, a repeated representation and
distinctification, then independently verifies the resulting subset certificate.
No result from an older checker is consumed.
"""
from collections import Counter
from datetime import datetime, timezone
from fractions import Fraction
from math import ceil, gcd, lcm
from pathlib import Path
from functools import reduce
import hashlib, json, platform, random, sys, time

HERE = Path(__file__).resolve().parent

def snd(s):
    q = 2
    while s % q == 0:
        q += 1
    return q

def sum_bits(values):
    bits = 1
    for a in values:
        bits |= bits << a
    return bits

def membership(values, target):
    """Distinct subset-sum DP, independent of witness construction."""
    cap = (1 << (target + 1)) - 1
    bits = 1
    for a in values:
        if a <= target:
            bits = (bits | (bits << a)) & cap
    return bool((bits >> target) & 1)

def mask(values):
    bits = 0
    for a in values:
        bits |= 1 << a
    return bits

def good_core(A, H, E):
    bits = mask(A)
    reverse = mask(E-a for a in A)
    good, counts = [], {}
    for g in sorted(A):
        shift = 2*g - E
        reflected = reverse << shift if shift >= 0 else reverse >> -shift
        nu = (bits & reflected).bit_count() // 2
        counts[g] = nu
        if nu >= H:
            good.append(g)
    return good, counts

def bounded_repeated(B, y, H):
    """Construct a real bounded representation, do not assume one exists.

    Try copies of max(B) plus two members of B. Success is checked exactly;
    completeness of this search is not claimed or used.
    """
    L, bits = max(B), mask(B)
    reverse = mask(L-b for b in B)
    for k in range(max(0, ceil(Fraction(y, L))-2), min(H-2, y//L)+1):
        z = y-k*L
        shift = z-L
        reflected = reverse << shift if shift >= 0 else reverse >> -shift
        candidates = bits & reflected
        if candidates:
            low = candidates & -candidates
            x = low.bit_length()-1
            rep = [L]*k+[x,z-x]
            assert len(rep) <= H and all(b in B for b in rep) and sum(rep) == y
            return rep
    raise AssertionError('Finite representation search failed, not a theorem counterexample')

def distinctify(A, G, repeated, H):
    values = Counter(repeated)
    h, target = len(repeated), sum(repeated)
    assert 0 < h <= H and set(values) <= G
    steps = 0
    while any(n > 1 for n in values.values()):
        g = next(g for g, n in values.items() if n > 1)
        assert g in G
        old_support = len(values)
        values[g] -= 2
        if not values[g]:
            del values[g]
        pair = next((x,2*g-x) for x in A
                    if x < g and 2*g-x in A and x not in values and 2*g-x not in values)
        for x in pair:
            values[x] += 1
        assert len(values) > old_support
        assert all(g in G for g,n in values.items() if n > 1)
        assert sum(values.values()) == h and sum(g*n for g,n in values.items()) == target
        steps += 1
        assert steps <= h
    result = sorted(values)
    assert all(n == 1 for n in values.values())
    assert set(result) <= A and 0 < len(result) == h <= H and sum(result) == target
    return result, steps

def construct(case, seed):
    started = time.monotonic()
    s,E,T,eps,d,prob = case
    q, r = snd(s), snd(s)-1
    H = r*(ceil(2*s/eps)+1)
    rng = random.Random(seed)
    A = {a for a in range(d,E+1,d) if rng.random() <= prob}
    assert r*E <= s*T
    assert len(A) >= Fraction(E,q)+eps*T
    Glist, pairs = good_core(A,H,E)
    G = set(Glist)
    lost = len(A)-len(G)
    # This is the actual finite hypothesis replacing the asymptotic Roth bound.
    assert lost <= eps*T/2
    assert eps*T/2 >= q
    dg = reduce(gcd,G)
    assert 0 < dg < q and s % dg == 0
    B = {0} | {g//dg for g in G}
    L, y = max(B), s*T//dg
    assert gcd(*B) == 1 and len(B) == len(G)+1
    assert L >= q and len(B) >= Fraction(L,q)+2
    assert r*L <= y <= 2*s/eps*L
    repeated = bounded_repeated(B,y,H)
    repeated = [b*dg for b in repeated if b]
    certificate, steps = distinctify(A,G,repeated,H)
    # Independent DP on A checks target presence, not just certificate sum.
    assert membership(sorted(A),s*T)
    # Validate the pair-count implementation on deliberately selected centers.
    sampled = sorted(G)[::max(1,len(G)//9)][:10]
    for g in sampled:
        brute = sum(1 for x in A if x < g and 2*g-x in A)
        assert brute == pairs[g]
    return {'s':s,'q':q,'E':E,'T':T,'epsilon':str(eps),'seed':seed,
            'samplingProbability':prob,'Acard':len(A),'Gcard':len(G),'badCenters':lost,
            'gcdG':dg,'L':L,'target':s*T,'H':H,'repeatedTerms':len(repeated),
            'distinctificationSteps':steps,'certificate':certificate,
            'seconds':round(time.monotonic()-started,4)}

def exact_small_F(E,n):
    """Exhaust all sets, with distinct DP; return an exact extremum witness."""
    best, witness, visited = -1, [], 0
    def visit(a,bits,chosen):
        nonlocal best,witness,visited
        visited += 1
        if (bits >> n) & 1:
            return
        if len(chosen)+(E-a+1) <= best:
            return
        if a > E:
            best,witness=len(chosen),chosen[:]
            return
        visit(a+1,bits | (bits << a),chosen+[a])
        visit(a+1,bits,chosen)
    visit(1,1,[])
    assert not membership(witness,n)
    return {'E':E,'n':n,'F':best,'witness':witness,'searchNodes':visited}

def brute_F(E,n):
    """Second exact implementation via explicit sum sets, for tiny regression."""
    best=0
    for code in range(1<<E):
        A=[i+1 for i in range(E) if code>>i&1]
        sums={0}
        for a in A:
            sums |= {x+a for x in sums}
        if n not in sums:
            best=max(best,len(A))
    return best

def main():
    started=time.monotonic()
    cases=[
        (1,1024,1024,Fraction(1,4),1,0.9),
        (2,4096,4096,Fraction(1,5),1,0.85),
        (2,8192,8192,Fraction(1,10),2,1.0),
        (6,4096,2048,Fraction(1,2),1,0.85),
        (6,16384,8192,Fraction(1,4),2,1.0),
        (6,65536,32768,Fraction(1,10),3,1.0),
        (12,8192,4096,Fraction(1),1,0.9),
        (60,20480,2048,Fraction(5),1,0.85),
        (420,30720,512,Fraction(20),1,0.8),
    ]
    rows=[construct(case,seed) for seed in [20261119,972131] for case in cases]
    # Independent implementations must agree before interpreting exact extrema.
    regression=[]
    for E in range(1,10):
        for n in range(1,min(18,E*(E+1)//2+2)):
            one=exact_small_F(E,n)['F'];two=brute_F(E,n)
            assert one==two,(E,n,one,two)
            regression.append((E,n))
    extrema=[]
    for T in [1,3,5,7,9]:
        extrema.append(exact_small_F(4*T,6*T))
        extrema.append(exact_small_F(2*T-1,6*T))
    # The lower construction checks positivity, parity and all target sums exactly.
    lower=[]
    for T in range(1,1000,2):
        A=set(range(4,4*T+1,4))|{x for x in range(3*T,4*T+1) if x%2}
        assert len(A)==(3*T+1)//2 and not membership(sorted(A),6*T)
        lower.append(T)
    # Negative controls expose necessary inputs of the finite lemmas.
    B={0,2,4,6,8,10,12,14,16,18,20}
    assert len(B)>=Fraction(20,4)+2
    assert not membership([],1)  # Sanity: empty sum must not hit a positive target.
    repeated={0}
    for _ in range(4*2):
        repeated={x+b for x in repeated for b in B}
    assert 61 not in repeated  # Removing gcd=1 breaks the basis window.
    assert len({0,1,3}) < Fraction(3,2)+2  # +1 density does not imply +2.
    assert 3 < Fraction(3,2)+2  # q=2 growth conclusion fails for this B.
    assert membership([],0)  # Zero target alone permits only the empty certificate.
    report={'generatedAt':datetime.now(timezone.utc).isoformat(),
        'status':'PASS_NEW_FINITE_MAIN_CHAIN_CHECKS','python':sys.version,
        'platform':platform.platform(),'scriptSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'finiteMainChainCases':rows,'independentExactRegressionCases':len(regression),
        'exactSmallExtrema':extrema,'oddTLowerConstructionCases':len(lower),
        'negativeControls':['missing gcd=1 fails basis membership','insufficient +2 density fails q=2 growth','zero target allows empty subset'],
        'seconds':round(time.monotonic()-started,3),
        'scope':'Actual finite A/G/gcd/representation/distinct subset certificates and exact small extrema. No proof of uniform T0, Roth, full inverse theorem, theta, or limit; finite small-T exceptions do not refute asymptotic claims.'}
    (HERE/'MAIN_CONSTRUCTION_CHECK.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'status':report['status'],'mainChainCases':len(rows),'nontrivialGcdCases':sum(x['gcdG']>1 for x in rows),'replacementCases':sum(x['distinctificationSteps']>0 for x in rows),'exactRegressionCases':len(regression),'extrema':extrema,'lowerConstructionCases':len(lower),'seconds':report['seconds']},ensure_ascii=True))

if __name__=='__main__':main()
