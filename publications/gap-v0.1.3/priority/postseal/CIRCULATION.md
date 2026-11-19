# 交流包 —— 图文说明 + 待发表论文

生成于 2026-11-16。本目录（`postseal/`）属于封存之后的发布准备层，**不在** `priority/MANIFEST.sha256` 的 68 个文件里；已封存的证据包未被改动。

**最快打开方式**：双击本目录的 `INDEX.html`，七份 PDF、网页版图文和说明文档都在那一页里点开；PDF 也可以直接从 `pdf/` 或 `paper_closed_loop/` 取。

## 〇、这次是三个包，别混

| 包 | 文件 | 里面是什么 | 怎么用 |
|---|---|---|---|
| 交流成品（本包） | `gap-v0.1.2-circulation-20261116.zip` | 本目录：7 份 PDF、图文网页、四篇分册与合并稿源码、闭环核验论文源码、中英长文、附言、`SHA256SUMS.txt` | 组内先看；可直接转发 |
| 证据归档 | `gap-v0.1.2-draft.tar.gz` | 68 文件封印包、四个 Lean 新文件与两处上游修改补丁、审计与日志、图、上游 arXiv v1 源 | 需要自己复核哈希 / 时间戳 / 日志时用 |
| 历史稿 | `gap-v0.1.2-history-20261116.zip` | 2026-11-14 封存前的内核验证工作稿与查重报告 | 只在追历史时给；**不要外传** |

三份都是 2026-11-16 重新打的。`release/gap-v0.1.0-circulation-20261116.zip` 是上一版（20 项、没有包内校验），
已被 v0.1.2 取代；`gap-v0.1.0-draft.tar.gz` 是更正前的旧归档，**不要转发**（见第八节）。

## 〇之二、本包清单与校验

本包 25 个文件，外加 `SHA256SUMS.txt`。解压后在包根目录跑：

```powershell
Get-Content SHA256SUMS.txt | ForEach-Object {
  $h, $p = $_ -split '  ', 2
  $a = (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower()
  if ($a -ne $h) { "MISMATCH $p" } else { "OK       $p" }
}
```

预期 25 行全 `OK`。任何 `MISMATCH` 说明传输或解压改了字节，先重取文件，再谈内容。

| 组 | 文件 | 数量 |
|---|---|---|
| 入口与说明 | `INDEX.html`、`CIRCULATION.md`、`COVER_zh.md`、`COVER_en.md` | 4 |
| 成品 PDF | `pdf/EXPLAINER.pdf`、`pdf/GOLDBACH_GAP.pdf`、`pdf/01_chen.pdf`、`02_liu`、`03_wu`、`04_paper`、`paper_closed_loop/paper.pdf`、`paper_closed_loop/paper_en.pdf` | 8 |
| 论文源码 | `GOLDBACH_GAP.tex`、`papers/01_chen.tex`…`04_paper.tex`、`papers/preamble.tex`、`papers/README.md` | 6 |
| 闭环核验论文 | `paper_closed_loop/paper.tex`、`paper_closed_loop/paper_en.tex`、`paper_closed_loop/README.md` | 3 |
| 长文 | `ARTICLE.zh.md`、`ARTICLE.en.md` | 2 |
| 图文网页 | `explainer/EXPLAINER.html` | 1 |
| 校验 | `SHA256SUMS.txt` | 1 |

## 一、最先发这两份

| 文件 | 页数 | 说明 |
|---|---|---|
| `pdf/EXPLAINER.pdf` | 6 页 A4 | 图文说明，适合直接转发或打印。网页版是同目录的 `explainer/EXPLAINER.html`：单文件、无外部依赖，浏览器里 Ctrl/Cmd+P 可再导出一份 |
| `pdf/GOLDBACH_GAP.pdf` | 9 页 Letter | 完整论文：六位作者、八个定理、证据数值、边界、AI 披露 |

## 二、按定理均分的四篇（每篇 2 个定理）

| 文件 | 页数 | 覆盖的两条 Lean 定理 |
|---|---|---|
| `pdf/01_chen.pdf` | 3 | `binaryGoldbach_implies_chen`、`chen_second_summand_class_includes_composite` |
| `pdf/02_liu.pdf` | 3 | `binaryGoldbach_implies_onePlusOneNine`、`liu_multiplier_class_includes_nontrivial` |
| `pdf/03_wu.pdf` | 3 | `binaryGoldbach_implies_onePlusOne8938`、`wu_multiplier_class_includes_nontrivial` |
| `pdf/04_paper.pdf` | 4 | `goldbachCount_pos_iff`、`paperTheorem_implies_binaryGoldbach` |

