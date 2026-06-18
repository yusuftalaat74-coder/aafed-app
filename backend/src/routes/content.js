import { Router } from "express";
import { query } from "../db.js";

const router = Router();

// القصص الإنسانية
router.get("/stories", async (_req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT s.*, p.title_ar AS project_title FROM stories s
       LEFT JOIN projects p ON p.id = s.project_id ORDER BY s.created_at DESC`
    );
    res.json(rows);
  } catch (e) { next(e); }
});

// اقتراحات أخبار المشاريع
router.get("/news", async (_req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT n.*, p.title_ar AS project_title FROM project_news n
       LEFT JOIN projects p ON p.id = n.project_id ORDER BY n.created_at DESC`
    );
    res.json(rows);
  } catch (e) { next(e); }
});

// أخبار من موزمبيق — النبض العام للبلد
router.get("/country-pulse", async (req, res, next) => {
  try {
    const { country } = req.query;
    const params = [];
    let sql = `SELECT cp.*, c.name_ar AS country_name FROM country_pulse cp
               LEFT JOIN countries c ON c.id = cp.country_id`;
    if (country) { params.push(country); sql += ` WHERE c.name_ar = $1`; }
    sql += ` ORDER BY cp.pulse_date DESC`;
    const { rows } = await query(sql, params);
    res.json(rows);
  } catch (e) { next(e); }
});

export default router;
