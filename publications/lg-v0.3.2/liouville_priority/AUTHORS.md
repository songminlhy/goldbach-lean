# 署名、贡献边界与许可

## 一、作者

署名唯一源为 `IDENTITY.json`；`CITATION.cff` 与 `zenodo.json` 由 `tools/build-metadata.py` 从它生成，不要手改生成文件。当前顺序：

| # | 姓名 | family_name | given_name | 项目分工（沿用既有记录） |
|---:|---|---|---|---|
| 1 | 宋敏 | 宋 | 敏 | 文本审计、统稿与发布 |
| 2 | 宋瑷成 | 宋 | 瑷成 | 研究设计 |
| 3 | 宋奥菲 | 宋 | 奥菲 | 论文写作 |
| 4 | 范钧睿 | 范 | 钧睿 | 形式化复核 |
| 5 | 胡安 | 胡 | 安 | 构建复核 |
| 6 | 涂源 | 涂 | 源 | 构建复核 |

> 共同作者目前只提供姓名；ORCID、单位、邮箱未提供，因此不写入元数据。

> “形式化复核”指复核并重跑上游 Lean 工程，**不**主张上游 `LiouvilleGoldbach/` 源码的作者权。该工程来自 2026 年 9 月上游手稿 B。

## 二、贡献边界（谁做了什么）

| 范围 | 归属 | 说明 |
|---|---|---|
| `liouville_audit/Liouville-Goldbach-Multiples-of-Four-main/**` | 上游 `CaptainSude`（原许可保留） | 手稿 A 及其 Lean 工程；本包只做快照、审计与引用 |
| `liouville_general_audit/Liouville-Goldbach-main/**` | 上游 `CaptainSude`（原许可保留） | 手稿 B 及其 Lean 工程；本包只做快照、审计、源码级重建与复核 |
| `frontier/goldbach-lean/LiouvilleGoldbach/**`、`LiouvilleGoldbach.lean` | 上游手稿 B 的 Lean 工程（Apache-2.0） | 本包移植到 `songminlhy/goldbach-lean` 的工作副本并重建；不重许可 |
| `frontier/goldbach-lean/GapCertificate.lean`、`LiouvilleAudit.lean`、`run_lg.ps1` | 本包（Apache-2.0） | 缺口证书、审计模块与重跑脚本 |
| `frontier/goldbach-lean/lakefile.toml` 中的 `LiouvilleGoldbach` 库条目 | 本包（对上游文件的一处新增） | 其余内容为上游 |
| `paper_boundary/**` | 本包（CC BY 4.0） | 论文、数值脚本、复核日志、证据哈希 |
| `liouville_priority/**` | 本包（CC BY 4.0；Lean 源码 Apache-2.0） | 封存包、审计背景与发布稿 |

## 三、AI 辅助声明

本工作区的多轮推导、审计、写作、打包与复核由本地 DeepSeek Harness（DSH）实例执行；作者设定目标、提供环境并决定发布。**所有数学结论的最终判据是 Lean 4 内核与所引出版定理**，不是任何模型的自述：

- 主定理 `LiouvilleGoldbach.liouville_goldbach` 经类型检查，公理集 ⊆ `{propext, Classical.choice, Quot.sound}`；
- 两条审计模块本次重跑均返回 0；
- 数值检查到 \(5\times10^6\)，0 失败；
- 证据日志与哈希随包提供，按 `VERIFY.md` 复核。

## 四、许可

- 论文、审计文字与数据：**CC BY 4.0**；
- 新增 Lean 源码与脚本：**Apache-2.0**（与上游一致）；
- 上游文件：按其原有许可（Apache-2.0 或仓库内声明的许可）与版权声明使用，不重许可。

## 五、不主张

- 不主张对二元哥德巴赫猜想的任何证明或发现权；
- 不主张对刘维尔--哥德巴赫定理的优先权；证明路线与 Lean 工程来自 2026 年 9 月上游手稿；
- 不主张对上游仓库整体或其历史贡献的著作权；
- 不主张“首个”；未做穷尽检索；
- 不主张早期稿对手稿 A 的“量词偷换”结论；该结论已按出版版摘要撤回（见 `CLAIM.md` C5）。
