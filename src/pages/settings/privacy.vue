<script setup lang="ts">
import { ref } from 'vue'
import AppButton from '@/components/AppButton.vue'
import AppCard from '@/components/AppCard.vue'
import BasePage from '@/components/BasePage.vue'

const showMatchIntent = ref(true)
const activityNotice = ref(true)
const preciseLocation = ref(false)

const updateSwitch = (target: 'intent' | 'notice' | 'location', event: Event) => {
  const checked = (event as CustomEvent<{ value: boolean }>).detail.value
  if (target === 'intent') showMatchIntent.value = checked
  if (target === 'notice') activityNotice.value = checked
  if (target === 'location') preciseLocation.value = checked
}

const save = () => uni.showToast({ title: '隐私设置已保存', icon: 'success' })
const clearData = () => {
  uni.showModal({
    title: '清除本地演示数据',
    content: '当前版本只使用本地假数据，不会影响任何线上账号。',
    confirmText: '确认清除',
    success: ({ confirm }) => confirm && uni.showToast({ title: '已清除', icon: 'success' })
  })
}
</script>

<template>
  <BasePage title="隐私与安全" subtitle="按需控制匹配资料、位置和通知范围">
    <AppCard title="资料可见性" subtitle="仅在你主动开启匹配时展示旅行意向">
      <view class="setting-row">
        <view class="setting-copy">
          <text class="setting-title">展示旅行匹配意向</text>
          <text class="setting-desc">城市、日期、旅行节奏和兴趣标签</text>
        </view>
        <switch :checked="showMatchIntent" color="#e7683f" @change="updateSwitch('intent', $event)" />
      </view>
      <view class="setting-row">
        <view class="setting-copy">
          <text class="setting-title">允许活动状态通知</text>
          <text class="setting-desc">申请结果、集合提醒与队伍变更</text>
        </view>
        <switch :checked="activityNotice" color="#e7683f" @change="updateSwitch('notice', $event)" />
      </view>
    </AppCard>

    <AppCard title="位置权限" subtitle="默认只展示城市或区域，不公开实时位置">
      <view class="setting-row setting-row--last">
        <view class="setting-copy">
          <text class="setting-title">使用精确位置</text>
          <text class="setting-desc">仅在地图导航等明确场景临时使用</text>
        </view>
        <switch :checked="preciseLocation" color="#e7683f" @change="updateSwitch('location', $event)" />
      </view>
    </AppCard>

    <AppCard title="安全原则">
      <text class="safe-item">• 首次见面请选择公共场所，并告知亲友</text>
      <text class="safe-item">• 平台不鼓励私下转账、代订或拼车交易</text>
      <text class="safe-item">• 遇到骚扰或异常信息可立即退出并举报</text>
    </AppCard>

    <AppButton @tap="save">保存设置</AppButton>
    <AppButton variant="ghost" @tap="clearData">清除本地演示数据</AppButton>
  </BasePage>
</template>

<style scoped>
.setting-row { display: flex; align-items: center; justify-content: space-between; gap: 24rpx; padding: 24rpx 0; border-bottom: 1rpx solid #edf0ef; }
.setting-row--last, .setting-row:last-child { border-bottom: 0; }
.setting-copy { flex: 1; }
.setting-title, .setting-desc, .safe-item { display: block; }
.setting-title { color: #2e3533; font-size: 28rpx; font-weight: 700; }
.setting-desc { margin-top: 6rpx; color: #87908d; font-size: 22rpx; line-height: 1.55; }
.safe-item { margin: 14rpx 0; color: #5d6965; font-size: 25rpx; line-height: 1.65; }
</style>
