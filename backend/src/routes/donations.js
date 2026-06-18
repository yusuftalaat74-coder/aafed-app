import { Router } from "express";
import { query } from "../db.js";
import { notify } from "../lib/notify.js";

const router = Router();

// تسجيل تبرّع → يحدّث المُجمَّع ويرسل تنبيهاً للمدير
router.post("/", async (req, res, next) => {
  try {
    const { donor_id, project_id, amount_minor, currency = "USD", method, category } = req.body;
    const { rows } = await query(
      `INSERT INTO donations (donor_id, project_id, amount_minor, currency, method, category)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [donor_id, project_id, amount_minor, currency, method, category]
    );
    await query(`UPDATE projects SET raised_minor = raised_minor + $1 WHERE id = $2`,
      [amount_minor, project_id]);

    const amount = (amount_minor / 100).toFixed(0);
    await notify({
      type: "donation",
      projectId: project_id,
      title: "تبرّع جديد",
      body: `تم تبرّع بقيمة ${amount} ${currency}.`,
    });
    res.status(201).json(rows[0]);
  } catch (e) { next(e); }
});

export default router;
