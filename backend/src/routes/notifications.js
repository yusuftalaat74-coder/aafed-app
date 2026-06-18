import { Router } from "express";
import { query } from "../db.js";

const router = Router();

// تنبيهات المدير
router.get("/", async (_req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT n.*, p.title_ar AS project_title
       FROM notifications n LEFT JOIN projects p ON p.id = n.project_id
       ORDER BY n.created_at DESC LIMIT 100`
    );
    res.json(rows);
  } catch (e) { next(e); }
});

// عدد غير المقروء
router.get("/unread-count", async (_req, res, next) => {
  try {
    const { rows } = await query(`SELECT COUNT(*)::int AS c FROM notifications WHERE is_read = false`);
    res.json({ count: rows[0].c });
  } catch (e) { next(e); }
});

router.post("/:id/read", async (req, res, next) => {
  try {
    await query(`UPDATE notifications SET is_read = true WHERE id = $1`, [req.params.id]);
    res.json({ ok: true });
  } catch (e) { next(e); }
});

export default router;
