# 发布记录与步骤（Liouville 奇偶性包 v0.3.1）

本文件记录发布前的状态与执行步骤；发布后的实际 id（Release、资产、Zenodo 记录 URL）以 GitHub 与 Zenodo 页面为准。

> v1 从未封存或发布；v0.2.0 是首个公开版本（GitHub Release 已转为 draft）；v0.3.0 是第二个公开版本；v0.3.1 是第三个公开版本，只增量加入 `IntervalLemma.lean`（103$\to$104 文件，28$\to$29 页），v0.3.0 保持原样可复核。

## 0. 发布前状态

- 论文：`paper_boundary/paper.pdf`，29 页，`Author: 宋敏, 宋瑷成, 宋奥菲, 范钧睿, 胡安, 涂源`。
- 数值：`check_boundary.py` 到 \(5\times10^6\)，0 失败（与 v0.3.0 相同，未改脚本与结果）。
- Lean：`GapCertificate.lean`、`LiouvilleAudit.lean`、`IntervalLemma.lean` 均 rc 0；公理集为三条标准公理；上游 9 模块重建 2851 任务。
- GitHub：分支 `lg-audit`，commit `51eabc1bb9cd23ce9394d50f81ad431aa8c4e93f`（父提交 `de957b9170e86f35a86443254f8ccd10aca50e58`，即 `lg-v0.3.0`）；注解标签 `lg-v0.3.1`（tag object `b1c45824dfe4e8060021978864b4b312d5ab5db1`）。
- Zenodo：由已发布记录 `24306341`（v0.3.0）派生新版本；草稿 id `24309847`，预留 DOI `10.5281/zenodo.24309847`，concept DOI 仍为 `10.5281/zenodo.24302031`。

## 1. 封印（必须最后做）

顺序：先把 `files.txt` 列出的每个文件定稿 → `py tools/build-metadata.py`（若署名/版本变动）→ `tools/seal.ps1`。

```powershell
cd C:\Users\宋敏\Documents\trae_projects\DSH_MM\goldbach\liouville_priority
py tools\build-metadata.py
powershell -NoProfile -ExecutionPolicy Bypass -File tools\seal.ps1
```

期望：

- `manifest: 104 files, sha256=...`（v0.3.0 为 103）；
- `timestamp: status=Granted genTime=... verify=OK`；
- `TIMESTAMP.md` 记录封存 UTC、清单哈希、令牌哈希、文件数；
- 在 `goldbach/` 下 `sha256sum -c liouville_priority/MANIFEST.sha256` 全绿。

## 2. 归档

归档不在 `files.txt` 内（归档包含清单，纳入会形成循环）。归档哈希单独发布。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File postseal\tools\make-release.ps1 -Version 0.3.1
```

产物：

- `postseal/release/lg-v0.3.1-draft.tar.gz` + `.sha256`（自足全包，104 文件 + 5 个封印文件）；
- `postseal/release/lg-v0.3.1-circulation-20261117.zip` + `.sha256`（审阅本，17 文件）；
- `postseal/release/lg-v0.3.1-history-20261117.zip` + `.sha256`（背景快照，66 文件）。

## 3. GitHub Release

用 API（本机 `git push` 因 schannel/OpenSSL 握手失败不可用；tag 与分支由 Git Data API 创建）：

1. `POST /repos/songminlhy/goldbach-lean/releases`，`tag_name=lg-v0.3.1`，`name=lg-v0.3.1 — Liouville–Goldbach: complete proof and the logical boundary with Goldbach`，正文取 `RELEASE-NOTES.md`，`draft=true`（延续 v0.2.0/v0.3.0 的审阅门）。
2. 上传资产：`POST https://uploads.github.com/repos/songminlhy/goldbach-lean/releases/{id}/assets?name=lg-v0.3.1-draft.tar.gz`（`Content-Type: application/gzip`），以及三个 `.sha256`（`text/plain`）。
3. 读回：`GET /repos/.../releases/{id}`，核对 `draft=true`、资产大小与 digest。

## 4. Zenodo

1. `POST /api/deposit/depositions/24306341/actions/newversion` 派生新版本；草稿为 `24309847`，预留 DOI 已写入 `DOI.txt`。
2. `PUT /api/deposit/depositions/24309847` 写入 `zenodo.json` 生成的元数据（`version=0.3.1`、`publication_date=2026-11-17`、`related_identifiers` 指向 `lg-v0.3.1`）。
3. **删除**新版本草稿自动继承的 6 个 v0.3.0 文件（`DELETE /api/deposit/depositions/24309847/files/{file_id}`），避免记录里混入旧归档。
4. 用 legacy multipart `POST /api/deposit/depositions/24309847/files` 逐个上传 6 个 v0.3.1 文件（三个归档 + 三个 `.sha256`；bucket `PUT` 在本环境曾静默失败）。
5. `POST /api/deposit/depositions/24309847/actions/publish`。
6. 读回 `GET /api/records/24309847`：`state=published`、DOI `10.5281/zenodo.24309847`、6 个文件、大小与 md5 匹配本地。

## 5. 发布顺序（不可颠倒）

```text
论文/数值/Lean 复核 → 定稿所有 files.txt 文件 → build-metadata → seal.ps1
→ 归档（draft/circulation/history） → GitHub tag + Release + 资产
→ Zenodo 元数据 + 文件替换 + publish → 读回 DOI/记录 → 通报
```

不要在封印前改 `files.txt` 里的任何文件；不要在 DOI 生效前发布社交媒体。

## 6. 验收

- `sha256sum -c liouville_priority/MANIFEST.sha256`：104/104 OK，0 FAILED；
- `openssl ts -verify ...`：`Verification: OK`；
- `pdfinfo`：29 页、六位作者；
- `check_boundary.py`：`passed: true`、0 失败；
- `lake env lean` 三个模块：rc 0；
- GitHub Release：`draft=true`，资产大小/摘要匹配；
- Zenodo：`published`，DOI 与文件哈希匹配，且不含任何 `lg-v0.3.0-*` 文件。

## 7. 已知限制

- Lean 复核是非 clean-room 的源码级重建，复用 Mathlib 产物；归档不含 `.lake` 缓存。
- 出版版 Mangerel 全文未取得，只核对到 Crossref 摘要。
- 归档哈希不在封印清单内；它们由 `.sha256` 文件与发布页单独给出。
- v0.3.0 的清单、标签与 DOI 不随 v0.3.1 改变；本包不重新封存 v0.3.0。
