# 审计时间线（Liouville 奇偶性包 v0.3.1）

本文件记录本包从上游快照到封存的证据链。时间为本地时间（UTC+08:00），另注明 UTC 的封存时间。

## 一、上游对象

| 对象 | 日期 | 本地快照 | 许可 |
|---|---|---|---|
| 手稿 A《Liouville's Goldbach Problem for Multiples of Four》与 Lean 工程 | 2026-09-15 | `liouville_audit/Liouville-Goldbach-Multiples-of-Four-main/` | 按仓库内 `LICENSE`/`LICENSES.md` |
| 手稿 B《A Goldbach theorem for the Liouville function》与 Lean 工程 | 2026-09-16 | `liouville_general_audit/Liouville-Goldbach-main/` | 按仓库内 `LICENSE` |
| Mangerel, IMRN 2024 | 2024 | 仅哈希与引用，不随包分发 | CC BY 4.0（出版版）；包内不复制 |

上游仓库 URL：

- `https://github.com/CaptainSude/Liouville-Goldbach-Multiples-of-Four`
- `https://github.com/CaptainSude/Liouville-Goldbach`

## 二、2026-11-17：审计与写作

| 时间 | 事件 | 证据 |
|---|---|---|
| 12:52–13:05 | 抓取 A/B 仓库 zip、Mangerel IMRN PDF、arXiv 2024b 与 arXiv 源码 | `background/PROVENANCE.json` 中的哈希 |
| 13:03 | 26 页稿的数值检查 `verify_liouville.py` | `liouville_paper/verification/verification_results.json` |
| 13:07 | 直接 `lean LiouvilleGoldbach/Main.lean` 失败：`Commuting.olean` 尚未生成 | `liouville_paper/verification/lean_general_main_v433.log` |
| 13:10 | `lake build LiouvilleGoldbach` 成功，2851 任务（Lean 4.33.0-rc1） | `liouville_paper/verification/lean_general_build_v433.log` |
| 14:20 | 前端/审计模块复核 | `liouville_paper/verification/audit_frontier_v433.log` |
| 15:04 | 26 页稿 `liouville_paper/paper.pdf` | 该目录 |
| 15:23 | `check_boundary.py`：到 \(5\times10^6\)，0 失败 | `paper_boundary/verification/verification_results.json` |
| 15:25 | `GapCertificate.lean`、`LiouvilleAudit.lean` 重跑，`GAP_RC=0`、`LG_RC=0` | `paper_boundary/verification/lean_recheck.log` |
| 15:36 | 27 页稿 `paper_boundary/paper.pdf` | 该目录 |
| 15:52–16:12 | 按六人署名对齐 PDF 元数据与作者行；修订对手稿 A 的审计（见下）；重编译 | `paper_boundary/paper.tex`、`paper.pdf` |
| 16:12–16:50 | 按 CLI 复核完成 v2：撤回 A 审计；修正 §1.5 路线图、§6.2 五条缺口证书、三处未引用文献、\(500\times500\) 乘法抽样与 §7.5 措辞；重编译 27 页 | `paper_boundary/paper.tex`、`verification/` |
| 17:00–17:40 | 完成 v3：引用 `sunnyspot114514` 的独立 replay；新增 `positive_prime_pairs_seven` 与 `binary_goldbach_implies_omega_le`；增加“间接价值”小节；重编译 28 页 | `paper_boundary/paper.tex`、`GapCertificate.lean`、`docs/LIOUVILLE.md` |
| 20:00–20:30 | 新增 `IntervalLemma.lean`：`exists_nat_between_sixth_and_fourth`（素数 \(p\ge11\) 时 \(n=p/4\) 落在 \((p/6,p/4)\) 内），`lake env lean IntervalLemma.lean` 返回 0，公理集为三条标准公理 | `frontier/goldbach-lean/IntervalLemma.lean` |
| 20:30–21:00 | 完成 v3.1：把 \(p\ge11\) 区间非空性写入 §1.2 贡献、§3.4 Remark、§5.2 复核段、附录 A 定理类型、附录 B 输出与附录 C 清单；重编译 29 页 | `paper_boundary/paper.tex`、`paper.pdf` |
| 2026-11-18 08:36–08:39 | v3.2 P0 文本更正：条件桥量词改为“存在一个 LG 表示，其两个加数均满足 \(\Omega\le2\)”；摘要与结论补 Mangerel 版本限定（只核对出版版摘要）；重编译 29 页；本地重封印 104 文件（manifest `7c11ab84…`） | `paper_boundary/paper.tex`、`MANIFEST.sha256` |
| 2026-11-18（上午） | 按审查摘要重修 v0.3.2 草稿：§1.2 增引 2026-09-25 MathOverflow 的更强先验结果（L. Meng，answer 515534，经 API 核实）；新增“AI 使用与上游归属”说明（两份上游快照内未见 AI 工具声明，不作推断）；README/CLAIM 口径对齐（DOI 已发布 vs 草稿无 DOI、页数、N10）；重编译 30 页；本地重封印 | `paper_boundary/paper.tex`、`liouville_priority/README.md`、`CLAIM.md`、`MANIFEST.sha256` |

