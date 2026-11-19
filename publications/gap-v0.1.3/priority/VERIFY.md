# 第三方复核（Verify in three steps）

本包的全部证据都可以在**不信任作者**的前提下复核。三层证据互相独立：

1. **哈希**：文件有没有被改过；
2. **时间戳**：这份 manifest 在什么时刻已经存在；
3. **内核**：Lean 定理是不是真的成立。

> 三层都通过，才构成"在 T 时刻已经做出了这些可复核的东西"。
> 单独任何一层都不够。

---

## 第 1 步：哈希（约 5 秒）

在 `goldbach/` 目录下（manifest 里的路径以 `goldbach/` 为根）：

```bash
sha256sum -c priority/MANIFEST.sha256
```

Windows 没有 `sha256sum` 时（Git for Windows 自带，位于 `C:\Program Files\Git\usr\bin\sha256sum.exe`）：

```powershell
cd goldbach
Get-Content priority\MANIFEST.sha256 | Where-Object { $_ -match '^[0-9a-f]{64}  ' } | ForEach-Object {
  $h, $p = $_ -split '  ', 2
  $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash.ToLower()
  if ($actual -ne $h) { "MISMATCH $p" } else { "OK       $p" }
}
```

**预期**：被 `#` 注释掉的标题行之外，全部 `OK`。任何 `MISMATCH` 说明文件被改动过——
此时时间戳仍然有效（它签的是 manifest），但"文件 = 被签名内容"的链断了，需要说明改动原因。

## 第 2 步：时间戳（约 3 秒）

`MANIFEST.tsr` 是 FreeTSA 对 `MANIFEST.sha256` 的 RFC 3161 签名回执。
证书链已固定在 `tsa/` 下，**不需要联网**：

```bash
openssl ts -verify \
  -data   priority/MANIFEST.sha256 \
  -in     priority/MANIFEST.tsr \
  -CAfile priority/tsa/cacert.pem \
  -untrusted priority/tsa/tsa.crt
```

**预期**：`Verification: OK`。

可读版本（含签名时间、TSA、策略 OID）：

```bash
openssl ts -reply -in priority/MANIFEST.tsr -text
# 或直接看 priority/MANIFEST.tsr.txt
```

> 说明：TSA 只能证明"某时刻这份哈希存在"。它不证明内容为真，也不证明作者是谁——
> 作者身份靠 `AUTHORS.md` / `IDENTITY.json` 与后续的 DOI/仓库账号绑定。

## 第 3 步：Lean 内核（约 30 秒，需要本机 Lean 4.33.0-rc1）

```bat
set ELAN_HOME=<repo>\.elan
set PATH=%ELAN_HOME%\bin;%PATH%
cd goldbach\frontier
python kernel_verify.py --checks Goldbach\GapChecks.lean ^
    --target Goldbach.Gap --log ..\logs\audit_gap_check_rerun.log
```

> 若 `python` 不在 PATH（Windows 应用商店别名常见），把上面的 `python` 换成 `py`。

**预期**（与 `logs/audit_gap_check_rerun.log` 一致）：

```text
8 条定理的 #print axioms 均 ⊆ {propext, Classical.choice, Quot.sound}
AXIOM SUMMARY ... expected subset: ['Classical.choice', 'Quot.sound', 'propext']
$ leanchecker.exe Goldbach.Gap
[exit=0 ...]
RESULT: PASS
```

活端点定义相等检查（需要 Li–Liu 闭包，约 3 分钟首次）：

```bat
python build_local.py --target Goldbach.OnePlusOneNine --workers 4 --lean-threads 1
python build_local.py --target Goldbach.GapLiveChecks --workers 4 --lean-threads 1
python kernel_verify.py --checks Goldbach\GapLiveChecks.lean ^
    --target Goldbach.GapLiveChecks --log ..\logs\audit_live_shape_check.log
```

---

## 常见问题

**日志里的中文路径是乱码？** 不是。日志由 Windows 控制台以 GBK 解码 UTF-8 路径产生
（`瀹嬫晱` = `宋敏`），只影响显示，不影响哈希与结论。

**为什么 `Gap.lean` 只依赖 `Goldbach.Statement`？** 为了让 C1–C4 的复核不依赖 1806 个模块的
大筛法工程——核心结论必须能被单独重放。

**`lake build` 直接跑行不行？** 不建议全量。本工作区的 `.olean` 有一部分由
`build_local.py` 直接调用 `lean -o` 产出，lake 没有它们的 trace，全量构建可能触发上万任务重建。
按本文件第 3 步走。

**时间戳过期/TSA 不可信怎么办？** 可以重跑 `tools/seal.ps1` 生成新的令牌（旧令牌不失效）；
也可以叠加 OpenTimestamps（`ots stamp priority/MANIFEST.sha256`）得到比特币锚定。
