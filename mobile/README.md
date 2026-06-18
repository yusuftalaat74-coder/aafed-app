# AAFED Mobile — Flutter

تطبيق المتبرّع (أندرويد + iOS) بكود واحد.

## التشغيل
```bash
cd mobile
flutter create .      # يولّد مجلدات android/ ios/ (يحافظ على lib/ الموجود)
flutter pub get
flutter run
```

> ملاحظة: محاكي أندرويد يصل للباكند المحلي عبر `http://10.0.2.2:4000` بدل `localhost`.
> عدّل `baseUrl` في `lib/services/api_service.dart` حسب بيئتك.

## البنية
```
lib/
├── main.dart                 # نقطة البداية + RTL + الثيم
├── theme/app_theme.dart      # هوية AAFED (كحلي + أخضر)
├── models/project.dart       # نموذج المشروع
├── services/api_service.dart # الاتصال بالـ API (+ بيانات تجريبية احتياطية)
└── screens/home_screen.dart  # الشاشة الرئيسية
```

الشاشة الحالية: الرئيسية (لافتة الأثر، الأقسام الدائرية، مشروع اليوم بشريط تقدّم وشارة توثيق).
