import { Router } from "express";
import { query } from "../db.js";

const router = Router();

// المتبرّع يقيّم الجمعية وتقاريرها ويقترح تعديلاً
router.post("/", async (req, res, next) => {
  try {
    const { donor_id, rating_org, rating_reports, suggestion_ar } = req.body;
    const { rows } = await query(
      `INSERT INTO association_feedback (donor_id, rating_org, rating_reports, suggestion_ar)
       VALUES ($1,$2,$3,$4) RETURNING *`,
      [donor_id, rating_org, rating_reports, suggestion_ar]
    );
    res.status(201).json(rows[0]);
  } catch (e) { next(e); }
});

// ملخّص التقييمات للداشبورد + الاقتراحات
router.get("/", async (_req, res, next) => {
  try {
    const avg = await query(
      `SELECT ROUND(AVG(rating_org)::numeric,1) AS avg_org,
              ROUND(AVG(rating_reports)::numeric,1) AS avg_reports,
              COUNT(*)::int AS total
       FROM association_feedback`
    );
    const suggestions = await query(
      `SELECT af.suggestion_ar, af.created_at, d.name AS donor_name
       FROM association_feedback af LEFT JOIN donors d ON d.id = af.donor_id
       WHERE af.suggestion_ar IS NOT NULL AND af.suggestion_ar <> ''
       ORDER BY af.created_at DESC LIMIT 50`
    );
    res.json({ summary: avg.rows[0], suggestions: suggestions.rows });
  } catch (e) { next(e); }
});

export default router;
