# postseal —— 封存之后的发布准备层

**状态**：本文件描述 v0.1.2 的 postseal 层。v0.1.3（2026-11-18）已把端点层级与 Wu 状态文件纳入 79 文件清单；下文出现的“68 文件”“不在本封存包内”等表述仅指 v0.1.2 历史快照，最新封存见 `RELEASE-NOTES.md` 的“第六次封存”。

## 这个目录里有什么

| 文件 | 用途 |
|---|---|
| `INDEX.html` | 一键打开入口：本地双击后点卡片即可看 PDF、网页版图文与说明（相对链接，不联网） |
| `CIRCULATION.md` | 交流包说明：发哪几份、每份页数、可引用数值、必须一起说出去的边界 |
| `pdf/` | 可直接转发的成品：`EXPLAINER.pdf`（6 页 A4 图文说明）、`GOLDBACH_GAP.pdf`（9 页完整论文）、`01_chen…04_paper.pdf`（四篇各 2 个定理） |
| `explainer/EXPLAINER.html` | 图文说明网页版（单文件、无外部依赖；打印即得 A4 PDF） |
| `papers/` | 四篇拆分论文源码（`preamble.tex` 共享）与 `README.md` |
| `GOLDBACH_GAP.tex` | 合并稿源码（八个定理一张表） |
| `ARTICLE.zh.md` | 可直接发布的中文长文成稿（发布前替换 `{{...}}`） |
| `ARTICLE.en.md` | English long-form version |
| `SOCIAL.md` | 微博 / 知乎 / X 短帖与 GitHub Release 说明 |
| `PUBLISH.md` | 从当前状态到 DOI 的逐步发布手册（含两条路线） |
| `tools/make-release.ps1` | 生成可上传 Zenodo 的归档（保留原始路径，manifest 可在归档内验证） |
| `COVER_zh.md` / `COVER_en.md` | 给共同作者的附言：包内清单、待确认的四项、必须一起说出去的边界 |
| `RELEASE-NOTES.md` | 两次 RFC 3161 封存的对照：为什么重封、两版差异、旧版如何复原、校验要在归档里做 |
| `release/` | 归档产物（由脚本生成；不纳入 manifest，避免循环）。2026-11-16 复核后分装为三份：`gap-v0.1.2-circulation-20261116.zip`（发共同作者的交流成品，25 个文件 + `SHA256SUMS.txt`）、`gap-v0.1.2-draft.tar.gz`（证据归档：68 文件封印包 + 四个 Lean 新文件 + 审计/日志/图 + 被核对的 arXiv v1 源）、`gap-v0.1.2-history-20261116.zip`（2026-11-14 封存前工作稿，不外传）。旧物 `gap-v0.1.0-circulation-20261116.zip`（20 项、无校验）与 `gap-v0.1.0-draft.tar.gz`（含已删除的错误句）均已被取代，不要外传 |

2026-11-18：新增 `release/gap-v0.1.3.tar.gz`（79 文件清单，SHA-256 见 `release/SHA256SUMS-v0.1.3.txt`）；v0.1.2 的三份归档保留不动。

## 新增的复核

- 2026-11-15 的 postseal 复跑：`py kernel_verify.py --checks Goldbach\GapChecks.lean --target Goldbach.Gap --log ..\logs\reverify_2026-11-15_postseal.log` → `RESULT: PASS`，`leanchecker` exit 0，axioms ⊆ `{propext, Classical.choice, Quot.sound}`。该日志**不在** manifest 里，属补充证据。
- 2026-11-17 02:01 的 Wu 1.8938 端点独立重编：3764/3764、0 失败、6 条 `#print axioms` = 标准三公理、端点模块 `leanchecker` rc 0。详见 `N4_WU_INDEPENDENT_BUILD_2026-11-17.md`。该次构建在 v0.1.2 中不在本封存包内，属 postseal 补充证据；v0.1.3 已将其纳入 79 文件清单，不改变封存时点的 N4 事实。

## 证据加强（postseal）

封存包 `CLAIM.md` 的 C2 强调第 180 行把 `G(2n-2) > 0` 列为输入。公开文章采用了一个**更直接**的文本证据：同一段开头写的是

> “we can assume that $G(2n-2)$ and $G(2n)$ are $\mathcal{O}\left(\frac{n}{\ln^{2} n}\right)$ functions …”

按字面读，当前情形 `G(2n)` 本身被列入了“可以假设”的对象；归纳假设只应给出 `n-1` 的 `G(2n-2)`。如果作者本意不是假设当前情形，就需要给出从 `G(2n-2)` 推出 `G(2n)` 的独立论证——论文没有给出。这不改变封存包的任何结论，只是把“循环”指得更准。若日后更新封存包，可把这句话补进 C2 的文本依据。

## 两条重要的核对结果

1. **论文标题**：arXiv:2611.09007v1 的标题是 *An Elementary Proof of the Binary Goldbach Conjecture*。工作区里的文件名 `A_Simple_Proof_of_Goldbach_Conjecture.tex` 是作者上传时使用的源文件名，不是论文标题。`PRIOR_ART.md` 里的搜索串沿用了文件名，不影响声明；公开写作请用论文标题。
2. **行号锚点**：本文引用的第 111 / 180 / 184 / 222 行都指 **arXiv v1 的 LaTeX 源文件**，不是 PDF 页码。该源文件的 SHA-256 是：

