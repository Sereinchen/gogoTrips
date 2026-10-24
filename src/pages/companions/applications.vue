<script setup lang="ts">
import { computed } from 'vue'
import BasePage from '@/components/BasePage.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import TagList from '@/components/TagList.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import ActivityCard from '@/components/ActivityCard.vue'
import { useTravelStore } from '@/store/travel'
const { state } = useTravelStore()
const applications = computed(() => state.activities.filter((item) => item.joinStatus !== 'none'))
const go = (id: string) => uni.navigateTo({ url: `/pages/companions/activity-detail?id=${id}` })
</script>

<template><BasePage compact><DemoNotice /><TagList :tags="['待审核','待确认','已参加','已结束']" selected="待审核" /><view class="notice"><StatusBadge label="状态说明" tone="warning" /><text>审核通过不等于已入队；你需要在活动详情再次确认。</text></view><ActivityCard v-for="activity in applications" :key="activity.id" :activity="activity" @tap="go(activity.id)" /></BasePage></template>
<style scoped>.notice { padding: 22rpx; display: flex; flex-direction: column; gap: 12rpx; border: 1px solid #f2d7a8; border-radius: 20rpx; background: #fff8e9; color: var(--muted); font-size: 23rpx; line-height: 1.5; }</style>
