# 致共同作者：机器复核版 Goldbach 差距（待发表稿）

各位老师、同学：

这是我们这轮工作的成品包，先发给组内过一遍。三件事：怎么读、需要你们确认什么、哪些话不能对外说。

## 一、包里有什么

- `INDEX.html` —— 入口页，打开后点卡片即可看所有 PDF
- `pdf/EXPLAINER.pdf` —— 6 页图文说明（A4），适合快速了解全貌
- `explainer/EXPLAINER.html` —— 同一份图文的网页版，自适应屏幕
- `pdf/GOLDBACH_GAP.pdf` —— 9 页完整论文（合并稿，八个定理一张表）
- `pdf/01_chen.pdf`、`pdf/02_liu.pdf`、`pdf/03_wu.pdf`、`pdf/04_paper.pdf` —— 按定理均分的四篇，每篇 2 个定理
- `GOLDBACH_GAP.tex`、`papers/*.tex` —— 论文源码（pdfLaTeX + CJKutf8，可直接重编）
- `CIRCULATION.md` —— 交流说明：可引用数值、边界、重建命令
- `ARTICLE.zh.md`、`ARTICLE.en.md` —— 中文/英文长文版（发布前需替换 DOI 等占位符）
- `SHA256SUMS.txt` —— 包内 25 个文件的 SHA-256 清单；校验命令在 `CIRCULATION.md` §0.2
- 另附两个包：`gap-v0.1.2-draft.tar.gz`（证据归档 —— 68 文件封印包、四个 Lean 新文件、审计与内核日志、被核对的那篇 arXiv v1 源）、`gap-v0.1.2-history-20261116.zip`（2026-11-14 封存前的工作稿，只供追溯，**不要外传**）

## 二、这轮做出来的东西是什么

1. 在 Lean 4 + Mathlib 里把三个“接近哥德巴赫”的端点证成二元哥德巴赫的推论：Chen 1+2、Li–Liu 1+1.9、Wu 1+1.8938，取乘数 `r = 1` 即可。共 8 条定理，全部由 `leanchecker` 重放通过。
2. 三条 witness 说明这些表示谓语确实更宽：`4 = 2·2`、`18 = 3 + 3·5`、`13 = 7 + 2·3`。
3. 在 arXiv:2611.09007v1 自己给出的 `O` 定义下，它的 Theorem 1.1 已经蕴含二元哥德巴赫；第 180 行把当前情形 `G(2n)` 本身列进“可以假设”，构成循环。前者是内核复核过的蕴含，后者是逐字文本对照。

## 三、请各位确认的清单

1. **署名与顺序**：现在是 宋敏、宋瑷成、宋奥菲、范钧睿、胡安、涂源，六人同序出现在所有 PDF、`CITATION.cff`、`zenodo.json` 里。请确认英文显示名、单位、ORCID 是否要补。
2. **通讯作者与联系方式**：目前 `IDENTITY.json` 只填了第一作者的邮箱与 GitHub 账号，其余留空，需要补齐。
3. **拆分方式**：现在是 4 篇 × 2 个定理（按端点分组，每条蕴含配它自己的 witness）。如果更偏好 2 篇或 1 篇合并投稿，可以调整。
4. **投稿去向**：还没定。四篇可以各自投，也可以合并稿直接挂 arXiv 预印本。

## 四、必须一起说出去的边界

- **不证明哥德巴赫**：没有任何无条件定理以二元哥德巴赫为结论。
- **不主张首创**：检索记录只说明“没有找到前驱”，附查询与日期；不是穷尽检索。
- **Wu 端点不写作已内核复核**：它是逐字转录，本次没有对上游证明做内核重跑。
- **witness 不是独立性结论**：它们只说明表示谓语更宽；`4`、`18`、`13` 本身都能写成两个素数之和。
- **上游工作不属于我们**：Chen / Li–Liu / Wu 的开发属于 `subfish-zhou/goldbach-lean`；本工作新增 4 个文件、修改 2 个文件。

## 五、可引用的证据数值

- 证据包 68 个文件，manifest SHA-256 `77df12642d7eb2210280ab09e398d101052e6158040033289074080d79ee8860`
- RFC 3161 时间戳令牌 genTime `Nov 16 23:56:45 2026 GMT`，签名校验 `OK`
- 代码：公开仓库 `https://github.com/songminlhy/goldbach-lean`，tag `gap-v0.1.2`、commit `c73fce1`；四个新增 Lean 文件与两处上游修改补丁都收在证据归档里
- 下载：`https://github.com/songminlhy/goldbach-lean/releases/tag/gap-v0.1.2`，附件 `gap-v0.1.2-draft.tar.gz` 与同名 `.sha256`
- 上游 `subfish-zhou/goldbach-lean`，`main` at `9d4c3a4`，Apache-2.0

## 六、怎么打开

- 最快：解压后双击 `INDEX.html`。
- 若浏览器拦 `file://`：在资源管理器地址栏粘 `INDEX.html` 的完整路径回车；或起静态服务 `py -m http.server 8765 --bind 127.0.0.1 --directory .`，再访问 `http://127.0.0.1:8765/INDEX.html`。
- 重编 PDF：`pdflatex -interaction=nonstopmode -output-directory=paper-build GOLDBACH_GAP.tex`（连跑两遍），四篇在 `papers/` 下同样处理。

有任何一处理解不同，尤其是第 180 行那段引文的读法，欢迎直接指出来，我们按具体行号重新核对。

—— 宋敏（通讯作者）
2026 年 11 月 16 日