```text
db1fa07154ae7430245d19ac377f6d22f02361608014498fe3449129c3765ffd
```

它与 arXiv v1 当前提供的源码逐字节一致（2026-11-15 核对）。任何人可以用这个哈希锁定版本，再核对行号。

## 措辞注意（最终元数据）

`CITATION.cff` / `zenodo.json` 的生成标题里用了 “kernel-checked circularity certificate”。严格说，内核复核的是 `PaperTheorem → BinaryGoldbach`；第 180 行的循环是逐字文本对照（见正文 §3.3 的两分法）。如果要在最终 Zenodo/CFF 元数据里更精确，建议在最终封存前把 `tools/build-metadata.py` 的 `TITLE` 常量改成：

```text
The 1+1 Gap, Machine-Checked: Goldbach endpoints as consequences of binary
Goldbach, and a formalized circularity in arXiv:2611.09007v1
```

改完后重跑 `build-metadata.py` 与 `seal.ps1`。不修改也不影响数学内容；这只是标题措辞的精度问题。

## 与最终封存的关系

推荐在填好 `IDENTITY.json`、拿到 DOI 之后，做一次**最终封存**：

1. 把本目录下的 `README.md`、`ARTICLE.zh.md`、`ARTICLE.en.md`、`SOCIAL.md`、`PUBLISH.md`、`DOI.txt` 加入 `priority/files.txt`；
2. 重新运行 `priority/tools/build-metadata.py`；
3. 重新运行 `priority/tools/seal.ps1`。

**不要**把 `release/*.tar.gz` 加入 `files.txt`：归档里包含 `MANIFEST.sha256`，把它再纳入 manifest 会形成循环。归档的 SHA-256 单独发布即可。

## 边界

本目录的文字遵循与 `priority/` 相同的边界：不声称证明哥德巴赫，不声称“首个”，不把 Wu 端点写成已内核复核，不把上游工作算作本工作。详见 `../CLAIM.md` 与 `../PRIOR_ART.md`。

## 2026-11-16 全量复核

复核范围：本工作区（`goldbach/`，上游 `frontier/goldbach-lean` 全量与第三方 `external/` 只作背景）+ 封存前散落在
`C:\Users\宋敏\Documents\Trae-CN\temp_20261114_01` 的工作稿。

| 项 | 复核结果 |
|---|---|
| 封印 manifest | 68/68 `OK`、0 缺失；`MANIFEST.sha256` = `8b7a1e1a…`，与 `TIMESTAMP.md` 一致 |
| RFC 3161 令牌 | 本轮重新验签 `Verification: OK`（用 Git for Windows 自带的 openssl）；`MANIFEST.tsr` = `26bfee4a…`，genTime `Nov 16 23:56:45 2026 GMT` |
| 静态检查 | 仓库自带 `py scripts/check.py --static-only` 曾因发布面里 4 处中文署名报 `untranslated CJK text`（2026-11-15 的旧日志早于这些提交）；署名改 ASCII 后现为 `issues: []`，并已据此重新封存 |
| 交流包 v0.1.0 | 20 项，11 条相对链接全部可解析；没有包内校验清单 |
| 证据归档 v0.1.0-draft | 陈旧：`priority/postseal/ARTICLE.en.md` 是删除错误句之前的版本；`patches/` 生成于提交之前，按现在的干净工作树重跑会得到空补丁 |
| 前期核验工作稿 | 6 个文件已归入 `goldbach/history/pre_seal_2026-11-14/`；截图里的 4 份 `REPORT_*.md` 在整个用户目录检索不到 |
| 仓库 | 远端 `mine` 已确认：`main` = `c73fce1`，tag `gap-v0.1.2` → `c73fce1`（`gap-v0.1.0` 仍指 `e5b4ded`）；2026-11-16 已设为公开（匿名 API 200、raw 可取 tag 文件），论文与图文说明的代码引用已改到 `gap-v0.1.2` |
| Release | 已发布：`https://github.com/songminlhy/goldbach-lean/releases/tag/gap-v0.1.2`，附件 `gap-v0.1.2-draft.tar.gz` 与同名 `.sha256`（校验值以 Release 页为准）；正文取自 `SOCIAL.md` 第 4 节 |
| Zenodo / DOI | **已完成**：`10.5281/zenodo.24270135`（概念 DOI，最新版本）/ `10.5281/zenodo.24270136`（本版）；记录 <https://zenodo.org/records/24270136>，版本 0.1.2、2026-11-16，文件 `gap-v0.1.2-draft.tar.gz`（2,219,091 B）；详见 `priority/DOI.txt` |

据此重做三份包：交流包 v0.1.2（加 `SHA256SUMS.txt`）、证据归档 v0.1.2-draft（补丁基线改为 `origin/main`、剔除构建产物、
补入图与数值脚本）、历史包 v0.1.2-history；附言与说明里的仓库行改为“本地 tag + 权限联系通讯作者”。
