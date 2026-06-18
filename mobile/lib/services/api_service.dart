import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import '../models/project_detail.dart';

class ApiService {
  // عدّلها لعنوان الباكند (محاكي أندرويد يستخدم 10.0.2.2 بدل localhost)
  static const String baseUrl = 'http://localhost:4000/api';

  Future<List<Project>> fetchProjects() async {
    final res = await http.get(Uri.parse('$baseUrl/projects'));
    if (res.statusCode != 200) {
      throw Exception('فشل تحميل المشاريع (${res.statusCode})');
    }
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProjectDetail> fetchProjectDetail(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/projects/$id'));
    if (res.statusCode != 200) {
      throw Exception('فشل تحميل المشروع (${res.statusCode})');
    }
    return ProjectDetail.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

/// بيانات تجريبية تُستخدم إن لم يكن الباكند متاحاً بعد.
List<Project> sampleProjects() => [
      Project(
        id: 1,
        type: 'health_center',
        titleAr: 'مركز نامبولا الصحي',
        summaryAr: '8,500 شخص بلا رعاية قريبة',
        regionName: 'نامبولا',
        countryName: 'موزمبيق',
        progress: 62,
        status: 'active',
        verified: true,
      ),
      Project(
        id: 2,
        type: 'well',
        titleAr: 'بئر مياه قرية بيمبا',
        summaryAr: 'مياه نظيفة لأول مرة في القرية',
        regionName: 'بيمبا',
        countryName: 'موزمبيق',
        progress: 30,
        status: 'active',
        verified: true,
      ),
    ];

ProjectDetail sampleProjectDetail(int id) => ProjectDetail(
      id: id,
      titleAr: 'مركز نامبولا الصحي',
      summaryAr: '8,500 شخص بلا رعاية قريبة',
      progress: 62,
      budgetMinor: 5000000,
      raisedMinor: 3100000,
      currency: 'USD',
      stages: [
        ProjectStage(titleAr: 'اختيار المنطقة واعتماد الحاجة', progress: 100, state: 'done', approved: true, stageDate: '2026-03-01'),
        ProjectStage(titleAr: 'اعتماد الميزانية والتصميم', progress: 100, state: 'done', approved: true, stageDate: '2026-04-01'),
        ProjectStage(titleAr: 'التأسيس والبناء', progress: 100, state: 'done', approved: true, stageDate: '2026-05-01'),
        ProjectStage(titleAr: 'التشطيب والتجهيز الطبي', progress: 62, state: 'now', approved: true, stageDate: '2026-06-15'),
        ProjectStage(titleAr: 'الافتتاح وأول مريض', progress: 0, state: 'pending', approved: false, stageDate: '2026-09-01'),
        ProjectStage(titleAr: 'التشغيل والمتابعة المستمرة', progress: 0, state: 'pending', approved: false),
      ],
      reports: [
        MonitoringReport(kind: 'progress', bodyAr: 'اكتمل صبّ الأساسات وبدأ بناء الجدران الخارجية.', createdAt: '2026-05-20'),
        MonitoringReport(kind: 'spend', bodyAr: 'صرف 540\$ على التجهيزات الطبية الأولية — موثّق.', createdAt: '2026-06-05'),
        MonitoringReport(kind: 'progress', bodyAr: 'تركيب الأبواب والنوافذ وبدء أعمال الدهان الداخلي.', createdAt: '2026-06-15'),
      ],
    );
