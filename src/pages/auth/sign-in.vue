<script setup lang="ts">
import { ref } from 'vue'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import { signIn, signUp } from '@/store/auth'
const email = ref('')
const password = ref('')
const loading = ref(false)
const message = ref('')
const submit = async (register: boolean) => {
  if (loading.value) return
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim()) || password.value.length < 6) {
    message.value = '请输入有效邮箱和至少 6 位密码；密码强度以服务端配置为准'
    return
  }
  loading.value = true
  message.value = ''
  try {
    if (register) {
      await signUp(email.value, password.value)
      message.value = '注册请求已提交。若开启邮箱确认，请查收邮件确认后再登录；若邮箱已注册，请直接登录。'
    } else {
      await signIn(email.value, password.value)
      password.value = ''
      uni.switchTab({ url: '/pages/profile/index' })
    }
  } catch (error) { message.value = error instanceof Error ? error.message : '认证失败' }
  finally { loading.value = false }
}
</script>
<template>
  <BasePage title="登录 GoGo Trip" subtitle="Supabase 真实账号 · 邮箱密码登录">
    <AppCard>
      <text>邮箱</text>
      <input v-model="email" class="field" placeholder="请输入你的邮箱" :disabled="loading" />
      <text>密码</text>
      <input v-model="password" class="field" password maxlength="128" placeholder="请输入密码" :disabled="loading" />
      <text v-if="message" class="message">{{ message }}</text>
      <AppButton label="登录" :loading="loading" @tap="submit(false)" />
      <AppButton label="注册邮箱账号" variant="secondary" :disabled="loading" @tap="submit(true)" />
    </AppCard>
    <text class="message">不再支持演示验证码 123456。注册可能发送确认邮件；服务未配置或限流时会显示真实错误。请勿将密码发到聊天中。</text>
    <text class="message">测试阶段使用邮箱登录；微信授权和短信登录尚未接入。登录不代表通过 18+ 结伴资格验证。</text>
  </BasePage>
</template>
<style scoped>
.field { box-sizing: border-box; height: 92rpx; padding: 20rpx; border: 1px solid var(--border); border-radius: 16rpx; font-size: 28rpx; }
.message { display: block; color: var(--muted); font-size: 24rpx; line-height: 1.7; }
</style>
