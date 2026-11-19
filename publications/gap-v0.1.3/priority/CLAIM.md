# 声明清单（Claims / Non-claims）

每条声明都绑定到**可复核的证据**：Lean 定理名、源码行号、内核日志。
证据强度分级：

- **A｜内核复核**：Lean 编译 + `leanchecker` 重放通过，公理集 ⊆ `{propext, Classical.choice, Quot.sound}`；
- **B｜文本比对**：逐字引用，行号可查；
- **C｜有限数值**：只覆盖所列范围，不构成全称命题；
- **D｜判断**：作者意见，不可作为事实引用。

---

## 一、可声明（C1–C5）

### C1｜三个头条端点都是 1+1 的推论　【A】

> 在 Lean 4 中，`BinaryGoldbach → ChenTheorem`、`BinaryGoldbach → OnePlusOneNineShape`、
> `BinaryGoldbach → OnePlusOne8938Shape` 三条定理成立；证明就是取第二个乘数 `r = 1`
> （Chen 的情形取第二个加数为素数）。

- 证据：`frontier/goldbach-lean/Goldbach/Gap.lean:62,72,86`
- 复核：`logs/audit_gap_check_rerun.log`（`RESULT: PASS`，axioms: `propext` / `propext, Quot.sound`）
- 意义：这三个端点是**比 1+1 弱**的命题，不是"差一点点的 1+1"。

### C2｜论文定理 1.1 在它自己的 `O` 定义下已经蕴含 1+1　【A + B】

> 令 `PaperTheorem` 为 arXiv:2611.09007v1 定理 1.1 在论文自身 `O` 定义下的形式化陈述
> （比值 `G(2n)·log²(2n)/n → c`，`c ≠ 0`），则 `PaperTheorem → BinaryGoldbach` 可证。

- 文本依据（B）：论文第 **111** 行原文——
  "We say that $f$ is a big $\mathcal{O}$ of $g$ … if $\lim_{n\to\infty} f(n)/g(n) = c$
  for some nonzero real number $c$."
- 形式化（A）：`Gap.lean:161`（`PaperTheorem`）、`Gap.lean:171`（`paperTheorem_implies_binaryGoldbach`）
- 推理链（全部在 Lean 内）：比值 ≥ 0 最终成立 ⇒ `c ≥ 0`；`c ≠ 0` ⇒ `c > 0`；
  ⇒ 比值最终 > 0 ⇒ `goldbachCount (2n) > 0` ⇒ 每个充分大偶数都是两素数之和。
- 与论文的接口（B）：第 **180** 行把当前情形 $G(2n)$ 列入"可以假设"的对象，构成循环；
  同一句把 "the positivity of $G(2n-2)$" 当作输入，在字面定义下已预设结论的正性，
  在标准读法下则失去依据。第 **184** 行又说 `α < 2` 是"`G(2n-2)` 是 `O(n/log²n)`"的推论——
  而 `α = 2 - c`，`α < 2 ⟺ c > 0`；这属于正性读法问题，不并入循环结论。
- 结论的准确措辞：**在该论文自己的 `O` 定义下，定理 1.1 不是弱于猜想的命题，它蕴含猜想；
  第 180 行又把当前情形 $G(2n)$ 列入可假设对象，故该步构成循环。** 这不是"论文证错了某个不等式"，
  是"定理陈述本身已经包含了结论"。

### C3｜三个端点的表示类确实包含 1+1 不允许的对象　【A】

> Chen 允许第二个加数是合数（见证 `4 = 2·2`）；Li–Liu 允许乘数 `r = 3 ≠ 1`
> （见证 `18 = 3 + 3·5`，且 `3¹⁰ ≤ 5⁹`）；Wu 允许 `r = 2 ≠ 1`
> （见证 `13 = 7 + 2·3`，且 `2⁵⁰⁰⁰ ≤ 3⁴⁴⁶⁹`）。

- 证据：`Gap.lean:102,108,116`
- 复核：`logs/audit_gap_check_rerun.log`

### C4｜计数与表示之间的桥　【A】

> `0 < goldbachCount N ↔ ∃ p q, p.Prime ∧ q.Prime ∧ N = p + q`。

- 证据：`Gap.lean:137`（定义）、`Gap.lean:141`（定理）
- 用途：C2 的最后一步；后续任何"正性 ⇒ 表示"的论证都可复用。

### C5｜Li–Liu 形状不是手抄，与活端点定义相等　【A】

> `GapLiveChecks.lean` 中 `live_one_plus_one_nine_has_shape : OnePlusOneNineShape`
> 直接由活端点 `Goldbach.one_plus_one_nine` 证出，Lean 接受定义相等。

- 证据：`frontier/goldbach-lean/Goldbach/GapLiveChecks.lean`
- 复核：`logs/audit_live_shape_check.log`（`RESULT: PASS`，`leanchecker` exit 0，27.5 s）

---

## 二、不可声明（N1–N6）——这些句子**不能**出现在任何发布稿里

| 编号 | 禁止的说法 | 事实 |
|---|---|---|
| **N1** | "我们证明了哥德巴赫猜想" | 没有任何一条无条件定理以 `BinaryGoldbach` 为结论。唯一一条 `… → BinaryGoldbach` 的前提 `PaperTheorem` 正是论文未证的东西。 |
| **N2** | "世界首个 / 首次" | 未做穷尽检索；`PRIOR_ART.md` 只记录"没找到"。改用"据我们所知"也必须附检索范围与日期。 |
| **N3** | "论文每一步都错了" | 只对第 111 行定义、第 180 行归纳、第 222 行 `R₁` 断言给出判断；数值审计只覆盖有限范围（C 级）。 |
| **N4** | "Wu 1.8938 已内核复核" | `research/wu2008/` 未构建，`src/` 下无 `.olean`；Wu 形状仅为逐字转录 + `#check`。 |
| **N5** | "goldbach-lean 是我们的工作" | 该仓库是 `subfish-zhou/goldbach-lean`（Apache-2.0），本次只新增 4 个文件、改 2 个文件。见 `AUTHORS.md`。 |
| **N6** | "我们证明了 1+2 推不出 1+1" | 三条 witness 定理只说明表示**谓词**更宽，不是独立性/元数学证明。 |

---

## 三、一句话版本（可直接引用）

> 我们把"1+2 / 1+1.9 / 1+1.8938 都是 1+1 的推论"和"arXiv:2611.09007v1 的定理 1.1
> 在其自身 `O` 定义下已蕴含 1+1"这两件事，做成了 8 条经 Lean 4 内核复核的定理
> （公理集 ⊆ `{propext, Classical.choice, Quot.sound}`）。
> **哥德巴赫猜想仍然开放；我们没有证明它，也不声称首创。**
