import { query } from "../db.js";

// يضيف تنبيهاً للمدير عند حدث مهم (تقرير / تبرّع / بدء مرحلة / خطر تأخّر).
export async function notify({ type, projectId = null, title, body, severity = "info" }) {
  await query(
    `INSERT INTO notifications (type, project_id, title_ar, body_ar, severity)
     VALUES ($1, $2, $3, $4, $5)`,
    [type, projectId, title, body, severity]
  );
}
