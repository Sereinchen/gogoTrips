import { reactive } from 'vue'
import { backendRequest, BackendError, type RequestOptions } from '@/lib/supabase/request'
import { supabaseUrl } from '@/lib/supabase/config'

interface AuthUser { id: string; email?: string }
interface Session { access_token: string; refresh_token: string; expires_at: number; expires_in?: number; user: AuthUser }
export interface Profile { id: string; name: string; avatar: string; city: string; intro: string; verified: boolean; is_public: boolean }
export const authState = reactive({ user: null as AuthUser | null, profile: null as Profile | null, ready: false, error: '' })
const storageKey = `gogo-auth:${supabaseUrl}`
let session: Session | null = null
let revision = 0
let initializing: Promise<void> | null = null
let refreshing: Promise<void> | null = null

function saveSession(next: Session) {
  next.expires_at = next.expires_at || Math.floor(Date.now() / 1000) + (next.expires_in || 3600)
  uni.setStorageSync(storageKey, JSON.stringify(next))
  session = next
  authState.user = next.user
}

function clearSession() {
  revision++
  session = null
  authState.user = null
  authState.profile = null
  uni.removeStorageSync(storageKey)
}

async function refresh() {
  if (refreshing) return refreshing
  if (!session) throw new Error('请先登录')
  const currentRevision = revision
  const refreshToken = session.refresh_token
  refreshing = (async () => {
    try {
      const next = await backendRequest<Session>('/auth/v1/token?grant_type=refresh_token', {
        method: 'POST', data: { refresh_token: refreshToken }
      })
      if (currentRevision !== revision) throw new Error('登录状态已变化，请重试')
      saveSession(next)
    } catch (error) {
      if (currentRevision === revision && error instanceof BackendError && [400, 401, 403].includes(error.status)) clearSession()
      throw error
    }
  })().finally(() => { refreshing = null })
  return refreshing
}

export async function initializeAuth() {
  if (authState.ready) return
  if (initializing) return initializing
  initializing = (async () => {
    try {
      const raw = uni.getStorageSync(storageKey)
      if (!raw) return
      const saved = JSON.parse(String(raw)) as Session
      if (!saved.access_token || !saved.refresh_token || !saved.user?.id) { clearSession(); return }
      session = saved
      if (!session.expires_at || session.expires_at <= Date.now() / 1000 + 60) await refresh()
      const user = await backendRequest<AuthUser>('/auth/v1/user', { token: session?.access_token })
      if (session) { session.user = user; authState.user = user }
    } catch (error) {
      authState.error = error instanceof Error ? error.message : '恢复登录失败'
      if (!(error instanceof BackendError) || [400, 401, 403].includes(error.status)) clearSession()
    } finally {
      authState.ready = true
    }
  })()
  return initializing
}

export async function authorizedRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  await initializeAuth()
  if (!session || !authState.user) throw new Error('请先登录后操作')
  if (session.expires_at <= Date.now() / 1000 + 60) await refresh()
  const currentRevision = revision
  try {
    const result = await backendRequest<T>(path, { ...options, token: session!.access_token })
    if (currentRevision !== revision) throw new Error('账号已切换，请重新加载')
    return result
  } catch (error) {
    if (!(error instanceof BackendError) || error.status !== 401 || currentRevision !== revision) throw error
    await refresh()
    const result = await backendRequest<T>(path, { ...options, token: session!.access_token })
    if (currentRevision !== revision) throw new Error('账号已切换，请重新加载')
    return result
  }
}

export async function loadProfile() {
  await initializeAuth()
  const userId = authState.user?.id
  if (!userId) return
  authState.error = ''
  try {
    let rows = await authorizedRequest<Profile[]>(`/rest/v1/profiles?id=eq.${userId}&select=id,name,avatar,city,intro,verified,is_public`)
    if (!rows.length) {
      await authorizedRequest('/rest/v1/profiles?on_conflict=id', {
        method: 'POST', data: { id: userId, name: '旅行者' },
        prefer: 'resolution=ignore-duplicates,return=minimal'
      })
      rows = await authorizedRequest<Profile[]>(`/rest/v1/profiles?id=eq.${userId}&select=id,name,avatar,city,intro,verified,is_public`)
    }
    if (!rows[0]) throw new Error('未能加载用户资料，请检查 profiles 权限')
    if (authState.user?.id === userId) authState.profile = rows[0]
  } catch (error) {
    authState.error = error instanceof Error ? error.message : '资料加载失败'
    throw error
  }
}

export async function signIn(email: string, password: string) {
  await initializeAuth()
  const next = await backendRequest<Session>('/auth/v1/token?grant_type=password', {
    method: 'POST', data: { email: email.trim(), password }
  })
  clearSession()
  saveSession(next)
  authState.error = ''
}

export async function signUp(email: string, password: string) {
  await initializeAuth()
  await backendRequest('/auth/v1/signup', { method: 'POST', data: { email: email.trim(), password } })
}

export async function signOut() {
  const token = session?.access_token
  clearSession()
  authState.error = ''
  if (token) await backendRequest('/auth/v1/logout?scope=local', { method: 'POST', token })
}
