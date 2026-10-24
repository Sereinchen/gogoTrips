<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import TagList from '@/components/TagList.vue'
import { useTravelStore } from '@/store/travel'
import { listTrips } from '@/lib/supabase/repository'
import { authState, initializeAuth } from '@/store/auth'
import type { Trip } from '@/types'

const { state } = useTravelStore()
const id = ref('')
const day = ref(0)
const view = ref<'timeline' | 'map'>('timeline')
onLoad((options) => { id.value = String(options?.id || '') })
const cloudTrip = ref<Trip | null>(null)
const error = ref('')
const loading = ref(false)
const isCloud = computed(() => /^[0-9a-f-]{36}$/i.test(id.value))
let requestId = 0
watch(() => authState.user?.id, () => { cloudTrip.value = null; requestId++ }, { flush: 'sync' })
const load = async () => {
  if (!isCloud.value) return
  await initializeAuth()
  const current = ++requestId
  loading.value = true
  error.value = ''
  cloudTrip.value = null
  try {
    const rows = await listTrips(id.value)
    if (current === requestId) cloudTrip.value = rows[0] || null
  } catch (cause) { if (current === requestId) error.value = cause instanceof Error ? cause.message : '加载失败' }
  finally { loading.value = false }
}
onShow(load)
const trip = computed(() => isCloud.value ? cloudTrip.value : state.trips.find((item) => item.id === id.value))
const activeDay = computed(() => trip.value?.days[Math.min(day.value, (trip.value?.days.length || 1) - 1)])
const go = (url: string) => uni.navigateTo({ url })
</script>

<template>
  <BasePage v-if="trip" compact :eyebrow="trip.status === 'draft' ? '行程草案' : '私人行程'" :title="`${trip.coverEmoji} ${trip.city}`" :subtitle="trip.dateRange">
    <text v-if="isCloud">云端私人行程 · 当前只读</text><DemoNotice v-else />
    <AppCard><view class="stats"><view><text class="muted">预计总预算</text><text class="price">¥{{ trip.budget }}</text></view><view><text class="muted">隐私状态</text><text class="label">🔒 仅自己可见</text></view><StatusBadge :label="`v${trip.version}`" tone="muted" /></view></AppCard>
    <TagList :tags="trip.days.map((_, index) => `Day ${index + 1}`)" :selected="`Day ${day + 1}`" @select="day = Number($event.replace('Day ', '')) - 1" />
    <view class="segments"><text :class="{ active: view === 'timeline' }" @tap="view = 'timeline'">时间轴</text><text :class="{ active: view === 'map' }" @tap="view = 'map'">地图</text></view>
    <AppCard v-if="view === 'timeline' && activeDay"><text class="card-title">{{ activeDay.label }}</text><view v-for="item in activeDay.items" :key="item.id" class="timeline"><view class="time"><text>{{ item.time }}</text><view class="dot" /></view><view class="copy"><view class="between"><text class="item-title">{{ item.title }}</text><text v-if="item.locked">🔒</text></view><text class="muted">{{ item.area }} · {{ item.duration }} · {{ item.cost === null ? '费用待确认' : `¥${item.cost}` }}</text><text v-if="item.transport" class="transport">↳ {{ item.transport }}</text><StatusBadge v-if="item.pendingVerification" label="地点待确认" tone="warning" /></view></view></AppCard>
    <AppCard v-else class="map"><text class="map-emoji">🗺️</text><text class="card-title">地图服务待接入</text><text class="muted center">时间轴仍可查看。接入 MapProvider 后展示每日路线和交通估价。</text></AppCard>
    <AppButton v-if="!isCloud" label="编辑行程（演示）" @tap="go(`/pages/trips/edit?id=${trip.id}`)" /><AppButton v-if="!isCloud" label="从行程片段发起结伴（演示）" variant="secondary" @tap="go('/pages/companions/activity-new')" />
  </BasePage>
  <BasePage v-else compact><AppCard><text class="card-title">{{ loading ? '正在加载' : '行程不可访问' }}</text><text class="muted">{{ error || '可能不存在、已删除，或不属于当前账号。' }}</text><AppButton v-if="isCloud" label="重试" :loading="loading" @tap="load" /></AppCard></BasePage>
</template>

<style scoped>.stats { display: flex; justify-content: space-between; align-items: center; gap: 16rpx; }.stats>view { display: flex; flex-direction: column; gap: 8rpx; }.muted { color: var(--muted); font-size: 23rpx; line-height: 1.5; }.price { color: var(--primary-dark); font-size: 34rpx; font-weight: 900; }.label,.item-title { font-size: 26rpx; font-weight: 800; }.segments { display: flex; padding: 8rpx; border-radius: 20rpx; background: var(--surface-muted); }.segments text { flex: 1; padding: 18rpx; text-align: center; color: var(--muted); font-weight: 800; border-radius: 14rpx; }.segments .active { color: var(--primary); background: #fff; }.card-title { font-size: 34rpx; font-weight: 850; }.timeline { min-height: 130rpx; display: flex; gap: 18rpx; }.time { width: 90rpx; display: flex; align-items: center; flex-direction: column; gap: 12rpx; font-size: 22rpx; font-weight: 800; }.dot { width: 16rpx; height: 16rpx; border-radius: 50%; background: var(--primary); }.copy { flex: 1; display: flex; flex-direction: column; gap: 8rpx; }.between { display: flex; justify-content: space-between; }.transport { color: var(--accent); font-size: 22rpx; }.map { min-height: 400rpx; align-items: center; justify-content: center; }.map-emoji { font-size: 90rpx; }.center { text-align: center; }</style>
