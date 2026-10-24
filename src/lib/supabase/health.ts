import { supabaseUrl, supabasePublishableKey, validateSupabaseConfig } from './config'

function probe(path: string): Promise<{ status: number; code?: string }> {
  return new Promise((resolve, reject) => {
    uni.request({
      url: `${supabaseUrl}${path}`,
      method: 'GET',
      header: { apikey: supabasePublishableKey },
      timeout: 15000,
      success: (response) => {
        const data = response.data as { code?: string } | null
        resolve({ status: response.statusCode, code: data?.code })
      },
      fail: () => reject(new Error('连接失败，请检查网络及微信 request 合法域名设置'))
    })
  })
}

export async function checkSupabaseConnection(): Promise<string> {
  validateSupabaseConfig()
  const auth = await probe('/auth/v1/settings')
  if (auth.status !== 200) throw new Error(`配置验证失败（HTTP ${auth.status}）`)
  const missing: string[] = []
  for (const table of ['posts', 'activities']) {
    const result = await probe(`/rest/v1/${table}?select=id&limit=0`)
    if (result.code === 'PGRST205') missing.push(table)
    else if (result.status !== 200) throw new Error(`${table} 访问失败（HTTP ${result.status}），请检查权限`)
  }
  return missing.length
    ? `配置验证通过；数据库尚未初始化：${missing.join('、')}。当前仍使用演示数据。`
    : '连接成功，公开表可访问。此检测不验证登录或写入权限。我的、行程列表和发现页已接入云端；其他演示页面另有标注。'
}
