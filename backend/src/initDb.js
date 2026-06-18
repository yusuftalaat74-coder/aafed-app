// ينشئ الجداول ويضيف بيانات تجريبية
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { pool } from "./db.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function main() {
  const schema = fs.readFileSync(path.join(__dirname, "../db/schema.sql"), "utf8");
  await pool.query(schema);
  console.log("✓ تم إنشاء/تحديث الجداول");

  const { rows } = await pool.query("SELECT COUNT(*)::int AS c FROM projects");
  if (rows[0].c === 0) {
    await pool.query(
      `INSERT INTO countries (name_ar, name_en) VALUES ('موزمبيق','Mozambique'),('مصر','Egypt'),('السعودية','Saudi Arabia')`
    );
    await pool.query(
      `INSERT INTO regions (country_id, name_ar, city, priority, preacher, need_note) VALUES
       (1,'نامبولا','نامبولا','عاجلة','د. عبدالله م.','8,500 شخص بلا رعاية على بُعد 40 كم'),
       (1,'بيمبا','بيمبا','متوسطة','د. يوسف ك.','قرية بحاجة لمسجد ومصلى')`
    );
    // مشروع 1: مركز صحي — في الموعد
    await pool.query(
      `INSERT INTO projects (region_id, type, title_ar, summary_ar, budget_minor, raised_minor, currency, progress, status, verified)
       VALUES (1,'health_center','مركز نامبولا الصحي','رعاية صحية لقرية بلا مركز قريب',5000000,3100000,'USD',62,'active',true)`
    );
    // مشروع 2: مسجد — متأخّر (لإظهار التنبيه)
    await pool.query(
      `INSERT INTO projects (region_id, type, title_ar, summary_ar, budget_minor, raised_minor, currency, progress, status, verified)
       VALUES (2,'mosque','مسجد قرية بيمبا','بناء مسجد ومصلى للقرية',3000000,1200000,'USD',40,'active',true)`
    );

    // مراحل مشروع 1 (بمدى زمني)
    await pool.query(
      `INSERT INTO project_stages (project_id, title_ar, progress, state, approved, planned_start, planned_end, actual_start, actual_end) VALUES
       (1,'اختيار المنطقة واعتماد الحاجة',100,'done',true,'2026-03-01','2026-03-15','2026-03-01','2026-03-14'),
       (1,'اعتماد الميزانية والتصميم',100,'done',true,'2026-03-16','2026-04-15','2026-03-16','2026-04-12'),
       (1,'التأسيس والبناء',100,'done',true,'2026-04-16','2026-05-31','2026-04-16','2026-05-28'),
       (1,'التشطيب والتجهيز الطبي',62,'now',true,'2026-06-01','2026-07-30','2026-06-01',NULL),
       (1,'الافتتاح وأول مريض',0,'pending',false,'2026-08-01','2026-09-01',NULL,NULL)`
    );
    // مراحل مشروع 2 (المرحلة الجارية تجاوزت موعدها → متأخّر)
    await pool.query(
      `INSERT INTO project_stages (project_id, title_ar, progress, state, approved, planned_start, planned_end, actual_start, actual_end) VALUES
       (2,'اختيار المنطقة',100,'done',true,'2026-02-01','2026-02-20','2026-02-01','2026-02-18'),
       (2,'الأساسات والبناء',40,'now',true,'2026-03-01','2026-06-01','2026-03-05',NULL),
       (2,'التجهيز والافتتاح',0,'pending',false,'2026-06-15','2026-07-15',NULL,NULL)`
    );

    await pool.query(
      `INSERT INTO monitoring_reports (project_id, kind, body_ar, approved) VALUES
       (1,'progress','اكتمل صبّ الأساسات وبدأ بناء الجدران الخارجية.',true),
       (1,'spend','صرف 540$ على التجهيزات الطبية الأولية — موثّق.',true),
       (1,'progress','تركيب الأبواب والنوافذ وبدء أعمال الدهان الداخلي.',true)`
    );

    // القسم الإعلامي
    await pool.query(
      `INSERT INTO media_tasks (project_id, need_type, status, notes) VALUES
       (1,'video','needed','تصوير فيديو لمرحلة التشطيب'),
       (1,'photo','shot','صور التجهيز الطبي — بانتظار النشر'),
       (2,'photo','needed','تصوير فوتوغرافي لموقع البناء المتأخّر'),
       (2,'video','edited','فيديو الأساسات جاهز ولم يُنشر')`
    );

    // قصص إنسانية + أخبار مقترحة
    await pool.query(
      `INSERT INTO stories (project_id, title_ar, body_ar, published) VALUES
       (1,'أمينة تحلم أن تصبح طبيبة','قصة طفلة من نامبولا تنتظر افتتاح المركز.',false)`
    );
    await pool.query(
      `INSERT INTO project_news (project_id, title_ar, body_ar, status) VALUES
       (1,'اقتراب افتتاح مركز نامبولا الصحي','المركز في مراحله الأخيرة قبل الافتتاح.','suggested'),
       (2,'حملة لاستكمال مسجد بيمبا','المشروع بحاجة لدعم لاستكمال البناء.','suggested')`
    );

    // أخبار من موزمبيق — النبض العام
    await pool.query(
      `INSERT INTO country_pulse (country_id, headline_ar, body_ar, pulse) VALUES
       (1,'موسم الأمطار يبدأ في الشمال','قد يؤثّر على حركة مواد البناء في بعض المناطق.','concern'),
       (1,'افتتاح طريق جديد قرب نامبولا','يسهّل وصول المساعدات للقرى.','positive')`
    );

    // CRM المتعاونين + مشاريعهم + تقاريرهم الدورية
    await pool.query(
      `INSERT INTO collaborators (type, name, contact, notes) VALUES
       ('organization','مؤسسة الخير القابضة','partners@khair.org','مانح مؤسسي — تقارير ربع سنوية'),
       ('individual','أ. محمد سعيد','m.saeed@email.com','متبرّع فرد منتظم')`
    );
    await pool.query(
      `INSERT INTO collaborator_projects (collaborator_id, project_id) VALUES (1,1),(1,2),(2,1)`
    );
    await pool.query(
      `INSERT INTO collaborator_reports (collaborator_id, period, sent_at, summary_ar) VALUES
       (1,'ربع سنوي','2026-04-01','تقرير الربع الأول: تقدّم المركز الصحي 45%'),
       (2,'شهري','2026-06-01','تحديث شهري عن كفالتك ومشروعك')`
    );

    // تقييم المتبرّع للجمعية + اقتراح
    await pool.query(
      `INSERT INTO donors (type, name, email) VALUES ('individual','يوسف طلعت','yusuf@email.com')`
    );
    await pool.query(
      `INSERT INTO association_feedback (donor_id, rating_org, rating_reports, suggestion_ar) VALUES
       (1,5,4,'حابب التقارير تيجي بصور أكتر من الموقع')`
    );

    // تنبيهات المدير الأولية
    await pool.query(
      `INSERT INTO notifications (type, project_id, title_ar, body_ar, severity) VALUES
       ('delay_risk',2,'مشروع متأخّر','مسجد قرية بيمبا تجاوز الموعد المخطّط للمرحلة الجارية.','warning'),
       ('report',1,'تقرير متابعة جديد','تم رفع تقرير تقدّم لمركز نامبولا.','info')`
    );

    // ===== محتوى الموقع الحقيقي =====
    await pool.query(
      `INSERT INTO site_content (key, value_ar) VALUES
       ('about','نحن «أفريقيا للتعليم والتنمية»، منظمة خيرية مكرّسة لتحسين الحياة عبر أفريقيا. مهمتنا التصدي للاحتياجات الحرجة مثل التعليم والرعاية الصحية والوصول إلى المياه النظيفة من خلال بناء المدارس والعيادات وآبار المياه، كما ندعم المجتمعات عبر توزيع المساعدات الغذائية وبناء المساجد.'),
       ('mission','تحسين الحياة وتعزيز الرفاهية للأفراد والمجتمعات المحتاجة، عبر توفير الدعم والموارد في الغذاء والتعليم والرعاية الصحية والمياه النظيفة، وبناء الوعي وتمكين المجتمعات لتحقيق تغيير إيجابي مستدام.'),
       ('vision','تحقيق ازدهار أفريقيا، حيث يتاح لكل فرد فرصة حياة صحية كريمة، ومستقبل نمحو فيه الفقر ونقص الفرص.'),
       ('projects_tagline','ساهم في تنمية المجتمعات الفقيرة التي تعاني المجاعات والأوبئة وينخر فيها الجهل والأمية.')`
    );

    await pool.query(
      `INSERT INTO project_types (slug, name_ar, slogan_ar) VALUES
       ('schools','المدارس التعليمية والشرعية','التعليم هو أهم أسباب القضاء على الفقر'),
       ('mosques','المساجد','إنما يعمر مساجد الله من آمن بالله واليوم الآخر'),
       ('health_centers','المراكز الصحية','ومن أحياها فكأنما أحيا الناس جميعاً'),
       ('clothing','توزيع الملابس','احتياج الفقراء في أفريقيا إلى الملابس'),
       ('bikes','توزيع الدراجات','الدراجات في بعض أماكن أفريقيا طوق نجاة'),
       ('quran','توزيع المصاحف','أن تكون سبباً في تعليم شخص القرآن هي أعظم الأسباب'),
       ('wheelchairs','توزيع كراسي متحركة','شراء الكراسي المتحركة ضرورة قصوى'),
       ('wells','آبار المياه','الماء سر الحياة، والآبار حل ندرة المياه في أفريقيا'),
       ('feeding','إطعام مسكين','أفريقيا أكثر قارة تحتاج لمواد غذائية في العالم'),
       ('qurbani','الأضاحي','أفريقيا أولى بأضحيتك'),
       ('cataract','عمليات المياه البيضاء','عمليات المياه البيضاء تغيّر حياة الآلاف')`
    );

    await pool.query(
      `INSERT INTO partners (name, logo_url) VALUES
       ('شريك 1','https://www.aafed.org/img/partners/partners_main_1710061739.png'),
       ('شريك 2','https://www.aafed.org/img/partners/partners_main_1710061750.png'),
       ('شريك 3','https://www.aafed.org/img/partners/partners_main_1710061760.png'),
       ('شريك 4','https://www.aafed.org/img/partners/partners_main_1710061770.png'),
       ('شريك 5','https://www.aafed.org/img/partners/partners_main_1710061857.png'),
       ('شريك 6','https://www.aafed.org/img/partners/partners_main_1710061874.png')`
    );

    await pool.query(
      `INSERT INTO team_groups (name_ar, image_url) VALUES
       ('الإدارة','https://www.aafed.org/img/management/management_main_1722344876.png'),
       ('فريق العمل','https://www.aafed.org/img/management/management_main_1710338156.png'),
       ('المتطوعون','https://www.aafed.org/img/management/management_main_1710338173.png')`
    );

    await pool.query(
      `INSERT INTO featured_cases (name, country, summary_ar) VALUES
       ('معاذ','موزمبيق','طفل بحاجة لكفالة تعليمية ومعيشية.'),
       ('حسن','موزمبيق','حالة موثّقة بانتظار كفيل.'),
       ('محمود','موزمبيق','يتيم يحتاج رعاية شهرية.'),
       ('خالد','موزمبيق','طفل ضمن برنامج الكفالات.')`
    );

    console.log("✓ تمت إضافة بيانات تجريبية موسّعة + محتوى الموقع الحقيقي");
  }
  await pool.end();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
