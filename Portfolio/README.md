# 策划案之外 · Portfolio Deploy

这个目录是作品集网站的公开发布源。

## 日常更新流程

1. 在 `Reforge_Obsidian/` 中修改文档。
2. 提交并推送到 GitHub。
3. GitHub Actions 会自动：
   - 按白名单同步 Obsidian 文档到 Quartz content。
   - 生成首页关系图 `graph-data.js`。
   - 构建 Quartz 文档站。
   - 把主页、资源和文档站发布到 GitHub Pages。

## 本地构建

```bash
bash Portfolio/scripts/build.sh
```

构建结果会生成到：

```text
Portfolio/dist/
```

`Portfolio/dist/` 是生成物，不提交到仓库。

## 文档公开范围

公开文档由 `Portfolio/scripts/sync-docs.sh` 中的 `WHITELIST` 控制。新增可公开文档时，在白名单里加文件名即可。
