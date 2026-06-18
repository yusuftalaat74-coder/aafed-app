import { Router } from "express";
import { query } from "../db.js";

const router = Router();

// قائمة المشاريع (مع فلترة اختيارية بالنوع/البلد)
router.get("/", async (req, res, next) => {
  try {
    const { type } = req.query;
    const params = [];
    let sql = `SELECT p.*, r.name_ar AS region_name, c.name_ar AS country_name
               FROM projects p
               LEFT JOIN regions r ON r.id = p.region_id
               LEFT JOIN countries c ON c.id = r.country_id`;
    if (type) {
      params.push(type);
      sql += ` WHERE p.type = $1`;
    }
    sql += ` ORDER BY p.created_at DESC`;
    const { rows } = await query(sql, params);
    res.json(rows);
  } catch (e) {
    next(e);
  }
});

// تفاصيل مشروع + مراحله + تقارير المتابعة المعتمدة
router.get("/:id", async (req, res, next) => {
  try {
    const { id } = req.params;
    const project = await query(`SELECT * FROM projects WHERE id = $1`, [id]);
    if (project.rows.length === 0) return res.status(404).json({ error: "not found" });
    const stages = await query(
      `SELECT * FROM project_stages WHERE project_id = $1 ORDER BY id`, [id]
    );
    const reports = await query(
      `SELECT * FROM monitoring_reports WHERE project_id = $1 AND approved = true ORDER BY created_at DESC`,
      [id]
    );
    res.json({ ...project.rows[0], stages: stages.rows, reports: reports.rows });
  } catch (e) {
    next(e);
  }
});

export default router;
