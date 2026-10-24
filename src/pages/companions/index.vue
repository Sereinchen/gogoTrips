<script setup lang="ts">
import { computed, ref } from 'vue'
import BasePage from '@/components/BasePage.vue'
import AppButton from '@/components/AppButton.vue'
import DemoNotice from '@/components/DemoNotice.vue'
import TagList from '@/components/TagList.vue'
import ActivityCard from '@/components/ActivityCard.vue'
import PersonCard from '@/components/PersonCard.vue'
import { people } from '@/data/mock-data'
import { useTravelStore } from '@/store/travel'

const { state } = useTravelStore()
const active = ref<'activity' | 'people'>('activity')
const city = ref('泉州')
const visibleActivities = computed(() => state.activities.filter((item) => city.value === '全部' || item.city === city.value))
const visiblePeople = computed(() => people.filter((item) => city.value === '全部' || item.city === city.value))
const go = (url: string) => uni.navigateTo({ url })
</script>

<template>
  <BasePage title="结伴同游" subtitle="公开必要信息，确认后再进入小队。">
    <template #action><view class="publish"><AppButton label="发布" variant="secondary" @tap="go('/pages/companions/activity-new')" /></view></template>
    <DemoNotice />
    <view class="segments"><text class="segment" :class="{ active: active === 'activity' }" @tap="active = 'activity'">找活动</text><text class="segment" :class="{ active: active === 'people' }" @tap="active = 'people'">找搭子</text></view>
    <TagList :tags="['泉州', '杭州', '全部']" :selected="city" @select="city = $event" />
    <template v-if="active === 'activity'"><ActivityCard v-for="activity in visibleActivities" :key="activity.id" :activity="activity" @tap="go(`/pages/companions/activity-detail?id=${activity.id}`)" /></template>
    <template v-else>
      <view class="section"><text class="section-title">与你时间相近</text><text class="link" @tap="go('/pages/companions/intent')">编辑我的意向</text></view>
      <PersonCard v-for="person in visiblePeople" :key="person.id" :person="person" @tap="go(`/pages/companions/person?id=${person.id}`)" />
    </template>
  </BasePage>
</template>

<style scoped>.publish { width: 150rpx; }.segments { display: flex; padding: 8rpx; border-radius: 22rpx; background: var(--surface-muted); }.segment { flex: 1; padding: 20rpx; color: var(--muted); text-align: center; font-weight: 800; border-radius: 16rpx; }.segment.active { color: var(--primary); background: #fff; }.section { display: flex; justify-content: space-between; align-items: center; }.section-title { font-size: 34rpx; font-weight: 850; }.link { color: var(--primary); font-size: 24rpx; font-weight: 750; }</style>
