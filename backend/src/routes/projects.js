import { Router } from "express";
import { query } from "../db.js";
import { notify } from "../lib/notify.js";
import { computeStatus } from "../lib/projectStatus.js";

const router = Router();

// قائمة المشاريع (مع فلترة اختيارية بالنوع)
router.get("/", async (req, res, next) => {
  try {
    const { type } = req.query;
    const params = [];
    let sql = `SELECT p.*, r.name_ar AS region_name, c.name_ar AS country_name
               FROM projects p
               LEFT JOIN regions r ON r.id = p.region_id
               LEFT JOIN countries c ON c.id = r.country_id`;
    if (type) { params.push(type); sql += ` WHERE p.type = $1`; }
    sql += ` ORDER BY p.created_at DESC`;
    const { rows } = await query(sql, params);
    res.json(rows);
  } catch (e) { next(e); }
});

// تفاصيل مشروع + مراحله (بمدى زمني) + حالته + تقارير المتابعة المعتمدة
router.get("/:id", async (req, res, next) => {
  try {
    const { id } = req.params;
    const project = await query(`SELECT * FROM projects WHERE id = $1`, [id]);
    if (project.rows.length === 0) return res.status(404).json({ error: "not found" });
    const stages = await query(
      `SELECT * FROM project_stages WHERE project_id = $1 ORDER BY id`, [id]
    );
    const reports = await query(
      `SELECT * FROM monitoring_reports WHERE project_id = $1 AND approved = true ORDER BY created_at DESC`, [id]
    );
    const status = computeStatus(stages.rows);
    res.json({ ...project.rows[0], status: status.status, status_label: status.label,
      delay_days: status.delayDays, stages: stages.rows, reports: reports.rows });
  } catch (e) { next(e); }
});

// رفع تقرير متابعة (معلّق) → تنبيه للمدير لاعتماده
router.post("/:id/reports", async (req, res, next) => {
  try {
    const { id } = req.params;
    const { kind = "progress", body_ar, uploaded_by } = req.body;
    const { rows } = await query(
      `INSERT INTO monitoring_reports (project_id, kind, body_ar, uploaded_by, approved)
       VALUES ($1,$2,$3,$4,false) RETURNING *`,
      [id, kind, body_ar, uploaded_by]
    );
    await notify({
      type: "report", projectId: Number(id),
      title: "تقرير متابعة جديد بانتظار الاعتماد",
      body: body_ar || "تم رفع تقرير متابعة جديد.",
    });
    res.status(201).json(rows[0]);
  } catch (e) { next(e); }
});

// بدء مرحلة فعلياً → تنبيه للمدير
router.post("/:id/stages/:stageId/start", async (req, res, next) => {
  try {
    const { id, stageId } = req.params;
    const { rows } = await query(
      `UPDATE project_stages SET state='now', actual_start = CURRENT_DATE
       WHERE id = $1 AND project_id = $2 RETURNING *`, [stageId, id]
    );
    if (rows.length === 0) return res.status(404).json({ error: "stage not found" });
    await notify({
      type: "stage_start", projectId: Number(id),
      title: "بدء مرحلة جديدة",
      body: `بدأت مرحلة: ${rows[0].title_ar}`,
    });
    res.json(rows[0]);
  } catch (e) { next(e); }
});

export default router;
