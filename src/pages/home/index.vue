<script setup lang="ts">
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import TripCard from '@/components/TripCard.vue'
import ActivityCard from '@/components/ActivityCard.vue'
import AppButton from '@/components/AppButton.vue'
import { useTravelStore } from '@/store/travel'

const { state } = useTravelStore()
const go = (url: string) => uni.navigateTo({ url })
const tab = (url: string) => uni.switchTab({ url })
</script>

<template>
  <BasePage eyebrow="GoGo Trip" title="下一站，和谁一起？" subtitle="先把旅程计划好，再遇见同路的人。">
    <template #action><text class="avatar">🌿</text></template>
    <DemoNotice />
    <view class="hero-row">
      <view class="hero primary" @tap="go('/pages/trips/new')"><text class="hero-icon">✦</text><text class="hero-title light">AI 规划旅行</text><text class="hero-copy light-copy">3 步生成可执行行程</text></view>
      <view class="hero secondary" @tap="tab('/pages/companions/index')"><text class="hero-icon">♧</text><text class="hero-title">找旅行搭子</text><text class="hero-copy">按活动或同行意向发现</text></view>
    </view>
    <AppCard><view class="search"><text class="search-icon">⌕</text><text class="muted">搜索目的地，如“泉州”</text></view></AppCard>
    <view class="section"><text class="section-title">最近行程</text><text class="link" @tap="tab('/pages/trips/index')">全部</text></view>
    <TripCard :trip="state.trips[0]" @tap="go(`/pages/trips/detail?id=${state.trips[0].id}`)" />
    <view class="section"><text class="section-title">正在发生</text><text class="link" @tap="tab('/pages/companions/index')">找更多</text></view>
    <ActivityCard :activity="state.activities[0]" @tap="go(`/pages/companions/activity-detail?id=${state.activities[0].id}`)" />
    <view class="section"><text class="section-title">灵感攻略</text><text class="link" @tap="tab('/pages/discover/index')">去发现</text></view>
    <AppButton label="浏览云端攻略" @tap="tab('/pages/discover/index')" />
  </BasePage>
</template>

<style scoped>
.avatar { font-size: 48rpx; }.hero-row { display: flex; gap: 20rpx; }.hero { flex: 1; min-height: 260rpx; padding: 28rpx; display: flex; flex-direction: column; justify-content: flex-end; gap: 10rpx; border-radius: 38rpx; }.primary { background: var(--primary); }.secondary { background: var(--primary-soft); border: 1px solid #b8e1d2; }.hero-icon { margin-bottom: 24rpx; font-size: 48rpx; }.hero-title { color: var(--primary-dark); font-size: 31rpx; font-weight: 900; }.hero-copy { color: var(--primary-dark); font-size: 22rpx; line-height: 1.45; }.light { color: #fff; }.light-copy { color: #d8f1e8; }.search { display: flex; align-items: center; gap: 16rpx; }.search-icon { color: var(--primary); font-size: 38rpx; }.muted { color: var(--muted); font-size: 25rpx; }.section { display: flex; align-items: center; justify-content: space-between; margin-top: 8rpx; }.section-title { font-size: 34rpx; font-weight: 850; }.link { color: var(--primary); font-size: 25rpx; font-weight: 750; }
</style>
