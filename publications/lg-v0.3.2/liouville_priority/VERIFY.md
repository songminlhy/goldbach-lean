# 复核手册

所有路径相对 `goldbach/`。归档解压后，根目录就是 `goldbach/` 的内容。

## 0. 先验封存

```bash
sha256sum -c liouville_priority/MANIFEST.sha256
# 期望：每个列出文件 OK；0 FAILED
```

```bash
openssl ts -verify -data liouville_priority/MANIFEST.sha256 \
  -in liouville_priority/MANIFEST.tsr \
  -CAfile liouville_priority/tsa/cacert.pem -untrusted liouville_priority/tsa/tsa.crt
# 期望：Verification: OK
```

`TIMESTAMP.md` 记录封存时间、清单 SHA-256、令牌 SHA-256、`token genTime` 与文件数。时间戳只签 `MANIFEST.sha256`，不签归档本身；归档哈希在发布页与 `.sha256` 文件中单独给出。

## 1. 论文

```bash
cd paper_boundary
xelatex paper.tex
xelatex paper.tex
pdfinfo paper.pdf
```

期望：

- 29 页，A4；
- `Author: 宋敏, 宋瑷成, 宋奥菲, 范钧睿, 胡安, 涂源`；
- 无 `LaTeX Error`；`paper.log` 中无未定义引用。

论文源码哈希见 `verification/SHA256SUMS.json`。PDF 是编译产物；不同 TeX 发行版可能产生不同字节，正文内容应以 `paper.tex` 为准。

## 2. 数值检查（到 \(5\times10^6\)）

```bash
cd paper_boundary/verification
py check_boundary.py        # Linux 用 python3
```

期望（控制台与 `verification_results.json`）：

- `passed: true`；
- `all_even.checked = 2499999`，`failures = []`；
- `multiples_of_four.checked = 1250000`，`failures = []`；
- `positive_prime_pairs.primes_checked = 667`，`failures = []`；
- `max_least_witness = 37`，`argmax_N = 125872`。

注意：脚本会重写 `verification_results.json`，其中 `generated_utc` 与 `seconds` 每次不同；因此重跑后的文件哈希通常**不等于**封存哈希。复核时应比对字段与失败列表，而不是要求字节相同。封存版本的哈希在 `verification/SHA256SUMS.json` 中。

## 3. Lean 复核

需要 Lean 4.33.0-rc1 与 Mathlib 提交 `e4c91783ca8e6a7c693ae624ade32fd22d4e43c1`，以及已构建的 Mathlib 产物。归档包含源码与日志，但不包含 `.lake` 构建缓存；从零复核需要先获取 Mathlib 缓存并构建。

```bash
cd frontier/goldbach-lean
lake env lean GapCertificate.lean
lake env lean LiouvilleAudit.lean
lake env lean IntervalLemma.lean
```

期望：三条命令均返回 0；`#print axioms` 只列 `propext`、`Classical.choice`、`Quot.sound`。v0.3.0 新增的 `positive_prime_pairs_seven` 与 `binary_goldbach_implies_omega_le` 也返回 0，公理集相同；v0.3.1 新增的 `IntervalLemma.lean`（`exists_nat_between_sixth_and_fourth`）同样返回 0，输出 `IL_RC=0`。本次审计的原始输出：

- `paper_boundary/verification/lean_recheck.log`（两个审计模块；`GAP_RC=0`、`LG_RC=0`）；
- 论文附录 B 的 `IL_RC=0` 段（`IntervalLemma.lean` 的本次输出；v0.3.1 未把它追加到上面的日志，以免改动 v0.3.0 已封存的日志字节）；
- `liouville_paper/verification/lean_general_build_v433.log`（9 个上游数学模块的 2851 任务构建）。

`liouville_paper/verification/lean_general_main_v433.log` 记录的是**构建前**直接 `lean LiouvilleGoldbach/Main.lean` 的失败：当时 `Commuting.olean` 尚未生成。它不是最终构建的失败；最终构建见 `lean_general_build_v433.log`。本包保留该日志，以免把中间失败从证据链中删掉。

## 4. 论文数字与证据的对应

| 论文位置 | 数字 | 证据 |
|---|---|---|
| 摘要 / 第 5 节 | 2851 任务 | `lean_general_build_v433.log` |
| 第 5 节 | 2,499,999 个偶数；1,250,000 个 4 的倍数；667 个素数对 | `verification_results.json` |
| 第 5 节 | 最小见证最大 37，\(N=125872\) | 同上 |
| 附录 | `verification_results.json` SHA-256 `1be66bda…` | `SHA256SUMS.json` |
| 附录 | `check_boundary.py` / `lean_recheck.log` 哈希 | `SHA256SUMS.json` |

## 5. 版本敏感的 A 审计

复核这条更正需要三份材料：

1. 手稿 A 的 `paper/liouville-goldbach-multiples-of-four.md` 第 13–16 行与参考文献 [2]（本地快照 `liouville_audit/…`）；
2. IMRN 出版版 DOI `10.1093/imrn/rnae149` 的摘要：**for all \(N\ge11\)**（Crossref 记录，2026-11-17 核对）；
3. arXiv v2 `2404.12117v2` 的摘要：**for all sufficiently large integers \(N\)**，正文定理为 \(\exists N_0\)，其 Remark 1 说明 \(N_0\) 无效。

A 引用的是 2，不是 3。因此 A 的 \(m\ge11\) 与它所引版本一致；早期稿的“量词偷换”判断已撤回。出版版全文本次未取得，正文 Theorem 1.2 的逐字陈述仍应以出版版为准。

## 6. 已知限制

- Lean 复核是非 clean-room 的源码级重建：复用 Mathlib 与依赖包的 `.lake` 产物；上游 B 的构建记录为 2901 任务（Lean 4.34.0-rc2），本地 4.33 重建为 2851 任务。
- 本次审计只重跑 `GapCertificate.lean`、`LiouvilleAudit.lean` 与 `IntervalLemma.lean` 三个模块，没有重跑上游 9 模块的完整构建（完整构建日志随包提供）。
- 出版版 Mangerel 全文未取得；只用 Crossref 摘要作版本对照。
- 数值检查是有限证据，不是全称证明。
