type UniRequestMethod =
  | 'GET'
  | 'POST'
  | 'PUT'
  | 'DELETE'
  | 'PATCH'
  | 'HEAD'
  | 'OPTIONS'

class UniHeaders {
  private map = new Map<string, string>()

  constructor(init?: Record<string, string>) {
    if (!init) return
    Object.entries(init).forEach(([key, value]) => {
      if (value != null) this.map.set(key.toLowerCase(), String(value))
    })
  }

  get(name: string) {
    return this.map.get(name.toLowerCase()) ?? null
  }

  has(name: string) {
    return this.map.has(name.toLowerCase())
  }

  forEach(callback: (value: string, key: string) => void) {
    this.map.forEach((value, key) => callback(value, key))
  }

  toRecord() {
    const result: Record<string, string> = {}
    this.map.forEach((value, key) => {
      result[key] = value
    })
    return result
  }
}

class UniResponse {
  readonly ok: boolean
  readonly status: number
  readonly statusText: string
  readonly headers: UniHeaders
  readonly url: string
  readonly redirected = false
  readonly type = 'basic' as const
  readonly body = null
  readonly bodyUsed = false

  constructor(
    private readonly rawBody: string,
    init: { status: number; statusText?: string; headers: Record<string, string>; url: string }
  ) {
    this.status = init.status
    this.statusText = init.statusText ?? ''
    this.ok = init.status >= 200 && init.status < 300
    this.headers = new UniHeaders(init.headers)
    this.url = init.url
  }

  async text() {
    return this.rawBody
  }

  async json() {
    if (!this.rawBody) return null
    return JSON.parse(this.rawBody)
  }

  clone() {
    return new UniResponse(this.rawBody, {
      status: this.status,
      statusText: this.statusText,
      headers: this.headers.toRecord(),
      url: this.url
    })
  }
}

function normalizeHeaders(headers?: HeadersInit): Record<string, string> {
  const result: Record<string, string> = {}
  if (!headers) return result

  if (typeof Headers !== 'undefined' && headers instanceof Headers) {
    headers.forEach((value, key) => {
      result[key] = value
    })
    return result
  }

  if (Array.isArray(headers)) {
    headers.forEach(([key, value]) => {
      result[key] = value
    })
    return result
  }

  Object.entries(headers).forEach(([key, value]) => {
    if (value != null) result[key] = String(value)
  })
  return result
}

function normalizeUrl(input: RequestInfo | URL): string {
  if (typeof input === 'string') return input
  if (typeof URL !== 'undefined' && input instanceof URL) return input.toString()
  return (input as Request).url
}

function normalizeBody(body: BodyInit | null | undefined): string | AnyObject | ArrayBuffer | undefined {
  if (body == null) return undefined
  if (typeof body === 'string') return body
  if (typeof ArrayBuffer !== 'undefined' && body instanceof ArrayBuffer) return body
  if (typeof Uint8Array !== 'undefined' && body instanceof Uint8Array) return body.buffer as ArrayBuffer
  return String(body)
}

function headerRecord(header: unknown): Record<string, string> {
  if (!header || typeof header !== 'object') return {}
  const result: Record<string, string> = {}
  Object.entries(header as Record<string, unknown>).forEach(([key, value]) => {
    if (Array.isArray(value)) result[key] = value.join(', ')
    else if (value != null) result[key] = String(value)
  })
  return result
}

/**
 * Fetch adapter backed by uni.request so Auth / PostgREST work on mini programs and App.
 * H5 keeps the native fetch implementation for Blob / FormData compatibility.
 */
export const uniFetch: typeof fetch = (input, init = {}) => {
  // #ifdef H5
  if (typeof fetch === 'function') {
    return fetch(input, init)
  }
  // #endif

  const url = normalizeUrl(input)
  const method = ((init.method || 'GET').toUpperCase()) as UniRequestMethod
  if (method === 'PATCH') {
    return Promise.reject(new Error('当前小程序请求适配不支持 PATCH，请通过经授权的 RPC 更新数据'))
  }
  const header = normalizeHeaders(init.headers)
  const data = normalizeBody(init.body)

  return new Promise((resolve, reject) => {
    const requestTask = uni.request({
      url,
      method,
      header,
      data,
      timeout: 60000,
      dataType: 'text',
      responseType: 'text',
      success: (res) => {
        const body = typeof res.data === 'string' ? res.data : JSON.stringify(res.data ?? '')
        resolve(
          new UniResponse(body, {
            status: res.statusCode,
            headers: headerRecord(res.header),
            url
          }) as unknown as Response
        )
      },
      fail: (err) => {
        reject(new Error(err.errMsg || 'uni.request failed'))
      }
    })

    const signal = init.signal
    if (signal) {
      const abort = () => requestTask.abort()
      if (signal.aborted) abort()
      else signal.addEventListener?.('abort', abort)
    }
  })
}
