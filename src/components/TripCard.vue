<script setup lang="ts">
import type { Trip } from '@/types'
import AppCard from './AppCard.vue'
import StatusBadge from './StatusBadge.vue'
defineProps<{ trip: Trip }>()
defineEmits<{ tap: [] }>()
</script>

<template><AppCard @tap="$emit('tap')"><view class="row"><text class="emoji">{{ trip.coverEmoji }}</text><view class="copy"><view class="between"><text class="title">{{ trip.city }}</text><StatusBadge :label="trip.status === 'saved' ? '已保存' : '草案'" :tone="trip.status === 'saved' ? 'success' : 'warning'" /></view><text class="muted">{{ trip.dateRange }}</text><text class="muted">预算约 ¥{{ trip.budget }} · 仅自己可见</text></view></view></AppCard></template>
<style scoped>.row { display: flex; align-items: center; gap: 22rpx; }.emoji { font-size: 68rpx; }.copy { flex: 1; display: flex; flex-direction: column; gap: 8rpx; }.between { display: flex; align-items: center; justify-content: space-between; gap: 12rpx; }.title { color: var(--text); font-size: 34rpx; font-weight: 850; }.muted { color: var(--muted); font-size: 24rpx; line-height: 1.5; }</style>
