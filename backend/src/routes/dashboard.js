import { Router } from "express";
import { query } from "../db.js";
import { computeStatus } from "../lib/projectStatus.js";

const router = Router();

// نظرة عامة للداشبورد: مؤشرات + حالة كل مشروع (تقدّم/تأخّر) + تنبيهات التأخّر
router.get("/overview", async (_req, res, next) => {
  try {
    const projects = await query(`SELECT * FROM projects ORDER BY created_at DESC`);
    const items = [];
    const alerts = [];
    for (const p of projects.rows) {
      const stages = await query(
        `SELECT * FROM project_stages WHERE project_id = $1 ORDER BY id`, [p.id]
      );
      const st = computeStatus(stages.rows);
      items.push({
        id: p.id, title_ar: p.title_ar, progress: p.progress,
        status: st.status, status_label: st.label, delay_days: st.delayDays,
      });
      if (st.status !== "on_track") {
        alerts.push({
          project_id: p.id, title_ar: p.title_ar,
          status: st.status, status_label: st.label, delay_days: st.delayDays,
        });
      }
    }

    const kpis = await query(`
      SELECT
        (SELECT COUNT(*)::int FROM projects) AS projects,
        (SELECT COUNT(*)::int FROM donors) AS donors,
        (SELECT COALESCE(SUM(amount_minor),0)::bigint FROM donations) AS raised_minor,
        (SELECT COUNT(*)::int FROM notifications WHERE is_read = false) AS unread_notifications
    `);

    res.json({ kpis: kpis.rows[0], projects: items, alerts });
  } catch (e) { next(e); }
});

export default router;
