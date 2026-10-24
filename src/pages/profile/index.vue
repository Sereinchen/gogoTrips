<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import BackendStatus from '@/components/BackendStatus.vue'
import { authState, initializeAuth, loadProfile, signOut } from '@/store/auth'
const loading = ref(false)
const message = ref('')
const reload = async () => {
  loading.value = true
  message.value = ''
  try { await initializeAuth(); await loadProfile() }
  catch (error) { message.value = error instanceof Error ? error.message : '资料加载失败' }
  finally { loading.value = false }
}
onShow(reload)
const login = () => uni.navigateTo({ url: '/pages/auth/sign-in' })
const logout = async () => {
  if (loading.value) return
  loading.value = true
  try { await signOut(); message.value = '已退出登录' }
  catch { message.value = '本机已退出，但服务端会话撤销失败。旧访问令牌可能在过期前仍然有效，请检查网络。' }
  finally { loading.value = false }
}
const copyId = () => { if (authState.user) uni.setClipboardData({ data: authState.user.id }) }
</script>
<template>
  <BasePage title="我的" subtitle="真实账号与云端资料">
    <BackendStatus />
    <AppCard v-if="authState.user">
      <text class="name">{{ authState.profile?.avatar || '🌿' }} {{ authState.profile?.name || '资料待加载' }}</text>
      <text class="muted">{{ authState.user.email }}</text>
      <text class="muted">用户 ID：{{ authState.user.id }}</text>
      <StatusBadge :label="authState.profile?.verified ? '结伴资格已验证' : '结伴资格未验证'" :tone="authState.profile?.verified ? 'success' : 'warning'" />
      <AppButton label="复制用户 ID（导入测试数据用）" variant="secondary" @tap="copyId" />
      <AppButton label="刷新个人资料" variant="ghost" :loading="loading" @tap="reload" />
      <AppButton label="退出登录" variant="ghost" :disabled="loading" @tap="logout" />
    </AppCard>
    <AppCard v-else><text class="name">尚未登录</text><text class="muted">登录后查看私人行程、收藏攻略。</text><AppButton label="登录 / 注册" @tap="login" /></AppCard>
    <text v-if="message || authState.error" class="muted">{{ message || authState.error }}</text>
    <text class="muted">账号、行程列表和发现页使用云端接口。AI、结伴与聊天仍为独立演示，不代表真实报名或消息发送。</text>
  </BasePage>
</template>
<style scoped>
.name { font-size: 34rpx; font-weight: 700; }
.muted { display: block; color: var(--muted); font-size: 24rpx; line-height: 1.7; word-break: break-all; }
</style>
