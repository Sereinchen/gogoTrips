import { supabaseUrl, supabasePublishableKey, validateSupabaseConfig } from './config'

export class BackendError extends Error {
  constructor(message: string, public status: number, public code?: string) { super(message) }
}

export interface RequestOptions {
  method?: 'GET' | 'POST' | 'DELETE'
  data?: Record<string, unknown>
  token?: string
  prefer?: string
}

export function backendRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  validateSupabaseConfig()
  if (!path.startsWith('/auth/v1/') && !path.startsWith('/rest/v1/')) throw new Error('非法后端路径')
  return new Promise((resolve, reject) => {
    const header: Record<string, string> = { apikey: supabasePublishableKey, 'Content-Type': 'application/json' }
    if (options.token) header.Authorization = `Bearer ${options.token}`
    if (options.prefer) header.Prefer = options.prefer
    uni.request({
      url: supabaseUrl + path,
      method: options.method || 'GET',
      header,
      data: options.data,
      timeout: 20000,
      success: (response) => {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          resolve(response.data as T)
          return
        }
        const error = response.data as { message?: string; msg?: string; error_description?: string; code?: string }
        reject(new BackendError(error?.msg || error?.message || error?.error_description || `请求失败 HTTP ${response.statusCode}`, response.statusCode, error?.code))
      },
      fail: () => reject(new BackendError('网络连接失败，请检查网络和微信 request 合法域名', 0))
    })
  })
}
