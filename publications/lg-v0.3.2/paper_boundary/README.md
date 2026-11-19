# 刘维尔--哥德巴赫定理与二元哥德巴赫猜想的逻辑边界

**状态：预印本 v3.2，未经同行评审。本文证明 LG，不证明 GC。**

> 作者署名沿用项目既有论文的六人名单；如实际署名或顺序不同，请修改 `paper.tex` 的 `\author` 与 `\hypersetup{pdfauthor=...}` 后重编译。

## 一句话结论

本文严格证明并机器复核刘维尔--哥德巴赫定理（LG）：

> 每个偶数 \(N>2\) 都是两个正整数之和，且两个加数的刘维尔值均为 \(-1\)。

同时证明

\[
  \mathrm{GC}\iff \mathrm{LG}_{\Omega\le2},
\]

其中 \(\mathrm{LG}_{\Omega\le2}\) 要求每个偶数 \(N>2\) 都存在一个 LG 表示，且该表示的两个加数的素因子个数（计重数）均不超过 \(2\)。因此，从 LG 到二元哥德巴赫猜想（GC）的缺口恰是一个与 GC 等价的加强；九月材料证明的是 LG，不是 GC。**哥德巴赫猜想仍开放，本文没有证明它。**

## 文件

| 文件 | 说明 |
|---|---|
| `paper.pdf` | 最终论文（30 页，A4，中文，含英文摘要、完整证明、审计、Lean 附录、参考文献） |
| `paper.tex` | LaTeX 源码（XeLaTeX + ctexart） |
| `verification/check_boundary.py` | 有限数值核验脚本（到 \(5\times10^6\)） |
| `verification/verification_results.json` | 数值结果（0 失败） |
| `verification/lean_recheck.log` | 本次 Lean 4.33 复核 `GapCertificate.lean` 与 `LiouvilleAudit.lean` 的原始输出 |
| `verification/SHA256SUMS.json` | 证据文件哈希 |

## 论文的主要更正

1. **LG 证明的 \(p=7\) 空区间。** 原证明在交换平方一步取 \(p/6<n<p/4\)；当 \(p=7\) 时该区间没有整数。本文显式验证 \(p=5,7\)，并说明 \(p\ge11\) 时区间非空（例如 \(n=\lfloor p/4\rfloor\) 可用），且论证对区间内任意整数 \(n\) 成立。自 v3.1 起，\(p\ge11\) 的非空性本身已内核化：`frontier/goldbach-lean/IntervalLemma.lean` 中的 `exists_nat_between_sixth_and_fourth` 对每个素数 \(p\ge11\) 取 \(n=p/4\) 并验证 \(p<6n\)、\(4n<p\)（rc 0，公理集为三条标准公理）。
2. **反射不等式的符号笔误。** 项目此前的重述稿把 \(\lambda(2n)\) 误写为 \(-1\)；正确值是 \(+1\)。结论不变，本文已改正。
3. **Mangerel 阈值的版本差异。** 手稿 A 引用的是 IMRN 出版版（DOI 10.1093/imrn/rnae149），该版摘要写的是对所有 \(m\ge11\)；arXiv v2 只写“充分大”，且 \(N_0\) 无效。两者不能混用。本文早期稿把 A 判为“量词偷换”，该判断已撤回：A 的引用与出版版一致；只有把同一句话接到 arXiv v2 上才会出现 \([11,N_0)\) 的空档。其 Lean 主定理显式依赖 `MangerelNonextremality`（定义为 \(\forall m\ge11\)），这是把 Mangerel 的证明作为外部输入，而不是额外的强假设。
4. **手稿 B 的 \(p=7\) 边界。** B 的主线正确，但正文同样没有写出 \(p=7\) 的小情形；其 Lean 证明通过分情况覆盖。补上后，纸面证明与形式化一致。

## 版本历史

