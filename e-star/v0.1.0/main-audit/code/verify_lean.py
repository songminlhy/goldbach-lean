"""Portable verification of this supplement, using caller-provided caches.

Usage: python verify_lean.py --lean <Lean4.33.0-rc1.exe>
       --library-path <OS-separated existing library directories>
       [--checker <matching leanchecker.exe>]
All build outputs/logs are written below code/results/; no dependency install.
"""
from pathlib import Path
from datetime import datetime, timezone
import argparse,hashlib,json,os,re,subprocess,time

HERE=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('--lean',required=True)
parser.add_argument('--library-path',required=True)
parser.add_argument('--checker')
args=parser.parse_args()
lean=Path(args.lean).resolve(strict=True)
version=subprocess.run([str(lean),'--version'],capture_output=True,timeout=30)
vtext=(version.stdout+version.stderr).decode('utf-8',errors='replace').strip()
assert version.returncode==0 and '4.33.0-rc1' in vtext,'Require the pinned Lean toolchain'
libraries=[Path(x).resolve(strict=True) for x in args.library_path.split(os.pathsep) if x]
out=HERE/'results';out.mkdir(exist_ok=True)
env=os.environ.copy();env['LEAN_PATH']=os.pathsep.join(map(str,[out,*libraries]))
order=json.loads((HERE/'LEAN_MODULE_ORDER.json').read_text(encoding='utf-8'))
rows=[];allowed={'propext','Classical.choice','Quot.sound'}
for module in order:
    source=HERE/(module+'.lean')
    expected=re.findall(r'^#print axioms\s+([\w.]+)',source.read_text(encoding='utf-8'),re.M)
    assert expected,'Each delivered module has explicit axiom audits'
    started=time.monotonic()
    proc=subprocess.run([str(lean),'-o',str(out/(module+'.olean')),str(source)],cwd=HERE,env=env,capture_output=True,timeout=600)
    data=proc.stdout+proc.stderr;text=data.decode('utf-8',errors='replace')
    (out/(module+'.log')).write_bytes(data)
    axioms={name:[x.strip() for x in values.split(',') if x.strip()]
       for name,values in re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",text)}
    for name in re.findall(r"'([^']+)' does not depend on any axioms",text):axioms[name]=[]
    names_ok=all(any(actual==name or actual.endswith('.'+name) for actual in axioms) for name in expected)
    axioms_ok=names_ok and all(set(values)<=allowed for values in axioms.values())
    row={'module':module,'exitCode':proc.returncode,'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),
         'seconds':round(time.monotonic()-started,3),'axiomsOk':axioms_ok,'axioms':axioms}
    rows.append(row);print(json.dumps(row,ensure_ascii=True),flush=True)
    if proc.returncode or not axioms_ok:break
compiled=len(rows)==len(order) and all(x['exitCode']==0 and x['axiomsOk'] for x in rows)
replays=[]
if compiled and args.checker:
    checker=Path(args.checker).resolve(strict=True)
    for module in order:
        proc=subprocess.run([str(checker),module],cwd=out,env=env,capture_output=True,timeout=600)
        (out/(module+'.kernel.log')).write_bytes(proc.stdout+proc.stderr)
        replays.append({'module':module,'exitCode':proc.returncode})
        if proc.returncode:break
ok=compiled and (not args.checker or len(replays)==len(order) and all(x['exitCode']==0 for x in replays))
record={'generatedAt':datetime.now(timezone.utc).isoformat(),'status':'PASS_DELIVERED_LEAN_SCOPE' if ok else 'FAILED_OR_INCOMPLETE',
  'toolchain':vtext,'checks':rows,'replays':replays,
  'scope':'Read exact signatures: the asymptotic inverse theorem remains conditional on GeneralBasisInput. Imported dependency caches reused; no claim of rebuilding or replaying the full dependency closure.'}
(out/'SUMMARY.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
raise SystemExit(0 if ok else 2)
