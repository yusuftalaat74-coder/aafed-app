# رفع المشروع على GitHub

تم تجهيز المستودع وعمل أول commit. نفّذ الخطوات دي من **Terminal على جهازك** داخل مجلد المشروع.

## 0) افتح المجلد في الطرفية
```bash
cd "/Users/yusuftalaat/Desktop/prompit milu system/ngo/aafed-app"
```

## 1) امسح ملفات القفل العالقة (مرة واحدة)
> نشأت بسبب مزامنة الملفات أثناء التجهيز — حذفها آمن تماماً.
```bash
rm -f .git/HEAD.lock .git/index.lock .git/objects/maintenance.lock
git status
```

## 2) أنشئ المستودع على GitHub وارفع

### الطريقة (أ): GitHub CLI — لو عندك `gh` ومسجّل دخول
```bash
gh repo create aafed-app --private --source=. --remote=origin --push
```

### الطريقة (ب): يدوياً
1. افتح https://github.com/new وأنشئ مستودعاً باسم `aafed-app` (بدون README).
2. ثم:
```bash
git branch -M main
git remote add origin https://github.com/<اسم-حسابك>/aafed-app.git
git push -u origin main
```

> ملاحظة أمان: أنا لا أدخل بيانات دخولك أو التوكن — الرفع يتم بحسابك أنت.

## بعد الرفع
أي تعديل لاحق:
```bash
git add -A
git commit -m "وصف التعديل"
git push
```
