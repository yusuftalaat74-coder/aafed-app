#!/bin/bash
# دوس دوبل-كليك على هذا الملف لرفع المشروع على GitHub.
cd "$(dirname "$0")" || exit 1

echo "==> تنظيف الملفات المؤقتة..."
rm -f .git/HEAD.lock .git/index.lock .git/objects/maintenance.lock

echo "==> حفظ آخر التعديلات..."
git add -A
git commit -m "AAFED app — تحديث" >/dev/null 2>&1
git branch -M main

echo "==> الربط بـ GitHub والرفع..."
git remote remove origin >/dev/null 2>&1
git remote add origin https://github.com/yusuftalaat74-coder/aafed-app.git

if git push -u origin main; then
  echo ""
  echo "✅ تم الرفع بنجاح!"
  echo "افتح: https://github.com/yusuftalaat74-coder/aafed-app"
else
  echo ""
  echo "⚠️ لو طلب منك تسجيل دخول: اكتب اسم المستخدم yusuftalaat74-coder"
  echo "   وفي خانة الباسورد الصق Personal Access Token من GitHub."
fi
echo ""
echo "تقدر تقفل النافذة دلوقتي."
