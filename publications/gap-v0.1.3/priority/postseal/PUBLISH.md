# 发布手册（从当前状态到 DOI，再到公开发布）

**当前状态（2026-11-15）**

- 证据包已封存：`MANIFEST.sha256`（68 files）+ FreeTSA RFC 3161 时间戳，`Verification: OK`。
- 8 条定理的 `leanchecker` 重放通过；日志在 `goldbach/logs/`。
- `IDENTITY.json` 已填六位作者；`CITATION.cff` / `zenodo.json` 已由 `tools/build-metadata.py` 按六位作者重新生成，并已于 2026-11-16 23:56:44 UTC 重新封存（署名改为 ASCII 后重封，旧令牌存于 `priority/archive/pre_reseal_20261116/`）。
- **尚未对外发布任何内容。**
- `postseal/` 下的文章与手册是封存之后新增的，**不在** manifest 里；最终封存时要把它们加入 `files.txt`。

发布是不可撤销的外部动作。下面每一步都给出命令和验收标准；真正执行 push / Zenodo / 发帖的是你。

---

## 0. 先做一次“发布前体检”

在 `goldbach/` 下：

```powershell
cd C:\Users\宋敏\Documents\trae_projects\DSH_MM\goldbach

# 1) 哈希仍然全绿
& "C:\Program Files\Git\usr\bin\sha256sum.exe" -c priority\MANIFEST.sha256

# 2) 时间戳仍然 OK
& "C:\Program Files\Git\usr\bin\openssl.exe" ts -verify -data priority\MANIFEST.sha256 `
  -in priority\MANIFEST.tsr -CAfile priority\tsa\cacert.pem -untrusted priority\tsa\tsa.crt

# 3) 内核复核（约 30 秒）
cd frontier
python kernel_verify.py --checks Goldbach\GapChecks.lean `
  --target Goldbach.Gap --log ..\logs\preflight_2026-11-15.log
```

预期：60 个 `OK`；`Verification: OK`；`RESULT: PASS`。

> 不要用 `..\logs\audit_gap_check_rerun.log` 作为这次体检的输出：那个文件在封存 manifest 里，覆盖它会让 `sha256sum -c` 失败。  
> 如果 `python` 不可用（Windows 应用商店别名常见），把命令里的 `python` 换成 `py`。

如果任何一步失败：先查清楚，不要继续发布。

---

## 1. 填署名并重新封存（G1，阻塞后续全部步骤）

编辑：

```text
goldbach/priority/IDENTITY.json
```

至少填：`given_name`、`family_name`、`repository_code`（**仓库 URL**，例如 `https://github.com/<你>/goldbach-lean`）。建议填 `email`、`github`、`orcid`。如果走 Zenodo 直传路线且暂时没有公开仓库，先建一个空仓库或稍后再补 `repository_code`；不要填一个语义不符的值。

然后：

```powershell
cd C:\Users\宋敏\Documents\trae_projects\DSH_MM\goldbach
python priority\tools\build-metadata.py
powershell -NoProfile -ExecutionPolicy Bypass -File priority\tools\seal.ps1
```

`seal.ps1` 会：重算 `MANIFEST.sha256` → 向 FreeTSA 取新令牌 → 离线验签 → 重写 `TIMESTAMP.md`。验收：

- 输出 `timestamp: status=Granted ... verify=OK`；
- `TIMESTAMP.md` 里的 `token genTime` 是新的；
- `sha256sum -c` 仍然全绿。

> **注意**：这一步会覆盖当前时间戳（2026-11-16 23:56:44 UTC）。旧令牌仍然可以单独验证（它签的是它自己那一版 manifest），但 `MANIFEST.tsr` 会被新令牌替换。若想保留当前令牌，先复制一份 `MANIFEST.tsr` 到 `priority/archive/` 再跑。

