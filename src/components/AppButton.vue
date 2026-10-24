<script setup lang="ts">
withDefaults(defineProps<{ label?: string; variant?: 'primary' | 'secondary' | 'ghost' | 'danger'; loading?: boolean; disabled?: boolean }>(), { label: '', variant: 'primary', loading: false, disabled: false })
defineEmits<{ tap: [] }>()
</script>

<template>
  <button class="button" :class="[variant, { 'is-disabled': disabled || loading }]" :loading="loading" :disabled="disabled || loading" @tap="$emit('tap')"><slot>{{ label }}</slot></button>
</template>

<style scoped>
.button { width: 100%; min-height: 92rpx; margin: 0; display: flex; align-items: center; justify-content: center; border-radius: 22rpx; font-size: 28rpx; font-weight: 800; line-height: 1; }
.primary { color: #fff; background: var(--primary); }
.secondary { color: var(--primary-dark); background: var(--primary-soft); border: 1px solid #b8e1d2; }
.ghost { color: var(--text); background: transparent; border: 1px solid var(--border); }
.danger { color: var(--danger); background: #fbeaea; border: 1px solid #f4c8c8; }
.is-disabled { opacity: .55; }
</style>
