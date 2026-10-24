# GoGo Trip uni-app

Vue 3 + TypeScript + uni-app 实现，可通过 HBuilderX 运行到 App、H5 和微信小程序。

## HBuilderX 启动

1. 安装 HBuilderX，并安装 uni-app（Vue3）编译器。
2. 使用 HBuilderX 打开本目录 `F:\myProjects\gogo-trip\uni-app`。
3. 选择“运行 → 运行到浏览器”启动 H5。
4. 选择“运行 → 运行到小程序模拟器 → 微信开发者工具”启动微信小程序。
5. 微信真机预览前，在 `src/manifest.json` 的 `mp-weixin.appid` 填写真实 AppID。

## CLI 验证

```bash
npm install
npm run dev:h5
npm run build:mp-weixin
```

假数据位于 `src/data/mock-data.ts`，状态与数据操作位于 `src/store/travel.ts`。后续接入 Supabase 时替换 store/repository，不改页面路由。
