"""Run finite checks offline in fresh task-owned output directories."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,shutil,subprocess,sys,tempfile,time
ROOT=Path(__file__).resolve().parent
RESULTS=ROOT/'results'
RESULTS.mkdir(exist_ok=True)
RUN=Path(tempfile.mkdtemp(prefix='finite-',dir=RESULTS))
rows=[]
for name,expected in [('check_finite_lemmas.py','verify_estar_lemmas.json'),
    ('check_combinatorial_boundaries.py','review_check_results.json'),('check_fresh_proof.py','fresh_proof_checks.json')]:
    source=ROOT/'checks'/name
    task=RUN/source.stem;task.mkdir()
    copy=task/name;shutil.copyfile(source,copy)
    started=time.monotonic()
    proc=subprocess.run([sys.executable,str(copy)],cwd=task,capture_output=True,timeout=120)
    (task/'stdout.log').write_bytes(proc.stdout)
    (task/'stderr.log').write_bytes(proc.stderr)
    result=task/expected
    row={'script':name,'sha256':hashlib.sha256(copy.read_bytes()).hexdigest(),'exitCode':proc.returncode,
         'seconds':round(time.monotonic()-started,3),'result':str(result.relative_to(ROOT)),
         'resultExists':result.is_file()}
    if result.is_file():row['reportedStatus']=json.loads(result.read_text(encoding='utf-8')).get('status')
    rows.append(row)
summary={'generatedAt':datetime.now(timezone.utc).isoformat(),'python':sys.version.split()[0],
         'scope':'Bounded exhaustive and constructive checks only; not proof of universal or asymptotic claims',
         'checks':rows,'status':'PASS_FINITE_CHECKS' if all(x['exitCode']==0 and x['resultExists'] for x in rows) else 'FAILED_OR_INCOMPLETE'}
(RUN/'summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(summary,ensure_ascii=True,indent=2))
raise SystemExit(0 if summary['status']=='PASS_FINITE_CHECKS' else 2)
