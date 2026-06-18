/// نموذج المشروع
class Project {
  final int id;
  final String type;
  final String titleAr;
  final String? summaryAr;
  final String? regionName;
  final String? countryName;
  final int progress;
  final String status;
  final bool verified;

  Project({
    required this.id,
    required this.type,
    required this.titleAr,
    this.summaryAr,
    this.regionName,
    this.countryName,
    required this.progress,
    required this.status,
    required this.verified,
  });

  factory Project.fromJson(Map<String, dynamic> j) => Project(
        id: j['id'] as int,
        type: j['type'] as String? ?? '',
        titleAr: j['title_ar'] as String? ?? '',
        summaryAr: j['summary_ar'] as String?,
        regionName: j['region_name'] as String?,
        countryName: j['country_name'] as String?,
        progress: (j['progress'] as num?)?.toInt() ?? 0,
        status: j['status'] as String? ?? 'active',
        verified: j['verified'] as bool? ?? false,
      );
}
