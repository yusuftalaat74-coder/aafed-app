import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';

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
