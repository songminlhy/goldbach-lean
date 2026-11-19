# 声明清单（Claims / Non-claims）

每条声明绑定到可复核的证据。证据等级：

- **A｜内核检查**：Lean 4 编译/重放通过，公理集 ⊆ `{propext, Classical.choice, Quot.sound}`；
- **B｜文本比对**：逐字引用，行号或 DOI 元数据可查；
- **C｜有限数值**：只覆盖所列范围，不构成全称命题；
- **D｜判断**：作者意见，不作为事实引用。

## 一、可声明

### C1｜LG 成立　【A + B】

> 每个偶数 \(N>2\) 都是两个正整数之和，且两个加数的刘维尔值均为 \(-1\)。

- 论文：第 3–5 节给出自足的初等证明，不使用 Mangerel 的相关和上界，也不使用 GRH。
- Lean：`LiouvilleGoldbach.liouville_goldbach` 在 Lean 4.33.0-rc1 下通过类型检查；`#print axioms` 只列 `propext`、`Classical.choice`、`Quot.sound`。
- 构建：上游 9 个数学模块在本地源码级重建，`lake build LiouvilleGoldbach` 完成 2851 个任务（`liouville_paper/verification/lean_general_build_v433.log`）。

### C2｜GC ⇔ LG\(_{\Omega\le2}\)　【A】

> 二元哥德巴赫猜想等价于“每个偶数都存在一个 LG 表示，且该表示的两个加数均满足 \(\Omega\le2\)”。

- Lean：`GapCertificate.lean` 中 `LiouvilleGoldbach.binary_goldbach_iff_liouville_omega_two`；公理集同 C1。
- 反例说明：`20 = 8 + 12`，两个加数都是合数，说明 LG 本身不提供 \(\Omega\) 界。

### C3｜\(p=7\) 的书写边界　【B + A】

> 交换平方一步取 \(p/6<n<p/4\)；\(p=7\) 时该区间为空。补上 \(14=4+10\) 与 \(p\ge11\) 的非空性后，纸面证明闭合。

- 论文：第 3.4 节；Lean 的 `by_cases` 与中心代表分类覆盖 \(p=7\)。
- 这是**书写边界**，不是定理的反例。

### C4｜手稿 B 的主线正确　【B】

> 一般稿的主线（反射不等式 → 奇延拓 → 交换平方 → 短代表元 → 小素数平方 → 两个素因子下降）逐行检查未发现不可修复的数学缺口；除 \(p=7\) 外不需要新论证。

- 其 Lean 主定理 `liouville_goldbach` 没有 `MangerelNonextremality` 之类的额外解析假设。
- “未发现缺口”是文本审计结论，不是同行评审结论。

### C5｜手稿 A 的 Mangerel 阈值是版本问题　【B】

> 手稿 A 引用 IMRN 出版版（DOI `10.1093/imrn/rnae149`），该出版版摘要写 **for all \(N\ge11\)**；arXiv v2（2404.12117v2）摘要写“for all sufficiently large integers \(N\)”，其证明依赖 Siegel 定理，\(N_0\) 无效。A 的 \(m\ge11\) 与它所引出版版一致。

- 证据：A 的 `paper/liouville-goldbach-multiples-of-four.md` 第 13–16 行与参考文献 [2]；Crossref 记录 `10.1093/imrn/rnae149` 的摘要（2026-11-17 核对）；arXiv API 的 v2 摘要。
- **本包撤回**早期稿“A 把 \(\exists N_0\) 误写成 \(\forall m\ge11\)”的判断；该判断混淆了 A 所引的出版版与 arXiv v2。
- 限制：出版版全文本次未取得（OUP 有访问挑战），只核对到摘要；正文 Theorem 1.2 的逐字陈述仍应以出版版为准。

### C6｜有限数值检查　【C】

> 到 \(5\times10^6\)：2,499,999 个偶数、1,250,000 个 \(4\) 的倍数、667 个 \(p\le5000\) 的正正对，0 失败；最小见证的最大值为 37（\(N=125872\)）。

- 脚本：`paper_boundary/verification/check_boundary.py`；结果：`verification_results.json`。
- 这是有限证据，不是全称证明。

### C7｜封存与时间戳　【A2】

> `MANIFEST.sha256` 绑定 `files.txt` 列出的每个文件；`MANIFEST.tsr` 是 FreeTSA 对清单的 RFC 3161 时间戳，离线验签通过。

- 时间戳只证明清单字节在 `token genTime` 存在，不证明作者身份、正确性或新颖性。

