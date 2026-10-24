<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { useTravelStore } from '@/store/travel'

const { state } = useTravelStore()
const id = ref('')
const instruction = ref('第二天轻松一点，少走路')
const preview = ref(false)
const saved = ref(false)
onLoad((options) => { id.value = String(options?.id || '') })
const trip = computed(() => state.trips.find((item) => item.id === id.value))
</script>

<template>
  <BasePage compact><DemoNotice /><AppCard v-if="trip"><text class="title">手工调整</text><view v-for="item in trip.days[0].items" :key="item.id" class="item"><text class="handle">≡</text><view class="copy"><text class="label">{{ item.title }}</text><text class="muted">{{ item.time }}–{{ item.endTime }} · {{ item.area }}</text></view><text>{{ item.locked ? '🔒' : '•••' }}</text></view><AppButton label="＋ 添加地点" variant="ghost" /></AppCard><AppCard><text class="title">用 AI 帮我调整</text><textarea v-model="instruction" class="textarea" /><AppButton label="生成变更预览" @tap="preview = true" /></AppCard><text v-if="trip" class="history">版本历史 · 当前 v{{ trip.version }} · 可回滚上一版本</text><StatusBadge v-if="saved" label="变更已应用（演示）" tone="success" />
    <view v-if="preview" class="overlay" @tap.self="preview = false"><view class="sheet"><text class="title">变更预览</text><StatusBadge label="尚未写入" tone="warning" /><view class="diff"><text class="minus">− 删除 Day 2 下午的永宁古城</text><text class="plus">＋ 增加海边咖啡休息 90 分钟</text><text class="muted">预计步行减少 3.2km · 预算增加 ¥38</text></view><AppButton label="确认应用" @tap="preview = false; saved = true" /><AppButton label="取消，不做修改" variant="ghost" @tap="preview = false" /></view></view>
  </BasePage>
</template>

<style scoped>.title { font-size: 34rpx; font-weight: 850; }.item { display: flex; align-items: center; gap: 18rpx; padding: 12rpx 0; }.handle { color: var(--muted); font-size: 34rpx; }.copy { flex: 1; display: flex; flex-direction: column; gap: 6rpx; }.label { font-size: 26rpx; font-weight: 800; }.muted { color: var(--muted); font-size: 23rpx; line-height: 1.5; }.textarea { width: 100%; min-height: 180rpx; padding: 20rpx; border: 1px solid var(--border); border-radius: 20rpx; background: #fff; font-size: 26rpx; }.history { color: var(--primary); font-size: 23rpx; font-weight: 750; text-align: center; }.overlay { position: fixed; inset: 0; z-index: 99; display: flex; justify-content: flex-end; background: rgba(10,32,27,.45); }.sheet { padding: 38rpx 28rpx 60rpx; display: flex; flex-direction: column; gap: 24rpx; border-radius: 38rpx 38rpx 0 0; background: #fff; }.diff { padding: 22rpx; display: flex; flex-direction: column; gap: 14rpx; border-radius: 20rpx; background: var(--surface-muted); }.minus { color: var(--danger); font-size: 25rpx; }.plus { color: var(--success); font-size: 25rpx; }</style>
