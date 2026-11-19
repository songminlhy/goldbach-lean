# Liouville 奇偶性证据包 v0.3.2

**状态：预印本 v0.3.2，未经同行评审。本文证明 LG，不证明 GC。**

> v0.2.0 是首个公开版本，撤回了 v1 对手稿 A 的审计；v0.3.0 增加 prior-art 引用、\(p=7\) 与 \(\Omega\) 层级的 Lean 证书，以及“间接价值”小节；v0.3.1 把 \(p\ge11\) 的区间非空性做成独立 Lean 定理 `exists_nat_between_sixth_and_fourth`（`IntervalLemma.lean`），封存清单 103$\to$104 文件。v0.3.2（本地草稿，未发布）是文本更正与先验补全：条件桥量词改为“存在一个 LG 表示，其两个加数均满足 \(\Omega\le2\)”，摘要与结论补 Mangerel 版本限定，§1.2 增引 2026-09-25 MathOverflow 的更强先验结果，并新增 AI 使用与上游归属说明；无新增数学主张，清单仍为 104 文件。v1 从未封存或发布。

- DOI：v0.3.1 已发布，`10.5281/zenodo.24309847`；当前工作副本是 v0.3.2 本地草稿，**尚未分配新 DOI**，发布前不要按 v0.3.2 引用
- 论文：`paper_boundary/paper.pdf`（30 页，A4，中文，含英文摘要）
- 证据清单：`liouville_priority/MANIFEST.sha256`（104 文件）
- 时间戳：`liouville_priority/MANIFEST.tsr`（FreeTSA，RFC 3161）
- 版本：`0.3.2`（本地草稿，未发布），日期：`2026-11-18`

## 一句话结论

本文给出刘维尔--哥德巴赫定理（LG）的一个自足初等证明：

> 每个偶数 \(N>2\) 都是两个正整数之和，且两个加数的刘维尔值均为 \(-1\)。

同时机器检查

\[
  \mathrm{GC}\iff \mathrm{LG}_{\Omega\le2},
\]

其中 \(\mathrm{LG}_{\Omega\le2}\) 额外要求两个加数的素因子个数（计重数）不超过 \(2\)。因此，LG 到二元哥德巴赫猜想（GC）的缺口恰是一个与 GC 等价的加强。**GC 仍开放，本文没有证明它。**

## 包内有什么

| 路径 | 内容 |
|---|---|
| `paper_boundary/` | 29 页论文 `paper.tex`/`paper.pdf`、README、数值核验脚本与结果、Lean 复核日志、证据哈希 |
| `liouville_paper/` | 26 页早期稿的验证日志与数值脚本（历史背景；其对手稿 A 的表述已被最终稿取代） |
| `liouville_audit/` | 2026-09-15“4 的倍数”手稿与 Lean 工程的源码快照（第三方，原许可保留） |
| `liouville_general_audit/` | 2026-09-16 一般稿与 Lean 工程的源码快照（第三方，原许可保留） |
| `frontier/goldbach-lean/` | 本次复核使用的 Lean 源码：`GapCertificate.lean`、`LiouvilleAudit.lean`、`IntervalLemma.lean`、`LiouvilleGoldbach/` 等 |
| `liouville_priority/background/` | 审计时间线、第三方来源与排除项的哈希、Mangerel 版本差异记录 |
| `liouville_priority/tools/` | `seal.ps1`（哈希 + RFC 3161）、`build-metadata.py`（署名唯一源） |

## 版本敏感的审计更正

对手稿 A 的审计在 v0.2.0 中已更正：

- A 引用的是 Mangerel 的 **IMRN 出版版**（2024, no. 16, 11865–11877，DOI `10.1093/imrn/rnae149`）；该出版版摘要写的是 **for all \(N\ge11\)**。
- **arXiv v2**（2404.12117v2）的摘要写的是“for all sufficiently large integers \(N\)”，其证明依赖 Siegel 定理，\(N_0\) 无效。
- 两者不能混用。A 的 \(m\ge11\) 与它所引出版版一致；本包**撤回**早期稿把 A 判为“量词偷换”的说法。
- 出版版全文本次未取得（OUP 站点有访问挑战）；论文只以 Crossref 所载摘要作为版本证据，正文 Theorem 1.2 的逐字陈述仍应以出版版为准。

## 复核（在 `goldbach/` 下）

```bash
# 1) 哈希全绿（清单路径相对 goldbach/）
sha256sum -c liouville_priority/MANIFEST.sha256

# 2) 时间戳
openssl ts -verify -data liouville_priority/MANIFEST.sha256 \
  -in liouville_priority/MANIFEST.tsr \
  -CAfile liouville_priority/tsa/cacert.pem -untrusted liouville_priority/tsa/tsa.crt
# 期望：Verification: OK

# 3) 数值检查（到 5e6）
cd paper_boundary/verification
py check_boundary.py
# 期望：passed true；0 failures

# 4) Lean 复核
cd ../../frontier/goldbach-lean
lake env lean GapCertificate.lean
lake env lean LiouvilleAudit.lean
lake env lean IntervalLemma.lean
# 期望：三条命令均返回 0

# 5) 论文
cd ../../paper_boundary
xelatex paper.tex && xelatex paper.tex
```

`MANIFEST.sha256` 的路径相对 `goldbach/`；归档解压后可直接按上面的命令复核。时间戳只证明清单字节在 `token genTime` 时存在，不证明作者身份、正确性或新颖性。

## 不主张

- 不证明二元哥德巴赫猜想；GC 仍开放。
- 不主张 LG 的优先权；LG 路线与 Lean 工程来自 2026 年 9 月上游手稿。
- 不主张“未发现缺口”等于同行评审通过。
- 不主张出版版 Mangerel 的证明已被本文逐行核对；本文只用其摘要作版本对照。
- 有限数值检查（到 \(5\times10^6\)）不是全称证明。

## 作者、许可、AI 声明

作者：宋敏、宋瑷成、宋奥菲、范钧睿、胡安、涂源。署名顺序与项目既有论文一致；贡献边界见 `AUTHORS.md`。

- 论文文字、审计与数据：CC BY 4.0；
- Lean 源码：Apache-2.0（与上游一致），上游文件保留原声明；
- 上游快照：按其原许可使用，不重许可。

本包的审计、起草、打包与复核由本地 DeepSeek Harness（DSH）实例执行；作者设定目标、提供环境并决定发布。数学结论的最终判据是 Lean 4 内核与所引出版定理，不是任何模型的自述。