### C8｜\(p=7\) 的内核证书　【A】

> `positive_prime_pairs_seven`：\(14=4+10\)，且 \(\lambda(4)=\lambda(10)=+1\)。

- 这把论文 §3.4 的书面补丁做成 Lean 证书；公理集仍为三条标准公理。

### C9｜\(\Omega\) 层级　【A】

> `binary_goldbach_implies_omega_le`：对任意 \(k\ge2\)，\(\mathrm{GC}\Rightarrow\mathrm{LG}_{\Omega\le k}\)；现有的 \(k=2\) 等价式是它的特例。

- 这把 \(\Omega\) 证书从单点推广为一个小层级；不声称 \(\mathrm{LG}_{\Omega\le k}\) 与 GC 形式独立。

### C10｜\(p\ge11\) 的区间非空性　【A】

> `exists_nat_between_sixth_and_fourth`：对每个素数 \(p\ge11\)，取 \(n=p/4\) 即满足 \(p<6n\) 与 \(4n<p\)，故交换平方一步所需的区间 \((p/6,p/4)\) 非空。

- 位置：`frontier/goldbach-lean/IntervalLemma.lean`（v0.3.1 新增，随 v0.3.1 的 104 文件清单封存；v0.3.0 的 103 文件清单与 `lg-v0.3.0` 标签不含它）。
- 运行 `lake env lean IntervalLemma.lean` 返回 0，公理集仍为三条标准公理。
- 它与 C8 合起来覆盖该步的全部小素数情形：\(p=7\) 单独验证，\(p\ge11\) 由内核保证区间非空。这是**算术事实**的内核化，不是定理的新证明。

## 二、不可声明

| 编号 | 禁止的说法 | 事实 |
|---|---|---|
| **N1** | “我们证明了哥德巴赫猜想” | 没有证明 GC；论文只证明 LG，且机器检查 \(\mathrm{GC}\iff\mathrm{LG}_{\Omega\le2}\)。 |
| **N2** | “世界首个 / 首次” | 未做穷尽检索；LG 路线与 Lean 工程来自 2026 年 9 月上游手稿。 |
| **N3** | “本文已通过同行评审” | 预印本 v0.3.2（本地草稿），未经同行评审。 |
| **N4** | “LG 的全文散文已被 Lean 验证” | Lean 覆盖形式陈述；论文散文是独立重述，逐行审计是文本结论。 |
| **N5** | “goldbach-lean 是我们的工作” | 仓库是 `subfish-zhou/goldbach-lean` 的派生副本；Liouville 模块来自上游 `CaptainSude`，本包只做移植、审计与复核。 |
| **N6** | “我们证明了手稿 A 错了” | 该指控已撤回；A 引用出版版，阈值与出版版摘要一致。只有改引 arXiv v2 时才会出现 \([11,N_0)\) 的空档。 |
| **N7** | “出版版 Mangerel 的证明已逐行核对” | 只核对到出版版摘要；正文未取得。 |
| **N8** | “数值检查到 \(5\times10^6\) 证明了全称命题” | 有限证据，不是全称证明。 |
| **N9** | “这是首次独立 Lean 复核” | `sunnyspot114514/Liouville-Goldbach-audit`（2026-09-17）已做独立全量 replay（2907 任务、PASS）；本文的增量是 \(p=7\)/\(\Omega\) 证书与更正记录。 |
| **N10** | “我们的结果比 Meng 2026-09-25 更强 / 更早” | L. Meng 的 MathOverflow 答案（answer 515534，2026-09-25）已给出更强的无条件结论：对每个 \(N\notin\{2,3,4,5,6,9,10\}\)，四种符号对都出现在分解 \(N=a+b\) 中，并注明偶数情形的证明与 Lean 形式化来自上游匿名作者。本文只处理 LG 及其与 GC 的逻辑边界，不涉及该更强结果，也不主张优先权。 |

## 三、一句话版本

> 我们给出 LG 的一个自足初等证明，补上 \(p=7\) 的书写边界（并把 \(p\ge11\) 的区间非空性做成内核定理），在 Lean 4.33 下重建上游形式化（2851 任务；主定理只用三条标准公理），并机器检查 \(\mathrm{GC}\iff\mathrm{LG}_{\Omega\le2}\)。**哥德巴赫猜想仍开放；我们没有证明它，也不主张优先权。** 对手稿 A 的“量词偷换”指控已按出版版摘要撤回；2026-09-25 已另有一份更强的无条件结果（Meng，MathOverflow answer 515534），本文不涉及它。
