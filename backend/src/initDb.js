// ينشئ الجداول ويضيف بيانات تجريبية
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { pool } from "./db.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function main() {
  const schema = fs.readFileSync(path.join(__dirname, "../db/schema.sql"), "utf8");
  await pool.query(schema);
  console.log("✓ تم إنشاء الجداول");

  // بيانات تجريبية (idempotent بسيطة)
  const { rows } = await pool.query("SELECT COUNT(*)::int AS c FROM projects");
  if (rows[0].c === 0) {
    await pool.query(
      `INSERT INTO countries (name_ar, name_en) VALUES ('موزمبيق','Mozambique'),('مصر','Egypt'),('السعودية','Saudi Arabia')`
    );
    await pool.query(
      `INSERT INTO regions (country_id, name_ar, city, priority, preacher, need_note)
       VALUES (1,'نامبولا','نامبولا','عاجلة','د. عبدالله م.','8,500 شخص بلا رعاية على بُعد 40 كم')`
    );
    await pool.query(
      `INSERT INTO projects (region_id, type, title_ar, summary_ar, budget_minor, raised_minor, currency, progress, status, verified)
       VALUES (1,'health_center','مركز نامبولا الصحي','رعاية صحية لقرية بلا مركز قريب',5000000,3100000,'USD',62,'active',true)`
    );
    await pool.query(
      `INSERT INTO project_stages (project_id, title_ar, progress, state, approved, stage_date) VALUES
       (1,'اختيار المنطقة واعتماد الحاجة',100,'done',true,'2026-03-01'),
       (1,'اعتماد الميزانية والتصميم',100,'done',true,'2026-04-01'),
       (1,'التأسيس والبناء',100,'done',true,'2026-05-01'),
       (1,'التشطيب والتجهيز الطبي',62,'now',true,'2026-06-15'),
       (1,'الافتتاح وأول مريض',0,'pending',false,'2026-09-01')`
    );
    await pool.query(
      `INSERT INTO monitoring_reports (project_id, kind, body_ar, approved) VALUES
       (1,'progress','اكتمل صبّ الأساسات وبدأ بناء الجدران الخارجية.',true),
       (1,'spend','صرف 540$ على التجهيزات الطبية الأولية — موثّق.',true),
       (1,'progress','تركيب الأبواب والنوافذ وبدء أعمال الدهان الداخلي.',true)`
    );
    console.log("✓ تمت إضافة بيانات تجريبية");
  }
  await pool.end();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
