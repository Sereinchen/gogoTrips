<script setup lang="ts">
import { computed, nextTick, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import DemoNotice from '@/components/DemoNotice.vue'
import { useTravelStore } from '@/store/travel'
const { state, sendMessage } = useTravelStore()
const id = ref('')
const text = ref('')
const bottomId = ref('bottom')
onLoad((options) => { id.value = String(options?.id || '') })
const team = computed(() => state.teams.find((item) => item.id === id.value))
const send = async () => { const body = text.value.trim(); if (!body || !team.value) return; sendMessage(team.value.id, body); text.value = ''; await nextTick(); bottomId.value = ''; await nextTick(); bottomId.value = 'bottom' }
</script>

<template><view class="chat"><view class="demo"><DemoNotice /></view><scroll-view v-if="team" scroll-y class="messages" :scroll-into-view="bottomId"><template v-for="message in team.messages" :key="message.id"><text v-if="message.system" class="system">{{ message.body }}</text><view v-else class="row" :class="{ mine: message.mine }"><text class="avatar">{{ message.avatar }}</text><view class="bubble"><text class="sender">{{ message.sender }}</text><text class="body">{{ message.body }}</text><text class="time">{{ message.time }} {{ message.status === 'sent' ? '✓' : '' }}</text></view></view></template><view id="bottom" /></scroll-view><view class="composer"><textarea v-model="text" auto-height maxlength="500" placeholder="说点什么…" /><button @tap="send">发送</button></view></view></template>
<style scoped>.chat { height: 100vh; display: flex; flex-direction: column; background: var(--background); }.demo { padding: 18rpx 24rpx; }.messages { flex: 1; min-height: 0; padding: 24rpx; }.system { display: block; width: fit-content; margin: 14rpx auto; padding: 12rpx 20rpx; border-radius: 999rpx; color: var(--muted); background: var(--surface-muted); font-size: 21rpx; }.row { max-width: 86%; margin-bottom: 22rpx; display: flex; align-items: flex-end; gap: 12rpx; }.row.mine { margin-left: auto; flex-direction: row-reverse; }.avatar { font-size: 40rpx; }.bubble { padding: 18rpx 20rpx; display: flex; flex-direction: column; gap: 6rpx; border: 1px solid var(--border); border-radius: 24rpx; background: #fff; }.mine .bubble { color: #fff; background: var(--primary); border-color: var(--primary); }.sender,.time { color: var(--muted); font-size: 19rpx; }.mine .sender,.mine .time { color: #cdeadd; }.body { font-size: 26rpx; line-height: 1.5; }.time { text-align: right; }.composer { padding: 18rpx 22rpx calc(18rpx + env(safe-area-inset-bottom)); display: flex; align-items: flex-end; gap: 12rpx; border-top: 1px solid var(--border); background: #fff; }.composer textarea { flex: 1; min-height: 78rpx; max-height: 180rpx; padding: 18rpx 24rpx; border-radius: 40rpx; background: var(--surface-muted); font-size: 25rpx; }.composer button { width: 120rpx; height: 78rpx; margin: 0; display: flex; align-items: center; justify-content: center; border-radius: 40rpx; color: #fff; background: var(--primary); font-size: 24rpx; font-weight: 800; }</style>
