"""Optional Lean recheck; requires caller-provided pinned toolchain and caches."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,time,re
ROOT=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('--lean',required=True,help='Absolute path to Lean 4.33.0-rc1 executable')
parser.add_argument('--library-path',required=True,help='Existing Mathlib/package olean directories separated by the OS path separator')
parser.add_argument('--checker',help='Optional matching leanchecker executable; replay only EStarDistinct module')
args=parser.parse_args()
lean=Path(args.lean).resolve(strict=True)
version=subprocess.run([str(lean),'--version'],capture_output=True,timeout=30)
text=(version.stdout+version.stderr).decode('utf-8',errors='replace')
if version.returncode!=0 or '4.33.0-rc1' not in text:raise SystemExit('Pinned Lean toolchain not available: '+text)
out=ROOT/'results/lean';out.mkdir(parents=True,exist_ok=True)
libraries=[Path(x).resolve(strict=True) for x in args.library_path.split(os.pathsep) if x]
env=os.environ.copy();env['LEAN_PATH']=os.pathsep.join(str(x) for x in [out,*libraries])
rows=[]
allowed={'propext','Classical.choice','Quot.sound'}
expected={'LevAssembly':3,'LevChain':6,'EStarDistinct':5}
for name in ('LevAssembly','LevChain','EStarDistinct'):
    source=ROOT/'formal'/(name+'.lean')
    command=[str(lean),'-o',str(out/(name+'.olean')),str(source)]
    started=time.monotonic()
    proc=subprocess.run(command,cwd=ROOT,env=env,capture_output=True,timeout=240)
    log=proc.stdout+proc.stderr
    (out/(name+'.log')).write_bytes(log)
    axioms=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",log.decode('utf-8',errors='replace'))
    axioms_ok=len(axioms)==expected[name] and all(set(x.strip() for x in values.split(','))<=allowed for _,values in axioms)
    rows.append({'module':name,'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),
                 'exitCode':proc.returncode,'seconds':round(time.monotonic()-started,3),'axiomsOk':axioms_ok,
                 'axioms':{decl:[x.strip() for x in values.split(',')] for decl,values in axioms}})
    if proc.returncode or not axioms_ok:break
if args.checker and len(rows)==3 and all(x['exitCode']==0 and x['axiomsOk'] for x in rows):
    proc=subprocess.run([str(Path(args.checker).resolve(strict=True)),'EStarDistinct'],cwd=out,env=env,capture_output=True,timeout=240)
    (out/'kernel.log').write_bytes(proc.stdout+proc.stderr)
    rows.append({'module':'EStarDistinct kernel replay','exitCode':proc.returncode})
record={'toolchain':text.strip(),'status':'PASS_SCOPED_LEAN_CHECKS' if len(rows)>=3 and all(x['exitCode']==0 and x.get('axiomsOk',True) for x in rows) else 'FAILED_OR_INCOMPLETE',
        'checks':rows,'scope':'Arithmetic steps and finite distinctification only; existing imported dependency environments reused'}
(out/'summary.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(record,ensure_ascii=True,indent=2))
raise SystemExit(0 if record['status'].startswith('PASS') else 2)
