import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/project.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Project>> _future;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    // يحاول جلب البيانات من الباكند، وإن فشل يعرض بيانات تجريبية.
    _future = _api.fetchProjects().catchError((_) => sampleProjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Project>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final projects = snap.data ?? sampleProjects();
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _header(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _impactCard(),
                      const SizedBox(height: 18),
                      _sectionTitle('تبرّع حسب النوع'),
                      const SizedBox(height: 10),
                      _categories(),
                      const SizedBox(height: 18),
                      _sectionTitle('مشروع اليوم'),
                      const SizedBox(height: 10),
                      ...projects.map(_projectCard),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 26),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navy, AppColors.navyLight],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.lime,
              child: Text('AA',
                  style: TextStyle(
                      color: AppColors.navy, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('السلام عليكم، يوسف',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('معاً نحو أفريقيا أكثر إشراقاً',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.notifications_none, color: Colors.white),
          ],
        ),
      );

  Widget _impactCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.green, Color(0xFF1F7A4D)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('أثرك مستمر منذ 2024',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 4),
            Text('غيّرت حياة 1,240 إنساناً',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _categories() {
    final cats = [
      ('مراكز صحية', Icons.local_hospital),
      ('آبار مياه', Icons.water_drop),
      ('مساجد', Icons.mosque),
      ('مدارس', Icons.school),
      ('كفالات', Icons.volunteer_activism),
    ];
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.line,
              child: Icon(cats[i].$2, color: AppColors.navy, size: 28),
            ),
            const SizedBox(height: 6),
            Text(cats[i].$1, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _projectCard(Project p) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withOpacity(.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.local_hospital, color: AppColors.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.titleAr,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${p.regionName ?? ''} · ${p.countryName ?? ''}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
                if (p.verified)
                  const Icon(Icons.verified, color: AppColors.green, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: p.progress / 100,
                minHeight: 8,
                backgroundColor: AppColors.line,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('التنفيذ ${p.progress}%',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
                const Text('موثّق ✓',
                    style: TextStyle(color: AppColors.green, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                child: const Text('تبرّع وتابِع الرحلة',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String t) => Align(
        alignment: Alignment.centerRight,
        child: Text(t,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.navy)),
      );

  Widget _bottomNav() => NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.track_changes), label: 'مشاريعي'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'كفالاتي'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'رحلتي'),
        ],
      );
}
