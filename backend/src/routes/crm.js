import { Router } from "express";
import { query } from "../db.js";

const router = Router();

// قائمة المتعاونين (أفراد/جمعيات) مع عدد المشاريع المرتبطة
router.get("/collaborators", async (_req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT c.*, COUNT(cp.project_id)::int AS projects_count
       FROM collaborators c
       LEFT JOIN collaborator_projects cp ON cp.collaborator_id = c.id
       GROUP BY c.id ORDER BY c.name`
    );
    res.json(rows);
  } catch (e) { next(e); }
});

// ملف متعاون: مشاريعه المرتبطة + التقارير الدورية المرسلة له
router.get("/collaborators/:id", async (req, res, next) => {
  try {
    const { id } = req.params;
    const c = await query(`SELECT * FROM collaborators WHERE id = $1`, [id]);
    if (c.rows.length === 0) return res.status(404).json({ error: "not found" });
    const projects = await query(
      `SELECT p.id, p.title_ar, p.progress, p.status FROM collaborator_projects cp
       JOIN projects p ON p.id = cp.project_id WHERE cp.collaborator_id = $1`, [id]
    );
    const reports = await query(
      `SELECT * FROM collaborator_reports WHERE collaborator_id = $1 ORDER BY sent_at DESC`, [id]
    );
    res.json({ ...c.rows[0], projects: projects.rows, reports: reports.rows });
  } catch (e) { next(e); }
});

router.post("/collaborators", async (req, res, next) => {
  try {
    const { type = "individual", name, contact, notes } = req.body;
    const { rows } = await query(
      `INSERT INTO collaborators (type, name, contact, notes) VALUES ($1,$2,$3,$4) RETURNING *`,
      [type, name, contact, notes]
    );
    res.status(201).json(rows[0]);
  } catch (e) { next(e); }
});

export default router;
