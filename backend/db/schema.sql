-- AAFED — مخطّط قاعدة البيانات (المرحلة 1)
-- ملاحظة: المبالغ تُخزَّن كأعداد صحيحة (أصغر وحدة عملة) لتجنّب أخطاء الفاصلة العائمة.

CREATE TABLE IF NOT EXISTS countries (
  id        SERIAL PRIMARY KEY,
  name_ar   TEXT NOT NULL,
  name_en   TEXT
);

CREATE TABLE IF NOT EXISTS regions (
  id          SERIAL PRIMARY KEY,
  country_id  INTEGER REFERENCES countries(id),
  name_ar     TEXT NOT NULL,
  city        TEXT,
  priority    TEXT,            -- عاجلة / متوسطة / عادية
  preacher    TEXT,            -- الداعية المسؤول
  need_note   TEXT,            -- سبب الأولوية
  lat         DOUBLE PRECISION,
  lng         DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS projects (
  id            SERIAL PRIMARY KEY,
  region_id     INTEGER REFERENCES regions(id),
  type          TEXT NOT NULL,         -- health_center / mosque / well / school / ...
  title_ar      TEXT NOT NULL,
  summary_ar    TEXT,
  budget_minor  BIGINT DEFAULT 0,      -- الميزانية بالأصغر وحدة
  raised_minor  BIGINT DEFAULT 0,
  currency      TEXT DEFAULT 'USD',
  progress      INTEGER DEFAULT 0,     -- 0..100
  status        TEXT DEFAULT 'active', -- active / completed / operating
  cover_url     TEXT,
  verified      BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS project_stages (
  id           SERIAL PRIMARY KEY,
  project_id   INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  title_ar     TEXT NOT NULL,
  description  TEXT,
  progress     INTEGER DEFAULT 0,
  state        TEXT DEFAULT 'pending', -- done / now / pending
  approved     BOOLEAN DEFAULT FALSE,
  stage_date   DATE
);

CREATE TABLE IF NOT EXISTS donors (
  id          SERIAL PRIMARY KEY,
  type        TEXT DEFAULT 'individual', -- individual / institution
  name        TEXT NOT NULL,
  email       TEXT UNIQUE,
  phone       TEXT,
  lang        TEXT DEFAULT 'ar',
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS donations (
  id            SERIAL PRIMARY KEY,
  donor_id      INTEGER REFERENCES donors(id),
  project_id    INTEGER REFERENCES projects(id),
  amount_minor  BIGINT NOT NULL,
  currency      TEXT DEFAULT 'USD',
  method        TEXT,              -- mobile_money / card / transfer
  category      TEXT,              -- sadaqah / zakat / general
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- تقارير المتابعة (تُرفع وتُعتمد ثم تظهر في سجل المشروع)
CREATE TABLE IF NOT EXISTS monitoring_reports (
  id            SERIAL PRIMARY KEY,
  project_id    INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  kind          TEXT,              -- progress / spend / opening / operating
  body_ar       TEXT,
  media_url     TEXT,
  uploaded_by   TEXT,
  approved      BOOLEAN DEFAULT FALSE, -- لا يظهر إلا بعد اعتماد المدير
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- مراجعات المتبرّعين (الشفافية المجتمعية)
CREATE TABLE IF NOT EXISTS donor_reviews (
  id              SERIAL PRIMARY KEY,
  project_id      INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  donor_id        INTEGER REFERENCES donors(id),
  rating_project  INTEGER,         -- 1..5
  rating_followup INTEGER,         -- تقييم متابعة الجمعية
  body_ar         TEXT,
  approved        BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- ============ المرحلة 2: مدى زمني + تنبيهات + إعلام + CRM + نبض البلد ============

-- مدى زمني مخطّط وفعلي لكل مرحلة (لرصد التقدّم/التأخّر)
ALTER TABLE project_stages ADD COLUMN IF NOT EXISTS planned_start DATE;
ALTER TABLE project_stages ADD COLUMN IF NOT EXISTS planned_end   DATE;
ALTER TABLE project_stages ADD COLUMN IF NOT EXISTS actual_start  DATE;
ALTER TABLE project_stages ADD COLUMN IF NOT EXISTS actual_end    DATE;

-- تنبيهات المدير (تقرير / تبرّع / بدء مرحلة / خطر تأخّر)
CREATE TABLE IF NOT EXISTS notifications (
  id          SERIAL PRIMARY KEY,
  type        TEXT,                  -- report / donation / stage_start / delay_risk
  project_id  INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  title_ar    TEXT,
  body_ar     TEXT,
  severity    TEXT DEFAULT 'info',   -- info / warning
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- القسم الإعلامي: مهام التصوير والنشر
CREATE TABLE IF NOT EXISTS media_tasks (
  id          SERIAL PRIMARY KEY,
  project_id  INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  need_type   TEXT,                  -- photo / video
  status      TEXT DEFAULT 'needed', -- needed / shot / edited / published
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- القصص الإنسانية الدورية
CREATE TABLE IF NOT EXISTS stories (
  id          SERIAL PRIMARY KEY,
  project_id  INTEGER REFERENCES projects(id),
  title_ar    TEXT,
  body_ar     TEXT,
  published   BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- اقتراحات أخبار عن المشاريع
CREATE TABLE IF NOT EXISTS project_news (
  id          SERIAL PRIMARY KEY,
  project_id  INTEGER REFERENCES projects(id),
  title_ar    TEXT,
  body_ar     TEXT,
  status      TEXT DEFAULT 'suggested', -- suggested / approved / published
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- نبض البلد: أخبار من موزمبيق
CREATE TABLE IF NOT EXISTS country_pulse (
  id          SERIAL PRIMARY KEY,
  country_id  INTEGER REFERENCES countries(id),
  headline_ar TEXT,
  body_ar     TEXT,
  pulse       TEXT,                  -- positive / neutral / concern
  pulse_date  DATE DEFAULT CURRENT_DATE,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- CRM المتعاونين (أفراد وجمعيات)
CREATE TABLE IF NOT EXISTS collaborators (
  id          SERIAL PRIMARY KEY,
  type        TEXT DEFAULT 'individual', -- individual / organization
  name        TEXT NOT NULL,
  contact     TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS collaborator_projects (
  collaborator_id INTEGER REFERENCES collaborators(id) ON DELETE CASCADE,
  project_id      INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  PRIMARY KEY (collaborator_id, project_id)
);

-- التقارير الدورية المرسلة للمتعاونين
CREATE TABLE IF NOT EXISTS collaborator_reports (
  id              SERIAL PRIMARY KEY,
  collaborator_id INTEGER REFERENCES collaborators(id) ON DELETE CASCADE,
  period          TEXT,              -- شهري / ربع سنوي
  sent_at         DATE,
  summary_ar      TEXT
);

-- تقييم المتبرّع للجمعية وتقاريرها + اقتراحات التعديل
CREATE TABLE IF NOT EXISTS association_feedback (
  id             SERIAL PRIMARY KEY,
  donor_id       INTEGER REFERENCES donors(id),
  rating_org     INTEGER,            -- 1..5 تقييم الجمعية
  rating_reports INTEGER,            -- 1..5 تقييم التقارير
  suggestion_ar  TEXT,
  created_at     TIMESTAMPTZ DEFAULT now()
);

-- المدفوعات: حالة ومرجع مزوّد الدفع (جاهز للربط بأي مزوّد)
ALTER TABLE donations ADD COLUMN IF NOT EXISTS status       TEXT DEFAULT 'paid'; -- pending / paid / failed
ALTER TABLE donations ADD COLUMN IF NOT EXISTS provider     TEXT;
ALTER TABLE donations ADD COLUMN IF NOT EXISTS provider_ref TEXT;
