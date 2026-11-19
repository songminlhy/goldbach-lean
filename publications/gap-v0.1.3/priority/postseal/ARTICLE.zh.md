# 1+2 不是 1+1：把哥德巴赫猜想的“差距”做成机器可查的定理

**副标题：兼论 arXiv:2611.09007v1 的定理 1.1 在其自身定义下已经蕴含 1+1——8 条 Lean 4 定理的内核复核记录**

> **发布前替换**：`{{REPO_URL}}`、`10.5281/zenodo.24270135`、`{{AUTHOR}}`、`{{DATE}}`。  
> 本文的完整证据在 `goldbach/priority/` 封存包中；行号、哈希与复核命令都可独立核对。

## 0. 先给结论

哥德巴赫猜想仍然开放。本文不证明它。

这次工作把两件经常被含糊带过的事，变成了 Lean 4 里可以被独立重放的定理：

1. **Chen 1+2、Li–Liu 1+1.9、Wu 1+1.8938 都是 1+1 的推论**，不是“差一点点的 1+1”。把第二个乘数取成 `1`（Chen 的情形取第二个加数为素数），三个端点立刻从 `BinaryGoldbach` 推出来。
2. **一篇 2026 年 11 月的预印本，按它自己给出的 big-O 定义，定理 1.1 已经蕴含 1+1。** 该文证明的第 180 行开头按字面读把 `G(2n)` 本身也列为可假设的对象（当前情形），又把“`G(2n-2) > 0`”列为推导的输入——在这个定义下，后者也已经由归纳假设蕴含。按字面读，这一步把结论当成了前提。

支撑这两条的是 **8 条 Lean 4 定理**。它们只依赖 `Goldbach.Statement` 与 Mathlib，不依赖上游 1800 多个模块的大筛法工程；`leanchecker` 重放通过，公理集不超过 `{propext, Classical.choice, Quot.sound}`。

**但请同时记住：**

- 没有证明哥德巴赫猜想；没有任何一条无条件定理以 `BinaryGoldbach` 为结论。
- 没有证明“端点推不出 1+1”；那需要元数学论证。三条见证只说明端点的表示谓词更宽。
- 不声称“首个”。检索范围与日期见 `PRIOR_ART.md`，它只能说明“没找到”。

## 1. 三个端点：它们比 1+1 弱，不是“差一点点”

先把 1+1 写清楚。本文说的 1+1 是二元哥德巴赫（大偶数情形）：

```lean
def BinaryGoldbach : Prop :=
  ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N → Even N →
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N = p + q
```

即：存在一个阈值，所有不小于它的偶数都是两个素数之和。

三个头条端点的形状是：

| 端点 | 形状 | 与 1+1 的差别 |
|---|---|---|
| Chen 1+2 | `N = p + q`，`q` 是素数，或是两个素数之积 | 第二个加数允许合数 |
| Li–Liu 1+1.9 | `N = p + r·q`，`r = 1` 或 `r` 是素数，`r¹⁰ ≤ q⁹` | 乘数允许素数 |
| Wu 1+1.8938 | `N = p + r·q`，`r = 1` 或 `r` 是素数，`r⁵⁰⁰⁰ ≤ q⁴⁴⁶⁹` | 乘数允许素数 |

注意方向：**1+1 ⇒ 端点**。把 `r` 取成 `1`，`N = p + q` 就是两个素数之和；Chen 的情形更直接，`q` 取素数即可。三条定理：

```lean
binaryGoldbach_implies_chen
binaryGoldbach_implies_onePlusOneNine
binaryGoldbach_implies_onePlusOne8938
```

它们说明：**端点比 1+1 弱**。这不是“1+2 离 1+1 只差一点”的修辞问题，而是逻辑方向问题。

一个自然的反问：既然 Chen 1+2 已经是定理，为什么不能反推 1+1？因为**反推**正是缺口。如果 `ChenTheorem → BinaryGoldbach` 成立，哥德巴赫猜想立刻解决。所以这条反推不可能靠现有材料顺手得到；我们也没有做。

