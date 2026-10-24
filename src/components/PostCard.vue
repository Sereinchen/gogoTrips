<script setup lang="ts">
import type { Post } from '@/types'
import AppCard from './AppCard.vue'
import StatusBadge from './StatusBadge.vue'
defineProps<{ post: Post }>()
defineEmits<{ tap: [] }>()
</script>

<template><AppCard @tap="$emit('tap')"><view class="cover"><text class="emoji">{{ post.coverEmoji }}</text><StatusBadge :label="post.city" tone="muted" /></view><text class="title">{{ post.title }}</text><text class="body">{{ post.summary }}</text><text class="muted">by {{ post.author }}<text v-if="post.savedCount !== undefined"> · {{ post.savedCount }} 人收藏</text></text></AppCard></template>
<style scoped>.cover { min-height: 150rpx; padding: 22rpx; display: flex; align-items: flex-start; justify-content: space-between; border-radius: 22rpx; background: var(--primary-soft); }.emoji { font-size: 68rpx; }.title { font-size: 34rpx; font-weight: 850; }.body { font-size: 27rpx; line-height: 1.55; }.muted { color: var(--muted); font-size: 24rpx; }</style>
