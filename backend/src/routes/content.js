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

// نصوص الموقع (من نحن / رؤية / رسالة / شعار)
router.get("/site", async (_req, res, next) => {
  try {
    const { rows } = await query(`SELECT key, value_ar FROM site_content`);
    const map = {};
    rows.forEach((r) => (map[r.key] = r.value_ar));
    res.json(map);
  } catch (e) { next(e); }
});

// أنواع المشاريع وشعاراتها (الأقسام الـ11)
router.get("/project-types", async (_req, res, next) => {
  try {
    const { rows } = await query(`SELECT * FROM project_types ORDER BY id`);
    res.json(rows);
  } catch (e) { next(e); }
});

// الشركاء/الداعمون
router.get("/partners", async (_req, res, next) => {
  try {
    const { rows } = await query(`SELECT * FROM partners ORDER BY id`);
    res.json(rows);
  } catch (e) { next(e); }
});

// مجموعات الفريق
router.get("/team", async (_req, res, next) => {
  try {
    const { rows } = await query(`SELECT * FROM team_groups ORDER BY id`);
    res.json(rows);
  } catch (e) { next(e); }
});

// حالات متاحة للكفالة
router.get("/cases", async (_req, res, next) => {
  try {
    const { rows } = await query(`SELECT * FROM featured_cases ORDER BY id`);
    res.json(rows);
  } catch (e) { next(e); }
});

export default router;
