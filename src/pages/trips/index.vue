<script setup lang="ts">
import { ref, watch } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppButton from '@/components/AppButton.vue'
import AppCard from '@/components/AppCard.vue'
import TripCard from '@/components/TripCard.vue'
import { listTrips } from '@/lib/supabase/repository'
import { authState, initializeAuth } from '@/store/auth'
import type { Trip } from '@/types'
const trips = ref<Trip[]>([])
const loading = ref(false)
const error = ref('')
let requestId = 0
watch(() => authState.user?.id, () => { trips.value = []; requestId++ }, { flush: 'sync' })
const load = async () => {
  await initializeAuth()
  const current = ++requestId
  trips.value = []
  error.value = ''
  if (!authState.user) return
  loading.value = true
  try { const rows = await listTrips(); if (current === requestId) trips.value = rows }
  catch (cause) { if (current === requestId) error.value = cause instanceof Error ? cause.message : '读取失败' }
  finally { loading.value = false }
}
onShow(load)
const go = (url: string) => uni.navigateTo({ url })
</script>
<template>
  <BasePage title="我的行程" subtitle="当前账号的云端私人行程">
    <AppButton v-if="!authState.user" label="登录查看私人行程" @tap="go('/pages/auth/sign-in')" />
    <AppButton v-else label="刷新行程" variant="ghost" :loading="loading" @tap="load" />
    <AppCard v-if="error"><text>{{ error }}</text></AppCard>
    <AppCard v-else-if="authState.user && !loading && !trips.length"><text>还没有云端行程，完成测试数据导入后可在此查看。</text></AppCard>
    <TripCard v-for="trip in trips" :key="trip.id" :trip="trip" @tap="go(`/pages/trips/detail?id=${trip.id}`)" />
    <AppButton label="AI 规划演示（不保存到云端）" variant="ghost" @tap="go('/pages/trips/new')" />
  </BasePage>
</template>