源码：`papers/01_chen.tex` … `papers/04_paper.tex`，共享 `papers/preamble.tex`；合并稿源码为 `GOLDBACH_GAP.tex`。两份都用 pdfLaTeX + CJKutf8 编译，中文作者名直接嵌在 PDF 里。

## 三、论文说了什么（三句话）

1. 三个“接近哥德巴赫”的端点——Chen 的 1+2、Li–Liu 的 1+1.9、Wu 的 1+1.8938——在 Lean 4 + Mathlib 里被证明是二元哥德巴赫的**推论**：把乘数取成 `r = 1`。
2. 三条 witness 说明这些表示谓语确实更宽：Chen 允许 `q = 4 = 2·2`，Li–Liu 允许 `r = 3`（`18 = 3 + 3·5`），Wu 允许 `r = 2`（`13 = 7 + 2·3`）。**这是表示层的陈述，不是数层的结论**：4、18、13 本身都能写成两个素数之和。
3. 在 arXiv:2611.09007v1 **自己的** `O` 定义下（比值趋于非零常数），它的 Theorem 1.1 已经蕴含二元哥德巴赫；而第 180 行把当前情形 `G(2n)` 本身列进了“可以假设”的对象，构成循环。这两条里，第一条由内核复核，第二条是逐字文本对照。

## 四、可以直接引用的数值

- 八个定理全部由 `leanchecker` 重放：`RESULT: PASS`，exit 0；公理集 ⊆ `{propext, Classical.choice, Quot.sound}`
- 证据包：68 个文件
- RFC 3161 token genTime `Nov 16 23:56:45 2026 GMT`，签名校验 `OK`
- 代码：公开仓库 `https://github.com/songminlhy/goldbach-lean`，tag `gap-v0.1.2`（commit `c73fce1`）；四个新增 Lean 文件与两处上游修改补丁也收在证据归档里
- Release：`https://github.com/songminlhy/goldbach-lean/releases/tag/gap-v0.1.2`，附件 `gap-v0.1.2-draft.tar.gz` 与同名 `.sha256`（校验值以 Release 页显示为准）
- 上游：`subfish-zhou/goldbach-lean`，`main` at `9d4c3a4`，Apache-2.0

两个完整哈希（PDF 里因排版拆行，这里给整串）：

```text
77df12642d7eb2210280ab09e398d101052e6158040033289074080d79ee8860   证据包 manifest
db1fa07154ae7430245d19ac377f6d22f02361608014498fe3449129c3765ffd   arXiv v1 源文件
```

## 五、必须一起说出去的边界

- **不证明哥德巴赫。** 没有任何无条件定理以二元哥德巴赫为结论。
- **不主张首创。** 检索记录只说明“没有找到前驱”，并附查询与日期。
- **Wu 端点不写作已内核复核。** 它是逐字转录，本次没有对其上游证明做内核重跑。
- **witness 不构成独立性结论。** 它们只说明表示谓语更宽。
- **上游不是本工作。** Chen / Li–Liu / Wu 的开发属于 `subfish-zhou/goldbach-lean`；本工作新增 4 个文件、修改 2 个文件。

## 六、作者与顺序

宋敏、宋瑷成、宋奥菲、范钧睿、胡安、涂源

## 七、自己重建 PDF

```powershell
cd goldbach\priority\postseal
pdflatex -interaction=nonstopmode -output-directory=paper-build GOLDBACH_GAP.tex   # 连跑两遍

cd papers
pdflatex -interaction=nonstopmode -output-directory=..\paper-build\papers 01_chen.tex   # 02/03/04 同样各两遍
```

图文说明：浏览器打开 `explainer/EXPLAINER.html`，打印为 A4 即可。本次的 `pdf/EXPLAINER.pdf` 由 Chrome 无头模式打印（`--print-to-pdf`，A4、12 mm 页边距），分页规则写在 HTML 的 `@media print` 里。

## 八、现在还不要对外说的

- **DOI 已分配**：`10.5281/zenodo.24270135`（概念 DOI，始终指向最新版本；本次记录 24270136）。Release 与 Zenodo 均已发布。
- **两个名字很像的 tar.gz，别拿错**：`gap-v0.1.0-draft.tar.gz` 是更正前的旧归档，里面的 `ARTICLE.en.md` 仍有已删除的错误句子（把 18 / 13 / 4 说成“不是两个素数之和”），**不要转发**；要发证据请发 `gap-v0.1.2-draft.tar.gz`（2026-11-16 重建，已核对不含该句）。当前口径以本目录的 `ARTICLE.zh.md`、`ARTICLE.en.md` 和四篇论文为准。
