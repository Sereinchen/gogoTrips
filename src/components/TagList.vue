<script setup lang="ts">
defineProps<{ tags: string[]; selected?: string }>()
defineEmits<{ select: [tag: string] }>()
</script>

<template><view class="tags"><text v-for="tag in tags" :key="tag" class="tag" :class="{ selected: selected === tag }" @tap="$emit('select', tag)">{{ tag }}</text></view></template>
<style scoped>.tags { display: flex; flex-wrap: wrap; gap: 12rpx; }.tag { padding: 12rpx 20rpx; border-radius: 999rpx; border: 1px solid var(--border); color: var(--muted); background: var(--surface); font-size: 23rpx; font-weight: 650; }.selected { color: var(--primary-dark); border-color: var(--primary); background: var(--primary-soft); font-weight: 800; }</style>
