"""Verify packaged bytes before executing optional reproductions."""
from pathlib import Path,PurePosixPath
import hashlib
ROOT=Path(__file__).resolve().parent
count=0
for line in (ROOT/'MANIFEST.sha256').read_text(encoding='utf-8').splitlines():
    expected,name=line.split('  ',1)
    member=PurePosixPath(name)
    if member.is_absolute() or '..' in member.parts:raise SystemExit('Unsafe manifest member')
    path=ROOT.joinpath(*member.parts)
    if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest()!=expected:
        raise SystemExit('Manifest mismatch: '+name)
    count+=1
print('PASS manifest: '+str(count)+' files')
