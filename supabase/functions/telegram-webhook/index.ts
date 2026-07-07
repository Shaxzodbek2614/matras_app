// ============================================================
// Telegram Webhook — Edge Function
// Mijoz botga /start yuborganda avtomatik `customers` jadvaliga qo'shadi.
// Telefon raqamni esa Telegram cheklovi tufayli faqat foydalanuvchi o'zi
// "Telefon raqamni ulashish" tugmasini bosgandagina olish mumkin.
//
// Deploy qilish:
//   supabase functions deploy telegram-webhook --no-verify-jwt
//
// Deploy qilingandan keyin Telegram'ga webhook manzilini o'rnatish:
//   https://api.telegram.org/bot<BOT_TOKEN>/setWebhook?url=<FUNCTION_URL>
//
// Kerakli environment (secrets):
//   supabase secrets set SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... TELEGRAM_BOT_TOKEN=...
// ============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  try {
    const update = await req.json();
    const message = update.message;

    if (!message) {
      return new Response("ok", { status: 200 });
    }

    const chatId = message.chat.id;

    // ------------------------------------------------------------
    // 1) Foydalanuvchi "Telefon raqamni ulashish" tugmasini bosganda
    //    Telegram shu yerga message.contact obyektini yuboradi.
    // ------------------------------------------------------------
    if (message.contact) {
      // Xavfsizlik: faqat foydalanuvchi O'ZINING raqamini ulashganini tekshiramiz
      // (boshqa birovning kontaktini yuborib qo'ymasligi uchun)
      if (message.contact.user_id && message.contact.user_id !== message.from?.id) {
        await sendTelegramMessage(chatId, "Iltimos, faqat o'zingizning telefon raqamingizni ulashing.");
        return new Response("ok", { status: 200 });
      }

      const phoneNumber = message.contact.phone_number;
      const { error } = await supabase
        .from("customers")
        .update({ phone_number: phoneNumber })
        .eq("telegram_chat_id", chatId);

      if (error) {
        console.error("Telefon raqamni saqlashda xatolik:", error);
      } else {
        await sendTelegramMessage(chatId, "✅ Telefon raqamingiz muvaffaqiyatli saqlandi. Rahmat!", {
          remove_keyboard: true,
        });
      }
      return new Response("ok", { status: 200 });
    }

    if (!message.text) {
      return new Response("ok", { status: 200 });
    }

    const text = message.text.trim();

    // ------------------------------------------------------------
    // 2) /start — mijozni ro'yxatdan o'tkazish
    // ------------------------------------------------------------
    if (text === "/start") {
      const firstName = message.from?.first_name ?? "";
      const lastName = message.from?.last_name ?? "";
      const fullName = `${firstName} ${lastName}`.trim() || "Noma'lum mijoz";
      const username = message.from?.username ?? null;

      // Agar mijoz avval ro'yxatdan o'tgan bo'lsa, qayta qo'shilmaydi (upsert),
      // lekin mavjud telefon raqami o'chib ketmasligi uchun uni bu yerda yangilamaymiz.
      const { error } = await supabase
        .from("customers")
        .upsert(
          {
            telegram_chat_id: chatId,
            name: fullName,
            telegram_username: username,
          },
          { onConflict: "telegram_chat_id", ignoreDuplicates: false },
        );

      if (error) {
        console.error("Mijozni saqlashda xatolik:", error);
        return new Response("ok", { status: 200 });
      }

      await sendTelegramMessage(
        chatId,
        `Assalomu alaykum, ${fullName}! 👋\n\nSiz muvaffaqiyatli ro'yxatdan o'tdingiz.\nXaridlaringiz va to'lovlaringiz haqida shu yerga xabar beriladi.\n\nQulaylik uchun telefon raqamingizni ham ulashib qo'yishingizni so'raymiz 👇`,
        {
          keyboard: [
            [{ text: "📱 Telefon raqamni ulashish", request_contact: true }],
          ],
          resize_keyboard: true,
          one_time_keyboard: true,
        },
      );
    }

    return new Response("ok", { status: 200 });
  } catch (e) {
    console.error("Webhook xatoligi:", e);
    return new Response("error", { status: 200 }); // Telegram qayta urinmasligi uchun 200 qaytariladi
  }
});

async function sendTelegramMessage(
  chatId: number,
  text: string,
  // deno-lint-ignore no-explicit-any
  replyMarkup?: any,
) {
  const botToken = Deno.env.get("TELEGRAM_BOT_TOKEN")!;
  const body: Record<string, unknown> = { chat_id: chatId, text };

  if (replyMarkup?.remove_keyboard) {
    body.reply_markup = { remove_keyboard: true };
  } else if (replyMarkup) {
    body.reply_markup = replyMarkup;
  }

  await fetch(`https://api.telegram.org/bot${botToken}/sendMessage`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
}