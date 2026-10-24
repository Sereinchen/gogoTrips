# Supabase 连接状态

项目 URL：`https://wdrhmnzozizsmfyjphqe.supabase.co`。

客户端配置保存在根目录 `.env`，变量为 `VITE_SUPABASE_URL` 和 `VITE_SUPABASE_PUBLISHABLE_KEY`。`.env` 已加入忽略规则。只允许使用 Publishable key，不允许使用 secret/service_role key。

2026-10-24 实测 Auth settings 返回 HTTP 200；`posts` 和 `activities` REST 查询返回 HTTP 404 / PGRST205，表尚未出现在 API schema cache 中。没有执行云端 DDL，也没有创建演示用户或种子数据。

## HBuilderX 验证

1. 修改环境变量后，停止再重新运行项目。
2. 在微信公众平台配置 request 合法域名 `https://wdrhmnzozizsmfyjphqe.supabase.co`。模拟器跳过域名校验不等于真机可用。
3. 打开“我的 → 检测后端连接”，检查返回结果。

检测使用 `uni.request`，只请求 Auth 配置及零条业务记录，不发送短信，不创建用户，也不读出私人记录。现有 SDK 客户端位于 `src/lib/supabase/client.ts`；业务 store 和登录页仍是演示实现，未切换成真实后端。

## 尚待完成

- 审查并测试 `migrations/202610240001_initial_schema.sql` 后，再通过受授权的数据库管理连接部署。此脚本目前未验证，不要直接当作生产部署脚本运行。
- 确定真实登录方式，配置认证服务，验证跨用户 RLS 后接入业务 store。
- Publishable key 不能创建数据库表；部署需要 SQL Editor、Supabase CLI 的管理授权或数据库连接，不能通过放宽 RLS 解决。