> **顺序**：先改完**所有被哈希的文件**（`files.txt` 列出的每一个），最后再封存。2026-11-16 那次重封就先跑了 `seal.ps1`、随后又改了 `paper_closed_loop/paper.tex` 里的两处计数文字，结果归档内 `sha256sum -c` 出现 1 条 FAILED，只能把令牌归档后重封一次。

> **可选**：生成的元数据标题含 “kernel-checked circularity certificate”。若想把措辞收紧为 “formalized circularity”，先改 `priority/tools/build-metadata.py` 的 `TITLE` 常量，再跑上面的两步；细节见 `postseal/README.md` 的“措辞注意”。

### 1.1 把 postseal 文章纳入最终封存（推荐）

在 `priority/files.txt` 的 `# --- this package ---` 段落下加入：

```text
priority/postseal/README.md
priority/postseal/ARTICLE.zh.md
priority/postseal/ARTICLE.en.md
priority/postseal/SOCIAL.md
priority/postseal/PUBLISH.md
```

**不要**把 `priority/postseal/release/*.tar.gz` 加进去：归档里包含 manifest，会形成循环。归档的哈希单独发布（见第 4 节）。

加完后重跑：

```powershell
python priority\tools\build-metadata.py
powershell -NoProfile -ExecutionPolicy Bypass -File priority\tools\seal.ps1
```

manifest 已经由 33 files 变成 68 files；`TIMESTAMP.md` 会记录新的数量。

---

## 2. 把新增 Lean 文件放进你自己的公开仓库（G2）

当前 `goldbach/frontier/goldbach-lean` 是 `subfish-zhou/goldbach-lean` 的浅克隆，`main` 在 `9d4c3a4` 之上已有本地提交。

> **2026-11-16 复核**：本地状态已不是“未提交”——`main` = `c459cc5`，分支 `gap-certificate` = `e5b4ded`，附注 tag
> `gap-v0.1.2` 指向 `c73fce1`，工作树干净；远端 `mine` 已推送到 `c73fce1`（`git ls-remote` 核对，2026-11-16）。
> 线上可见性本次无法复核：匿名访问 `github.com/songminlhy/goldbach-lean` 返回 404，`git ls-remote` 被本机代理阻断。
> 2.1 / 2.2 若已执行过，可跳过，直接从 2.3 开始。

### 2.1 本地提交

```powershell
# 先设一个真实身份（当前仓库没有 user.name / user.email）
git config --global user.name  "<你的名字>"
git config --global user.email "<你的邮箱>"

cd C:\Users\宋敏\Documents\trae_projects\DSH_MM\goldbach\frontier\goldbach-lean

# 当前是浅克隆；推到新 fork 前先补全历史，否则父提交对象可能缺失
git fetch --unshallow origin

git checkout -b gap-certificate

git add Goldbach/Gap.lean Goldbach/GapChecks.lean Goldbach/GapLiveChecks.lean docs/GAP.md
git add MathlibNt/SieveTheory/LiLiuGoldbachG12FlexibleWF.lean scripts/check.py

git commit -m "feat(gap): machine-checked 1+1 gap and circularity certificate for arXiv:2611.09007v1"
git tag -a gap-v0.1.2 -m "gap certificate v0.1.2"
```

### 2.2 fork 并推送

在 GitHub 上 fork `subfish-zhou/goldbach-lean` 到你的账号，然后：

```powershell
git remote add mine https://github.com/<你的用户名>/goldbach-lean.git
git push -u mine gap-certificate --tags
```

**不要**直接推到上游 `origin`。**不要**把 1806 个模块整棵树提交进去；上游已有，只推这 4 个新文件 + 2 个补丁。

### 2.3 GitHub Release

在**你的 fork** 上，用 tag `gap-v0.1.2` 建一个 Release，标题用：

```text
gap-v0.1.2 — the 1+1 gap, machine-checked
```

说明文字可以直接用 `SOCIAL.md` 第 4 节。把第 4 节生成的 release 归档作为附件上传（可选，但推荐）。

---

## 3. 拿到 DOI（G4，GitHub 路线）

