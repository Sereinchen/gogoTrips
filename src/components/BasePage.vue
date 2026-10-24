<script setup lang="ts">
defineProps<{ title?: string; subtitle?: string; eyebrow?: string; compact?: boolean }>()
</script>

<template>
  <view class="page" :class="{ compact }">
    <view v-if="title" class="header">
      <view class="header-copy">
        <text v-if="eyebrow" class="eyebrow">{{ eyebrow }}</text>
        <text class="title">{{ title }}</text>
        <text v-if="subtitle" class="subtitle">{{ subtitle }}</text>
      </view>
      <slot name="action" />
    </view>
    <slot />
  </view>
</template>

<style scoped>
.page { min-height: 100vh; padding: calc(var(--status-bar-height) + 28rpx) 28rpx 160rpx; display: flex; flex-direction: column; gap: 24rpx; background: var(--background); }
.page.compact { padding-top: 24rpx; }
.header { display: flex; align-items: flex-start; justify-content: space-between; gap: 20rpx; }
.header-copy { flex: 1; display: flex; flex-direction: column; gap: 8rpx; }
.eyebrow { color: var(--primary); font-size: 22rpx; font-weight: 800; letter-spacing: 2rpx; }
.title { color: var(--text); font-size: 52rpx; line-height: 1.15; font-weight: 900; }
.subtitle { color: var(--muted); font-size: 26rpx; line-height: 1.55; }
</style>
