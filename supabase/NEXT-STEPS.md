# 云端登录与数据联调

## 已实现

- 邮箱密码注册、登录、会话恢复、请求前刷新令牌、退出登录。
- “我的”显示真实邮箱、用户 UUID 和 profiles；初次登录自动创建本人资料，verified 默认 false。
- “发现”从已发布 posts 读取，作者通过 posts_author_id_fkey 明确关联；收藏/取消收藏使用当前 JWT 并由 RLS 校验。
- “行程”读取当前用户的 trips → trip_days → trip_items；云端详情只读，不再跳转到假保存的编辑流程。
- 请求失败显示错误；云端空表显示空状态，不回退 mock。收藏总数接口未实现，因此不展示伪造数字。

## 当前仍然是演示的功能

首页推荐行程、活动、AI 规划、结伴申请/队伍/聊天等仍使用独立 mock，并有演示标识。真实复制行程、编辑保存、发布活动、入队状态机、Realtime 尚未接通。本阶段不修改线上权限，也不绕过 RLS。已登录不等于通过年龄资格验证。

## 你需要操作一次

1. 停止并重新运行 HBuilderX 项目。
2. “我的 → 登录 / 注册”，填写你自己的邮箱和密码。不要把密码发给助手。
3. 当前线上 Email 已启用、邮箱确认开启。注册后检查邮件，完成确认再回到小程序用邮箱密码登录。本阶段不依赖确认链接自动跳回小程序。若邮件确认页面跳转失败，请在 Supabase Authentication Users 查看确认状态，并检查 Auth 的 Site URL 配置，不要为了测试关闭确认保护。
4. 邮件发送限流、验证码/CAPTCHA 配置或服务未配置会返回真实错误；也可在 Supabase Authentication Users 手动创建专用测试账号，再使用该账号登录。
5. 登录后在“我的”点“复制用户 ID”。
6. 打开 `supabase/seed-test-account.sql`，只把 target_user 声明中的全零 UUID 换成刚复制的用户 ID。不要修改下方全零保护条件。
7. 在 onlineData 的 SQL Editor 新建查询，粘贴整个 seed 脚本并 Run。前提是已运行 mock-schema.sql；不要重新运行旧初始化 migration。
8. 此脚本会给指定用户插入 2 份私人测试行程、4 天、9 个地点，以及 2 篇标明“测试攻略”的公开攻略。不会创建 Auth 账号、修改已有资料公开状态或将 verified 设真。所有地点都标待确认，测试日期沿用 mock，不代表当前真实旅行安排。
9. 重复执行不会重复插入或覆盖编辑过的记录。公开攻略可被匿名访问；没有公开作者资料时显示“作者未公开资料”。本阶段不造假 328/191 收藏人数，也不添加真实报名活动。
10. 回到小程序刷新“行程”和“发现”；收藏一篇，关闭页面再打开，检查收藏状态是否保留。

## 权限验收

本地验证使用 PGlite 的实际 PostgreSQL 引擎，模拟 auth.uid 和三个角色；它不等于线上 Supabase Auth/PostgREST 或真机验收。

已覆盖：建表 SQL 执行、种子脚本重复执行、匿名不能读私人行程、B 不能读取 A 的行程/日期/项目、B 不能伪造 A 的行程或收藏、普通用户不能修改 verified、成员发消息/非成员拒绝、不能伪造系统消息、离队后拒绝访问。

客户端契约测试使用模拟网络，覆盖登录请求、不会持久化密码、资料插入、作者关联、收藏/取消、服务错误不会显示成功、退出清理、过期会话刷新去重。未用你的真实密码自动登录或创建测试用户。

线上请另注册 B 账号，不导入 A 的数据。用 B 登录时“行程”应为空，公开攻略仍能看；B 的收藏不影响 A。退出再切换 A，应该恢复 A 自己的行程和收藏。也需在微信真机确认 request 域名与访问网络，不以模拟器通过代替真机通过。

## 运行本地检查

```powershell
npm run type-check
node scripts/validate-cloud-client.mjs
npm install --prefix "$env:TEMP\gogo-db-validation" @electric-sql/pglite --no-audit --no-fund
$env:PGLITE_MODULE="$env:TEMP\gogo-db-validation\node_modules\@electric-sql\pglite\dist\index.js"
node scripts/validate-database.mjs
npm run build:mp-weixin
npm run build:h5
```

## 实现说明

活跃认证入口是 src/store/auth.ts，通过 uni.request 调用 Supabase Auth REST；数据层是 src/lib/supabase/repository.ts。使用 POST/GET/DELETE，避免小程序缺少浏览器 Fetch/Headers/WebSocket 全局对象以及 PATCH 的兼容问题。不要同时初始化另一个 SDK 会话管理器。旧 client.ts 暂未作为页面入口使用。

会话以项目 URL 隔离保存在 uni 本地存储，包含敏感刷新令牌但不存密码。不要记录、分享或上传此存储；发布前应评估 App 安全存储、设备会话失效和账号删除策略。退出会立即清空本机身份，网络失败时会明确提示服务端撤销未完成；JWT 在到期前仍可能有效。

VITE_SUPABASE_URL 和 VITE_SUPABASE_PUBLISHABLE_KEY 继续使用 .env.local 的现有配置；没有引入任何服务端密钥。
