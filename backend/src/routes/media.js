import { Router } from "express";
import { query } from "../db.js";

const router = Router();
const withProject = `SELECT m.*, p.title_ar AS project_title FROM media_tasks m
                     LEFT JOIN projects p ON p.id = m.project_id`;

// كل مهام القسم الإعلامي
router.get("/tasks", async (_req, res, next) => {
  try {
    const { rows } = await query(`${withProject} ORDER BY m.created_at DESC`);
    res.json(rows);
  } catch (e) { next(e); }
});

// مشاريع محتاجة تصوير (فيديو/فوتو)
router.get("/needs-shooting", async (_req, res, next) => {
  try {
    const { rows } = await query(`${withProject} WHERE m.status = 'needed' ORDER BY m.created_at DESC`);
    res.json(rows);
  } catch (e) { next(e); }
});

// تمّ تصويره ولم يُنشر بعد
router.get("/unpublished", async (_req, res, next) => {
  try {
    const { rows } = await query(`${withProject} WHERE m.status IN ('shot','edited') ORDER BY m.created_at DESC`);
    res.json(rows);
  } catch (e) { next(e); }
});

export default router;
