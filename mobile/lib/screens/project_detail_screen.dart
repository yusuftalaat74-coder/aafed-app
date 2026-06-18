import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/project_detail.dart';
import '../services/api_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  final String title;
  const ProjectDetailScreen(
      {super.key, required this.projectId, required this.title});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Future<ProjectDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService()
        .fetchProjectDetail(widget.projectId)
        .catchError((_) => sampleProjectDetail(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            indicatorColor: AppColors.lime,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'الرحلة'),
              Tab(text: 'المالية'),
              Tab(text: 'تقارير المتابعة'),
            ],
          ),
        ),
        body: FutureBuilder<ProjectDetail>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final d = snap.data ?? sampleProjectDetail(widget.projectId);
            return TabBarView(
              children: [
                _journeyTab(d),
                _financeTab(d),
                _reportsTab(d),
              ],
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              child: const Text('تبرّع وتابِع الرحلة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),
      ),
    );
  }

  // ===== تبويب الرحلة (التايم لاين) =====
  Widget _journeyTab(ProjectDetail d) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _ringProgress(d.progress),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.titleAr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  if (d.summaryAr != null)
                    Text(d.summaryAr!,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...List.generate(d.stages.length, (i) => _stageTile(d.stages[i], i == d.stages.length - 1)),
      ],
    );
  }

  Widget _ringProgress(int pct) => SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: pct / 100,
                strokeWidth: 7,
                backgroundColor: AppColors.line,
                color: AppColors.green,
              ),
            ),
            Text('$pct%',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.navy)),
          ],
        ),
      );

  Widget _stageTile(ProjectStage s, bool isLast) {
    final Color nodeColor = s.state == 'done'
        ? AppColors.green
        : s.state == 'now'
            ? AppColors.gold
            : AppColors.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor, width: 2),
                ),
                child: Icon(
                  s.state == 'done'
                      ? Icons.check
                      : s.state == 'now'
                          ? Icons.bolt
                          : Icons.circle_outlined,
                  size: 15,
                  color: s.state == 'pending' ? AppColors.muted : Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.line)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.titleAr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    s.state == 'now'
                        ? 'جارٍ الآن — ${s.progress}%'
                        : (s.stageDate ?? ''),
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                  if (s.approved)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('● موثّق من الجمعية',
                          style: TextStyle(color: AppColors.green, fontSize: 11)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== تبويب المالية =====
  Widget _financeTab(ProjectDetail d) {
    final remaining = (d.budget - d.raised).clamp(0, double.infinity);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _financeRow('جُمع حتى الآن', '${d.raised.toStringAsFixed(0)} ${d.currency}', AppColors.green),
        _financeRow('إجمالي الميزانية', '${d.budget.toStringAsFixed(0)} ${d.currency}', AppColors.navy),
        _financeRow('المتبقّي', '${remaining.toStringAsFixed(0)} ${d.currency}', AppColors.gold),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: d.budget == 0 ? 0 : d.raised / d.budget,
            minHeight: 10,
            backgroundColor: AppColors.line,
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 12),
        const Text('● كل صرف مرتبط بإثبات ميداني موثّق',
            style: TextStyle(color: AppColors.green, fontSize: 12)),
      ],
    );
  }

  Widget _financeRow(String label, String value, Color c) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: c, fontSize: 16)),
          ],
        ),
      );

  // ===== تبويب تقارير المتابعة =====
  Widget _reportsTab(ProjectDetail d) {
    if (d.reports.isEmpty) {
      return const Center(
        child: Text('لا توجد تقارير متابعة معتمدة بعد',
            style: TextStyle(color: AppColors.muted)),
      );
    }
    const kinds = {
      'progress': 'تقدّم البناء',
      'spend': 'إثبات صرف',
      'opening': 'الافتتاح',
      'operating': 'تقرير تشغيل',
    };
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: d.reports.length,
      itemBuilder: (_, i) {
        final r = d.reports[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withOpacity(.08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(kinds[r.kind] ?? r.kind,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy)),
                  ),
                  const Spacer(),
                  Text(r.createdAt?.split('T').first ?? '',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              Text(r.bodyAr ?? '', style: const TextStyle(fontSize: 13, height: 1.5)),
              const SizedBox(height: 6),
              const Text('● موثّق من الجمعية',
                  style: TextStyle(color: AppColors.green, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}
