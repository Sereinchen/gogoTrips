# 从 mock 建立 Supabase 数据表

## 只选择一个初始化方案

本次脚本为 `mock-schema.sql`，适用于尚未建立业务表的 Supabase 项目，一次性执行。不要与旧的 `migrations/202610240001_initial_schema.sql` 混合执行；两者字段命名不同，不能作为连续迁移。旧脚本尚未验证，本次不使用。

脚本使用 BEGIN / COMMIT 包裹，不删除旧表、不覆盖旧结构。若有同名表或函数，它会报错并回滚本次事务；不要为绕过错误而删表。请保留错误信息并确认现有结构后再做升级迁移。

## 执行

1. 在 Supabase 打开 onlineData 项目，确认项目 ID 为 wdrhmnzozizsmfyjphqe。
2. SQL Editor → New query，数据库角色使用默认 postgres。
3. 在编辑器打开本地 mock-schema.sql，复制全部内容，粘贴到 SQL Editor。
4. 不选中局部 SQL，点击 Run 执行全文。
5. 成功时最后一个 SELECT 应显示 12 行，每行 rowsecurity 均为 true。
6. Table Editor 选择 public schema，应看到 12 张表；空表显示 0 行是正常的。

本次脚本只有建表、约束、索引和基础权限，没有插入 mock 数据、没有创建 Auth 用户，没有自动接通前端。不要把 SQL Editor 的管理员查询成功当作普通用户权限测试通过。上线前仍需测试匿名用户及至少两个不同登录用户的 RLS。

## mock 对应关系

| mock | 数据表 / 字段 |
| --- | --- |
| currentUser、people | profiles；id 必须是 Auth 用户 UUID |
| trips | trips，owner_id 为行程所有者 |
| trips.days | trip_days，以 sort_order 排序 |
| days.items | trip_items，以 day_id 关联 |
| activities | activities；organizer 对应 organizer_id |
| joinStatus | activity_applications.status；无记录时前端显示 none |
| teams | teams；activityId → activity_id；meetupDetail → meetup_detail |
| teams.members | team_members 关联 profiles；left_at 非空表示离队 |
| teams.messages | team_messages；sender/avatar 从 profiles 读取；系统消息 sender_id 为空 |
| teams.proposal | team_proposals；before/after → before_text/after_text |
| posts | posts；author 从 profiles.name 读取，places 保留 text[] |
| bookmarked | post_bookmarks 是否存在当前用户记录 |

其余 camelCase 改用 snake_case，例如 dateRange → date_range、coverEmoji → cover_emoji、endTime → end_time。private 改为 is_private，system 改为 is_system。

mock 的 trip-1/person-1 等示例字符串不是 UUID，不能原样插入。请先通过 Supabase Auth 注册测试用户，再建立 profiles，使用真实 UUID 关联业务记录。未自动触发创建 profiles，登录接入时应插入本人资料。

activities.date/time 改为 starts_at/ends_at（timestamptz），避免中文时间字符串无法排序。trip_days.date 可为空以支持待定草案；展示文字存于 date_range。跨夜项目不能仅比较 time/end_time，后续排程逻辑必须考虑日期。

joined 应按有效 team_members 统计（包含队长）；savedCount 应按 post_bookmarks 统计。mock 中 328/191 等收藏数不会伪装为真实数据。当前没有公开计数接口，不能通过放开成员/收藏表的 RLS 来统计，后续应补受控聚合 RPC。mine 根据 sender_id 与当前登录用户计算；sending/failed 属于客户端状态，不写入成功消息表。

## 基础权限边界

- 匿名：仅可读 is_public=true 的公开资料、公开状态活动与已发布攻略。
- 登录用户：管理自己的普通资料、私人行程、行程天/项目和收藏；只能读自己的申请或本人组织活动的申请。
- profiles 的 verified 不能由客户端修改。date_range/city/intro 随 is_public 一起公开，不要在其中存放手机号、住宿地址等私密信息。
- 小队、成员、集合详情、消息、提案仅有效成员可读。有效成员可以发消息、提交待处理提案，但不能伪造系统消息或审批状态。
- 活动发布、申请状态变更、入队/离队、提案审批、资格认证及攻略发布暂只允许受信任管理端写入。尚未实现事务 RPC，因此客户端按钮不能直接更新状态。严禁为调通演示而关闭 RLS。
- trips 即便 is_private=false，仍不会自动向其他人开放；分享权限需后续单独实现。
- 此版是与 mock 对齐的数据库基础，不是完整 PRD 后端。版本快照、并发入队 RPC、拉黑/举报、通知、Realtime 和 Storage 等仍待实现。

## .env.local

在项目根目录（与 package.json 同级）新建 .env.local：

```dotenv
VITE_SUPABASE_URL=https://wdrhmnzozizsmfyjphqe.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=替换为控制台的sb_publishable开头密钥
```

当前代码使用 VITE_SUPABASE_PUBLISHABLE_KEY，并检查 sb_publishable_ 前缀，不读取 VITE_SUPABASE_ANON_KEY。使用已提供的 Publishable key 即可，它承担旧 anon key 的客户端用途；不要把旧 JWT anon key 直接填入当前校验器。

Supabase 项目设置的 API Keys 页面可复制 Publishable key。禁止填入 service_role、sb_secret_ 或数据库密码。VITE_ 变量会进入小程序包，.env.local 并不使前端配置保密。

.env.local 通常覆盖 .env 中的同名变量；若存在 .env.development/.env.production 等模式配置或 shell 环境变量，请检查是否覆盖了它。保存后停止 HBuilderX 运行，再重新运行，打开“我的 → 检测后端连接”。表检测通过不等于业务页已从云端读取。

真机还需在微信公众平台设置 request 合法域名 https://wdrhmnzozizsmfyjphqe.supabase.co。当前 .gitignore 已忽略 .env.local。
