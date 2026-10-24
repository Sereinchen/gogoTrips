<script setup lang="ts">
import type { Person } from '@/types'
import AppCard from './AppCard.vue'
import StatusBadge from './StatusBadge.vue'
import TagList from './TagList.vue'
defineProps<{ person: Person }>()
defineEmits<{ tap: [] }>()
</script>

<template><AppCard @tap="$emit('tap')"><view class="row"><view class="avatar">{{ person.avatar }}</view><view class="copy"><view class="inline"><text class="title">{{ person.name }}</text><StatusBadge v-if="person.verified" label="18+ 已验证" tone="success" /></view><text class="muted">{{ person.city }} · {{ person.dateRange }}</text><text class="muted">{{ person.pace }}</text></view></view><TagList :tags="person.interests" /></AppCard></template>
<style scoped>.row { display: flex; align-items: center; gap: 20rpx; }.avatar { width: 92rpx; height: 92rpx; display: flex; align-items: center; justify-content: center; border-radius: 50%; background: var(--primary-soft); font-size: 44rpx; }.copy { flex: 1; display: flex; flex-direction: column; gap: 8rpx; }.inline { display: flex; align-items: center; flex-wrap: wrap; gap: 12rpx; }.title { font-size: 34rpx; font-weight: 850; }.muted { color: var(--muted); font-size: 24rpx; }</style>