## 2. 差距在哪：谓词多开了一扇门

“弱”不能只靠一句话。三条机器见证说明端点的表示谓词确实允许 1+1 不允许的**表示**；它们是表示层结论，不是数层结论：

- **Chen**：`4 = 2 · 2`。第二个加数 `q = 4` 是合数，但满足“素数或两个素数之积”。带 `q = 4` 的表示不是 1+1 表示；`4` 本身是 `2 + 2`。
- **Li–Liu**：`18 = 3 + 3 · 5`，`r = 3 ≠ 1`，且 `3¹⁰ ≤ 5⁹`。这不是 1+1 表示；`18 = 5 + 13 = 7 + 11`，所以 `18` 本身是两个素数之和。
- **Wu**：`13 = 7 + 2 · 3`，`r = 2 ≠ 1`，且 `2⁵⁰⁰⁰ ≤ 3⁴⁴⁶⁹`。这也不是 1+1 表示；`13 = 2 + 11`，所以 `13` 本身是两个素数之和。

三条 Lean 定理：

```lean
chen_second_summand_class_includes_composite
liu_multiplier_class_includes_nontrivial
wu_multiplier_class_includes_nontrivial
```

必须说清楚：**它们只说明表示谓词更宽，不是“端点推不出 1+1”的独立性证明，也没有给出 1+1 之外的数。** 要证后者需要元数学论证；本文没有做，也不假装做了。

## 3. 第二件事：那篇预印本的定理 1.1 已经蕴含 1+1

这一节是本文最有信息量的部分。

