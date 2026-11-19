# 封存与重封记录

本页记录 `priority/` 证据包的 **四次** RFC 3161 封存，供复核者把令牌、manifest 与文件版本对上。现行有效的是第四次（2026-11-16 22:57:24 UTC，见文末）。

## 前两次封存

| | 第一次 | 第二次（现行） |
|---|---|---|
| 封存时间（UTC） | 2026-11-15 15:59:25 | 2026-11-16 02:12:04 |
| manifest SHA-256 | `5920890003ab3cfa97190780555a53b5f04d70c0e3d10508b34fbf2089b172e3` | `8b7a1e1a9cbe6732bda6dbe0e84925cfe9b5974645d9daec6751bb4d1ea94a75` |
| 令牌 SHA-256 | `bd8e81f6a130090c6d43319cafe225057733aeee13b6099df6e04dca5725381e` | `ca37a16b36ac3d1c72209a31ab4b5feba195c5fa8a8daf095be7d4bf91815259` |
| token genTime | `Nov 15 15:59:25 2026 GMT` | `Nov 16 02:12:06 2026 GMT` |
| 令牌与 manifest 位置 | `priority/archive/pre_reseal_20261116/` | `priority/` |

两个令牌都离线可验（证书链固定在本包 `tsa/` 下）：

```bash
openssl ts -verify -data  <MANIFEST.sha256 路径> \
  -in <MANIFEST.tsr 路径> \
  -CAfile priority/tsa/cacert.pem -untrusted priority/tsa/tsa.crt
```

预期 `Verification: OK`。**令牌只对它自己那份 manifest 有效**，两份不能交叉配对。

## 为什么重封

第一次封存之后，复核发现仓库自带的发布面检查通不过：

```text
py scripts/check.py --static-only
→ CHECK FAILED: release source checks failed
   issues: untranslated CJK text: scripts/check.py
           untranslated CJK text: MathlibNt/SieveTheory/LiLiuGoldbachG12FlexibleWF.lean
           untranslated CJK text: NOTICE
           untranslated CJK text: docs/AUTHORSHIP.md
```

原因是发布面文件里写了中文署名「宋敏」。论文与长文当时写着「1806 个源模块，issues: []」，与这棵树不符——那份静态检查日志早于署名提交，之后的提交没有再跑过检查。处理方式：4 处署名改为 ASCII（`Song Min`），`AUTHORSHIP.md` 里 `git log --author=` 的示例改用提交中真实存在的邮箱，重跑检查得到 `issues: []`，然后重新封存。

## 两版之间真正变了什么

| 文件 | 变化 | 影响数学内容 |
|---|---|---|
| `scripts/check.py` | 第 2 行署名注释：中文名 → ASCII | 否 |
| `MathlibNt/SieveTheory/LiLiuGoldbachG12FlexibleWF.lean` | 第 2 行署名注释：同上 | 否 |
| `priority/README.md` | 时间线新增一行重封说明 | 否 |

其余 30 个文件两版完全相同：`Goldbach/Gap.lean`、`GapChecks.lean`、`GapLiveChecks.lean`、`docs/GAP.md`、审计与全部内核日志一字未动。

## 想核对旧版怎么办

- **旧令牌**：直接对归档里的 `MANIFEST.sha256` 验签（上面那条命令）。
- **旧 manifest 的 33 个哈希**对应 2026-11-15 的工作树；其中 30 个与当前树相同，可照常 `sha256sum -c`。
- **3 个不同的文件**：
  - `scripts/check.py`、`LiLiu…lean` 的旧字节在 git 提交 `c459cc5` 里。注意工作树是 CRLF（`LiLiu…lean` 工作树 5729 B、blob 5606 B），`git archive` 输出的是 LF，直接算哈希会对不上；要在 `core.autocrlf=true` 下 checkout 那个提交。
  - `priority/README.md` 的旧字节保存在 `postseal/release/gap-v0.1.0-draft.tar.gz` 内的 `gap-v0.1.0/priority/README.md`（哈希与旧 manifest 一致）。

## 校验要在归档里做

manifest 记录的是 Windows 工作树字节，个别文件是 CRLF。在 Linux/macOS 上 `git clone` 后直接 `sha256sum -c` 会对这些文件报不符——那不是文件被改，是换行被规范化。正确做法是在解压后的归档根目录（`goldbach/`）里校验：

```bash
cd goldbach && sha256sum -c priority/MANIFEST.sha256
```

## 第三次封存（2026-11-16 21:29:18 UTC，现行）

| field | value |
|---|---|
| 封存时间（UTC） | 2026-11-16 21:29:18 |
| manifest | `priority/MANIFEST.sha256`（60 files） |
| manifest SHA-256 | `6629a758a4ae6de6fa4a36434fd9145499aa77f3a8d32521dde7010583603b79` |
| 令牌 SHA-256 | `bc5777e4fc651905cb07ae69ae50778f348b4ee4ddb5e5e538ce035dcfe659e7` |
| token genTime | `Nov 16 21:29:20 2026 GMT` |
| 签名校验 | `Verification: OK`（FreeTSA，证书链在 `priority/tsa/`） |

