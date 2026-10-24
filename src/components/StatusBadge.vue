<script setup lang="ts">
withDefaults(defineProps<{ label: string; tone?: 'info' | 'success' | 'warning' | 'danger' | 'muted' }>(), { tone: 'info' })
</script>

<template><text class="badge" :class="tone">{{ label }}</text></template>

<style scoped>
.badge { display: inline-flex; align-self: flex-start; padding: 8rpx 18rpx; border-radius: 999rpx; font-size: 22rpx; font-weight: 800; }
.info { color: #247ba0; background: #e5f2f8; }.success { color: var(--success); background: #e2f4eb; }.warning { color: var(--warning); background: #fff1d9; }.danger { color: var(--danger); background: #fbeaea; }.muted { color: var(--muted); background: var(--surface-muted); }
</style>
