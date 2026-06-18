/// مرحلة في رحلة المشروع
class ProjectStage {
  final String titleAr;
  final String? description;
  final int progress;
  final String state; // done / now / pending
  final bool approved;
  final String? stageDate;

  ProjectStage({
    required this.titleAr,
    this.description,
    required this.progress,
    required this.state,
    required this.approved,
    this.stageDate,
  });

  factory ProjectStage.fromJson(Map<String, dynamic> j) => ProjectStage(
        titleAr: j['title_ar'] as String? ?? '',
        description: j['description'] as String?,
        progress: (j['progress'] as num?)?.toInt() ?? 0,
        state: j['state'] as String? ?? 'pending',
        approved: j['approved'] as bool? ?? false,
        stageDate: j['stage_date']?.toString(),
      );
}

/// تقرير متابعة (يظهر بعد اعتماد الجمعية)
class MonitoringReport {
  final String kind; // progress / spend / opening / operating
  final String? bodyAr;
  final String? createdAt;

  MonitoringReport({required this.kind, this.bodyAr, this.createdAt});

  factory MonitoringReport.fromJson(Map<String, dynamic> j) => MonitoringReport(
        kind: j['kind'] as String? ?? 'progress',
        bodyAr: j['body_ar'] as String?,
        createdAt: j['created_at']?.toString(),
      );
}

/// تفاصيل المشروع الكاملة
class ProjectDetail {
  final int id;
  final String titleAr;
  final String? summaryAr;
  final int progress;
  final int budgetMinor;
  final int raisedMinor;
  final String currency;
  final List<ProjectStage> stages;
  final List<MonitoringReport> reports;

  ProjectDetail({
    required this.id,
    required this.titleAr,
    this.summaryAr,
    required this.progress,
    required this.budgetMinor,
    required this.raisedMinor,
    required this.currency,
    required this.stages,
    required this.reports,
  });

  double get raised => raisedMinor / 100.0;
  double get budget => budgetMinor / 100.0;

  factory ProjectDetail.fromJson(Map<String, dynamic> j) => ProjectDetail(
        id: j['id'] as int,
        titleAr: j['title_ar'] as String? ?? '',
        summaryAr: j['summary_ar'] as String?,
        progress: (j['progress'] as num?)?.toInt() ?? 0,
        budgetMinor: (j['budget_minor'] as num?)?.toInt() ?? 0,
        raisedMinor: (j['raised_minor'] as num?)?.toInt() ?? 0,
        currency: j['currency'] as String? ?? 'USD',
        stages: ((j['stages'] as List?) ?? [])
            .map((e) => ProjectStage.fromJson(e as Map<String, dynamic>))
            .toList(),
        reports: ((j['reports'] as List?) ?? [])
            .map((e) => MonitoringReport.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
