// طبقة دفع مجرّدة — استبدل الدالتين بمنطق مزوّد الدفع الحقيقي
// (مثل Paymob / Stripe / M-Pesa) عند الربط، دون تغيير باقي الكود.
//
// المتغيّرات المطلوبة لاحقاً في .env:
//   PAYMENT_PROVIDER=...      اسم المزوّد
//   PAYMENT_API_KEY=...       مفتاح المزوّد
//   PAYMENT_WEBHOOK_SECRET=.. سرّ التحقق من الـ webhook

export const providerName = process.env.PAYMENT_PROVIDER || "mock";

// ينشئ جلسة دفع لدى المزوّد ويعيد رابط الدفع ومرجعه.
export async function createCheckout({ donationId, amountMinor, currency, method }) {
  // TODO: نداء API مزوّد الدفع الحقيقي هنا.
  // مؤقتاً (mock) — نعيد مرجعاً ورابطاً وهميَّين للاختبار.
  const ref = `${providerName}_${donationId}_${Date.now()}`;
  return {
    ref,
    checkoutUrl: `https://pay.example/checkout/${ref}`,
    provider: providerName,
  };
}

// يتحقّق من توقيع الـ webhook ويستخرج النتيجة.
// يجب التحقّق من التوقيع باستخدام PAYMENT_WEBHOOK_SECRET عند الربط الحقيقي.
export function parseWebhook(body) {
  // TODO: تحقّق من التوقيع وفق وثائق المزوّد.
  // متوقّع من الجسم: { ref, status } حيث status ∈ paid | failed
  return {
    ref: body?.ref ?? null,
    status: body?.status === "paid" ? "paid" : "failed",
  };
}
