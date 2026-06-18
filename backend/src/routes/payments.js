import { Router } from "express";
import { query } from "../db.js";
import { notify } from "../lib/notify.js";
import { createCheckout, parseWebhook } from "../lib/paymentProvider.js";

const router = Router();

// 1) إنشاء نية دفع → يسجّل تبرّعاً معلّقاً ويعيد رابط الدفع من المزوّد
router.post("/intent", async (req, res, next) => {
  try {
    const { donor_id, project_id, amount_minor, currency = "USD", method, category } = req.body;
    if (!amount_minor || amount_minor <= 0) {
      return res.status(400).json({ error: "amount_minor مطلوب" });
    }
    const ins = await query(
      `INSERT INTO donations (donor_id, project_id, amount_minor, currency, method, category, status)
       VALUES ($1,$2,$3,$4,$5,$6,'pending') RETURNING *`,
      [donor_id, project_id, amount_minor, currency, method, category]
    );
    const donation = ins.rows[0];

    const checkout = await createCheckout({
      donationId: donation.id, amountMinor: amount_minor, currency, method,
    });
    await query(`UPDATE donations SET provider = $1, provider_ref = $2 WHERE id = $3`,
      [checkout.provider, checkout.ref, donation.id]);

    res.status(201).json({
      donation_id: donation.id,
      checkout_url: checkout.checkoutUrl,
      provider_ref: checkout.ref,
    });
  } catch (e) { next(e); }
});

// 2) webhook المزوّد → عند النجاح: يؤكّد التبرّع، يحدّث المُجمَّع، وينبّه المدير
router.post("/webhook", async (req, res, next) => {
  try {
    const { ref, status } = parseWebhook(req.body);
    if (!ref) return res.status(400).json({ error: "ref مفقود" });

    const found = await query(`SELECT * FROM donations WHERE provider_ref = $1`, [ref]);
    if (found.rows.length === 0) return res.status(404).json({ error: "not found" });
    const d = found.rows[0];
    if (d.status === "paid") return res.json({ ok: true, already: true });

    if (status === "paid") {
      await query(`UPDATE donations SET status = 'paid' WHERE id = $1`, [d.id]);
      await query(`UPDATE projects SET raised_minor = raised_minor + $1 WHERE id = $2`,
        [d.amount_minor, d.project_id]);
      await notify({
        type: "donation", projectId: d.project_id,
        title: "تبرّع جديد مؤكَّد",
        body: `تم استلام تبرّع بقيمة ${(d.amount_minor / 100).toFixed(0)} ${d.currency}.`,
      });
    } else {
      await query(`UPDATE donations SET status = 'failed' WHERE id = $1`, [d.id]);
    }
    res.json({ ok: true });
  } catch (e) { next(e); }
});

export default router;
