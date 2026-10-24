import type { Activity, Person, Post, Team, Trip } from '@/types'

export const currentUser: Person = { id: 'me', name: '林小满', avatar: '🌿', city: '杭州', dateRange: '11月8日–11日', interests: ['城市漫步', '摄影', '咖啡'], pace: '松弛慢游', intro: '喜欢早起逛老街，也愿意为一家小店绕路。', verified: true }

export const people: Person[] = [
  { id: 'person-1', name: '阿岚', avatar: '🧢', city: '泉州', dateRange: '11月9日–12日', interests: ['古城', '小吃', '摄影'], pace: '松弛慢游', intro: '第一次去泉州，想把重点放在老城和本地小吃，拒绝特种兵。', verified: true },
  { id: 'person-2', name: '木木', avatar: '📷', city: '泉州', dateRange: '11月10日–13日', interests: ['建筑', '人文', '夜景'], pace: '适中', intro: '建筑专业，想找同样爱拍照的人一起走街串巷。', verified: true },
  { id: 'person-3', name: '十一', avatar: '🥾', city: '杭州', dateRange: '11月16日', interests: ['徒步', '自然', '咖啡'], pace: '活力探索', intro: '周末轻徒步爱好者，路线安全第一。', verified: true }
]

export const trips: Trip[] = [
  { id: 'trip-1', city: '泉州', dateRange: '11月9日–11日 · 3天2晚', timezone: 'Asia/Shanghai', budget: 1680, currency: 'CNY', coverEmoji: '🏮', status: 'saved', private: true, version: 3, days: [
    { date: '2026-11-09', label: 'Day 1 · 古城初见', items: [
      { id: 'item-1', time: '09:30', endTime: '11:00', title: '开元寺', area: '鲤城区', duration: '1.5小时', cost: 0, locked: true },
      { id: 'item-2', time: '11:20', endTime: '12:30', title: '西街小吃漫游', area: '西街', duration: '1小时', transport: '步行 8 分钟', cost: 55 },
      { id: 'item-3', time: '14:00', endTime: '16:00', title: '蟳埔簪花体验', area: '丰泽区', duration: '2小时', transport: '打车约 25 分钟', cost: 168 }
    ] },
    { date: '2026-11-10', label: 'Day 2 · 海风与古厝', items: [
      { id: 'item-4', time: '09:00', endTime: '11:30', title: '洛伽寺与黄金海岸', area: '石狮', duration: '2.5小时', cost: 80 },
      { id: 'item-5', time: '14:00', endTime: '16:00', title: '永宁古卫城', area: '永宁镇', duration: '2小时', transport: '驾车约 35 分钟', cost: 30 }
    ] },
    { date: '2026-11-11', label: 'Day 3 · 闽南烟火', items: [
      { id: 'item-6', time: '09:30', endTime: '11:00', title: '清净寺与关岳庙', area: '涂门街', duration: '1.5小时', cost: 3 },
      { id: 'item-7', time: '11:20', endTime: '13:00', title: '面线糊午餐', area: '府文庙附近', duration: '1小时', cost: 35, pendingVerification: true }
    ] }
  ] },
  { id: 'trip-2', city: '杭州', dateRange: '11月16日 · 周末一天', timezone: 'Asia/Shanghai', budget: 380, currency: 'CNY', coverEmoji: '🍂', status: 'draft', private: true, version: 1, days: [
    { date: '2026-11-16', label: 'Day 1 · 九溪秋日', items: [
      { id: 'item-8', time: '08:30', endTime: '11:00', title: '九溪烟树', area: '西湖区', duration: '2.5小时', cost: 0 },
      { id: 'item-9', time: '11:30', endTime: '13:00', title: '龙井村午餐', area: '龙井村', duration: '1.5小时', cost: 90 }
    ] }
  ] }
]

export const activities: Activity[] = [
  { id: 'activity-1', title: '西街夜拍与小吃散步', city: '泉州', date: '11月9日', time: '18:30–21:00', category: '城市漫步', organizer: people[0], meetupArea: '西街钟楼附近', description: '边走边吃，沿途拍夜景。具体集合点将在确认入队后通知。', capacity: 4, joined: 2, costPolicy: '餐饮各自支付，无组织费用', status: 'open', joinStatus: 'none', tags: ['夜景', '摄影', '小吃'] },
  { id: 'activity-2', title: '石狮海岸线半日同行', city: '泉州', date: '11月10日', time: '08:30–13:00', category: '自然风景', organizer: people[1], meetupArea: '泉州古城公共交通站点附近', description: '一起去海边看寺庙和礁石，慢节奏拍照，不拼车交易。', capacity: 3, joined: 2, costPolicy: '交通与餐饮现场各自支付', status: 'open', joinStatus: 'approved', teamId: 'team-1', tags: ['海边', '建筑', '摄影'] },
  { id: 'activity-3', title: '九溪轻徒步', city: '杭州', date: '11月16日', time: '08:00–12:00', category: '轻徒步', organizer: people[2], meetupArea: '九溪公交站附近', description: '约 8 公里轻徒步，雨天取消。请穿防滑鞋并自备饮水。', capacity: 6, joined: 4, costPolicy: '无费用', status: 'open', joinStatus: 'pending', tags: ['徒步', '自然', '周末'] }
]

export const posts: Post[] = [
  { id: 'post-1', title: '泉州三天：把时间留给街巷', city: '泉州', author: '南风慢慢', coverEmoji: '🏮', summary: '一条不赶路的古城路线，包含寺庙、老街、咖啡和本地小吃。', places: ['开元寺', '西街', '清净寺', '蟳埔村'], savedCount: 328, bookmarked: false },
  { id: 'post-2', title: '杭州入秋后最舒服的一日步行', city: '杭州', author: '一颗青梅', coverEmoji: '🍂', summary: '九溪到龙井的轻量路线，给第一次来杭州又不想挤西湖的人。', places: ['九溪烟树', '龙井村', '满觉陇'], savedCount: 191, bookmarked: true }
]

export const teams: Team[] = [
  { id: 'team-1', activityId: 'activity-2', members: [currentUser, people[1]], meetupDetail: '确认入队后可见：08:20 古城游客中心正门', proposal: { id: 'proposal-1', title: '将出发时间提前 20 分钟', before: '08:30 出发', after: '08:10 出发，避开早高峰', status: 'pending' }, messages: [
    { id: 'message-1', sender: '系统', avatar: '✓', body: '你已确认加入「石狮海岸线半日同行」', time: '10:12', system: true },
    { id: 'message-2', sender: '木木', avatar: '📷', body: '欢迎！我会带一台胶片机，天气好的话海边很出片。', time: '10:18' },
    { id: 'message-3', sender: '林小满', avatar: '🌿', body: '太好了，我也想拍一些建筑细节。', time: '10:21', mine: true, status: 'sent' }
  ] }
]