**为什么第三次封存**：把这三件事的产物并入证据包，使 `postseal/` 里引用它们的地方都有可校验的字节支撑——

1. Q4 反例扫描：5 条带证书的断言（`audit/claims/*.json` + `*_results.json`）与 7 个可复算的 scanner（`audit/search/*.py`）；
2. 前序检索扩展：zbMATH / Crossref / arXiv 三源 117 条命中（`originality/prior_art_hits_20261116.jsonl`）与说明（`originality/PRIOR_ART_2026-11-16.md`）；
3. 那篇条件性证明的精读笔记（`frontier/READING_1p9.md`）。

清单从 **33 files 增加到 60 files**。新增 27 个文件全部是**追加**：前两次封存的 33 个文件字节未改（`CITATION.cff`、`zenodo.json` 由 `tools/build-metadata.py` 重新生成后哈希不变）。

**第二次封存的令牌去哪了**：`tools/seal.ps1` 会就地覆盖 `priority/MANIFEST.tsr`，所以第三次封存会顶掉第二次的令牌。第二次的令牌与它那一版 manifest 已从旧的 `gap-v0.1.1-draft.tar.gz` 取回，存放在 `priority/archive/pre_third_seal_20261116/`（`MANIFEST.sha256` = `8b7a1e1a…`、`MANIFEST.tsr` = `ca37a16b…`，用上面那条命令验签得到 `Verification: OK`）。

**这次重封之后发到哪了**（2026-11-16 21:45–21:52 UTC）：

- GitHub Release `gap-v0.1.1`：旧的两个附件已删除，换成 `gap-v0.1.1-draft.tar.gz`（2 350 010 B，GitHub 侧 `digest=sha256:03dc4cf8…`，与本地 `.sha256` 一致）与同名 `.sha256`；附件 id 分别为 `756561622`、`756561835`。
- Zenodo：第三版 `10.5281/zenodo.24293527`（concept DOI 不变，仍是 `10.5281/zenodo.24270135`），`version = 0.1.1`，单一文件 `gap-v0.1.1-draft.tar.gz` 2 350 010 B，md5 `45b4b65feb263ad71f7ea28c2527c71b` 与本地一致。

## 第四次封存（2026-11-16 23:05:07 UTC，现行）

| field | value |
|---|---|
| 封存时间（UTC） | 2026-11-16 23:05:07 |
| manifest | `priority/MANIFEST.sha256`（67 files） |
| manifest SHA-256 | `31b396e97ebb1020f9d5a67675e8556f003259eefbca2067c9354bd94ea09057` |
| 令牌 SHA-256 | `d9c36568cce2b33efa1ff2c94330f3cf32c0cdb03ef7465b4692aed28f92f835` |
| token genTime | `Nov 16 23:05:08 2026 GMT` |
| 签名校验 | `Verification: OK` |

**为什么第四次封存**：把 2026-11-17 的闭环核验论文并入证据包——`paper_closed_loop/paper.tex`、`README.md`、`make_figures.py` 与四张图（`figures/fig1_pipeline.pdf/.png`、`figures/fig2_progress.pdf/.png`），共 **7 个文件**，清单从 60 files 增加到 **67 files**。`paper.pdf` 与其他五份 PDF 一样是编译产物，不进 manifest，随归档与 circulation 包分发。

这一版的论文端变化：作者从「宋敏（独立研究者）」改为六人同序（宋敏、宋瑷成、宋奥菲、范钧睿、胡安、涂源），PDF 的 `/Author` 元数据同步为六人（`pdfinfo` 读回一致），作者贡献段保留宋敏已写明的四项工作，其余五位的角色指向 `priority/AUTHORS.md`，不虚构分工。

**一次被自己作废的封存**：第一次跑哈希（22:57:24 UTC，`96e27cc2…`）之后，论文里两处「已封存的 33 文件」字面又被改成 67，导致 `paper_closed_loop/paper.tex` 与清单不符（归档内 `sha256sum -c` 出现 1 条 FAILED）。同名清单随即在 23:05:07 UTC 重新封存为本节这一版，并把被顶掉的那一版令牌与清单存到 `priority/archive/pre_reseal_2_20261116/`（`96e27cc2…` / `c253d7dc…`，可离线验签）。教训写在 `PUBLISH.md`：**先改完所有被哈希的文件，最后再封存。**

顺带修掉一个跨多次封存一直没被发现的问题：五份 LaTeX 源把 manifest 哈希排成 8 段 `\texttt{}`，字符串级替换从未命中，PDF 里长期印着第二次封存的 `8b7a1e1a…`。这一版起五份 PDF 印的都是 `31b396e9…`，并从成品 PDF 抽文本核对过。

**这一版发到哪了**（2026-11-16 23:1x UTC）：

