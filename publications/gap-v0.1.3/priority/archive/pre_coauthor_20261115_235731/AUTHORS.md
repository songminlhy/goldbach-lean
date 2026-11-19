# 署名、贡献边界与许可

## 一、作者

| 字段 | 值（**待填**） |
|---|---|
| 姓名 | `<FILL: 真实姓名 / 拼音>` |
| ORCID | `<FILL: 0000-0000-0000-0000>` |
| 邮箱 | `<FILL: 公开可联系的邮箱>` |
| GitHub | `<FILL: 用户名>` |
| 单位 | `<FILL: 可选>` |

> 全部署名信息只写在 `IDENTITY.json` 一个文件里；`CITATION.cff` 与 `zenodo.json`
> 由 `tools/build-metadata.py` 从它生成，**不要手改**这两个文件。
> 填完后重跑 `tools/seal.ps1` 重新封存（旧时间戳仍然有效，但它签的是占位版本）。

## 二、贡献边界（谁做了什么）

| 范围 | 归属 | 说明 |
|---|---|---|
| `MathlibNt/**`、`Goldbach/Theorem.lean`、`Goldbach/OnePlusOneNine.lean`、`research/wu2008/**`、`docs/` 下除 `GAP.md` 外的文档 | **上游** `subfish-zhou/goldbach-lean`（Apache-2.0）及其再上游 | 本工作**不主张**任何著作权；原有版权与许可声明保留 |
| `Goldbach/Gap.lean`、`Goldbach/GapChecks.lean`、`Goldbach/GapLiveChecks.lean`、`docs/GAP.md` | 本工作（新增，Apache-2.0） | 8 条定理 + 活端点定义相等检查 |
| `AUDIT_2026-11-15.md`、`PROGRESS_2026-11-15.md`、`audit/audit_goldbach.py`、`audit/audit_results.json` | 本工作（新增，Apache-2.0） | 数值审计与文本审计 |
| `MathlibNt/SieveTheory/LiLiuGoldbachG12FlexibleWF.lean`、`scripts/check.py` 的本地修改 | 本工作（对上游文件的补丁，Apache-2.0） | 一处 `sum_congr` 证明改写；一处 Windows 路径分隔符修复 |
| `priority/**` | 本工作（新增，CC BY 4.0 或 Apache-2.0，发布前定） | 存证包与发布稿 |

## 三、AI 辅助声明（建议保留）

本工作区的多轮推导、审计与文字起草由本地 DeepSeek Harness（DSH）实例执行，由作者设定目标、
提供环境并决定发布。**所有数学结论的最终判据是 Lean 4 内核**，不是任何模型的自述：

- 8 条定理经 `leanchecker` 重放，公理集 ⊆ `{propext, Classical.choice, Quot.sound}`；
- 证据日志在 `goldbach/logs/`，可按 `VERIFY.md` 复现。

发布时建议保留本段：它既诚实，也把"可信"锚在可复核的内核上，而不是锚在"AI 说的"上。

## 四、许可

- 新增 Lean 源码与脚本：**Apache-2.0**（与上游一致，避免许可拼盘）；
- `priority/` 下的说明文字与发布稿：建议 **CC BY 4.0**（便于传播与引用）；
- 上游文件：按其原有许可（Apache-2.0）与版权声明使用，不重许可。

## 五、不主张

- 不主张对哥德巴赫猜想本身、对 Chen / Li–Liu / Wu 的数学证明的任何发现权；
- 不主张对上游仓库整体或其历史贡献的著作权；
- 不主张"首个"——见 `PRIOR_ART.md`。