1. 在 Zenodo 里启用对该仓库的归档（GitHub 集成），或手动 New upload；
2. 用 `gap-v0.1.2` 建 GitHub Release 后，Zenodo 会归档并给出 DOI（形如 `10.5281/zenodo.XXXXXXX`）；
3. 把 DOI 记录到：

```text
goldbach/priority/DOI.txt
```

并在 `ANNOUNCE.zh.md` / `ANNOUNCE.en.md` / 两篇文章 / `SOCIAL.md` 里替换 `{{DOI}}`。

> **一个小的元数据修正**：`CHECKLIST.md` 说“把 DOI 填进 `IDENTITY.json` 的 `repository_code`”。`repository_code` 在 `CITATION.cff` 里对应 `repository-code`，语义是**仓库 URL**，不是 DOI。建议：
> - `repository_code` = `https://github.com/<你的用户名>/goldbach-lean`
> - DOI = `priority/DOI.txt` + 文章/社交文案
>
> 这样 `CITATION.cff` 不会被塞进一个语义不对的值。

### 3.1 最终封存（带 DOI）

```powershell
cd C:\Users\宋敏\Documents\trae_projects\DSH_MM\goldbach
# 把 priority/DOI.txt 加进 files.txt 的 this package 段
python priority\tools\build-metadata.py
powershell -NoProfile -ExecutionPolicy Bypass -File priority\tools\seal.ps1
```

这是**最终封存版**：署名、DOI、文章、manifest 都在里面。

---

## 4. 备选路线：不走 GitHub，直接上传 Zenodo

如果暂时不想 fork / push，可以直接把归档上传 Zenodo，同样拿 DOI，只是没有 GitHub tag 的关联。

### 4.1 生成归档

```powershell
cd C:\Users\宋敏\Documents\trae_projects\DSH_MM\goldbach\priority\postseal
powershell -NoProfile -ExecutionPolicy Bypass -File tools\make-release.ps1 -Version 0.1.2 -Final
```

输出：

```text
release/gap-v0.1.2.tar.gz
release/gap-v0.1.2.tar.gz.sha256
```

`-Final` 只要求署名已填、生成元数据无 `<FILL: ...>`；**不要求** `DOI.txt` 已存在——因为 Zenodo 直传路线是“先上传、后拿 DOI”。拿到 DOI 后，把 DOI 写进 `priority/DOI.txt`，再跑一次 `-Final`，就得到带 DOI 的 version-of-record；需要的话作为新版本上传。

归档保留原始 `goldbach/` 目录结构，所以解压后可以直接：

```bash
sha256sum -c priority/MANIFEST.sha256
```

### 4.2 Zenodo 手动上传

1. New upload → 选 `gap-v0.1.2.tar.gz`；
2. Upload type: **Software**；Title / Description / Keywords / License 用 `priority/zenodo.json` 里的字段；
3. Related identifiers：
   - `arXiv:2611.09007` → `references`
   - `https://github.com/subfish-zhou/goldbach-lean` → `isSupplementTo`
4. Publish → 得到 DOI；
5. 回到本文第 3 步，填 DOI、最终封存。

> 直接上传的版本没有“GitHub tag”这一层锚，但 DOI 本身是独立、可引用、带时间戳的。两条路线可以以后合并：先用 Zenodo DOI 占住，再把 GitHub 仓库关联到同一个 Zenodo 记录（新建 version）。

---

## 5. 发布顺序（不可颠倒）

```text
内核复核 → 最终封存 → GitHub 仓库 + tag（或 Zenodo 归档）→ DOI
        → 通知原作者 → 中文长文 → 英文短帖 → 社交媒体
```

**不要**在 DOI 之前发社交媒体：那样你只有“我说过”，没有可引用的版本。

### 5.1 通知原作者（G6，礼数，不是请示）

在 DOI 生效后、公开批评前，给通讯作者发一封短信：

