export type JoinStatus = 'none' | 'pending' | 'approved' | 'confirmed' | 'rejected' | 'withdrawn' | 'expired'
export type ActivityStatus = 'open' | 'full' | 'cancelled' | 'completed'
export interface TripItem { id: string; time: string; endTime: string; title: string; area: string; duration: string; transport?: string; cost: number | null; locked?: boolean; pendingVerification?: boolean }
export interface TripDay { date: string; label: string; items: TripItem[] }
export interface Trip { id: string; city: string; dateRange: string; timezone: string; budget: number; currency: string; coverEmoji: string; status: 'draft' | 'saved'; private: boolean; version: number; days: TripDay[] }
export interface Person { id: string; name: string; avatar: string; city: string; dateRange: string; interests: string[]; pace: string; intro: string; verified: boolean }
export interface Activity { id: string; title: string; city: string; date: string; time: string; category: string; organizer: Person; meetupArea: string; description: string; capacity: number; joined: number; costPolicy: string; status: ActivityStatus; joinStatus: JoinStatus; teamId?: string; tags: string[] }
export interface Post { id: string; title: string; city: string; author: string; coverEmoji: string; summary: string; places: string[]; savedCount?: number; bookmarked: boolean }
export interface Message { id: string; sender: string; avatar: string; body: string; time: string; mine?: boolean; system?: boolean; status?: 'sending' | 'sent' | 'failed' }
export interface Team { id: string; activityId: string; members: Person[]; meetupDetail: string; proposal?: { id: string; title: string; before: string; after: string; status: 'pending' | 'approved' | 'rejected' }; messages: Message[] }
