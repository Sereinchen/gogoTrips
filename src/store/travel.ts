import { reactive } from 'vue'
import { activities, posts, teams, trips } from '@/data/mock-data'
import type { Activity, JoinStatus, Message, Trip } from '@/types'

const state = reactive({
  trips: [...trips],
  activities: [...activities],
  posts: [...posts],
  teams: [...teams]
})

type PublishInput = Pick<Activity, 'title' | 'city' | 'date' | 'time' | 'category' | 'meetupArea' | 'description' | 'capacity' | 'costPolicy'>

export function useTravelStore() {
  const createGeneratedTrip = async (city: string) => {
    await new Promise((resolve) => setTimeout(resolve, 700))
    const generated: Trip = { ...trips[0], id: `trip-${Date.now()}`, city: city || '泉州', dateRange: '待保存草案 · 3天2晚', status: 'draft', version: 1 }
    state.trips.unshift(generated)
    return generated
  }

  const updateJoinStatus = (activityId: string, status: JoinStatus) => {
    const activity = state.activities.find((item) => item.id === activityId)
    if (!activity) return
    activity.joinStatus = status
    if (status === 'confirmed') activity.joined = Math.min(activity.joined + 1, activity.capacity)
  }

  const publishActivity = (input: PublishInput) => {
    const activity: Activity = { ...input, id: `activity-${Date.now()}`, organizer: activities[0].organizer, joined: 1, status: 'open', joinStatus: 'confirmed', tags: [input.category, input.city] }
    state.activities.unshift(activity)
    return activity
  }

  const toggleBookmark = (postId: string) => {
    const post = state.posts.find((item) => item.id === postId)
    if (!post) return
    post.bookmarked = !post.bookmarked
    if (post.savedCount !== undefined) post.savedCount += post.bookmarked ? 1 : -1
  }

  const copyPostToTrip = (postId: string) => {
    const post = state.posts.find((item) => item.id === postId)
    if (!post) return
    const trip: Trip = { ...trips[1], id: `trip-${Date.now()}`, city: post.city, dateRange: '由攻略复制 · 待安排日期', coverEmoji: post.coverEmoji, status: 'draft', version: 1, days: [{ date: '待定', label: `来自 ${post.author} 的攻略草案`, items: post.places.map((place, index) => ({ id: `copied-${index}`, time: `${9 + index * 2}:00`, endTime: `${10 + index * 2}:30`, title: place, area: post.city, duration: '待确认', cost: 0, pendingVerification: true })) }] }
    state.trips.unshift(trip)
    return trip
  }

  const sendMessage = (teamId: string, body: string) => {
    const team = state.teams.find((item) => item.id === teamId)
    if (!team) return
    const message: Message = { id: `message-${Date.now()}`, sender: '林小满', avatar: '🌿', body, time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }), mine: true, status: 'sent' }
    team.messages.push(message)
  }

  const resolveProposal = (teamId: string, decision: 'approved' | 'rejected') => {
    const team = state.teams.find((item) => item.id === teamId)
    if (team?.proposal) team.proposal.status = decision
  }

  return { state, createGeneratedTrip, updateJoinStatus, publishActivity, toggleBookmark, copyPostToTrip, sendMessage, resolveProposal }
}