被讨论的预印本是 Khaled Qazaqzeh 与 Aymen Rawashdeh 的 *An Elementary Proof of the Binary Goldbach Conjecture*（[arXiv:2611.09007v1](https://arxiv.org/abs/2611.09007)，2026-11-06，math.NT，9 页）。以下行号都指 **arXiv v1 的 LaTeX 源文件**（`A_Simple_Proof_of_Goldbach_Conjecture.tex`），不是 PDF 页码。该源文件的 SHA-256 是：

```text
db1fa07154ae7430245d19ac377f6d22f02361608014498fe3449129c3765ffd
```

它与 arXiv v1 当前提供的源码逐字节一致（2026-11-15 核对）。引用原文时，任何人可以用这个哈希锁定版本。

### 3.1 定义 2.1 把 big-O 定义成了“比值趋于非零常数”

论文第 111 行（定义 2.1 的第一条）原文：

> “We say that $f$ is a big $\mathcal{O}$ of $g$, denoted by $\mathcal{O}(g)$, if $\lim\limits_{n\to \infty} \frac{f(n)}{g(n)} = c$ for some nonzero real number $c$.”

标准 big-O 只要求最终有上界 `|f| ≤ C·g`；这个定义要求**比值收敛到一个非零常数**。这不是“宽松的上界”，而是一个强得多的双向渐近条件。

### 3.2 在这个定义下，定理 1.1 直接推出 1+1

论文定理 1.1 说：有序 Goldbach 对的数量 `G(2n)` 是 `O(n / ln² n)`。按论文自己的定义，这就是

```text
lim_{n→∞} G(2n) · ln²(2n) / n = c ≠ 0.
```

（论文定理的陈述写的是 `ln² n`，而它第 182/184 行实际用的是 `ln²(2n)`；两者只差一个趋于 1 的因子 `(ln(2n)/ln n)²`，不改变非零极限。形式化采用证明中实际出现的 `ln²(2n)` 形式。）

推理只有四步：

1. `G(2n) ≥ 0`，所以比值最终 `≥ 0`，取极限得 `c ≥ 0`；
2. `c ≠ 0`，所以 `c > 0`；
3. 比值最终 `> 0`；又 `ln²(2n) > 0`、`n > 0`，所以 `G(2n) > 0` 最终成立；
4. `G(2n) > 0` 意味着存在素数 `p, q` 使 `2n = p + q`。于是每个充分大的偶数都是两个素数之和——这就是 1+1。

形式化里的 `goldbachCount` 把 `p = 2` 也纳入计数范围；对 `N ≥ 6`，`p = 2` 时 `N - 2` 是大于 2 的偶数，不可能是素数，因此它与论文的 `G` 在充分大时一致。这个边界项不影响“充分大”的结论；`docs/GAP.md` 里有说明。

我们把“该文的定理 1.1，按该文自己的 O 定义”形式化为 `PaperTheorem`，并证明了：

```lean
paperTheorem_implies_binaryGoldbach : PaperTheorem → BinaryGoldbach
```

这条定理是机器复核的（第 8 条，见下）。它说明：**该文的定理 1.1 不是比猜想弱的命题；在这个定义下，它已经蕴含猜想。**

### 3.3 循环在哪：第 180 行把结论当成了输入

如果只是“定理很强”，那还不是循环。循环在证明里。

论文第 180 行（证明的开头）原文（加粗是我们加的；`\ref` 交叉引用已还原为编号）：

> “We proceed by induction on n to verify the claim of the theorem. Thus we can assume that $G(2n-2)$ and $G(2n)$ are $\mathcal{O}\left(\frac{n}{\ln^{2} n}\right)$ functions as a consequence of the result of Lemma (note). As a consequence of Equation (1), the induction hypothesis on the antidiagonals $I_{2n-2}$, **the positivity of $G(2n-2)$** and the result of Lemma (note), we conclude …”

第一句按字面读，把 `G(2n-2)` **和 `G(2n)`** 都列为“可以假设”的对象。`G(2n)` 正是当前要证的那个 n；归纳假设只应给出 n-1 的情形（`G(2n-2)`）。如果作者的本意不是假设当前情形，就需要给出从 `G(2n-2)` 推出 `G(2n)` 的独立论证——论文没有给出。

同一句还把 `G(2n-2) > 0` 列为推导的输入之一。可是在论文自己的 O 定义下，“`G(2n-2)` 是 `O(n/ln² n)`” 已经蕴含 `G(2n-2) > 0`（充分大时）。所以这个“正性”并不是独立于定理的额外信息；真正的问题在于 `G(2n)` 被列入了假设。

同一段第 184 行还写 `α < 2`，并说它来自“`G(2n-2)` 是 `O(n/ln² n)`”。若 `G(2n-2) ~ c·n/ln² n`，则 `α = 2 - c`；`α < 2` 当且仅当 `c > 0`。又回到同一个正性。

所以准确的表述是：

- **机器复核的部分**：在该文的 O 定义下，定理 1.1 ⇒ 1+1（`paperTheorem_implies_binaryGoldbach`）。
- **文本对照的部分**：第 180 行开头按字面读把 `G(2n)` 本身列为“可以假设”的对象（当前情形），并把 `G(2n-2) > 0` 列为推导输入；在这个定义下，后者也已经是结论的一部分。因此该证明是循环的，不是“某个不等式算错了”。

这两部分证据强度不同，本文分开说，不混在一起。

### 3.4 如果作者认为我们读错了

欢迎指出。第 111 行的引文是逐字的，源文件哈希在上；`PaperTheorem` 对应的是该文的 O 定义与定理 1.1 陈述，第 180 行则是逐字引用的文本对照。如果作者认为定义 2.1 应取另一种读法，或者 v2 修改了定义，请给出具体行号；我们按 v2 重新核对，并注明“针对 v1”。

## 4. 机器到底复核了什么

8 条定理在 `Goldbach/Gap.lean`，逐条 `#check` 与 `#print axioms` 在 `Goldbach/GapChecks.lean`。核心清单：

| # | Lean 定理 | 内容 |
|---|---|---|
| 1 | `binaryGoldbach_implies_chen` | 1+1 ⇒ Chen 1+2 |
| 2 | `binaryGoldbach_implies_onePlusOneNine` | 1+1 ⇒ Li–Liu 1+1.9 |
| 3 | `binaryGoldbach_implies_onePlusOne8938` | 1+1 ⇒ Wu 1+1.8938 |
| 4 | `chen_second_summand_class_includes_composite` | Chen 谓词允许合数第二加数（`4 = 2·2`） |
| 5 | `liu_multiplier_class_includes_nontrivial` | Li–Liu 谓词允许 `r = 3 ≠ 1`（`18 = 3 + 3·5`） |
| 6 | `wu_multiplier_class_includes_nontrivial` | Wu 谓词允许 `r = 2 ≠ 1`（`13 = 7 + 2·3`） |
| 7 | `goldbachCount_pos_iff` | `0 < goldbachCount N ↔ N 是两个素数之和` |
| 8 | `paperTheorem_implies_binaryGoldbach` | 论文定理 1.1（按其 O 定义）⇒ 1+1 |

另有一条**定义相等检查**，不计入 8 条数学定理：

```lean
live_one_plus_one_nine_has_shape : OnePlusOneNineShape :=
  Goldbach.one_plus_one_nine
```

它说明 `OnePlusOneNineShape` 不是照着日志手抄的形状，而是与活端点定义相等。它放在单独的 `GapLiveChecks.lean`，因此 `Goldbach.Gap` 仍然只依赖 `Goldbach.Statement` 与 Mathlib。

**复核结果**（日志在 `goldbach/logs/`）：

- 8 条定理的 `#print axioms` 都落在 `{propext, Classical.choice, Quot.sound}` 内；
- 没有 `sorry`、`admit`、自定义 `axiom`、`native_decide`；
- `leanchecker.exe Goldbach.Gap` 重放通过，exit 0；
- 静态检查：1806 个源模块，`issues: []`。

**没有复核的**：Wu 1+1.8938 的端点形状是逐字转录的；`research/wu2008/` 是独立子工程，本次没有构建，因此 Wu 形状没有内核重跑。不要把它写成“已内核复核”。

## 5. 哪些话不能说

这一节看起来像自我限制，其实是这份工作的使用方法。以下句子不能出现在发布稿、推文或摘要里：

| 不要写 | 事实 | 可以怎么写 |
|---|---|---|
| “我们证明了哥德巴赫猜想” | 没有任何无条件定理以 `BinaryGoldbach` 为结论 | “我们证明了三个端点是 1+1 的推论；没有证明 1+1” |
| “世界首个 / 首次” | 未做穷尽检索 | “据我们所知（检索范围与日期见 `PRIOR_ART.md`），此前没有找到公开的形式化版本” |
| “Wu 1.8938 已内核复核” | Wu 子工程未构建 | “Wu 端点为逐字转录，未做内核重跑” |
| “goldbach-lean 是我们的工作” | 上游是 `subfish-zhou/goldbach-lean`（Apache-2.0） | “我们新增 4 个文件、修改 2 个文件；其余是上游的工作” |
| “论文每一步都错了” | 只对具体行给出判断 | “第 111 行的定义、第 180 行开头对 `G(2n)` 的‘可假设’表述与 `G(2n-2) > 0` 输入、第 222 行的 `R₁` 断言存在具体问题” |
| “我们证明了端点推不出 1+1” | 三条见证只说明谓词更宽 | “端点的表示谓词严格更宽；这不是独立性证明” |

**真正的硬货是 C2，不是 C1。** `1+1 ⇒ 1+2` 在数学上是一行的事；有信息量的是“按这篇具体预印本自己的 O 定义，它的定理 1.1 已经蕴含 1+1，而第 180 行的推导输入写的就是结论”。被质疑“这谁都知道”时，把重点移到 C2。

## 6. 这件事的意义

不是“又一篇哥德巴赫科普”。它的意义在三个层面：

1. **把常识变成可查对象**：1+2 / 1+1.9 / 1+1.8938 比 1+1 弱，这是常识；但常识容易被“接近证明”的叙事带走。机器可查的蕴含关系，让“端点 ⇒ 1+1”的越界声明立刻暴露。
2. **把具体文本的循环变成可复核的接口**：`PaperTheorem` 把该文的 O 定义、定理 1.1 与 1+1 接在一起；第 180 行的原文引用给出循环的位置。以后无论是作者发 v2，还是别人引用该文，都有一个明确的核对入口。
3. **把“可信”锚在内核，而不是作者**：`leanchecker` 不看作者是谁，也不看模型是谁。所有公理、所有依赖都在日志里。

## 7. 三条命令，自己复核

不需要相信本文。按 `VERIFY.md` 走三层：

**第一层：哈希**（在 `goldbach/` 下）

```bash
sha256sum -c priority/MANIFEST.sha256
```

预期：当前封存清单的 68 个文件全部 `OK`（如果之后重新封存、加入了新文件，以 `TIMESTAMP.md` 记录的数量为准）。

**第二层：时间戳**

```bash
openssl ts -verify -data priority/MANIFEST.sha256 \
  -in priority/MANIFEST.tsr \
  -CAfile priority/tsa/cacert.pem -untrusted priority/tsa/tsa.crt
```

预期：`Verification: OK`。证书链固定在 `tsa/`，可离线验证。

**第三层：Lean 内核**

```bat
cd goldbach\frontier
python kernel_verify.py --checks Goldbach\GapChecks.lean ^
    --target Goldbach.Gap --log ..\logs\audit_gap_check_rerun.log
```

预期：`RESULT: PASS`，`leanchecker` exit 0。

> 时间戳只证明“这些字节在某个时刻存在”，不证明作者是谁，也不证明首创。可引用的版本以 DOI 为准。

## 8. 结语：这不是明珠，是尺子

哥德巴赫猜想仍然开放。这次没有证明它，也没有假装证明它。

但如果“1+2 不是 1+1”和“这篇预印本的证明是循环的”这两件事，从此以后不再是口头判断，而是有定理名、有公理集、有内核日志、有哈希和时间戳的对象，那么至少我们手里多了一把尺子——**一把能把明珠和玻璃珠分开的尺子**。

欢迎指出错误。数学的判据是证明，证明的判据是内核。

---

## 附录：证据与版本

- **论文**：Khaled Qazaqzeh, Aymen Rawashdeh, *An Elementary Proof of the Binary Goldbach Conjecture*, arXiv:2611.09007v1, 2026-11-06, math.NT, 9 pages. License: CC BY 4.0.
- **论文源码哈希**：`db1fa07154ae7430245d19ac377f6d22f02361608014498fe3449129c3765ffd`（SHA-256，见 §3）。
- **Lean 工具链**：Lean 4.33.0-rc1 + Mathlib（仓库固定版本，见 `lean-toolchain` 与 `lake-manifest.json`）。
- **上游仓库**：`subfish-zhou/goldbach-lean`，`main` at `9d4c3a4`（2026-10-28），Apache-2.0。
- **本工作新增**：`Goldbach/Gap.lean`、`Goldbach/GapChecks.lean`、`Goldbach/GapLiveChecks.lean`、`docs/GAP.md`；修改 `MathlibNt/SieveTheory/LiLiuGoldbachG12FlexibleWF.lean`、`scripts/check.py`。
- **证据日志**：`goldbach/logs/audit_gap_check_rerun.log`、`audit_live_shape_check.log`、`audit_chen_check_rerun.log`、`audit_liliu_check_rerun.log`、`static_check_2026-11-15.log`；postseal 复跑见 `reverify_2026-11-15_postseal.log`（未纳入封存，属补充证据）。
- **封存**：`goldbach/priority/`；RFC 3161 时间戳封存于 2026-11-16 23:56:44 UTC（令牌时间 23:56:45 UTC）；manifest 为 68 files。
- **仓库**：{{REPO_URL}}　**DOI**：10.5281/zenodo.24270135
- **作者**：宋敏、宋瑷成、宋奥菲、范钧睿、胡安、涂源　**日期**：{{DATE}}
- **AI 辅助声明**：本工作区的多轮推导、审计与文字起草由本地 DeepSeek Harness（DSH）实例执行；数学结论的最终判据是 Lean 4 内核，不是任何模型的自述。
