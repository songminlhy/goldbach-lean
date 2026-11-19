# 检索记录与措辞红线（Prior art）

**检索时间**：2026-11-15 16:20–16:40（+08:00）
**检索人**：本会话（DSH 实例）
**结论先行**：在可检索范围内**没有发现**与本工作重复的公开产物；但这是"没找到"，不是"不存在"。

---

## 一、检索了什么

| # | 查询 | 结果 |
|---|---|---|
| 1 | `arXiv 2611.09007 Goldbach` | 命中 arXiv abs 页本身：v1，2026-11-06，Qazaqzeh & Rawashdeh，math.NT，9 页 |
| 2 | `"A Simple Proof of Goldbach Conjecture" 2026 preprint circular` | 只有论坛帖与无关预印本，**无**针对该文的公开评论 |
| 3 | `Lean 4 Goldbach 1+1.9 Li Liu formalization` | 命中 `subfish-zhou/goldbach-lean`（Reservoir 包、GitHub 文档页） |
| 4 | `goldbach-lean subfish-zhou` | 同上 |
| 5 | `"paperTheorem" "binaryGoldbach" Lean` | **零命中** |
| 6 | `Goldbach 1+2 endpoint formalized Lean theorem implication` | 未命中"端点 ⇒ 1+1"的形式化 |
| 7 | `2611.09007 critique rebuttal Goldbach error` | 未命中任何公开质疑/勘误 |

**渠道局限**（必须写进任何"据我们所知"的句子里）：
只查了公开 web 与 arXiv 元数据；**未**系统检索 Google Scholar、zbMATH、MathSciNet、
Lean Zulip / Reservoir 全量索引，也未检索中文渠道与私人通信。
arXiv 页面显示该文**只有 v1**（核查时刻 2026-11-15 16:22 UTC+8）。

## 二、已存在的相关产物（都不是本工作）

| 产物 | 性质 | 与本工作的关系 |
|---|---|---|
| [`subfish-zhou/goldbach-lean`](https://github.com/subfish-zhou/goldbach-lean)（Apache-2.0，22 stars） | Chen 1+2、Li–Liu 1+1.9、Wu 1+1.8938 的 Lean 形式化，`main` 最后提交 2026-10-28（`9d4c3a4`） | **本工作的宿主仓库**。上游 `main` 上没有 `Gap.lean`；本次新增 4 文件、改 2 文件 |
| [`reservoir: subfish-zhou/goldbach`](https://reservoir.lean-lang.org/@subfish-zhou/goldbach) | Lean 包索引 | 只索引上游包，不含本工作 |
| [arXiv:2611.09007v1](https://arxiv.org/abs/2611.09007) | 被审计的论文（CC BY 4.0） | 本工作**批评**的对象，不是本工作的来源 |
| [arXiv:2606.05224](https://arxiv.org/abs/2606.05224)（Li–Liu 1+1.9） | 上游形式化的数学来源 | 与本工作无关，仅作背景 |

## 三、这条工作的新颖性到底在哪（诚实版）

- `BinaryGoldbach → 1+2` 这类蕴含在数学上是**一行**的事（取 `r = 1`）。它的价值不在难度，
  在于**把"1+2 不是 1+1"从口头共识变成机器可查的对象**，并让后续任何"端点 ⇒ 1+1"的
  越界声明立刻暴露。
- 真正有信息量的是 **C2**：把某篇具体预印本的 `O` 定义与它的定理 1.1 接起来，证明
  "该定理已经蕴含 1+1"。这是**针对具体文本**的、可复核的判断，不是泛泛的科普。
- 因此：新颖性主张应落在 **"machine-checked certificate about this specific preprint"**，
  而不是"我们发明了 1+1 ⇒ 1+2"。

## 四、措辞红线

| 不要写 | 改写为 |
|---|---|
| "世界首个 / the first" | "据我们所知（检索范围：…，截至 2026-11-15），此前没有公开的形式化版本" |
| "证明了哥德巴赫猜想" | "没有证明；我们证明的是三个端点蕴含于 1+1，以及该论文的定理 1.1 蕴含 1+1" |
| "论文是错的"（笼统） | "该论文第 111 行的 `O` 定义使其定理 1.1 蕴含猜想；第 180 行的归纳假设包含结论" |
| "1+2 推不出 1+1（已证明）" | "三个端点的表示谓词严格更宽（有机器见证）；这不是独立性证明" |

> 若日后发现更早的同类工作：**改措辞，不改事实**。本包的时间戳保护的是"我们在 T 时刻
> 已经做出并写下了这些字节"，不是"我们是唯一想到的人"。