## 三、对手稿 A 审计的更正（v0.2.0）

早期 26 页稿与 27 页稿的第一版认为：手稿 A 把 Mangerel 定理的“存在无效的 \(N_0\)”误写成“对所有 \(m\ge11\)”。2026-11-17 封装前核对发现：

1. 手稿 A 的 `paper/liouville-goldbach-multiples-of-four.md` 第 13–16 行写的是 \(m\ge11\)，参考文献 [2] 明确指向 **IMRN 出版版**（2024, no. 16, 11865–11877, DOI `10.1093/imrn/rnae149`）。
2. Crossref 所载该出版版的摘要写：**for all \(N\ge11\)**。
3. arXiv v2（`2404.12117v2`）的摘要写：**for all sufficiently large integers \(N\)**；正文定理为 \(\exists N_0\)，其 Remark 1 说明 \(N_0\) 由 Siegel 定理给出、无效。

因此，A 的 \(m\ge11\) 与它所引出版版一致；早期稿的“量词偷换”判断把 A 的引用对象换成了 arXiv v2，结论不成立。27 页稿已在摘要、引言、第 6 节、对比表、结论与检查表中改写为“版本差异”，并明确撤回该指控。详细证据见 `background/MANGEREL-NOTES.md`。

限制：出版版全文本次未取得（OUP 站点有访问挑战），只核对到 Crossref 摘要；正文 Theorem 1.2 的逐字陈述仍应以出版版为准。

## 四、2026-11-17：封存与发布

| 步骤 | 结果 |
|---|---|
| v1 状态 | 从未封存或发布；旧标签 `lg-v0.1.0` 已删除 |
| v0.2.0 | 已发布，DOI `10.5281/zenodo.24302032`；GitHub Release 转为 draft |
| v0.3.0 Zenodo 草稿 | id `24306341`，预留 DOI `10.5281/zenodo.24306341` |
| 封印 | 见 `TIMESTAMP.md`（FreeTSA，RFC 3161） |
| 归档 | `postseal/release/lg-v0.3.0-draft.tar.gz`（自足全包）、`lg-v0.3.0-circulation-20261117.zip`（审阅本）、`lg-v0.3.0-history-20261117.zip`（背景快照） |
| GitHub | tag `lg-v0.3.0` + Release（资产：全包与 `.sha256`） |
| Zenodo | 发布 v0.3.0 草稿，DOI 生效 |
| v0.3.1 Zenodo 新版本 | 由 v0.3.0 记录 `24306341` 派生（同一 concept `24302031`）；草稿 id `24309847`，预留 DOI `10.5281/zenodo.24309847` |
| v0.3.1 封印 | 104 文件（新增 `frontier/goldbach-lean/IntervalLemma.lean`），见 `TIMESTAMP.md` |
| v0.3.1 归档 | `postseal/release/lg-v0.3.1-draft.tar.gz`、`lg-v0.3.1-circulation-20261117.zip`、`lg-v0.3.1-history-20261117.zip` |
| v0.3.2（本地草稿） | **未发布**：无新 DOI、无新标签、无归档；封存清单仍 104 文件，本地 manifest 与 TSA 令牌按 11-18 的字节重建 |

> 发布后的 Release id、资产 id、Zenodo 记录 URL 与时间戳不在本清单内（它们发生在封印之后）；以 GitHub Release 页与 Zenodo 记录页为准。

## 五、未随包分发的对象

| 对象 | 原因 | 哈希 |
|---|---|---|
| 原始 CLI 审计转录 `C:\Users\宋敏\Downloads\LG_Windows PowerShell.txt`（740,020 B） | 含模型内部推理与本地路径，不作为公开学术产物分发 | `bc04c08f15b85dd1f6f55d05f996200b345e660686ae278376b00b734b438f25` |
| v2 复核转录 `C:\Users\宋敏\Downloads\(新)LG_Windows PowerShell.txt`（688,757 B） | 同上；它是 v2 撤回 A 审计的直接依据 | `a69e33344a99a4521a5232e4c4e7bdfa07a72dfe4cc2b333a72873f47b702163` |
| Mangerel IMRN 2024 PDF / 文本 / arXiv 源码 | 第三方版权；只保留引用与哈希 | 见 `PROVENANCE.json` |
| A/B 仓库 zip | 与已解压快照重复；保留哈希 | 见 `PROVENANCE.json` |

## 六、结论边界

- “未发现数学缺口”是文本审计结论，不是同行评审结论。
- 形式化结论只针对所列 Lean 陈述；论文散文是独立重述。
- 数值检查到 \(5\times10^6\) 是有限证据，不是全称证明。
- 本包不证明 GC，也不主张 LG 的优先权。
