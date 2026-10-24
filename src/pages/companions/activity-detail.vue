<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import TagList from '@/components/TagList.vue'
import { useTravelStore } from '@/store/travel'
const { state, updateJoinStatus } = useTravelStore()
const id = ref('')
onLoad((options) => { id.value = String(options?.id || '') })
const activity = computed(() => state.activities.find((item) => item.id === id.value))
const statusCopy = { none: '可申请', pending: '待审核', approved: '审核通过，待你确认', confirmed: '已加入小队', rejected: '申请未通过', withdrawn: '已撤回', expired: '申请已过期' } as const
const action = () => { if (!activity.value) return; if (activity.value.joinStatus === 'none') updateJoinStatus(activity.value.id, 'pending'); else if (activity.value.joinStatus === 'approved') updateJoinStatus(activity.value.id, 'confirmed'); else if (activity.value.joinStatus === 'confirmed' && activity.value.teamId) uni.navigateTo({ url: `/pages/companions/team?id=${activity.value.teamId}` }) }
const label = computed(() => activity.value?.joinStatus === 'none' ? '申请加入' : activity.value?.joinStatus === 'approved' ? '确认参加' : activity.value?.joinStatus === 'confirmed' ? '进入小队' : activity.value ? statusCopy[activity.value.joinStatus] : '')
const report = () => uni.showModal({ title: '举报活动', content: '演示版仅展示入口，不会提交真实举报。', showCancel: false })
</script>

<template><BasePage v-if="activity" compact><DemoNotice /><AppCard><view class="between"><StatusBadge :label="activity.category" /><StatusBadge :label="statusCopy[activity.joinStatus]" :tone="activity.joinStatus === 'approved' ? 'warning' : activity.joinStatus === 'confirmed' ? 'success' : 'info'" /></view><text class="title">{{ activity.title }}</text><text class="body">📅 {{ activity.date }} · {{ activity.time }}</text><text class="body">📍 {{ activity.meetupArea }}</text><text class="body">👥 {{ activity.joined }}/{{ activity.capacity }} 人</text><text class="body">💰 {{ activity.costPolicy }}</text><TagList :tags="activity.tags" /></AppCard><AppCard><text class="card-title">活动说明</text><text class="body">{{ activity.description }}</text><text class="warning">具体集合点仅在确认入队后向有效成员展示。</text></AppCard><AppCard><view class="profile"><text class="avatar">{{ activity.organizer.avatar }}</text><view class="copy"><text class="label">发起人 · {{ activity.organizer.name }}</text><text class="muted">{{ activity.organizer.intro }}</text></view><StatusBadge label="已验证" tone="success" /></view></AppCard><AppButton :label="label" :disabled="['pending','rejected','withdrawn','expired'].includes(activity.joinStatus)" @tap="action" /><AppButton v-if="activity.joinStatus === 'pending'" label="撤回申请" variant="danger" @tap="updateJoinStatus(activity.id, 'withdrawn')" /><AppButton label="举报活动" variant="ghost" @tap="report" /></BasePage></template>
<style scoped>.between { display: flex; justify-content: space-between; }.title { font-size: 44rpx; line-height: 1.25; font-weight: 900; }.card-title { font-size: 34rpx; font-weight: 850; }.body { font-size: 27rpx; line-height: 1.55; }.warning { color: var(--warning); font-size: 22rpx; line-height: 1.5; }.profile { display: flex; align-items: center; gap: 18rpx; }.avatar { font-size: 58rpx; }.copy { flex: 1; display: flex; flex-direction: column; gap: 8rpx; }.label { font-size: 25rpx; font-weight: 800; }.muted { color: var(--muted); font-size: 22rpx; line-height: 1.5; }</style>
