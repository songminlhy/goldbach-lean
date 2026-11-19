"""Bounded independent set checks for the new residue-lifting interfaces."""
from pathlib import Path
from datetime import datetime,timezone
from itertools import combinations
import hashlib,json,math,time
HERE=Path(__file__).resolve().parent
start=time.monotonic()
def repeated(B,h):
    S={0}
    for _ in range(h):S={a+b for a in B for b in S}
    return S
def periods(C,L):return {x for x in range(L) if {(c+x)%L for c in C}==C}
def prime(n):return n>=2 and all(n%d for d in range(2,math.isqrt(n)+1))
counts={'sets':0,'liftSteps':0,'heavyBlockLiftSteps':0,'primeDiameterLevSteps':0,'compositeAperiodicSteps':0,'compositeFullSteps':0,'compositeProperNontrivialPeriodSteps':0,'properNontrivialPeriodWithGcdOneSteps':0,'properPeriodKneserAndFiberCertificates':0}
examples=[]
for L in range(1,14):
    for mask in range(1 << max(0,L-1)):
        B={0,L}|{a for a in range(1,L) if (mask>>(a-1))&1}
        counts['sets']+=1
        prev={0}
        for h in range(1,7):
            S={a+b for a in B for b in prev}
            R={x%L for x in S}
            new=S-prev
            assert prev<=S
            assert {x%L for x in new}==R,(L,B,h)
            assert len(prev)+len(R)<=len(S)
            counts['liftSteps']+=1
            oldResidues={x%L for x in prev}
            freshResidues=R-oldResidues
            blocks=[freshResidues]+[{c} for c in freshResidues]
            for C in blocks:
                Q={x for x in S if x%L in C}
                assert not(C&oldResidues)
                assert len(prev)+len(R)+len(Q)<=len(S)+len(C)
                counts['heavyBlockLiftSteps']+=1
            if h>=2:
                inc=min(L,h*(len(B)-2)+1)
                if prime(L):
                    assert len(R)>=inc
                    assert len(S)>=len(prev)+inc
                    counts['primeDiameterLevSteps']+=1
                else:
                    H=periods(R,L)
                    if len(R)==L:counts['compositeFullSteps']+=1
                    elif len(H)==1:
                        assert len(R)>=h*(len(B)-2)+1
                        counts['compositeAperiodicSteps']+=1
                    else:
                        counts['compositeProperNontrivialPeriodSteps']+=1
                        if math.gcd(*B)==1:
                            counts['properNontrivialPeriodWithGcdOneSteps']+=1
                            Abar={x%L for x in B}
                            Aplus={(a+t)%L for a in Abar for t in H}
                            W={(a+t)%L for a in oldResidues for t in H}
                            assert W<R
                            seen=set()
                            for c in R-W:
                                C=frozenset((c+t)%L for t in H)
                                if C in seen:continue
                                seen.add(C)
                                Q={x for x in S if x%L in C}
                                assert not(C&oldResidues)
                                assert h*len(Aplus)<=len(R)+(h-1)*len(C)
                                assert h*len(Abar)+h*len(C)<=len(Q)+h*len(Aplus)+(h-1)
                                counts['properPeriodKneserAndFiberCertificates']+=1
                            if len(examples)<3:examples.append({'L':L,'B':sorted(B),'h':h,'residueCard':len(R),'periods':sorted(H),'integerSumsetCard':len(S),'previousCard':len(prev),'gcd':1})
            prev=S
B={0,1,4,5,8,9,12};L=12;h=2
S=repeated(B,h);R={x%L for x in S};A={x%L for x in B}
assert len(R)==9 and 2*len(A)-1==11 and len(S)==18
periodic={'L':L,'B':sorted(B),'h':h,'Abar':sorted(A),'hAbar':sorted(R),'periods':sorted(periods(R,L)),'naiveCauchyDavenportLower':2*len(A)-1,'actualCyclicCard':len(R),'actualIntegerCard':len(S),'LevLower':len(B)+min(L,h*(len(B)-2)+1)}
negative=[]
for name,B in [('missing_zero',{1,2}),('missing_top',{0,1})]:
    L=2;P=repeated(B,1);S=repeated(B,2);R={x%L for x in S}
    assert len(P)+len(R)>len(S)
    negative.append({'omittedCondition':name,'B':sorted(B),'L':L,'previousCard':len(P),'residueCard':len(R),'nextCard':len(S)})
record={'generatedAt':datetime.now(timezone.utc).isoformat(),'status':'PASS_BOUNDED_RESIDUE_LIFT_AND_PRIME_GROWTH_WITH_REQUIRED_PERIODIC_OBSTRUCTION','scope':'All endpoint-containing B subsets [0,L], 1<=L<=13, h<=6. Does not prove universal Lev or Kneser.','seconds':round(time.monotonic()-start,3),'counts':counts,'properPeriodExamples':examples,'explicitCompositeObstruction':periodic,'negativeControls':negative,'scriptSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
(HERE/'residue_check_results.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(record,ensure_ascii=True))
