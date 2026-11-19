# Zenodo v2（24270169）的 `version` 字段：为什么改不了、能做什么

**日期**：2026-11-17
**结论先说**：这一项**在本机无法关闭**——不是权限问题，是 Zenodo 的规则；但可以准备好措辞，在下一次发布时把说明写进最新版。

## 一、实测到的事实

| 尝试 | 结果 |
|---|---|
| `PUT /api/deposit/depositions/24270169`（发布后改元数据） | 早前实测不可改（返回 404/405） |
| `PATCH /api/records/24270169`（新版 records API） | **405** `The method is not allowed for the requested URL.` |
| `PATCH /api/records/24295090`（当前最新版，对照组） | **405**，同上 |

两条 PATCH 是对照实验：**records API 对所有已发布记录都只读**，所以 405 不是 v2 特有的问题。已发布版本的元数据只能在 Zenodo 网页上，对**最新版本**点 Edit 修改；v2 早已被 v3/v4/v5 取代，属于历史版本，网页上也不再提供可编辑入口。

因此“把 v2 的 `version` 填成 0.1.1”**没有可行路径**，只能作为历史事实保留。

## 二、已经准备好的补救措辞（下次发新版时粘进 description）

> *Metadata note (added 2026-11-17).* The second version of this record (DOI
> 10.5281/zenodo.24270169) was published with an empty `version` field. That record is
> superseded and its metadata is frozen; the correct version label for it is `0.1.1`,
> matching the `gap-v0.1.1` release it carries.

## 三、如果将来要在网页上改最新版的元数据

1. 登录 Zenodo → 打开 <https://zenodo.org/records/24295090>（当前最新版）；
2. 右上 **Edit**；
3. 在 *Version* 输入框填 `0.1.2`（现已是 0.1.2，无需改），或在 *Description* 末尾粘上面那段；
4. **Publish**（对已发布记录的元数据编辑会立即生效，不产生新版本、不改 DOI）。

## 四、边界

- 这一步只能在浏览器里由你完成，我无法代做；`PATCH`/`PUT` 已实测被拒，不是我没试。
- v2 的空字段不影响任何 DOI 解析与文件完整性：那份记录的 manifest 与令牌仍可离线验签（见 `RELEASE-NOTES.md`）。
- 本文件不在 68 文件封存清单内，是补充记录。
