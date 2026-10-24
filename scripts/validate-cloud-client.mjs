import assert from 'node:assert/strict'
import fs from 'node:fs'
import vm from 'node:vm'
import path from 'node:path'
import { createRequire } from 'node:module'
const require = createRequire(import.meta.url)
const ts = require('typescript')
const root = path.resolve(import.meta.dirname, '..')
const user = { id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', email: 'test@example.invalid' }
const storage = new Map()
const calls = []
let route
const uni = {
  getStorageSync: key => storage.get(key),
  setStorageSync: (key, value) => storage.set(key, value),
  removeStorageSync: key => storage.delete(key),
  request: options => {
    calls.push(options)
    Promise.resolve().then(() => route(options)).then(
      response => options.success({ statusCode: 200, data: response }),
      error => error.network ? options.fail({ errMsg: 'offline' }) : options.success({ statusCode: error.status || 400, data: { message: error.message } })
    )
    return { abort() {} }
  }
}
const modules = new Map()
const config = { supabaseUrl: 'https://test.supabase.co', supabasePublishableKey: 'sb_publishable_test', validateSupabaseConfig() {} }
function load(relative) {
  const full = path.resolve(root, relative)
  if (modules.has(full)) return modules.get(full).exports
  const module = { exports: {} }
  modules.set(full, module)
  const compiled = ts.transpileModule(fs.readFileSync(full, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 }
  }).outputText
  const localRequire = specifier => {
    if (specifier.endsWith('/config') || specifier === './config') return config
    if (specifier.startsWith('@/')) return load('src/' + specifier.slice(2) + '.ts')
    if (specifier.startsWith('.')) return load(path.relative(root, path.resolve(path.dirname(full), specifier + '.ts')))
    return require(specifier)
  }
  vm.runInNewContext(compiled, { module, exports: module.exports, require: localRequire, uni, console, Date, setTimeout, clearTimeout }, { filename: full })
  return module.exports
}
const auth = load('src/store/auth.ts')
const session = { access_token: 'access-test', refresh_token: 'refresh-test', expires_at: Math.floor(Date.now()/1000) + 3600, user }
route = async options => {
  if (options.url.endsWith('grant_type=password')) return session
  if (options.url.includes('profiles?on_conflict')) return ''
  if (options.url.includes('/profiles?')) return []
  return []
}
await auth.initializeAuth()
assert.equal(auth.authState.user, null)
await auth.signIn(user.email, 'test-password')
assert.equal(auth.authState.user.id, user.id)
await assert.rejects(auth.loadProfile(), /未能加载/)
const insert = calls.find(call => call.url.includes('profiles?on_conflict'))
assert.equal(insert.data.id, user.id)
assert.equal(insert.data.verified, undefined)
assert.equal(insert.header.Authorization, 'Bearer access-test')
assert.equal([...storage.values()].some(value => value.includes('test-password')), false)
const repository = load('src/lib/supabase/repository.ts')
route = async options => {
  if (options.url.includes('/posts?')) return [{ id: 'post-id', title: '云端攻略', city: '泉州', cover_emoji: '🏮', summary: '', places: [], profiles: null }]
  return []
}
const posts = await repository.listPosts()
assert.equal(posts.length, 1)
assert.equal(posts[0].savedCount, undefined)
assert.equal(posts[0].author, '作者未公开资料')
assert.ok(calls.find(call => call.url.includes('profiles!posts_author_id_fkey')))
await repository.setBookmark('post-id', true)
assert.equal(calls.at(-1).method, 'POST')
assert.equal(calls.at(-1).data.user_id, user.id)
await repository.setBookmark('post-id', false)
assert.equal(calls.at(-1).method, 'DELETE')
route = async () => { throw { status: 403, message: 'forbidden' } }
await assert.rejects(repository.setBookmark('post-id', true), /forbidden/)
await assert.rejects(auth.signOut())
assert.equal(auth.authState.user, null)
assert.equal(storage.size, 0)
await assert.rejects(repository.setBookmark('post-id', true), /请先/)

modules.clear()
storage.set('gogo-auth:https://test.supabase.co', JSON.stringify({ ...session, expires_at: 1 }))
let refreshCount = 0
route = async options => {
  if (options.url.endsWith('grant_type=refresh_token')) { refreshCount++; return session }
  if (options.url.endsWith('/user')) return user
  return []
}
const restored = load('src/store/auth.ts')
await Promise.all([restored.initializeAuth(), restored.initializeAuth()])
assert.equal(refreshCount, 1)
assert.equal(restored.authState.user.id, user.id)
let attempted = false
route = async options => {
  if (options.url.endsWith('grant_type=refresh_token')) { refreshCount++; return session }
  if (!attempted) { attempted = true; throw { status: 401, message: 'expired' } }
  return []
}
await restored.authorizedRequest('/rest/v1/trips')
assert.equal(refreshCount, 2)
console.log('PASS: real Auth request contracts, no password persistence, profile insert, author join, bookmarks, failure propagation, logout, single-flight refresh')
