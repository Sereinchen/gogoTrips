import assert from 'node:assert/strict'
import fs from 'node:fs'
import path from 'node:path'
import { pathToFileURL } from 'node:url'

const runtime = process.env.PGLITE_MODULE
if (!runtime) throw new Error('请设置 PGLITE_MODULE 指向本地 pglite/dist/index.js')
const { PGlite } = await import(pathToFileURL(runtime).href)
const db = new PGlite()
const root = path.resolve(import.meta.dirname, '..')
const userA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
const userB = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
await db.exec(`
  create role anon;
  create role authenticated;
  create role service_role bypassrls;
  create schema auth;
  create table auth.users(id uuid primary key);
  create function auth.uid() returns uuid language sql stable as
  $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
  grant usage on schema public, auth to anon, authenticated;
  grant execute on function auth.uid() to anon, authenticated;
  insert into auth.users values ('${userA}'), ('${userB}');
`)
await db.exec(fs.readFileSync(path.join(root, 'supabase/mock-schema.sql'), 'utf8'))
const seed = fs.readFileSync(path.join(root, 'supabase/seed-test-account.sql'), 'utf8').replaceAll('00000000-0000-0000-0000-000000000000', userA)
const validSeed = seed.replace(`if target_user = '${userA}' then`, 'if false then')
await db.exec(validSeed)
await db.exec(validSeed)
assert.equal((await db.query('select count(*)::int as total from public.trips')).rows[0].total, 2)
assert.equal((await db.query('select count(*)::int as total from public.trip_items')).rows[0].total, 9)
assert.equal((await db.query('select count(*)::int as total from public.posts')).rows[0].total, 2)

async function asRole(role, user, action) {
  await db.exec('begin')
  try {
    await db.exec(`set local role ${role}`)
    await db.query("select set_config('request.jwt.claim.sub', $1, true)", [user || ''])
    return await action()
  } finally { await db.exec('rollback') }
}
async function total(table) {
  return (await db.query(`select count(*)::int as total from public.${table}`)).rows[0].total
}
await asRole('anon', null, async () => {
  assert.equal(await total('posts'), 2)
  assert.equal(await total('profiles'), 0)
  await assert.rejects(db.query('select * from public.trips'))
})
await asRole('authenticated', userA, async () => {
  assert.equal(await total('trips'), 2)
  assert.equal(await total('trip_items'), 9)
})
await asRole('authenticated', userB, async () => {
  assert.equal(await total('trips'), 0)
  assert.equal(await total('trip_days'), 0)
  assert.equal(await total('trip_items'), 0)
  await assert.rejects(db.query('insert into public.trips(owner_id,city) values($1,$2)', [userA,'越权']))
})
await asRole('authenticated', userB, async () => {
  await db.query('insert into public.profiles(id,name) values($1,$2) on conflict(id) do nothing', [userB,'用户B'])
  await assert.rejects(db.query('update public.profiles set verified=true where id=$1', [userB]))
})
await asRole('authenticated', userA, async () => {
  await db.query('insert into public.post_bookmarks(user_id,post_id) select $1,id from public.posts on conflict(user_id,post_id) do nothing', [userA])
  assert.equal(await total('post_bookmarks'), 2)
  await db.exec('delete from public.post_bookmarks')
  assert.equal(await total('post_bookmarks'), 0)
})
await asRole('authenticated', userB, async () => {
  await assert.rejects(db.query('insert into public.post_bookmarks(user_id,post_id) select $1,id from public.posts', [userA]))
})
await db.query('insert into public.profiles(id,name) values($1,$2)', [userB,'用户B'])
await db.query('insert into public.post_bookmarks(user_id,post_id) select $1,id from public.posts', [userA])
await asRole('authenticated', userB, async () => {
  assert.equal(await total('post_bookmarks'), 0)
})
await db.exec(`
  insert into public.activities(id,organizer_id,title,city,category,starts_at,ends_at,meetup_area,capacity)
  values('cccccccc-cccc-4ccc-8ccc-cccccccccccc','${userA}','测试活动','泉州','漫步',now()+interval '1 day',now()+interval '2 days','公共区域',2);
  insert into public.teams(id,activity_id,leader_id,meetup_detail)
  values('dddddddd-dddd-4ddd-8ddd-dddddddddddd','cccccccc-cccc-4ccc-8ccc-cccccccccccc','${userA}','私密集合点');
  insert into public.team_members(team_id,user_id,role)
  values('dddddddd-dddd-4ddd-8ddd-dddddddddddd','${userA}','leader');
`)
await asRole('authenticated', userB, async () => {
  assert.equal(await total('teams'), 0)
  assert.equal(await total('team_members'), 0)
  await assert.rejects(db.exec(`insert into public.team_messages(team_id,sender_id,body) values('dddddddd-dddd-4ddd-8ddd-dddddddddddd','${userB}','越权消息')`))
})
await asRole('authenticated', userA, async () => {
  assert.equal(await total('teams'), 1)
  await db.exec(`insert into public.team_messages(team_id,sender_id,body) values('dddddddd-dddd-4ddd-8ddd-dddddddddddd','${userA}','合法消息')`)
  assert.equal(await total('team_messages'), 1)
})
await asRole('authenticated', userA, async () => {
  await assert.rejects(db.exec(`insert into public.team_messages(team_id,sender_id,body,is_system) values('dddddddd-dddd-4ddd-8ddd-dddddddddddd',null,'假系统消息',true)`))
})
await db.exec(`insert into public.team_messages(team_id,sender_id,body) values('dddddddd-dddd-4ddd-8ddd-dddddddddddd','${userA}','持久化私密消息')`)
await asRole('authenticated', userB, async () => {
  assert.equal(await total('team_messages'), 0)
})
await db.exec('update public.team_members set left_at=now()')
await asRole('authenticated', userA, async () => {
  assert.equal(await total('teams'), 0)
  assert.equal(await total('team_members'), 0)
  assert.equal(await total('team_messages'), 0)
})
await db.close()
console.log('PASS: schema, repeatable seed, anon, ownership isolation, privilege protection, bookmarks, member-only chat, leave revocation')
