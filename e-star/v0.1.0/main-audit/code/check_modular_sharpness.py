"""Independent finite checks of proposed sharpness corollaries.

Construction idea is already public (Erdos forum361 post1164, 2025-10-17).
Neither these checks nor absence of an earlier theta formula proves novelty.
"""
from datetime import datetime, timezone
from fractions import Fraction
from math import ceil
from pathlib import Path
import hashlib,json,sys,time

HERE=Path(__file__).resolve().parent

def avoids(A,t):
    cap=(1<<(t+1))-1
    bits=1
    for a in sorted(A):
        if a<=t:
            bits=(bits|(bits<<a))&cap
    return not bool((bits>>t)&1)

def one(q,s,m,k,theta):
    r=q-1
    alpha=(theta+r)/2
    beta=(Fraction(2,m)-Fraction(1,q))*s/alpha-Fraction(s,m*k)
    assert beta>0 and theta<alpha<r
    eps=beta/2
    minimum=max(ceil(4/beta),ceil(theta*alpha/(s*(alpha-theta))))+10
    # sT = 1 (mod m); in q=4 use odd T to retain snd(sT)=4.
    T=minimum
    while s*T%m!=1 or (q==4 and T%2!=1):
        T+=1
    t=s*T;E=ceil(Fraction(t,alpha))
    A0=set(range(m,E+1,m))
    A1={a for a in range(m-1,E+1,m) if k*a>t}
    A=A0|A1
    assert not A0&A1 and t%m==1
    assert k==m-1
    assert len(A)==E//m+(E+1)//m-(t//k+1)//m
    assert len(A)>=Fraction(E,q)+eps*T
    assert theta*E<=t
    assert all(a%m==m-1 and k*a>t for a in A1)
    assert avoids(A,t)
    return {'q':q,'s':s,'modulus':m,'minimumRequiredAddedTerms':k,
      'theta':str(theta),'alpha':str(alpha),'epsilon':str(eps),'T':T,'E':E,'target':t,
      'Acard':len(A),'densityThreshold':str(Fraction(E,q)+eps*T),
      'rangeSatisfied':True,'targetAvoidedByIndependentDistinctDP':True,
      'constructionSha256':hashlib.sha256(','.join(map(str,sorted(A))).encode()).hexdigest()}

def main():
    start=time.monotonic();rows=[]
    for q,s,m,k in [(2,1,2,1),(3,2,3,2),(5,12,5,4),(7,60,7,6),(4,6,5,4)]:
        for gap in [Fraction(1,2),Fraction(1,10),Fraction(1,100)]:
            rows.append(one(q,s,m,k,Fraction(q-1)-gap))
    report={'generatedAt':datetime.now(timezone.utc).isoformat(),
      'status':'PASS_FINITE_MODULAR_SHARPNESS_CONSTRUCTIONS','python':sys.version,
      'scriptSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
      'cases':rows,'seconds':round(time.monotonic()-start,3),
      'mathematicalScope':'Finite tests of infinite-family paper arguments. Together with the unformalized inverse-theorem upper bound, the paper arguments imply theta_q=q-1 for prime q and global theta_4=3. These are internally checked corollaries, not external peer review or complete Lean proofs.',
      'theta4Scope':'Counterexample family fixes s=6. This suffices for theta_4 defined uniformly over all s with snd(s)=4, and for the fixed s=6 constant; it does not prove sharpness separately for every such s.',
      'provenance':'Modular high-residue construction already appears in https://www.erdosproblems.com/forum/thread/361#post-1164 ; no new-construction or priority claim.'}
    (HERE/'MODULAR_SHARPNESS_CHECK.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'status':report['status'],'cases':len(rows),'maxTarget':max(x['target'] for x in rows),'seconds':report['seconds']},ensure_ascii=True))

if __name__=='__main__':main()
