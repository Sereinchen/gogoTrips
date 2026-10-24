import { createClient } from '@supabase/supabase-js'
import { uniFetch } from './uni-fetch'
import { uniStorage } from './uni-storage'
import { supabaseUrl, supabasePublishableKey, validateSupabaseConfig } from './config'

validateSupabaseConfig()

export const supabase = createClient(supabaseUrl, supabasePublishableKey, {
  auth: {
    storage: uniStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
    flowType: 'pkce'
  },
  global: {
    fetch: uniFetch
  }
})
