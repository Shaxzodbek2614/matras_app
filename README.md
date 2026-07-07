# Matras Savdo Boshqaruv Ilovasi

Bitta sotuvchi uchun mo'ljallangan Flutter + Supabase + Telegram Bot ilovasi.
Clean Architecture, Provider (state management) va GoRouter asosida qurilgan.

## 📁 Loyiha strukturasi

```
lib/
  core/                     # Umumiy: konstantalar, tema, servislar, reusable widgetlar
    constants/              # Ranglar, matnlar (uz)
    theme/                  # Material 3 tema
    services/               # SupabaseService, TelegramService
    router/                 # GoRouter sozlamalari
    utils/                  # Formatlash, validatsiya
    widgets/                # CustomButton, CustomTextField, Loading/Empty/Error state'lar
  features/
    auth/                   # Statik parol ekrani (login/registratsiya YO'Q)
    products/               # Mahsulotlar katalogi (CRUD, active/inactive)
    customers/               # Mijozlar ro'yxati, profil, qarz to'lash
    sales/                  # Savdo jarayoni: mijoz -> mahsulotlar -> to'lov
    payments/               # To'lovlar (qarzni yopish)
    home/                   # Bottom navigation bilan asosiy ekran

supabase/
  sql/schema.sql            # Barcha jadvallar, VIEW, RLS policy'lar
  functions/telegram-webhook/  # Deno Edge Function (/start ni tutib mijoz qo'shadi)
```

Har bir feature `data/` (model + repository) va `presentation/` (provider + screens + widgets)
qatlamlariga bo'lingan — bu kelajakda yangi funksiya qo'shishni osonlashtiradi.

---

## 🚀 O'rnatish qadamlari

### 1. Flutter paketlarini o'rnatish

```bash
cd matras_app
flutter pub get
```

### 2. Supabase loyihasini yaratish

1. https://supabase.com da yangi loyiha yarating.
2. **SQL Editor** bo'limiga o'ting va `supabase/sql/schema.sql` faylidagi barcha kodni
   nusxalab, to'liq ishga tushiring. Bu quyidagilarni yaratadi:
   - `customers`, `products`, `sales`, `sale_items`, `payments` jadvallari
   - `customers_summary` VIEW (mijozning umumiy qarzini avtomatik hisoblaydi)
   - RLS policy'lar (anon key uchun to'liq ruxsat — pastdagi xavfsizlik eslatmasiga qarang)
3. **Project Settings -> API** bo'limidan `Project URL` va `anon public key`'ni oling.
4. `lib/core/services/supabase_service.dart` faylidagi quyidagi joylarni to'ldiring:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Telegram botini sozlash

1. Telegram'da **@BotFather** orqali yangi bot yarating (`/newbot`), bot tokenini oling.
2. `lib/core/services/telegram_service.dart` faylida:

```dart
static const String botToken = 'YOUR_TELEGRAM_BOT_TOKEN';
```

3. **Supabase CLI** o'rnatib, Edge Function'ni deploy qiling (mijozlar `/start` yuborganda
   avtomatik bazaga qo'shilishi uchun):

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase secrets set TELEGRAM_BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN
supabase functions deploy telegram-webhook --no-verify-jwt
```

4. Webhookni Telegram'ga ulash (FUNCTION_URL — deploy natijasida chiqadigan manzil,
   odatda `https://YOUR_PROJECT_REF.supabase.co/functions/v1/telegram-webhook`):

```bash
curl "https://api.telegram.org/bot<BOT_TOKEN>/setWebhook?url=<FUNCTION_URL>"
```

Shundan so'ng, kimdir botga `/start` yuborsa, u avtomatik `customers` jadvaliga qo'shiladi
va tabrik xabarini oladi.

### 4. Statik parolni o'zgartirish

`lib/features/auth/presentation/providers/auth_provider.dart` faylida:

```dart
static const String _correctPassword = '1234'; // shu yerga o'z parolingizni yozing
```

### 5. Ishga tushirish

```bash
flutter run
```

---

## 🔐 Xavfsizlik haqida eslatma

Ilovada Supabase Auth ishlatilmagani sababli (talabga ko'ra login/registratsiya yo'q),
`anon key` uchun barcha jadvallarga to'liq CRUD ruxsati berilgan (RLS policy `using (true)`).

Bu quyidagi holatlarda yetarli darajada xavfsiz:
- Ilova faqat sizning shaxsiy qurilmangizda ishlatiladi
- APK/IPA fayl ommaviy tarqatilmaydi

Agar kelajakda ilovani kengroq tarqatish yoki xavfsizlikni oshirish kerak bo'lsa,
Supabase Auth (masalan oddiy email/parol orqali) qo'shib, RLS policy'larni
`auth.uid()` asosida cheklashni tavsiya qilaman — bu haqida alohida so'rasangiz,
tayyorlab beraman.

---

## 🧩 Kengaytirish g'oyalari

- **Statistika/Dashboard**: kunlik/oylik savdo hajmi, eng ko'p sotilgan mahsulotlar
- **Excel/PDF eksport**: savdolar va qarzdorlik hisobotlarini export qilish
- **Push bildirishnoma**: yangi mijoz ro'yxatdan o'tganda sotuvchiga xabar
- **Ko'p tilli qo'llab-quvvatlash**: `app_strings.dart` allaqachon markazlashtirilgan,
  shuning uchun i18n qo'shish oson

## ⚠️ Diqqat

Ushbu kod to'liq ishlaydigan Clean Architecture asosidagi loyiha skeleti va barcha
asosiy funksiyalarni (mahsulotlar, savdo, mijozlar, qarz, Telegram xabarlari) o'z ichiga
oladi. Lekin quyidagilarni **o'zingiz** bajarishingiz kerak:
- Supabase URL/Key va Telegram Bot Token'larni kiritish (yuqorida ko'rsatilgan)
- `flutter pub get` va real qurilmada/emulyatorda sinab ko'rish
- Android/iOS uchun ilova ikonkasi, nomi va boshqa platforma sozlamalarini qo'shish
