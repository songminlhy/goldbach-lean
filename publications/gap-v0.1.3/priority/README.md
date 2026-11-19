# 优先权存证包（Priority / Originality Pack）

**对象**：`Goldbach.Gap` 形式化 + 对 arXiv:2611.09007v1 的核验（本工作区 2026-11-15 的产物）
**目的**：在**公开发布之前**先把"谁、在什么时候、做出了什么、证据在哪"固定下来，
使得日后无论谁先发声，都有一份**时间点不可回填、内容可独立复核**的记录。
**状态**：已封存（RFC 3161 时间戳）。**尚未对外发布任何内容。**

---

## 一、先说清楚这个包能做什么、不能做什么

| 它能做到 | 它做不到 |
|---|---|
| 证明"这些字节在 T 时刻已经存在"（TSA 签名 + 哈希） | 证明"世界上没有别人更早想到" |
| 把可声明的结论逐条钉死到 Lean 定理 / 日志行号 | 证明"首创"（需要穷尽检索，见 `PRIOR_ART.md`） |
| 让第三方用三条命令独立复核 | 替你完成公开发布（发布是不可撤销的外部动作） |

> **一句话**：时间戳只买"时间点"，优先权仍然来自**尽早公开**（DOI / arXiv / 带 tag 的仓库）。
> 这个包的作用是让"公开"这一步可以在 24 小时内完成，并且公开时说的话**不夸大、可复核、赖不掉**。

---

## 二、三句话结论

1. **可声明**：在 Lean 4 + Mathlib 中，Chen 1+2、Li–Liu 1+1.9、Wu 1+1.8938 三个头条端点
   都是 `BinaryGoldbach` 的逻辑推论（1+1 是它们的特例）；并且按论文**自己的** `O` 定义，
   arXiv:2611.09007v1 的定理 1.1 已经蕴含 1+1——第 180 行把当前情形 `G(2n)` 列入归纳假设，
   构成循环；同一句把 `G(2n-2) > 0` 当作输入，在字面定义下已预设结论的正性，
   在标准读法下则失去依据。
2. **不可声明**：哥德巴赫猜想没有被证明（本项目没有任何一条以 `BinaryGoldbach` 为结论的
   无条件定理）；也没有证明"端点推不出 1+1"（那需要元数学论证）。
3. **不可声明**："世界首创"。见 `PRIOR_ART.md`：检索只能说明"没找到"，不能说明"不存在"。

---

## 三、包里有什么

```
goldbach/priority/
├─ README.md              本文件：总览与边界
├─ CLAIM.md               可声明 / 不可声明清单（逐条对应证据与行号）
├─ PRIOR_ART.md           检索记录、相关项目、措辞红线
├─ VERIFY.md              第三方复核步骤（哈希 / 时间戳 / Lean 内核）
├─ CHECKLIST.md           官宣门禁：从"现在"到"发出去"的逐条动作
├─ ANNOUNCE.zh.md         中文发布稿（可直接改后发）
├─ ANNOUNCE.en.md         English announcement
├─ AUTHORS.md             署名、贡献边界、上游归属、许可
├─ IDENTITY.json          署名信息（**唯一**需要你填的文件）
├─ CITATION.cff           引用元数据（由 IDENTITY.json 生成）
├─ zenodo.json            Zenodo 元数据（由 IDENTITY.json 生成）
├─ files.txt              被存证文件清单（manifest 的唯一来源）
├─ MANIFEST.sha256        文件哈希清单（**被时间戳签名的对象**）
├─ MANIFEST.tsq/.tsr      RFC 3161 请求与令牌
├─ MANIFEST.tsr.txt      令牌的可读文本（含时间、TSA、策略）
├─ TIMESTAMP.md           本次封存记录（时间、算法、验证结果）
├─ tsa/                   固定下来的 TSA 证书链（离线可验）
├─ tools/seal.ps1         重新封存：重算哈希 → 取时间戳 → 验证
└─ tools/build-metadata.py IDENTITY.json → CITATION.cff / zenodo.json
```

---

## 四、已经发生的事实（时间线）

| 时间（+08:00） | 事件 | 证据 |
|---|---|---|
| 2026-11-06 13:39 UTC | arXiv:2611.09007v1 提交（Qazaqzeh & Rawashdeh） | arXiv abs 页 |
| 2026-11-15 14:37 | 数值审计跑完（式 (1)(2) 差一、比值非恒定） | `audit/audit_run.log` |
| 2026-11-15 15:31–16:14 | `Gap.lean` / `GapChecks.lean` / `GapLiveChecks.lean` 写完并内核复核 | `logs/audit_*_rerun.log` |
| 2026-11-15 16:15 | 审计与进展报告定稿 | `AUDIT_2026-11-15.md`、`PROGRESS_2026-11-15.md` |
| 2026-11-15 16:33 | 本包生成并加 RFC 3161 时间戳（FreeTSA，`Verification: OK`） | `TIMESTAMP.md` |
| 2026-11-16 02:11 UTC | 重新封存：发布面里的中文署名改为 ASCII（宋敏 → Song Min），使仓库自带静态检查 `issues` 归零；数学与证据内容未变，上一版令牌存于 `priority/archive/pre_reseal_20261116/` | `TIMESTAMP.md` |

---

## 五、三条命令自检

```powershell
# 1) 哈希：在 goldbach/ 下
cd goldbach
sha256sum -c priority/MANIFEST.sha256      # Windows 无 sha256sum 时见 VERIFY.md 的 PowerShell 版

# 2) 时间戳：验证令牌确实签的是上面这份 manifest
openssl ts -verify -data priority/MANIFEST.sha256 `
  -in priority/MANIFEST.tsr `
  -CAfile priority/tsa/cacert.pem -untrusted priority/tsa/tsa.crt

# 3) 内核：复核 8 条定理（需要本机 Lean 工具链，约 30 秒）
python frontier/kernel_verify.py --checks Goldbach/GapChecks.lean `
  --target Goldbach.Gap --log ../logs/audit_gap_check_rerun.log
```

任何一步失败，说明包被改动过或环境不符——**先查清楚，再谈发布**。

---

## 六、下一步

按 `CHECKLIST.md` 走。最短路径：

1. 填 `IDENTITY.json`（署名、ORCID、GitHub）→ 跑 `tools/build-metadata.py`；
2. 重跑 `tools/seal.ps1` 重新封存（换掉占位署名后的最终版）：
   `powershell -NoProfile -ExecutionPolicy Bypass -File priority\tools\seal.ps1`；
3. 把 `files.txt` 里的 Lean 文件 + `docs/GAP.md` 提交到一个**你自己的**公开 fork/仓库并打 tag；
4. Zenodo 关联该 tag 取 DOI（不可变、可引用、时间戳独立）；
5. 再发 `ANNOUNCE.*`（顺序很重要：DOI 先于社交媒体）。

**不要**在 DOI 之前发社交媒体：那样你只有"我说过"，没有"可引用的版本"。
