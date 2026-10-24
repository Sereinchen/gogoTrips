<script setup lang="ts">
import { ref } from 'vue'
import AppButton from './AppButton.vue'
import AppCard from './AppCard.vue'
import { checkSupabaseConnection } from '@/lib/supabase/health'

const loading = ref(false)
const message = ref('已配置 Supabase，点击检测网络、密钥及业务表。')
const check = async () => {
  if (loading.value) return
  loading.value = true
  try {
    message.value = await checkSupabaseConnection()
  } catch (error) {
    message.value = error instanceof Error ? error.message : '连接检测失败'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <AppCard>
    <text class="backend-title">Supabase 后端连接</text>
    <text class="backend-message">{{ message }}</text>
    <AppButton label="检测后端连接" variant="secondary" :loading="loading" @tap="check" />
  </AppCard>
</template>

<style scoped>
.backend-title { font-size: 30rpx; font-weight: 700; }
.backend-message { display: block; color: var(--muted); font-size: 24rpx; line-height: 1.6; margin: 18rpx 0; }
</style>
