import type { Post, Trip } from '@/types'
import { backendRequest } from './request'
import { authorizedRequest, authState, initializeAuth } from '@/store/auth'

interface PostRow {
  id: string; title: string; city: string; cover_emoji: string; summary: string; places: string[]
  profiles: { name: string } | null
}
export interface CloudPost extends Omit<Post, 'savedCount'> { savedCount?: number }
export async function listPosts(id?: string): Promise<CloudPost[]> {
  const filter = id ? `&id=eq.${encodeURIComponent(id)}` : ''
  const rows = await backendRequest<PostRow[]>(`/rest/v1/posts?select=id,title,city,cover_emoji,summary,places,profiles!posts_author_id_fkey(name)&status=eq.published&order=created_at.desc&limit=50${filter}`)
  await initializeAuth()
  const bookmarks = authState.user
    ? await authorizedRequest<{ post_id: string }[]>(`/rest/v1/post_bookmarks?user_id=eq.${authState.user.id}&select=post_id`)
    : []
  return rows.map(row => ({
    id: row.id, title: row.title, city: row.city, coverEmoji: row.cover_emoji,
    summary: row.summary, places: row.places, author: row.profiles?.name || '作者未公开资料',
    bookmarked: bookmarks.some(bookmark => bookmark.post_id === row.id)
  }))
}

export async function setBookmark(postId: string, bookmarked: boolean) {
  await initializeAuth()
  const userId = authState.user?.id
  if (!userId) throw new Error('请先在“我的”页面登录')
  if (bookmarked) {
    await authorizedRequest('/rest/v1/post_bookmarks?on_conflict=user_id,post_id', {
      method: 'POST', data: { user_id: userId, post_id: postId },
      prefer: 'resolution=ignore-duplicates,return=minimal'
    })
  } else {
    await authorizedRequest(`/rest/v1/post_bookmarks?user_id=eq.${userId}&post_id=eq.${encodeURIComponent(postId)}`, { method: 'DELETE' })
  }
}

interface TripRow {
  id: string; city: string; date_range: string; timezone: string; budget: number; currency: string
  cover_emoji: string; status: 'draft' | 'saved'; is_private: boolean; version: number
  trip_days: { id: string; date: string | null; label: string; sort_order: number; trip_items: {
    id: string; time: string | null; end_time: string | null; title: string; area: string; duration: string
    transport: string | null; cost: number | null; locked: boolean; pending_verification: boolean; sort_order: number
  }[] }[]
}
export async function listTrips(id?: string): Promise<Trip[]> {
  await initializeAuth()
  if (!authState.user) throw new Error('请先登录查看私人行程')
  const filter = id ? `&id=eq.${encodeURIComponent(id)}` : ''
  const rows = await authorizedRequest<TripRow[]>(`/rest/v1/trips?select=*,trip_days(*,trip_items(*))&owner_id=eq.${authState.user.id}&order=created_at.desc&limit=50${filter}`)
  return rows.map(row => ({
    id: row.id, city: row.city, dateRange: row.date_range, timezone: row.timezone,
    budget: row.budget, currency: row.currency, coverEmoji: row.cover_emoji, status: row.status,
    private: row.is_private, version: row.version,
    days: row.trip_days.sort((first, second) => first.sort_order - second.sort_order).map(day => ({
      date: day.date || '待定', label: day.label,
      items: day.trip_items.sort((first, second) => first.sort_order - second.sort_order).map(item => ({
        id: item.id, time: item.time?.slice(0, 5) || '待定', endTime: item.end_time?.slice(0, 5) || '待定',
        title: item.title, area: item.area, duration: item.duration, transport: item.transport || undefined,
        cost: item.cost, locked: item.locked, pendingVerification: item.pending_verification
      }))
    }))
  }))
}
