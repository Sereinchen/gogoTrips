export const supabaseUrl = (import.meta.env.VITE_SUPABASE_URL || '').trim().replace(/[)\]/]+$/g, '')
export const supabasePublishableKey = (import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || '').trim()

export function validateSupabaseConfig() {
  if (!/^https:\/\/[a-z0-9-]+\.supabase\.co$/.test(supabaseUrl)) {
    throw new Error('请配置有效的 VITE_SUPABASE_URL')
  }
  if (!supabasePublishableKey.startsWith('sb_publishable_')) {
    throw new Error('客户端必须使用 Supabase Publishable key，不能使用服务端密钥')
  }
}
