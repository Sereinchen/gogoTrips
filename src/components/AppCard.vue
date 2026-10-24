<script setup lang="ts">
defineEmits<{ tap: [] }>()
</script>

<template>
  <view class="card" @tap="$emit('tap')"><slot /></view>
</template>

<style scoped>
.card { display: flex; flex-direction: column; gap: 18rpx; padding: 28rpx; background: var(--surface); border: 1px solid var(--border); border-radius: 28rpx; box-shadow: 0 10rpx 28rpx rgba(12, 53, 43, 0.07); }
</style>
