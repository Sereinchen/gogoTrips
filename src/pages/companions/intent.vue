<script setup lang="ts">
import { ref } from 'vue'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import TagList from '@/components/TagList.vue'
const visible = ref(true)
const saved = ref(false)
</script>

<template><BasePage compact><DemoNotice /><AppCard><text class="title">公开旅行意向</text><StatusBadge :label="visible ? '当前公开' : '仅自己可见'" :tone="visible ? 'success' : 'muted'" /><view class="field"><text>目的地</text><input value="泉州" /></view><view class="field"><text>出行窗口</text><input value="2026-11-09 至 2026-11-12" /></view><view class="field"><text>可结伴时段</text><input value="11月9日晚、11月10日全天" /></view><text class="label">兴趣标签</text><TagList :tags="['古城','小吃','摄影']" selected="古城" /><view class="field"><text>公开简介</text><textarea value="希望一起慢慢逛街拍照，行程不赶。" /></view><text class="privacy">公开后只展示本页信息，不展示完整私人行程、酒店或联系方式。</text><AppButton :label="saved ? '已保存' : '保存旅行意向'" @tap="saved = true" /><AppButton :label="visible ? '停止公开' : '重新公开'" :variant="visible ? 'danger' : 'secondary'" @tap="visible = !visible" /></AppCard></BasePage></template>
<style scoped>.title { font-size: 34rpx; font-weight: 850; }.label,.field>text { font-size: 25rpx; font-weight: 750; }.field { display: flex; flex-direction: column; gap: 10rpx; }.field input,.field textarea { min-height: 88rpx; padding: 20rpx; border: 1px solid var(--border); border-radius: 20rpx; background: #fff; font-size: 26rpx; }.field textarea { min-height: 160rpx; }.privacy { color: var(--muted); font-size: 22rpx; line-height: 1.55; }</style>
