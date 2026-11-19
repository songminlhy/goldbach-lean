# N4 补充：Wu 1.8938 端点独立重编完成（postseal，2026-11-17）

**性质**：本文件在 `priority/postseal/` 下，**不在** `priority/MANIFEST.sha256` 的 68 个文件里。
封存包在 2026-11-16 23:56:44 UTC 重新封存（并入 Q4 与前序检索证据）；本条是那之前的构建记录：sealed at `2026-11-16 23:56:44 UTC`，manifest `77df12642d7eb2210280ab09e398d101052e6158040033289074080d79ee8860`，
token `26bfee4a…`，genTime `Nov 16 23:56:45 2026 GMT`。本文件**不是**对封存内容的修改，
也**不**触发重封存；是否重封存由作者决定。

## 1. 为什么要写这份补充

封存包 `CLAIM.md` 的 N4 写：

> **N4** | "Wu 1.8938 已内核复核" | `research/wu2008/` 未构建，`src/` 下无 `.olean`；Wu 形状仅为逐字转录 + `#check`。

这句话的事实前提是 **2026-11-16 02:12（封存时点）** 的工作区状态。2026-11-17 02:01，本地独立重编已完成，
N4 的事实前提在本工作区**已过期**；但 N4 作为**发布措辞禁令**仍然成立——只是禁令的理由从
「没有构建」变成「构建的范围有限，不能越界表述」。这份补充把「可写什么、不可写什么」钉在证据上。

## 2. 新证据（2026-11-17 02:01:33）

| 项 | 值 | 证据 |
|---|---|---|
| 闭包 / 完成 | 3764 / 3764 | `frontier/wu_verify/STATUS.json` |
| 真实失败 | 0 | 同上 `failures: []`；`logs/supervised_20261117_0012_a1.log` |
| 构建方式 | `build_wu.py` 直接调 Lean 4.33.0-rc1，不经 Lake 调度器 | `STATUS.json.lean` |
| 源码身份 | 3764/3764 LF SHA-256 = manifest；30,215,769 B / 621,451 物理行 | `closure_audit.json` |
| 词法禁忌 | `sorry`/`admit`/自定义 `axiom`/`native_decide`/`unsafe`/`skipKernelTC` 0 命中 | 同上 |
| 构建产物 | `missing_build_artifact = 0`，`build_complete = true` | 同上（本轮起参与 `status`） |
| 端点探针 | `probe_rc = 0`；6 条 `#print axioms` 全部恰好 `{propext, Classical.choice, Quot.sound}` | `logs/final_probe.log`、`FINAL_STATUS.json.axioms` |
| `leanchecker` | `WR2ClassicalCertificate` rc 0（37.5 s；补充 `--verbose` 重放 rc 0） | `FINAL_STATUS.json.checker_rc`、`logs/final_leanchecker_verbose.log` |
| 端点 `.olean` | SHA-256 `6e8702bdc2b6f0d2cf5856d99d6c8a275744d9ef2f72f91bac7f9608e7d1877e`，20,192 B | `FINAL_STATUS.json` |
| 终判 | `status: PASS`；`AUTO_VERIFY_DONE.txt` = `result=PASS` | 两个判据文件 |

端点自身编译日志 `logs/WR2ClassicalCertificate.log` 也打印了同样三行：
`one8938`、`one894`、`classical_lower` 均只依赖标准三公理。

## 3. 现在可以写的一句话（推荐措辞）

> 在本工作区，`WuPaper.ClassicalSlots.one8938` 的 3764 个导入闭包模块已由本地独立重编完成
> （Lean 4.33.0-rc1，0 失败）；端点字面类型与 `Goldbach.OnePlusOne8938Shape` 的探针均通过，
> 6 条 `#print axioms` 恰好为标准三公理，端点模块的 `leanchecker` 重放 rc 0。

如果要更短：

> Wu 1.8938 的端点闭包已在本地独立重编并通过标准三公理检查（不是 1+1 的证明）。

## 4. 仍然**不能**写（N4 的更新版）

1. **不能写「Wu 1.8938 已内核复核」而不带范围。** 内核重放只覆盖
   `WR2ClassicalCertificate` **一个模块**的声明；`leanchecker` 不重放 3764 个导入模块，
   也不是第二个独立内核（Lean 源码自述：not an external verifier, simply a tool to detect
   environment hacking）。准确说法见 §3。
2. **不能写「验证了论文」。** 内核检查的是 `src/` 里的 Lean 源码；论文正文
   「为什么这些槽位成立」的数学论证没有被检查；形式陈述与论文语义的逐行一致性没有机器证明。
3. **不能写「4151 个模块全部构建」。** 本地只构建了端点导入闭包 3764；`source-manifest.json`
   的 4151 是全研究范围，二者不能混写。
4. **不能写「12 项任务已完成」。** `research/wu2008/mathematical-status.json` 的 12 项仍全部
   `global_complete: false`；本地构建不改变那本账。
5. **不能写「clean-room 重编」。** `.ok` 跨会话复用，最后一段是在已有 3147 个产物上续编 617 个；
   每个模块都被本管线编译过一次，但不是「清空 `lib` 一次跑完」。
6. **不能引用旧日志冒充新结果。** 以 `FINAL_STATUS.json` 的 `status` 与 `started/finished_utc` 为准；
   2026-11-16 23:54 的 `closure_audit.json` 曾在缺 690 个产物时写 `PASS`，本轮已把
   `missing_build_artifact` 纳入 `status`（只收紧，不放松）。

## 5. 与封存包的关系

- `priority/` 的 68 个文件**未改**；本文件与 `postseal/README.md` 都不在 manifest 里。
- 若作者决定重封存：把本文件、`frontier/wu_verify/FINAL_STATUS.json`、`closure_audit.json`、
  `AUTO_VERIFY_DONE.txt`、`logs/final_probe.log`、`logs/final_leanchecker_verbose.log` 纳入
  `files.txt`，重跑 `tools/build-metadata.py` 与 `tools/seal.ps1`；**不要**把 `release/*.tar.gz`
  纳入（会与 `MANIFEST.sha256` 形成循环）。
- 若不重封存：本文件作为 postseal 补充证据保留，对外引用时同时给出封存时点与本次构建时点，
  不要把 2026-11-17 的结论回写成 2026-11-16 封存包的内容。

## 6. 复现

```bat
cd goldbach\frontier\wu_verify
type FINAL_STATUS.json
type AUTO_VERIFY_DONE.txt
type closure_audit.json
py -3 verify_closure.py --root WR2ClassicalCertificate
py -3 final_check.py
```

`.ok` 会跳过已完成模块；`FINAL_STATUS.json` 会被覆盖。重建全量请见
`WU18938_INDEPENDENT_BUILD_2026-11-16.md` §8。
