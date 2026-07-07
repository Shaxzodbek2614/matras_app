-- ============================================================
-- Matras Savdo Boshqaruv Ilovasi — Supabase SQL sxemasi
-- Buni Supabase Dashboard -> SQL Editor'da to'liq ishga tushiring
-- ============================================================

create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- 1) CUSTOMERS — Telegram bot orqali /start yuborgan mijozlar
-- ------------------------------------------------------------
create table if not exists customers (
  id uuid primary key default uuid_generate_v4(),
  telegram_chat_id bigint unique not null,
  name text not null default 'Noma''lum mijoz',
  telegram_username text,
  phone_number text,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 2) PRODUCTS — mahsulotlar katalogi
-- ------------------------------------------------------------
create table if not exists products (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  size text,
  price numeric(14, 2) not null check (price >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 3) SALES — bitta savdo (bir nechta mahsulot bo'lishi mumkin)
-- ------------------------------------------------------------
create table if not exists sales (
  id uuid primary key default uuid_generate_v4(),
  customer_id uuid not null references customers(id) on delete restrict,
  grand_total numeric(14, 2) not null check (grand_total >= 0),
  cash_paid numeric(14, 2) not null check (cash_paid >= 0),
  debt_amount numeric(14, 2) not null check (debt_amount >= 0),
  created_at timestamptz not null default now(),
  constraint cash_debt_matches_total check (cash_paid + debt_amount = grand_total)
);

-- ------------------------------------------------------------
-- 4) SALE_ITEMS — bitta savdo ichidagi har bir mahsulot qatori
-- ------------------------------------------------------------
create table if not exists sale_items (
  id uuid primary key default uuid_generate_v4(),
  sale_id uuid not null references sales(id) on delete cascade,
  product_id uuid not null references products(id) on delete restrict,
  price numeric(14, 2) not null check (price >= 0),
  quantity integer not null check (quantity > 0),
  total numeric(14, 2) not null check (total >= 0),
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 5) PAYMENTS — qarz to'lovlari
-- ------------------------------------------------------------
create table if not exists payments (
  id uuid primary key default uuid_generate_v4(),
  customer_id uuid not null references customers(id) on delete restrict,
  amount numeric(14, 2) not null check (amount > 0),
  payment_date timestamptz not null default now(),
  note text,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- Indekslar (tezlik uchun)
-- ------------------------------------------------------------
create index if not exists idx_sales_customer_id on sales(customer_id);
create index if not exists idx_sale_items_sale_id on sale_items(sale_id);
create index if not exists idx_payments_customer_id on payments(customer_id);

-- ------------------------------------------------------------
-- customers_summary VIEW — har bir mijozning jami xarid/to'lov/qarz
-- summasini avtomatik hisoblab beradi. Flutter ilovasi shu VIEW'dan o'qiydi.
-- ------------------------------------------------------------
create or replace view customers_summary as
select
  c.id,
  c.telegram_chat_id,
  c.name,
  c.telegram_username,
  c.phone_number,
  c.created_at,
  coalesce((select sum(s.grand_total) from sales s where s.customer_id = c.id), 0) as total_purchases,
  coalesce((select sum(p.amount) from payments p where p.customer_id = c.id), 0) as total_paid
from customers c;

-- ------------------------------------------------------------
-- ROW LEVEL SECURITY (RLS)
-- Ilovada Supabase Auth ishlatilmaydi (faqat statik parol Flutter tarafida
-- tekshiriladi), shuning uchun anon key uchun to'liq CRUD ruxsati beriladi.
--
-- MUHIM XAVFSIZLIK ESLATMASI:
-- Bu yondashuv faqat ANON KEY hech qayerda oshkor qilinmasa (masalan reklama
-- qilinmagan ichki ilova) yetarli darajada xavfsiz hisoblanadi. Agar ilovani
-- Play Store'ga chiqarsangiz va xavfsizlikni oshirishni istasangiz, Supabase
-- Auth (masalan email/parol yoki magic link) qo'shib, quyidagi policy'larni
-- shunga moslab auth.uid() bilan cheklashni tavsiya qilamiz.
-- ------------------------------------------------------------
alter table customers enable row level security;
alter table products enable row level security;
alter table sales enable row level security;
alter table sale_items enable row level security;
alter table payments enable row level security;

create policy "anon full access - customers" on customers
  for all using (true) with check (true);

create policy "anon full access - products" on products
  for all using (true) with check (true);

create policy "anon full access - sales" on sales
  for all using (true) with check (true);

create policy "anon full access - sale_items" on sale_items
  for all using (true) with check (true);

create policy "anon full access - payments" on payments
  for all using (true) with check (true);
