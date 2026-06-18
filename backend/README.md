# AAFED Backend — Node.js + Express + PostgreSQL

## التشغيل
```bash
cp .env.example .env
npm install
npm run db:init   # ينشئ/يحدّث الجداول + بيانات تجريبية
npm run dev       # http://localhost:4000
```

## نقاط النهاية

### المشاريع والتايم لاين
- `GET /api/health`
- `GET /api/projects` — قائمة المشاريع (`?type=health_center`)
- `GET /api/projects/:id` — تفاصيل + مراحل (بمدى زمني) + **حالة (في الموعد/خطر تأخّر/متأخّر)** + تقارير معتمدة
- `POST /api/projects/:id/reports` — رفع تقرير متابعة (معلّق) → **تنبيه للمدير**
- `POST /api/projects/:id/stages/:stageId/start` — بدء مرحلة فعلياً → **تنبيه للمدير**

### التبرّعات والتنبيهات
- `POST /api/donations` — تسجيل تبرّع → يحدّث المُجمَّع + **تنبيه للمدير**
- `GET /api/notifications` · `GET /api/notifications/unread-count` · `POST /api/notifications/:id/read`

### القسم الإعلامي
- `GET /api/media/tasks` — كل المهام
- `GET /api/media/needs-shooting` — مشاريع محتاجة تصوير
- `GET /api/media/unpublished` — صُوِّر ولم يُنشر بعد

### المحتوى وأخبار موزمبيق
- `GET /api/content/stories` — القصص الإنسانية
- `GET /api/content/news` — اقتراحات أخبار المشاريع
- `GET /api/content/country-pulse?country=موزمبيق` — النبض العام للبلد

### CRM المتعاونين
- `GET /api/crm/collaborators` — الأفراد والجمعيات + عدد مشاريعهم
- `GET /api/crm/collaborators/:id` — مشاريعه + التقارير الدورية المرسلة له
- `POST /api/crm/collaborators`

### تقييم المتبرّع للجمعية
- `POST /api/feedback` — تقييم الجمعية وتقاريرها + اقتراح تعديل
- `GET /api/feedback` — ملخّص التقييمات + الاقتراحات (للداشبورد)

### الداشبورد
- `GET /api/dashboard/overview` — مؤشرات + حالة كل مشروع (تقدّم/تأخّر) + **تنبيهات التأخّر**

## رصد التأخّر
كل مرحلة لها `planned_start/planned_end` (مخطّط) و`actual_start/actual_end` (فعلي).
الحالة تُحسب من المرحلة الجارية: تجاوز الموعد = **متأخّر**؛ قارب الموعد والتقدّم < 80% = **خطر تأخّر**.
