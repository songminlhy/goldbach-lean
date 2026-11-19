# 社交短帖与转发文案（发布前替换 `{{...}}`）

> 顺序：DOI 先于社交媒体。下面每一条都假定 `10.5281/zenodo.24270135` 与 `{{REPO_URL}}` 已经可用。
> 不要改写成“证明了哥德巴赫”或“世界首个”。

## 1. 中文微博 / Bluesky / Mastodon（约 280 字）

> 哥德巴赫猜想仍未被证明。我们用 Lean 4 机器复核了两件事：  
> ① Chen 1+2、Li–Liu 1+1.9、Wu 1+1.8938 都是 1+1 的**推论**，不是“差一点点的 1+1”；  
> ② arXiv:2611.09007v1 按它**自己**的 big-O 定义，定理 1.1 已经蕴含 1+1；第 180 行开头把当前情形 `G(2n)` 也列入了“可以假设”的对象。  
> 8 条定理，公理集 ⊆ {propext, Classical.choice, Quot.sound}，`leanchecker` 重放通过。  
> 哥德巴赫没有被证明；我们也没说自己是第一个。  
> 论文与复核：10.5281/zenodo.24270135　代码：{{REPO_URL}}

## 2. 中文长文导语（知乎 / 公众号）

> 这是一份“反高潮”的工作：它没有证明哥德巴赫猜想，反而把“1+2 离 1+1 只差一点”这句常见的安慰话拆开了。  
> 我们把 Chen 1+2、Li–Liu 1+1.9、Wu 1+1.8938 三个端点写成 Lean 4 定理，证明它们都是 1+1 的**逻辑推论**；又把一篇 2026 年 11 月的预印本按它自己的 big-O 定义形式化，证明它的定理 1.1 已经蕴含 1+1——而它的第 180 行把“`G(2n-2) > 0`”当成了推导输入。  
> 全文的判据不是“作者说”，是 Lean 内核、公理集、日志和哈希。  
> 哥德巴赫仍然开放；这份工作只是把“差距在哪里”变成了一把可以拿起来的尺子。  
> 长文：{{ARTICLE_URL}}　DOI：10.5281/zenodo.24270135

## 3. 英文 X / Mastodon thread（5 条）

**1/5**

> Goldbach is still open. We did not prove it.  
> We machine-checked two narrower claims in Lean 4:  
> (1) Chen 1+2, Li–Liu 1+1.9, Wu 1+1.8938 are all **consequences** of 1+1—not “almost 1+1”.  
> (2) arXiv:2611.09007v1's Theorem 1.1 already implies 1+1 under its own big-O definition.

**2/5**

> The preprint defines `f = O(g)` as `lim f(n)/g(n) = c ≠ 0` (line 111 of its LaTeX source).  
> That is not an upper bound; it is a two-sided asymptotic. Under it, `G(2n)·log²(2n)/n → c ≠ 0`, so `G(2n) > 0` eventually—i.e. 1+1.

**3/5**

> We formalized that statement as `PaperTheorem` and proved `PaperTheorem → BinaryGoldbach`.  
> The proof opens at line 180 by listing `G(2n)` itself—the current case—among the things it may assume, and then lists “the positivity of `G(2n-2)`” as an input. Under the paper's own definition, that input is already contained in the induction hypothesis. The step assumes the conclusion.

**4/5**

> Eight Lean 4 theorems. Axioms ⊆ `{propext, Classical.choice, Quot.sound}`. `leanchecker` replays them.  
> `Goldbach.Gap` imports only `Goldbach.Statement` + Mathlib, so the check does not depend on the 1,800-module sieve development.  
> Wu's endpoint is transcription-only; we did **not** kernel-replay it.

**5/5**

> What we are not saying: we did not prove Goldbach; we did not prove the endpoints cannot imply 1+1; we do not claim to be first.  
> Paper: 10.5281/zenodo.24270135  
> Code: {{REPO_URL}}  
> Corrections welcome.

## 4. GitHub Release 说明（短）

> **gap-v0.1.2 — the 1+1 gap, machine-checked.**  
> Eight Lean 4 theorems: the three headline endpoints (Chen 1+2, Li–Liu 1+1.9, Wu 1+1.8938) are consequences of binary Goldbach; and Theorem 1.1 of arXiv:2611.09007v1, under its own big-O definition, already implies binary Goldbach.  
> Axioms ⊆ `{propext, Classical.choice, Quot.sound}`; `leanchecker` replay passes. The repository's own release-surface check reports 1,806 source modules with no issues.  
> **Not proved:** Goldbach itself; no independence claim; Wu's endpoint is transcription-only.  
> Evidence, logs, and a timestamped manifest are under `priority/`; the pack carries four seals (2026-11-15 15:59:25 UTC, 2026-11-16 02:12:04 UTC, 2026-11-16 21:29:18 UTC and 2026-11-16 22:57:24 UTC), compared in `postseal/RELEASE-NOTES.md`.  
> Tag `gap-v0.1.2` = commit `c73fce1`.

## 5. 一条绝对不要发的版本（反例）

> ❌ “我们用 AI 证明了哥德巴赫猜想！1+2、1+1.9、1+1.8938 全部拿下，世界首个！”

这句话同时踩中 N1（没有证明哥德巴赫）、N2（没有做穷尽检索）、N4/N5（把上游和转录说成自己的），并且会把真正有价值的那条 C2 淹没。**不要发。**
