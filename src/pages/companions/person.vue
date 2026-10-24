<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import TagList from '@/components/TagList.vue'
import { people } from '@/data/mock-data'
const id = ref('')
const invite = ref(false)
const sent = ref(false)
onLoad((options) => { id.value = String(options?.id || '') })
const person = computed(() => people.find((item) => item.id === id.value))
const report = () => uni.showModal({ title: '安全操作', content: '演示版暂不提交真实举报。', showCancel: false })
</script>

<template><BasePage compact><DemoNotice /><AppCard v-if="person"><view class="profile"><text class="avatar">{{ person.avatar }}</text><view class="copy"><text class="title">{{ person.name }}</text><text class="muted">{{ person.city }} · {{ person.dateRange }}</text></view><StatusBadge label="18+ 已验证" tone="success" /></view><text class="body">{{ person.intro }}</text><TagList :tags="person.interests" /><text class="muted">旅行节奏：{{ person.pace }}</text></AppCard><AppButton v-if="!invite" :label="sent ? '邀请已发送' : '邀请同游'" :disabled="sent" @tap="invite = true" /><AppCard v-else><text class="title">发送具体活动邀请</text><view class="field"><text>日期</text><input value="2026-11-10" /></view><view class="field"><text>公开集合区域</text><input value="泉州古城公共区域" /></view><view class="field"><text>邀请说明</text><textarea value="想一起走西街和开元寺，预计半天。" /></view><AppButton label="确认发送邀请" @tap="sent = true; invite = false" /><AppButton label="取消" variant="ghost" @tap="invite = false" /></AppCard><view class="safety"><text>不会展示生日、手机号、酒店坐标或完整私人行程。</text></view><AppButton label="拉黑或举报" variant="ghost" @tap="report" /></BasePage></template>
<style scoped>.profile { display: flex; align-items: center; gap: 18rpx; }.avatar { font-size: 70rpx; }.copy { flex: 1; display: flex; flex-direction: column; gap: 8rpx; }.title { font-size: 34rpx; font-weight: 850; }.body { font-size: 27rpx; line-height: 1.6; }.muted { color: var(--muted); font-size: 23rpx; line-height: 1.5; }.field { display: flex; flex-direction: column; gap: 10rpx; font-size: 24rpx; font-weight: 750; }.field input,.field textarea { min-height: 88rpx; padding: 20rpx; border: 1px solid var(--border); border-radius: 20rpx; font-size: 26rpx; }.field textarea { min-height: 160rpx; }.safety { padding: 22rpx; border-radius: 18rpx; color: var(--muted); background: var(--surface-muted); font-size: 22rpx; line-height: 1.55; }</style>
