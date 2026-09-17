-- ==========================================================
-- RELS READING - Supabase Database Setup & Migration Script
-- รันคำสั่งนี้ใน Supabase Dashboard -> SQL Editor
-- ==========================================================

-- 1. Helper function for updated_at timestamps
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ==========================================================
-- 2. Novels Table
-- ==========================================================
create table if not exists public.novels (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  cover_url text not null default '',
  author_id uuid references public.users(id) on delete cascade,
  author_name text not null default 'นักเขียน',
  tags text[] not null default '{}',
  chapters_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Add columns if table already existed without them
alter table public.novels add column if not exists author_name text not null default 'นักเขียน';
alter table public.novels add column if not exists tags text[] not null default '{}';
alter table public.novels add column if not exists chapters_count integer not null default 0;

create index if not exists idx_novels_author_id on public.novels(author_id);
create index if not exists idx_novels_created_at on public.novels(created_at desc);

drop trigger if exists set_novels_updated_at on public.novels;
create trigger set_novels_updated_at
  before update on public.novels
  for each row
  execute function public.handle_updated_at();

alter table public.novels enable row level security;

-- Policies for novels
drop policy if exists "allow public read on novels" on public.novels;
create policy "allow public read on novels" on public.novels
  for select
  using (true);

drop policy if exists "allow authenticated insert on novels" on public.novels;
create policy "allow authenticated insert on novels" on public.novels
  for insert
  with check (true);

drop policy if exists "allow author update on novels" on public.novels;
create policy "allow author update on novels" on public.novels
  for update
  using (true);

drop policy if exists "allow author delete on novels" on public.novels;
create policy "allow author delete on novels" on public.novels
  for delete
  using (true);

-- ==========================================================
-- 3. Chapters Table
-- ==========================================================
create table if not exists public.chapters (
  id uuid primary key default gen_random_uuid(),
  novel_id uuid not null references public.novels(id) on delete cascade,
  chapter_number integer not null,
  title text not null,
  content text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint unique_novel_chapter unique (novel_id, chapter_number)
);

create index if not exists idx_chapters_novel_id on public.chapters(novel_id);
create index if not exists idx_chapters_novel_chapter_num on public.chapters(novel_id, chapter_number asc);

drop trigger if exists set_chapters_updated_at on public.chapters;
create trigger set_chapters_updated_at
  before update on public.chapters
  for each row
  execute function public.handle_updated_at();

-- Auto update chapters_count trigger function
create or replace function public.update_novel_chapters_count()
returns trigger as $$
begin
  if (TG_OP = 'INSERT') then
    update public.novels
    set chapters_count = (select count(*) from public.chapters where novel_id = new.novel_id)
    where id = new.novel_id;
  elsif (TG_OP = 'DELETE') then
    update public.novels
    set chapters_count = (select count(*) from public.chapters where novel_id = old.novel_id)
    where id = old.novel_id;
  end if;
  return null;
end;
$$ language plpgsql;

drop trigger if exists update_chapters_count_on_change on public.chapters;
create trigger update_chapters_count_on_change
  after insert or delete on public.chapters
  for each row
  execute function public.update_novel_chapters_count();

alter table public.chapters enable row level security;

-- Policies for chapters
drop policy if exists "allow public read on chapters" on public.chapters;
create policy "allow public read on chapters" on public.chapters
  for select
  using (true);

drop policy if exists "allow authenticated insert on chapters" on public.chapters;
create policy "allow authenticated insert on chapters" on public.chapters
  for insert
  with check (true);

drop policy if exists "allow author update on chapters" on public.chapters;
create policy "allow author update on chapters" on public.chapters
  for update
  using (true);

drop policy if exists "allow author delete on chapters" on public.chapters;
create policy "allow author delete on chapters" on public.chapters
  for delete
  using (true);

-- ==========================================================
-- 4. Bookmarks Table
-- ==========================================================
create table if not exists public.bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  novel_id uuid not null references public.novels(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint unique_user_novel_bookmark unique (user_id, novel_id)
);

create index if not exists idx_bookmarks_user_id on public.bookmarks(user_id);
create index if not exists idx_bookmarks_novel_id on public.bookmarks(novel_id);

alter table public.bookmarks enable row level security;

drop policy if exists "allow user read own bookmarks" on public.bookmarks;
create policy "allow user read own bookmarks" on public.bookmarks
  for select
  using (true);

drop policy if exists "allow user manage bookmarks" on public.bookmarks;
create policy "allow user manage bookmarks" on public.bookmarks
  for all
  using (true);

-- ==========================================================
-- 5. Comments Table
-- ==========================================================
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.chapters(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_comments_chapter_id on public.comments(chapter_id);
create index if not exists idx_comments_user_id on public.comments(user_id);

drop trigger if exists set_comments_updated_at on public.comments;
create trigger set_comments_updated_at
  before update on public.comments
  for each row
  execute function public.handle_updated_at();

alter table public.comments enable row level security;

drop policy if exists "allow public read on comments" on public.comments;
create policy "allow public read on comments" on public.comments
  for select
  using (true);

drop policy if exists "allow user create comments" on public.comments;
create policy "allow user create comments" on public.comments
  for insert
  with check (true);

drop policy if exists "allow author delete comments" on public.comments;
create policy "allow author delete comments" on public.comments
  for delete
  using (true);

-- ==========================================================
-- 6. Insert Initial Default Novels & Chapters (If not exists)
-- ==========================================================
do $$
declare
  admin_user_id uuid;
  n1_id uuid;
  n2_id uuid;
  n3_id uuid;
  n4_id uuid;
begin
  -- Get first existing user as default author
  select id into admin_user_id from public.users order by created_at asc limit 1;

  if not exists (select 1 from public.novels where title like 'หวนคืนสู่บัลลังก์จอมราชันย์%') then
    insert into public.novels (id, title, description, cover_url, author_id, author_name, tags, chapters_count)
    values (
      gen_random_uuid(),
      'หวนคืนสู่บัลลังก์จอมราชันย์ (Return of the Sovereign King)',
      'หลังจากการทรยศหักหลังในสงครามหมื่นภพ จอมราชันย์ "หลินเฟิง" ได้ตื่นขึ้นมาอีกครั้งในร่างของเด็กหนุ่มตระกูลตกอับ พร้อมกับความทรงจำและวิชากลืนสวรรค์ที่สะเทือนทั้งปฐพี!',
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80',
      admin_user_id,
      'พยัคฆ์ทมิฬคำราม',
      array['#กำลังภายใน', '#เกิดใหม่', '#พระเอกเก่ง', '#เทพเซียน'],
      2
    ) returning id into n1_id;

    if n1_id is not null then
      insert into public.chapters (novel_id, chapter_number, title, content)
      values
        (n1_id, 1, 'บทที่ 1: การตื่นขึ้นของมหาราชันย์', 'ท่ามกลางพายุฝนฟ้าคะนองเหนือยอดเขาเทวะ ท้องฟ้าถูกฉีกขาดเป็นสองส่วนด้วยสายฟ้าสีม่วงคราม...'),
        (n1_id, 2, 'บทที่ 2: คัมภีร์กลืนสวรรค์', 'หลินเฟิงนั่งขัดสมาธิบนเตียงไม้เก่าๆ ลมหายใจของเขาเริ่มเป็นจังหวะสม่ำเสมอ...');
    end if;
  end if;

  if not exists (select 1 from public.novels where title like 'ลิขิตรักข้ามกาลเวลา%') then
    insert into public.novels (id, title, description, cover_url, author_id, author_name, tags, chapters_count)
    values (
      gen_random_uuid(),
      'ลิขิตรักข้ามกาลเวลา พันธนาการดวงใจ',
      'แพทย์สาวอัจฉริยะยุคศตวรรษที่ 21 ประสบอุบัติเหตุตื่นขึ้นมาในยุคโบราณ กลายเป็นพระชายาผู้ถูกทอดทิ้งของท่านอ๋องผู้เย็นชา นางจึงต้องใช้ความรู้ทางการแพทย์และไหวพริบเอาชีวิตรอด!',
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
      admin_user_id,
      'บุปผาโปรยปราย',
      array['#โรแมนติก', '#ย้อนเวลา', '#แพทย์สาว', '#ท่านอ๋อง'],
      1
    ) returning id into n2_id;

    if n2_id is not null then
      insert into public.chapters (novel_id, chapter_number, title, content)
      values
        (n2_id, 1, 'บทที่ 1: ตื่นขึ้นในร่างพระชายาผู้ถูกทอดทิ้ง', 'กลิ่นสมุนไพรไหม้เกรียมและไอความเย็นชวนขนลุกปลุกให้ "ไป๋ลั่วอัน" ลืมตาตื่นขึ้น...');
    end if;
  end if;

  if not exists (select 1 from public.novels where title like 'ไซเบอร์พังค์ 2099%') then
    insert into public.novels (id, title, description, cover_url, author_id, author_name, tags, chapters_count)
    values (
      gen_random_uuid(),
      'ไซเบอร์พังค์ 2099: กำเนิดสตรีทเลเจนด์',
      'ในมหานครนีออนที่ผู้คนหลงระเริงกับเทคโนโลยีและชิปไซเบอร์เนติกส์ แฮกเกอร์หนุ่มไร้สังกัดได้ค้นพบโปรเจกต์ลับของเมกะคอร์ปอเรชัน ที่หมายจะล้างสมองมวลมนุษยชาติทั้งเมือง',
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80',
      admin_user_id,
      'NeonGhost',
      array['#ไซไฟ', '#ไซเบอร์พังค์', '#แฮกเกอร์', '#โลกอนาคต'],
      1
    ) returning id into n3_id;

    if n3_id is not null then
      insert into public.chapters (novel_id, chapter_number, title, content)
      values
        (n3_id, 1, 'บทที่ 1: แสงนีออนและเงาดำแห่งไนท์ซิตี้', 'สายฝนกรดโปรยปรายลงมากระทบหน้าต่างกระจกเปื้อนคราบเขม่า แสงไฟนีออนสีชมพูสลับฟ้าน้ำเงินสะท้อนบนแอ่งน้ำ...');
    end if;
  end if;

  if not exists (select 1 from public.novels where title like 'ร้านสะดวกซื้อแห่งมิติคู่ขนาน%') then
    insert into public.novels (id, title, description, cover_url, author_id, author_name, tags, chapters_count)
    values (
      gen_random_uuid(),
      'ร้านสะดวกซื้อแห่งมิติคู่ขนาน',
      'ร้านสะดวกซื้อเล็กๆ ที่เปิดเฉพาะตอนเที่ยงคืน มีสินค้าแปลกประหลาดที่ช่วยเยียวยาบาดแผลในหัวใจของผู้มาเยือน จากเรื่องราวสุดอบอุ่นหัวใจและปาฏิหาริย์ที่คาดไม่ถึง',
      'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&auto=format&fit=crop&q=80',
      admin_user_id,
      'ชาอุ่นในสายฝน',
      array['#ชีวิตประจำวัน', '#อบอุ่นหัวใจ', '#แฟนตาซี', '#เยียวยา'],
      1
    ) returning id into n4_id;

    if n4_id is not null then
      insert into public.chapters (novel_id, chapter_number, title, content)
      values
        (n4_id, 1, 'บทที่ 1: เที่ยงคืนกับแสงไฟอุ่น', 'เสียงกระดิ่งลมหน้าร้านดังขึ้นแผ่วเบาเมื่อเข็มนาฬิกาบนหอนาฬิกาเก่าแก่ชี้ไปที่เลขสิบสอง...');
    end if;
  end if;

end $$;