- 附 DOI 和论文链接（注明针对 **v1**）；
- 指出第 111 行的 `O` 定义、第 180 行开头把 `G(2n)` 列为“可以假设”的表述，以及同一段的 `G(2n-2) > 0` 输入；
- 说明第 111 行引文与 `PaperTheorem` 的对应关系，欢迎指出误读；
- 不要用“我们证明你错了”的语气；用“我们可能读错，请指正”的语气。

这既降低对抗，也留下“我们先私下沟通过”的记录。

### 5.2 中文长文 → 英文短帖 → 社交媒体

用：

- `postseal/ARTICLE.zh.md`（长文）
- `postseal/ARTICLE.en.md`（英文版）
- `postseal/SOCIAL.md`（短帖）

发布前把 `{{REPO_URL}}`、`{{DOI}}`、`{{AUTHOR}}`、`{{DATE}}`、`{{ARTICLE_URL}}` 全部替换。

---

## 6. 发布前最后一遍“禁句”扫描

先扫描**将要发布的三份正文**：

```powershell
$files = @(
  'priority\ANNOUNCE.zh.md',
  'priority\ANNOUNCE.en.md',
  'priority\postseal\ARTICLE.zh.md',
  'priority\postseal\ARTICLE.en.md'
)
Select-String -Path $files -Pattern '证明了哥德巴赫|世界首个|已内核复核|proves Goldbach|first ever' |
  Select-Object Path, LineNumber, Line
```

预期：**命中的只应该是“不要写”表格里的反例**；正文断言为零。人工看一遍每条命中，按 `CLAIM.md` 的 N1–N6 处理。

注意：`CLAIM.md`、`CHECKLIST.md`、`PRIOR_ART.md`、`SOCIAL.md` 本身包含“禁止说法”的示例，扫描它们必然命中；这不是问题，但不要把这些示例当成正文。

同时检查占位符：

```powershell
Select-String -Path $files -Pattern '<FILL:|\{\{'
```

预期：发布正文里没有；`PUBLISH.md` 作为操作手册可以保留模板占位符。`SOCIAL.md` 里的 `{{...}}` 也要在发帖前替换。

---

## 7. 事故预案（摘要）

| 情况 | 应对 |
|---|---|
| 发现更早的同类形式化 | 在 README 顶部加 “Prior work” 引用；改“据我们所知”的措辞。**事实不变，措辞变。** |
| 作者反驳“你读错了 O 的定义” | 贴第 111 行原文 + 源文件哈希；请对方给出具体行号。若 v2 改定义，注明“针对 v1”。 |
| 有人说“1+2 弱于 1+1 是常识” | 同意。把重点移到 C2：该论文的定理 1.1 在其自身定义下已蕴含 1+1。 |
| 有人质疑“AI 生成的证明” | 指向 `leanchecker` 日志、公理集、`VERIFY.md` 的三条命令。内核不看作者是谁。 |
| 有人抢先发了同样的评论 | 不争执。引用对方 + 指出本包的独立时间戳与 DOI，让记录自己说话。 |

---

## 8. 我现在已经做完 / 还没做的事

**已经做完（可复核）**

- 封存包完整性复核：68/68 哈希 OK，RFC 3161 `Verification: OK`；
- 论文 v1 源码逐字节核对：本地 tex 与 arXiv v1 源一致，SHA-256 `db1fa071...`；
- 8 条定理内核重放通过（日志 `logs/reverify_2026-11-15.log`）；
- 中文长文、英文长文、社交短帖、发布手册；
- 可上传 Zenodo 的 release 归档生成脚本（第 4 节）。

**只有你能做**

- 填真实署名（`IDENTITY.json`）；
- 设 git 身份、fork、push、建 Release；
- Zenodo 上传与 DOI；
- 给作者发邮件；
- 最终点击“发布”。

**我没有做、也不应该替你做**

- 没有 push 任何东西；
- 没有创建 DOI；
- 没有给作者发邮件；
- 没有在社交媒体发布任何内容。
