<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import BasePage from '@/components/BasePage.vue'
import AppCard from '@/components/AppCard.vue'
import AppButton from '@/components/AppButton.vue'
import TagList from '@/components/TagList.vue'
import PostCard from '@/components/PostCard.vue'
import { listPosts, type CloudPost } from '@/lib/supabase/repository'
import { authState, initializeAuth } from '@/store/auth'
const posts = ref<CloudPost[]>([])
const loading = ref(false)
const error = ref('')
const city = ref('全部')
let requestId = 0
watch(() => authState.user?.id, () => { posts.value = []; requestId++ }, { flush: 'sync' })
const visiblePosts = computed(() => posts.value.filter(post => city.value === '全部' || post.city === city.value))
const load = async () => {
  await initializeAuth()
  const current = ++requestId
  loading.value = true
  error.value = ''
  posts.value = []
  try { const result = await listPosts(); if (current === requestId) posts.value = result }
  catch (cause) { if (current === requestId) error.value = cause instanceof Error ? cause.message : '加载失败' }
  finally { loading.value = false }
}
onShow(load)
const go = (id: string) => uni.navigateTo({ url: `/pages/discover/post?id=${id}` })
</script>
<template>
  <BasePage title="发现攻略" subtitle="Supabase 云端数据 · 不使用本地假攻略">
    <TagList :tags="['全部','泉州','杭州']" :selected="city" @select="city = $event" />
    <AppButton label="刷新攻略" variant="ghost" :loading="loading" @tap="load" />
    <AppCard v-if="error"><text>{{ error }}</text></AppCard>
    <AppCard v-else-if="!loading && !visiblePosts.length"><text>暂无已发布攻略，请先导入测试数据或由管理端发布。</text></AppCard>
    <PostCard v-for="post in visiblePosts" :key="post.id" :post="post" @tap="go(post.id)" />
  </BasePage>
</template>
