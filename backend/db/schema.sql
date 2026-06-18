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
