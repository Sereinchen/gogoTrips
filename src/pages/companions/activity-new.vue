<script setup lang="ts">
import { ref } from 'vue'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { useTravelStore } from '@/store/travel'
const { publishActivity } = useTravelStore()
const title = ref('西街夜拍与小吃散步')
const city = ref('泉州')
const review = ref(false)
const publish = () => { const activity = publishActivity({ title: title.value, city: city.value, date: '11月9日', time: '18:30–21:00', category: '城市漫步', meetupArea: '西街钟楼附近', description: '边走边吃，沿途拍夜景。具体集合点确认后通知。', capacity: 4, costPolicy: '餐饮各自支付' }); review.value = false; uni.redirectTo({ url: `/pages/companions/activity-detail?id=${activity.id}` }) }
</script>

<template><BasePage compact><DemoNotice /><AppCard><text class="title">活动信息</text><view class="field"><text>活动名称</text><input v-model="title" /></view><view class="field"><text>活动类型</text><input value="城市漫步" /></view><view class="field"><text>日期与时间</text><input value="11月9日 · 18:30–21:00" /></view><view class="field"><text>城市</text><input v-model="city" /></view><view class="field"><text>公开集合区域</text><input value="西街钟楼附近" /><text class="hint">请勿填写酒店、房间号或精确私人地址。</text></view><view class="field"><text>人数上限</text><input value="4" type="number" /></view><view class="field"><text>费用方式</text><input value="餐饮各自支付" /></view><view class="field"><text>活动说明</text><textarea value="边走边吃，沿途拍夜景。具体集合点确认后通知。" /></view></AppCard><AppCard><StatusBadge label="已关联泉州行程片段" tone="success" /><text class="body">Day 1 · 西街小吃漫游</text><text class="muted">只会公开这一活动片段，不公开酒店和其他日期。</text></AppCard><AppButton label="预览公开内容" @tap="review = true" /><view v-if="review" class="overlay" @tap.self="review = false"><view class="sheet"><text class="title">公开内容确认</text><StatusBadge label="公众可见" tone="warning" /><text class="body">{{ title }}</text><text class="muted">{{ city }} · 11月9日 · 18:30–21:00</text><text class="muted">集合区域：西街钟楼附近</text><text class="muted">不会公开：完整行程、酒店信息、精确实时位置</text><AppButton label="确认发布" @tap="publish" /><AppButton label="返回修改" variant="ghost" @tap="review = false" /></view></view></BasePage></template>
<style scoped>.title { font-size: 34rpx; font-weight: 850; }.body { font-size: 27rpx; line-height: 1.55; }.muted,.hint { color: var(--muted); font-size: 22rpx; line-height: 1.5; }.field { display: flex; flex-direction: column; gap: 10rpx; font-size: 24rpx; font-weight: 750; }.field input,.field textarea { min-height: 88rpx; padding: 20rpx; border: 1px solid var(--border); border-radius: 20rpx; font-size: 26rpx; }.field textarea { min-height: 160rpx; }.overlay { position: fixed; inset: 0; z-index: 99; display: flex; justify-content: flex-end; background: rgba(10,32,27,.45); }.sheet { padding: 38rpx 28rpx 60rpx; display: flex; flex-direction: column; gap: 24rpx; border-radius: 38rpx 38rpx 0 0; background: #fff; }</style>
