# 官宣门禁清单（Go-public checklist）

目标：**在 72 小时内**把"可引用、可复核、不可篡改"的版本放出去，而不是先发一条微博。
顺序错了就只剩"我说过"。

---

## 第 0 步：已经做好的（本包）

- [x] 8 条定理内核复核，日志落盘（`logs/audit_*_rerun.log`）
- [x] 声明/非声明逐条绑定证据（`CLAIM.md`）
- [x] 检索记录与措辞红线（`PRIOR_ART.md`）
- [x] 哈希清单 + RFC 3161 时间戳（`MANIFEST.sha256` / `MANIFEST.tsr`）
- [x] 中英文发布稿（`ANNOUNCE.*.md`）
- [x] 复核手册（`VERIFY.md`）

---

## G1｜署名（10 分钟，**阻塞后续全部步骤**）

1. 编辑 `IDENTITY.json`：`given_name`、`family_name`、`orcid`、`email`、`github`、`repository_code`；
2. `python priority/tools/build-metadata.py`（生成 `CITATION.cff`、`zenodo.json`）；
3. `powershell -NoProfile -ExecutionPolicy Bypass -File priority\tools\seal.ps1`
   （重新封存，替换掉占位署名的那一版）。

> `IDENTITY.json` 是唯一的署名来源。**不要**手改 `CITATION.cff` / `zenodo.json`。

## G2｜把新增文件放进**你自己的**公开仓库（30 分钟）

当前状态：`goldbach/frontier/goldbach-lean` 是 `subfish-zhou/goldbach-lean` 的浅克隆，
`main` 停在 `9d4c3a4`（2026-10-28），本工作**全部未提交**。

```powershell
# 0) 先设一个真实身份（当前 git 没有配置 user.name / user.email）
git config --global user.name  "<你的名字>"
git config --global user.email "<你的邮箱>"

cd goldbach\frontier\goldbach-lean
git checkout -b gap-certificate
git add Goldbach/Gap.lean Goldbach/GapChecks.lean Goldbach/GapLiveChecks.lean docs/GAP.md
git add MathlibNt/SieveTheory/LiLiuGoldbachG12FlexibleWF.lean scripts/check.py
git commit -m "feat(gap): machine-checked 1+1 gap and circularity certificate for arXiv:2611.09007v1"
git tag -a gap-v0.1.0 -m "gap certificate v0.1.0"
```

然后把 `gap-certificate` 推到**你 fork 出来的仓库**（不要直接推上游 `main`）：

```powershell
git remote add mine https://github.com/<你的用户名>/goldbach-lean.git
git push -u mine gap-certificate --tags
```

> 可选：之后向上游发 PR。PR 是公开动作，等于立即官宣——把它排在 DOI 之后。
> **不要**把 1806 个模块整棵树提交进去；上游已有，只需 4 个新文件 + 2 个补丁。

## G3｜许可头（可选，5 分钟）

新增的 3 个 `.lean` 文件目前没有 Apache 头。若要加，**先加再重新封存并重跑内核复核**
（加注释不改证明，但会改哈希，旧 manifest 随即失效）：

```lean
/-
Copyright (c) 2026 <作者>. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
```

## G4｜拿到 DOI（20 分钟）

1. GitHub 仓库 → Settings → Webhooks/Zenodo 集成（或手动在 Zenodo 里 New upload → 关联 GitHub）；
2. 建一个 **GitHub Release**，tag 用 `gap-v0.1.0`；
3. Zenodo 自动归档并给出 DOI（形如 `10.5281/zenodo.XXXXXXX`）；
4. 把 DOI 填进 `ANNOUNCE.*.md` 的 `{{DOI}}`、`IDENTITY.json` 的 `repository_code`，
   再跑一次 `build-metadata.py` + `seal.ps1`（这是**最终封存版**）。

> DOI 的价值：不可变、可引用、带独立时间戳、别人抢不走。
> 这比任何"我先说的"都硬。

## G5｜arXiv（可选，1–3 天，可能被拒）

- 类别：`math.NT`（主）；交叉 `cs.LO`。
- 标题建议：*The 1+1 Gap, Machine-Checked: Endpoint Implications and a Circularity Certificate
  for arXiv:2611.09007v1*。
- 风险：对具体预印本的评论可能被认为"不是研究论文"而被 moderater 拒。**拒了不影响 G4**，
  DOI 已经生效。
- 需要 endorsement 的话，先找一位有 arXiv 权限的合作者；不要临时抱佛脚。

## G6｜通知原作者（与 G5 同日，**礼数，不是请示**）

在 DOI 生效后、公开批评前，给通讯作者发一封短信：附 DOI、说明针对 **v1**、
指出第 111 行定义与第 180 行归纳假设、邀请对方指出误读。
这既降低对抗，也留下"我们先私下沟通过"的记录。

## G7｜发布顺序（不可颠倒）

```
内核复核 → 封存 → GitHub 仓库 + tag → Zenodo DOI → 通知作者 → 中文长文 → 社交媒体
```

**不要**反过来。先发社交媒体再补 DOI，等于把优先权交给"谁先截图"。

---

## 时间线

| 时间 | 动作 |
|---|---|
| T+0 | 填 `IDENTITY.json`，`build-metadata.py`，`seal.ps1` |
| T+1h | fork + push + tag + GitHub Release |
| T+2h | Zenodo DOI 到手，回填 DOI，最终封存 |
| T+3h | 邮件通知原作者；中文长文排版 |
| T+24h | 发中文长文 + 英文短帖，附 DOI 与复核命令 |
| T+72h | 检查反馈；若有人指出更早工作，按下面的预案改措辞 |

---

## 事故预案

| 情况 | 应对 |
|---|---|
| 发现更早的同类形式化 | 在 README 顶部加"Prior work"引用它，改"据我们所知"的措辞。**事实不变，措辞变。** |
| 作者反驳"你读错了 O 的定义" | 贴第 111 行原文 + `Gap.lean:161` 的逐字转写，请对方给出他们认为正确的行号。若对方发 v2 改定义，注明"针对 v1"。 |
| 有人说"1+2 弱于 1+1 是常识" | 同意。把重点移到 C2（该论文的定理蕴含 1+1），C1 只是把常识变成可查对象。 |
| 有人质疑"AI 生成的证明" | 指向 `leanchecker` 日志、公理集、`VERIFY.md` 的三条命令。内核不看作者是谁。 |
| 有人抢先发了同样的评论 | 不争执。引用对方 + 指出本包的独立时间戳与 DOI，让记录自己说话。 |

---

## 绝对不要做

- ❌ 说"证明了哥德巴赫猜想"（`CLAIM.md` N1）
- ❌ 说"世界首个"（N2）
- ❌ 把 Wu 端点写成"已内核复核"（N4）
- ❌ 把上游 1806 个模块的功劳算到自己头上（N5）
- ❌ 在 DOI 之前发社交媒体
- ❌ 在没有重跑复核的情况下改 `.lean` 文件后继续用旧日志