- GitHub Release `gap-v0.1.1`：两个附件换成 `gap-v0.1.1-draft.tar.gz`（3 261 993 B，GitHub 侧 `digest=sha256:4b9a9b83…`，与本地 `.sha256` 一致）与同名 `.sha256`；附件 id `756800925`、`756801168`。
- Zenodo：第四版 `10.5281/zenodo.24294459`（concept DOI 仍是 `10.5281/zenodo.24270135`），`version = 0.1.1`，文件 3 261 993 B，md5 `7378c8d074a9ae3a64199191dc5faa74` 与本地一致。

## 第五次封存（2026-11-16 23:56:44 UTC，现行，release 0.1.2）

| field | value |
|---|---|
| 封存时间（UTC） | 2026-11-16 23:56:44 |
| manifest | `priority/MANIFEST.sha256`（68 files） |
| manifest SHA-256 | `77df12642d7eb2210280ab09e398d101052e6158040033289074080d79ee8860` |
| 令牌 SHA-256 | `26bfee4ad63c585324459af9484a6d5407baf637f523d6515f75ceab1ed2209c` |
| token genTime | `Nov 16 23:56:45 2026 GMT` |
| 签名校验 | `Verification: OK` |

**为什么第五次封存**：版本号升到 0.1.2、英文版并入（`paper_closed_loop/paper_en.tex`，清单 67 → 68），中文版同期改了两处——作者行改为单行顿号（`宋敏、宋瑷成、宋奥菲、范钧睿、胡安、涂源`），作者贡献按分工重写（宋敏：文本审计；宋瑷成：研究设计；宋奥菲：论文写作；范钧睿：形式化；胡安、涂源：构建复核）。`IDENTITY.json` 的版本与日期同步为 0.1.2 / 2026-11-17。

**又一次顺序事故**：第六次封存（23:50:07，`38eaa9db…`）之后又改了这两份论文源码里的计数与版本字样，归档内 `sha256sum -c` 出现 2 条 FAILED，于是重封为第五节这一版；第六次令牌与清单归档在 `priority/archive/pre_reseal_3_20261116/`。

**发到哪了**（2026-11-17 00:0x UTC）：

- GitHub：annotated tag `gap-v0.1.2`（tag 对象 `f4f6c82a…`，指向 `c73fce1`；因本机 git 的 TLS 握手失败，tag 与 ref 经 GitHub API 建立），Release id `447793106`，资产 `756940474` = `gap-v0.1.2-draft.tar.gz`（3 754 968 B，`digest=sha256:5848d742…`，与本地一致）+ `756940747` = `.sha256`。
- Zenodo：第五版 `10.5281/zenodo.24295090`（concept DOI 仍为 `10.5281/zenodo.24270135`），`version = 0.1.2`，文件 3 754 968 B，md5 `0b207f1d3de15c8ccb0466d401d5879a` 与本地一致。
- 三个包：circulation 25 个文件（2 186 370 B）、history 7 个文件（651 927 B）、draft 204 个文件（3 754 968 B）。

## 第六次封存（2026-11-18 00:41:29 UTC，release 0.1.3）

| field | value |
|---|---|
| 封存时间（UTC） | 2026-11-18 00:41:29 |
| manifest | `priority/MANIFEST.sha256`（79 files） |
| manifest SHA-256 | `80467079b6827f3b20008f66332d11e143c9b990d0b97c29dcdbfb631475feff` |
| 令牌 SHA-256 | `7124e6ed1cafe4691c1c41ac7ccb92cc9eecc0dde1820473c59747b3fcbe6b9d` |
| token genTime | `Nov 18 00:41:31 2026 GMT` |
| 签名校验 | `Verification: OK` |

**为什么第六次封存**：P0 文本更正与证据清单对齐，无新增数学主张。文本更正包括：式 (1)(2) 的偏差方向改为“各差 1、方向相反”；循环证据收窄为第 180 行把当前情形 `G(2n)` 列入归纳假设，`G(2n-2) > 0` 单独列为正性读法问题。证据清单加入 `EndpointHierarchy.lean`、`EndpointHierarchyChecks.lean`、端点层级检查日志、Wu 重建的 `STATUS.json`、`closure_audit.json`、`FINAL_STATUS.json`、`AUTO_VERIFY_DONE.txt`，以及 `final_probe.log`、`final_leanchecker*.log`、`WR2ClassicalCertificate.log`；清单 68 → 79 文件。`IDENTITY.json` 的版本与日期同步为 0.1.3 / 2026-11-18。

**旧版保护**：v0.1.2 的清单与令牌归档在 `priority/archive/pre_v013_20261118/`，未被就地改写。

**DOI**：概念 DOI `10.5281/zenodo.24270135` 保持不变；v0.1.3 的版本 DOI 由 Zenodo 在上传后分配。

**发到哪了**：本地 release 归档已生成；GitHub Release 与 Zenodo 新版本仍需外部上传。本次执行环境无法访问 `github.com`，且没有 Zenodo 凭据，因此没有声称已完成上传。

## 边界

令牌证明「这些字节在某时刻已经存在」，不证明内容正确、不证明作者身份、不证明首创。优先权来自公开可引用的版本（DOI / arXiv / 带 tag 的公开仓库），见 `PRIOR_ART.md` 与 `CHECKLIST.md`。
