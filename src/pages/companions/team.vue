<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { useTravelStore } from '@/store/travel'
const { state, resolveProposal } = useTravelStore()
const id = ref('')
onLoad((options) => { id.value = String(options?.id || '') })
const team = computed(() => state.teams.find((item) => item.id === id.value))
const activity = computed(() => state.activities.find((item) => item.id === team.value?.activityId))
const leave = () => uni.showModal({ title: '确认退出？', content: '退出后将立即停止接收新的私密消息。' })
const openChat = () => team.value && uni.navigateTo({ url: `/pages/companions/chat?id=${team.value.id}` })
const showProposalHint = () => uni.showToast({ title: '已预置演示提案', icon: 'none' })
</script>

<template><BasePage v-if="team && activity" compact><DemoNotice /><AppCard><view class="between"><StatusBadge label="活动进行中" tone="success" /><text class="muted">{{ team.members.length }}/{{ activity.capacity }} 人</text></view><text class="title">{{ activity.title }}</text><text class="body">{{ activity.date }} · {{ activity.time }}</text><text class="body">📍 {{ team.meetupDetail }}</text><view class="members"><view v-for="member in team.members" :key="member.id" class="member"><text class="avatar">{{ member.avatar }}</text><text class="muted">{{ member.name }}</text></view></view><AppButton label="进入小队聊天" @tap="openChat" /></AppCard><AppCard v-if="team.proposal"><view class="between"><text class="card-title">行程变更建议</text><StatusBadge :label="team.proposal.status === 'pending' ? '待队长处理' : team.proposal.status === 'approved' ? '已同意' : '已拒绝'" :tone="team.proposal.status === 'pending' ? 'warning' : team.proposal.status === 'approved' ? 'success' : 'danger'" /></view><text class="label">{{ team.proposal.title }}</text><text class="before">原：{{ team.proposal.before }}</text><text class="after">新：{{ team.proposal.after }}</text><template v-if="team.proposal.status === 'pending'"><AppButton label="同意应用" @tap="resolveProposal(team.id, 'approved')" /><AppButton label="拒绝" variant="ghost" @tap="resolveProposal(team.id, 'rejected')" /></template></AppCard><AppButton label="提出修改建议" variant="secondary" @tap="showProposalHint" /><AppButton label="退出小队" variant="danger" @tap="leave" /></BasePage></template>
<style scoped>.between { display: flex; justify-content: space-between; align-items: center; gap: 16rpx; }.title,.card-title { font-size: 34rpx; font-weight: 850; }.body { font-size: 27rpx; line-height: 1.5; }.muted { color: var(--muted); font-size: 22rpx; }.members { display: flex; gap: 26rpx; }.member { display: flex; align-items: center; flex-direction: column; gap: 6rpx; }.avatar { font-size: 52rpx; }.label { font-size: 25rpx; font-weight: 800; }.before { color: var(--danger); font-size: 25rpx; }.after { color: var(--success); font-size: 25rpx; }</style>
