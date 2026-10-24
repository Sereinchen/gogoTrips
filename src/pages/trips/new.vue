<script setup lang="ts">
import { ref } from 'vue'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import TagList from '@/components/TagList.vue'
import { useTravelStore } from '@/store/travel'

const { createGeneratedTrip } = useTravelStore()
const step = ref(1)
const city = ref('泉州')
const budget = ref('1800')
const pace = ref('松弛慢游')
const mustVisit = ref('开元寺、西街')
const loading = ref(false)

const generate = async () => {
  loading.value = true
  const trip = await createGeneratedTrip(city.value)
  loading.value = false
  uni.redirectTo({ url: `/pages/trips/detail?id=${trip.id}` })
}
</script>

<template>
  <BasePage compact>
    <DemoNotice />
    <view class="progress"><view v-for="item in 3" :key="item" class="bar" :class="{ active: item <= step }" /></view>
    <AppCard v-if="step === 1"><text class="card-title">先确定时间和地点</text><view class="field"><text>目的地</text><input v-model="city" placeholder="例如：泉州" /></view><view class="field"><text>出行日期</text><input value="2026-11-09 至 2026-11-11" disabled /></view><view class="field"><text>出行人数</text><input value="1 人" disabled /></view></AppCard>
    <AppCard v-else-if="step === 2"><text class="card-title">预算和旅行节奏</text><view class="field"><text>总预算（人民币）</text><input v-model="budget" type="number" /></view><text class="label">旅行节奏</text><TagList :tags="['松弛慢游', '适中', '活力探索']" :selected="pace" @select="pace = $event" /><text class="label">兴趣</text><TagList :tags="['人文古迹', '本地小吃', '摄影', '自然']" selected="人文古迹" /></AppCard>
    <AppCard v-else><text class="card-title">还有哪些限制？</text><view class="field"><text>必须去的地点</text><input v-model="mustVisit" /></view><view class="field"><text>酒店区域（可选）</text><input placeholder="只需填写区域，不填精确地址" /></view><view class="field"><text>其他说明</text><textarea placeholder="例如：第二天少走路，不安排早起" /></view></AppCard>
    <AppButton v-if="step > 1" label="上一步" variant="ghost" @tap="step--" /><AppButton v-if="step < 3" label="下一步" @tap="step++" /><AppButton v-else label="生成行程" :loading="loading" @tap="generate" />
    <text class="notice">AI 生成内容仅为草案。地点、营业信息和路线将在接入地图服务后校验。</text>
  </BasePage>
</template>

<style scoped>.progress { display: flex; gap: 12rpx; }.bar { flex: 1; height: 8rpx; border-radius: 99rpx; background: var(--border); }.bar.active { background: var(--primary); }.card-title { font-size: 34rpx; font-weight: 850; }.label,.field>text { font-size: 25rpx; font-weight: 750; }.field { display: flex; flex-direction: column; gap: 12rpx; }.field input,.field textarea { width: 100%; min-height: 88rpx; padding: 20rpx; border: 1px solid var(--border); border-radius: 20rpx; background: #fff; font-size: 27rpx; }.field textarea { min-height: 180rpx; }.notice { color: var(--muted); font-size: 22rpx; line-height: 1.5; text-align: center; }</style>
