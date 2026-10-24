import type { SupportedStorage } from '@supabase/supabase-js'

/**
 * Auth session persistence for uni-app.
 * Mini programs / App have no localStorage; uni storage maps to localStorage on H5.
 */
export const uniStorage: SupportedStorage = {
  getItem: (key) => {
    const value = uni.getStorageSync(key)
    return value === '' || value === undefined || value === null ? null : String(value)
  },
  setItem: (key, value) => {
    uni.setStorageSync(key, value)
  },
  removeItem: (key) => {
    uni.removeStorageSync(key)
  }
}
