begin;

do $seed$
declare
  target_user uuid := '00000000-0000-0000-0000-000000000000';
  fixture jsonb := $json${"trips":[{"id":"trip-1","city":"泉州","dateRange":"11月9日–11日 · 3天2晚","timezone":"Asia/Shanghai","budget":1680,"currency":"CNY","coverEmoji":"🏮","status":"saved","private":true,"version":3,"days":[{"date":"2026-11-09","label":"Day 1 · 古城初见","items":[{"id":"item-1","time":"09:30","endTime":"11:00","title":"开元寺","area":"鲤城区","duration":"1.5小时","cost":0,"locked":true},{"id":"item-2","time":"11:20","endTime":"12:30","title":"西街小吃漫游","area":"西街","duration":"1小时","transport":"步行 8 分钟","cost":55},{"id":"item-3","time":"14:00","endTime":"16:00","title":"蟳埔簪花体验","area":"丰泽区","duration":"2小时","transport":"打车约 25 分钟","cost":168}]},{"date":"2026-11-10","label":"Day 2 · 海风与古厝","items":[{"id":"item-4","time":"09:00","endTime":"11:30","title":"洛伽寺与黄金海岸","area":"石狮","duration":"2.5小时","cost":80},{"id":"item-5","time":"14:00","endTime":"16:00","title":"永宁古卫城","area":"永宁镇","duration":"2小时","transport":"驾车约 35 分钟","cost":30}]},{"date":"2026-11-11","label":"Day 3 · 闽南烟火","items":[{"id":"item-6","time":"09:30","endTime":"11:00","title":"清净寺与关岳庙","area":"涂门街","duration":"1.5小时","cost":3},{"id":"item-7","time":"11:20","endTime":"13:00","title":"面线糊午餐","area":"府文庙附近","duration":"1小时","cost":35,"pendingVerification":true}]}]},{"id":"trip-2","city":"杭州","dateRange":"11月16日 · 周末一天","timezone":"Asia/Shanghai","budget":380,"currency":"CNY","coverEmoji":"🍂","status":"draft","private":true,"version":1,"days":[{"date":"2026-11-16","label":"Day 1 · 九溪秋日","items":[{"id":"item-8","time":"08:30","endTime":"11:00","title":"九溪烟树","area":"西湖区","duration":"2.5小时","cost":0},{"id":"item-9","time":"11:30","endTime":"13:00","title":"龙井村午餐","area":"龙井村","duration":"1.5小时","cost":90}]}]}],"posts":[{"id":"post-1","title":"泉州三天：把时间留给街巷","city":"泉州","author":"南风慢慢","coverEmoji":"🏮","summary":"一条不赶路的古城路线，包含寺庙、老街、咖啡和本地小吃。","places":["开元寺","西街","清净寺","蟳埔村"],"savedCount":328,"bookmarked":false},{"id":"post-2","title":"杭州入秋后最舒服的一日步行","city":"杭州","author":"一颗青梅","coverEmoji":"🍂","summary":"九溪到龙井的轻量路线，给第一次来杭州又不想挤西湖的人。","places":["九溪烟树","龙井村","满觉陇"],"savedCount":191,"bookmarked":true}]}$json$::jsonb;
  trip_data jsonb;
  day_data jsonb;
  item_data jsonb;
  post_data jsonb;
  trip_key uuid;
  day_key uuid;
  day_order integer;
  item_order integer;
begin
  if target_user = '00000000-0000-0000-0000-000000000000' then
    raise exception '请先将 target_user 替换为小程序“我的”页复制的真实用户 UUID';
  end if;
  if not exists(select 1 from auth.users where id = target_user) then
    raise exception '目标 Auth 用户不存在，请先注册并登录';
  end if;
  insert into public.profiles(id, name) values(target_user, '测试旅行者')
  on conflict(id) do nothing;

  for trip_data in select value from jsonb_array_elements(fixture->'trips') loop
    trip_key := md5(target_user::text || ':gogo-seed:' || (trip_data->>'id'))::uuid;
    insert into public.trips(id,owner_id,city,date_range,timezone,budget,currency,cover_emoji,status,is_private,version)
    values(trip_key,target_user,trip_data->>'city','[测试数据] ' || (trip_data->>'dateRange'),
      trip_data->>'timezone',(trip_data->>'budget')::numeric,trip_data->>'currency',
      trip_data->>'coverEmoji',trip_data->>'status',true,1)
    on conflict(id) do nothing;
    day_order := 0;
    for day_data in select value from jsonb_array_elements(trip_data->'days') loop
      day_key := md5(trip_key::text || ':day:' || day_order::text)::uuid;
      insert into public.trip_days(id,trip_id,date,label,sort_order)
      values(day_key,trip_key,(day_data->>'date')::date,day_data->>'label',day_order)
      on conflict(id) do nothing;
      item_order := 0;
      for item_data in select value from jsonb_array_elements(day_data->'items') loop
        insert into public.trip_items(id,day_id,time,end_time,title,area,duration,transport,cost,locked,pending_verification,sort_order)
        values(md5(day_key::text || ':item:' || item_order::text)::uuid,day_key,
          (item_data->>'time')::time,(item_data->>'endTime')::time,item_data->>'title',item_data->>'area',
          item_data->>'duration',item_data->>'transport',(item_data->>'cost')::numeric,
          coalesce((item_data->>'locked')::boolean,false),true,item_order)
        on conflict(id) do nothing;
        item_order := item_order + 1;
      end loop;
      day_order := day_order + 1;
    end loop;
  end loop;
  for post_data in select value from jsonb_array_elements(fixture->'posts') loop
    insert into public.posts(id,author_id,title,city,cover_emoji,summary,places,status)
    values(md5(target_user::text || ':gogo-seed:' || (post_data->>'id'))::uuid,target_user,
      '[测试攻略] ' || (post_data->>'title'),post_data->>'city',post_data->>'coverEmoji',
      '仅供功能测试；原 mock 作者：' || (post_data->>'author') || '。' || (post_data->>'summary'),
      array(select jsonb_array_elements_text(post_data->'places')),'published')
    on conflict(id) do nothing;
  end loop;
end;
$seed$;

commit;
