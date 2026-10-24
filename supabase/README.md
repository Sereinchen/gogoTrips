# Supabase 数据库

当前项目：onlineData（wdrhmnzozizsmfyjphqe）。

## 当前采用的方案

- `mock-schema.sql`：已由用户运行的 12 表初始化方案。不要重复运行。
- `seed-test-account.sql`：将声明中的 target_user 换成真实测试账号 UUID 后，在 SQL Editor 执行；插入 2 份私人行程、2 篇公开测试攻略。
- `NEXT-STEPS.md`：真实邮箱登录、数据导入、双账号权限验收与本地测试说明。
- `MOCK-SCHEMA-GUIDE.md`：字段映射与初始权限边界。
- `CONNECTION.md`：初始接入阶段的历史记录；最新状态以 NEXT-STEPS.md 为准。

## 不要混合执行旧稿

`migrations/202610240001_initial_schema.sql` 是早期方案草稿，不适配当前 mock-schema 字段。保留用于历史参考，不属于当前部署流程，禁止直接通过 db push 或 SQL Editor 与当前方案混跑。

前端仅使用 Publishable key。不能为了让调用成功而关闭 RLS 或填入服务端密钥。数据库结构成功创建与客户端构建通过，都不能代替真实双账号和真机验收。
