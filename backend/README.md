# AAFED Backend — Node.js + Express + PostgreSQL

## التشغيل
```bash
cp .env.example .env
npm install
npm run db:init   # ينشئ الجداول + بيانات تجريبية
npm run dev       # http://localhost:4000
```

## نقاط النهاية (المرحلة 1)
- `GET /api/health` — فحص الحالة
- `GET /api/projects` — قائمة المشاريع (فلترة اختيارية `?type=health_center`)
- `GET /api/projects/:id` — تفاصيل مشروع + مراحله + تقارير المتابعة المعتمدة

## الجداول
countries · regions · projects · project_stages · donors · donations · monitoring_reports · donor_reviews
