# E* conditional-limit and source follow-up

Anonymous · CC BY 4.0 · 2026-11-19

Read [中文报告](REPORT.zh-CN.md) first. This is a new supplement; the original [paper and review package](https://doi.org/10.5281/zenodo.24342987) are unchanged.

The actual extremal function and original floor-based quarter-limit on the entire n=6 mod12 class are formalized **relative to the explicit classical `LevGrowthInput`**. Exact least-positive-nondivisor definitions are supplied. This does not claim an unconditional Lean proof of Lev, novelty or external peer review.

## Reproduction

Use Lean 4.33.0-rc1 and compatible existing package libraries. The host Mathlib revision was `e4c91783ca8e6a7c693ae624ade32fd22d4e43c1`. Provide library paths separated by the operating-system separator (`;` on Windows, `:` on Unix).

```text
python code/verify_lean.py --lean <absolute-lean-executable> --library-path <existing-package-library-directories> --checker <matching-leanchecker-executable>
```

The runner compiles modules sequentially in `code/LEAN_MODULE_ORDER.json`, axiom-audits them and optionally module-replays them, writing only `code/results/`. It installs nothing and changes no global setting. Single-thread and process memory defaults reflect this host's checked run; imported caches are reused, not a full dependency-closure rebuild/replay.

Publisher baseline results in `results/LEAN_SUMMARY.json` distinguish previously checked immutable dependencies from this round's new compiled modules. The original dependency source bytes and their source licenses are retained; their inclusion is not a new claim of mathematical contribution or a new run of every unchanged dependency.

`code/check_residue_branches.py` is a standard-library finite checker for the partial Lev branches and the required composite-period obstruction; its finite results do not establish the general Lev theorem or Kneser's theorem.

## Attribution

Reused good-core, Roth and center-covering proof code comes from [matejasevick/erdos361, fixed commit](https://github.com/matejasevick/erdos361/tree/27f45e7f84894993c1471e952608319aebc53eee), under MIT. The license is in `code/UPSTREAM_LICENSE.txt`; legacy relative license paths in original comments refer to its original workspace layout. New material is licensed as described in `LICENSE.txt`.

The classic Lev theorem remains a mathematical parameter. Partial prime-diameter or aperiodic-period proofs cannot discharge it for all normalized sets. The paper's source/PDF identity and its machine proof status are separate.

No third-party paper PDF, private conversation, credential or personal path is distributed here. Failed drafts and runtime diagnostics remain local; only frozen passing proof sources are included.
