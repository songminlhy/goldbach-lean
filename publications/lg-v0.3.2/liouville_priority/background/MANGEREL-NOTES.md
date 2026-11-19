# Mangerel 阈值的版本差异（对手稿 A 审计的更正依据）

## 一、手稿 A 的原文与引用

手稿 A（`liouville_audit/Liouville-Goldbach-Multiples-of-Four-main/paper/liouville-goldbach-multiples-of-four.md`）第 13–16 行：

> The only external theorem needed is Mangerel's bound [2, Theorem 1.2]:
> \[
> \left|\sum_{n=1}^{m-1}\lambda(n)\lambda(m-n)\right|<m-1\qquad(m\geq11).
> \]

其参考文献 [2]（同文件第 80 行）：

> A. P. Mangerel, *On a Goldbach-Type Problem for the Liouville Function*,
> International Mathematics Research Notices **2024**, no. 16, 11865-11877.
> https://doi.org/10.1093/imrn/rnae149

因此，A 引用的是 **IMRN 出版版**，不是 arXiv 预印本。

## 二、出版版摘要（Crossref）

DOI `10.1093/imrn/rnae149` 的 Crossref 记录（2026-11-17 核对；Semantic Scholar 的同一 DOI 摘要一致）：

> Let \(\lambda\) denote the Liouville function. We show that **for all \(N \geq 11\)**, the (non-trivial) convolution sum bound
> \[
> \left|\sum_{n < N} \lambda(n)\lambda(N-n)\right| < N-1
> \]
> holds. We also determine all \(N\) for which no cancellation in the convolution sum occurs. This answers a question posed at the 2018 AIM workshop on Sarnak's conjecture.

该摘要的阈值是 **\(N\ge11\)**，与 A 的 \(m\ge11\) 一致。

## 三、arXiv v2 摘要与说明

arXiv API（`2404.12117v2`，2024-05-02）的摘要：

> Let \(\lambda\) denote the Liouville function. We show that **for all sufficiently large integers \(N\)**, the (non-trivial) convolution sum bound
> \[
> \left|\sum_{1 \leq n < N} \lambda(n) \lambda(N-n)\right| < N-1
> \]
> holds.

arXiv v2 的 Remark 1 说明：证明依赖 Siegel 关于二次 Dirichlet 特征 \(L(1,\chi)\) 下界的定理，因此阈值 \(N_0\) 是无效的（ineffective），不能给出可计算的上界。本地快照 `liouville_audit/mangerel/mangerel.txt` 是该版本，SHA-256 `dc8a0e2e…`。

## 四、结论

1. A 的 \(m\ge11\) 与它所引的 **IMRN 出版版摘要**一致；它不是把 \(\exists N_0\) 偷换成 \(\forall m\ge11\)。
2. 26 页早期稿与 27 页稿第一版的“量词偷换”判断，实际是拿 **arXiv v2** 的“充分大”去对照 A；该判断已撤回。
3. 保留的正确警告是：**引用 Mangerel 时必须写明版本**。若引 arXiv v2，则 \([11,N_0)\) 没有依据；若引 IMRN 出版版，则阈值是 \(N\ge11\)。
4. Lean 的 `MangerelNonextremality` 定义为 \(\forall m\ge11\)，与出版版摘要同型；它是把 Mangerel 的证明作为外部输入（该证明未被形式化），不是比出版版更强的额外假设。

## 五、限制

本次未取得 IMRN 出版版全文（OUP 站点有访问挑战；Durham 机构库副本同样被挑战页拦截）。因此：

- 本文只把 **Crossref 所载摘要** 作为版本阈值证据；
- 出版版正文 Theorem 1.2 的逐字陈述、以及其证明是否与摘要的均匀阈值完全一致，仍应以出版版全文复核；
- 上述限制不改变 A 的引用与其所引出版版摘要一致这一事实，但也不构成对出版版证明的独立验证。