- **v1（未发布）**：27 页首版。对手稿 A 的审计把 arXiv v2 的“充分大”当成 Mangerel 定理的实际陈述，错误地把 A 的 \(m\ge11\) 判为量词偷换。
- **v2**：撤回上述指控，改为“arXiv v2 与 IMRN 出版版的阈值差异”；同步修正 §1.5 路线图、§6.2 五条缺口证书、三处未引用文献、\(500\times500\) 乘法抽样与 §7.5 的独立性措辞。v1 从未封存或发布。
- **v3（v0.3.0）**：增加 prior-art 对照，引用 `sunnyspot114514/Liouville-Goldbach-audit` 的独立 Lean replay；把 \(p=7\) 补丁做成 Lean 证书 `positive_prime_pairs_seven`，新增 \(\Omega\) 层级定理 `binary_goldbach_implies_omega_le`；增加“间接价值”小节。LG/GC 结论不变；28 页。
- **v3.1（v0.3.1）**：把 \(p\ge11\) 的区间非空性做成独立模块 `IntervalLemma.lean` 中的内核定理 `exists_nat_between_sixth_and_fourth`；§1.2、§3.4、§5.2、附录 A/B/C 各补一处；29 页；封存清单 103$\to$104 文件。LG/GC 结论与边界不变。
- **v3.2（本稿，v0.3.2 本地草稿）**：文本更正与先验补全，无新增数学主张。条件桥改为“每个偶数 \(N>2\) 都存在一个 LG 表示，其两个加数均满足 \(\Omega\le2\)”；摘要与结论补充 Mangerel 版本限定（只核对出版版摘要 \(N\ge11\)，未逐行审计出版版正文；arXiv v2 的 \(N_0\) 无效，两个阈值不得互相替代）；§1.2 增引 2026 年 9 月 25 日 MathOverflow 的更强先验结果（Meng，answer 515534）并明确本文不涉及该结果、不主张优先权；新增“AI 使用与上游归属”说明（上游快照内未见 AI 工具声明，不作推断）。LG/GC 结论与边界不变；30 页；封存清单仍为 104 文件。

## 复现

### 论文

需要 XeLaTeX、ctex、SimSun/SimHei 字体。在目录内运行两次：

```bat
xelatex paper.tex
xelatex paper.tex
```

### 数值核验

需要 Python 3 与 NumPy（脚本本身只用标准库；当前实现未用 NumPy）：

```bat
cd verification
python check_boundary.py
```

### Lean 复核

工程位于 `../frontier/goldbach-lean/`，使用工作区 `.elan` 中的 Lean 4.33.0-rc1：

```powershell
$env:ELAN_HOME='C:\Users\宋敏\Documents\trae_projects\DSH_MM\.elan'
$env:PATH="$env:ELAN_HOME\bin;$env:PATH"
cd ..\frontier\goldbach-lean
lake env lean GapCertificate.lean
lake env lean LiouvilleAudit.lean
lake env lean IntervalLemma.lean
```

三条命令应返回 0；前两条的完整输出见 `verification/lean_recheck.log`，第三条（v3.1 新增）的输出见论文附录 B 的 `IL_RC=0` 段。

## 重要边界

- 本文**不证明**哥德巴赫猜想，也不声称 LG 足以推出 GC。
- 本文不主张 LG 的优先权；证明路线来自九月一般稿及其 Lean 工程，本文做独立重述、边界修复、审计、机器复核与逻辑边界分析。
- “未发现数学缺口”是文本审计结论，不是同行评审结论；形式化结论只针对所列 Lean 陈述。
- 本次 Lean 复核复用已有 Mathlib 产物，是非 clean-room 的源码级复核。上游手稿 B 的构建记录为 2901 任务（Lean 4.34.0-rc2）；项目在 Lean 4.33 下的源码级重建为 2851 任务，记录见 `../liouville_paper/`。本次没有重跑这两次完整构建，只复跑了 `GapCertificate.lean`、`LiouvilleAudit.lean` 与 `IntervalLemma.lean` 三个模块。
- 数值检查到 \(5\times10^6\) 是有限证据，不是全称证明。

## 为什么标题不是“哥德巴赫猜想的证明”

因为那会是一个错误的标题。现有材料能证明的是 LG；从 LG 到 GC 需要 \(\Omega\le2\) 的升级，而这个升级与 GC 等价。把 LG 改名为 GC 不是学术写作，而是谓词偷换。本文把这一点写成可机器检查的等价式，并明确给出“本文不证明 GC”的范围声明。
