<script setup lang="ts">
import type { Activity } from '@/types'
import AppCard from './AppCard.vue'
import StatusBadge from './StatusBadge.vue'
import TagList from './TagList.vue'
defineProps<{ activity: Activity }>()
defineEmits<{ tap: [] }>()
</script>

<template><AppCard @tap="$emit('tap')"><view class="between"><StatusBadge :label="activity.category" /><text class="capacity">剩 {{ activity.capacity - activity.joined }} 个名额</text></view><text class="title">{{ activity.title }}</text><text class="body">📍 {{ activity.meetupArea }}</text><text class="muted">{{ activity.date }} · {{ activity.time }} · {{ activity.city }}</text><TagList :tags="activity.tags" /></AppCard></template>
<style scoped>.between { display: flex; justify-content: space-between; align-items: center; }.capacity { color: var(--primary); font-size: 23rpx; font-weight: 800; }.title { color: var(--text); font-size: 34rpx; font-weight: 850; }.body { color: var(--text); font-size: 27rpx; }.muted { color: var(--muted); font-size: 24rpx; }</style>
