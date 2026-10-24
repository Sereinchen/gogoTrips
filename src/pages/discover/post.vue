<script setup lang="ts">
import { ref, watch } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import TagList from '@/components/TagList.vue'
import { listPosts, setBookmark, type CloudPost } from '@/lib/supabase/repository'
import { authState, initializeAuth } from '@/store/auth'
const post = ref<CloudPost | null>(null)
const postId = ref('')
const loading = ref(false)
const saving = ref(false)
const error = ref('')
let requestId = 0
watch(() => authState.user?.id, () => { post.value = null; requestId++ }, { flush: 'sync' })
onLoad(query => { postId.value = String(query?.id || '') })
const load = async () => {
  await initializeAuth()
  const current = ++requestId
  loading.value = true
  error.value = ''
  post.value = null
  try {
    if (!/^[0-9a-f-]{36}$/i.test(postId.value)) throw new Error('无效的云端攻略 ID，请从发现页重新进入')
    const rows = await listPosts(postId.value)
    if (current === requestId) {
      post.value = rows[0] || null
      if (!post.value) error.value = '攻略不存在、未发布或已删除'
    }
  } catch (cause) { if (current === requestId) error.value = cause instanceof Error ? cause.message : '读取失败' }
  finally { loading.value = false }
}
onShow(load)
const bookmark = async () => {
  if (!post.value || saving.value) return
  saving.value = true
  error.value = ''
  const target = post.value
  try { await setBookmark(target.id, !target.bookmarked); if (post.value === target) target.bookmarked = !target.bookmarked }
  catch (cause) { error.value = cause instanceof Error ? cause.message : '收藏失败' }
  finally { saving.value = false }
}
</script>
<template>
  <BasePage title="攻略详情" subtitle="云端公开攻略">
    <AppButton label="重新加载" variant="ghost" :loading="loading" @tap="load" />
    <AppCard v-if="error"><text>{{ error }}</text></AppCard>
    <AppCard v-if="post">
      <text class="emoji">{{ post.coverEmoji }}</text><text class="title">{{ post.title }}</text>
      <text>作者：{{ post.author }}</text><text class="body">{{ post.summary }}</text><TagList :tags="post.places" />
      <AppButton :label="post.bookmarked ? '取消收藏' : '收藏攻略'" :loading="saving" @tap="bookmark" />
      <text class="hint">收藏实际写入当前账号。复制为行程的事务接口尚未部署，暂不提供复制操作。</text>
    </AppCard>
  </BasePage>
</template>
<style scoped>
.emoji { font-size: 100rpx; }
.title { font-size: 36rpx; font-weight: 700; }
.body { font-size: 28rpx; line-height: 1.7; }
.hint { color: var(--muted); font-size: 24rpx; line-height: 1.6; }
</style>
