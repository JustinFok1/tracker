import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';
import '../data/theme_store.dart';
import '../data/body_metric_store.dart';
import '../data/data_service.dart';
import '../models/body_metric.dart';
import 'home_screen.dart';
import 'track_screen.dart';
import '../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _ProfileScreen extends StatefulWidget {
  const _ProfileScreen();

  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  @override
  void initState() {
    super.initState();
    BodyMetricStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    BodyMetricStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool _showAllMetrics = false;

  List<BodyMetric> get _metrics => BodyMetricStore.instance.metrics;
  BodyMetric? get _latest => _metrics.isNotEmpty ? _metrics.first : null;
  BodyMetric? get _previous => _metrics.length > 1 ? _metrics[1] : null;

  String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  List<FlSpot> _weightDataPoints() {
    final withWeight = _metrics.where((m) => m.weight != null).toList().reversed.toList();
    if (withWeight.length < 2) return [];
    final last = withWeight.length > 14 ? withWeight.sublist(withWeight.length - 14) : withWeight;
    return last.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight!)).toList();
  }

  void _showLogSheet({BodyMetric? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(
        existing: existing,
        onSave: (metric) {
          if (existing != null) {
            BodyMetricStore.instance.update(existing, metric);
          } else {
            BodyMetricStore.instance.add(metric);
          }
        },
      ),
    );
  }

  void _showDetailSheet(BodyMetric m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MetricDetailSheet(
        metric: m,
        onEdit: () {
          Navigator.pop(context);
          _showLogSheet(existing: m);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final spots = _weightDataPoints();
    final latest = _latest;
    final prev = _previous;

    final delta = (latest?.weight != null && prev?.weight != null)
        ? latest!.weight! - prev!.weight!
        : null;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Profile",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _showLogSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "+ Log Weight",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weight stat card
            _sectionLabel("BODY METRICS"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.card, context.colors.card2],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.monitor_weight_outlined,
                        color: Colors.tealAccent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("WEIGHT",
                          style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 10,
                              letterSpacing: 1.1)),
                      const SizedBox(height: 4),
                      Text(
                        latest?.weight != null
                            ? "${latest!.weight!.toStringAsFixed(1)} ${latest.weightUnit}"
                            : "—",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent),
                      ),
                    ],
                  ),
                  if (delta != null) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Icon(
                          delta > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: delta > 0 ? Colors.redAccent : Colors.greenAccent,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} ${latest!.weightUnit}",
                          style: TextStyle(
                            fontSize: 12,
                            color: delta > 0 ? Colors.redAccent : Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Weight chart
            if (spots.length >= 2) ...[
              const SizedBox(height: 16),
              _weightChart(spots),
            ],

            // History
            if (_metrics.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionLabel("HISTORY"),
              const SizedBox(height: 12),
              ...(_showAllMetrics ? _metrics : _metrics.take(3))
                  .map((m) => _metricCard(m)),
              if (_metrics.length > 3)
                GestureDetector(
                  onTap: () => setState(() => _showAllMetrics = !_showAllMetrics),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Center(
                      child: Text(
                        _showAllMetrics
                            ? "Show less"
                            : "Show all (${_metrics.length})",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 20),
            _sectionLabel("DATA"),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.table_chart_outlined,
              iconColor: Colors.tealAccent,
              title: "Export Body Metrics",
              subtitle: "Save as CSV",
              onTap: () => DataService.exportBodyMetrics(context),
            ),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.history,
              iconColor: Colors.purpleAccent,
              title: "Export Dose History",
              subtitle: "Save as CSV",
              onTap: () => DataService.exportDoseHistory(context),
            ),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.cloud_upload_outlined,
              iconColor: Colors.blueAccent,
              title: "Backup All Data",
              subtitle: "Export full backup as JSON",
              onTap: () => DataService.backupAll(context),
            ),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.cloud_download_outlined,
              iconColor: Colors.orangeAccent,
              title: "Restore from Backup",
              subtitle: "Import a JSON backup file",
              onTap: () => DataService.restoreFromBackup(context),
            ),

            const SizedBox(height: 20),
            _sectionLabel("SETTINGS"),
            const SizedBox(height: 12),

            // Appearance toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.purpleAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Appearance",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(isDark ? "Dark mode" : "Light mode",
                            style: TextStyle(
                                color: context.colors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (_) => ThemeStore.instance.toggle(),
                    activeThumbColor: Colors.purpleAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Text(text,
            style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.border, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: context.colors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: context.colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _weightChart(List<FlSpot> spots) {
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 3,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: context.colors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 9),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.tealAccent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: 3,
                  color: Colors.tealAccent,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.tealAccent.withValues(alpha: 0.2),
                    Colors.tealAccent.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(BodyMetric m) {
    return Dismissible(
      key: Key('metric_${m.id}'),
      direction: DismissDirection.horizontal,
      // Swipe right → edit (teal)
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.tealAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit_outlined, color: Colors.tealAccent, size: 20),
      ),
      // Swipe left → delete (red)
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showLogSheet(existing: m);
        } else {
          BodyMetricStore.instance.delete(m);
          // Delete associated photos from disk
          for (final path in m.photoPaths) {
            final file = File(path);
            if (await file.exists()) await file.delete();
          }
        }
        return false;
      },
      child: GestureDetector(
        onTap: () => _showDetailSheet(m),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.monitor_weight_outlined,
                    color: Colors.tealAccent, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDate(m.date),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (m.notes != null && m.notes!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(m.notes!,
                          style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              if (m.photoPaths.isNotEmpty) ...[
                Icon(Icons.photo_library_outlined,
                    color: context.colors.textSecondary, size: 14),
                const SizedBox(width: 4),
              ],
              Text(
                "${m.weight?.toStringAsFixed(1) ?? '—'} ${m.weightUnit}",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.tealAccent),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right,
                  color: context.colors.textSecondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== DETAIL SHEET =====
class _MetricDetailSheet extends StatelessWidget {
  final BodyMetric metric;
  final VoidCallback onEdit;

  const _MetricDetailSheet({required this.metric, required this.onEdit});

  String _formatDate(DateTime d) {
    const months = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasPhotos = metric.photoPaths.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Date + edit button
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(metric.date),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Edit",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weight
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.card2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.monitor_weight_outlined,
                      color: Colors.tealAccent, size: 18),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("WEIGHT",
                        style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 10, letterSpacing: 1.1)),
                    const SizedBox(height: 4),
                    Text(
                      "${metric.weight?.toStringAsFixed(1) ?? '—'} ${metric.weightUnit}",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: Colors.tealAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notes
          if (metric.notes != null && metric.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.card2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NOTES",
                      style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 10, letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  Text(metric.notes!,
                      style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
              ),
            ),
          ],

          // Photos
          if (hasPhotos) ...[
            const SizedBox(height: 12),
            Text("PHOTOS",
                style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 10, letterSpacing: 1.1,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: metric.photoPaths.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final file = File(metric.photoPaths[i]);
                  return GestureDetector(
                    onTap: () => _viewPhoto(context, metric.photoPaths[i]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        file,
                        width: 110, height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 110, height: 110,
                          color: context.colors.card2,
                          child: Icon(Icons.broken_image_outlined,
                              color: context.colors.textSecondary),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _viewPhoto(BuildContext context, String path) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: Center(
          child: InteractiveViewer(
            child: Image.file(File(path)),
          ),
        ),
      ),
    ));
  }
}

// ===== LOG SHEET =====
class _LogSheet extends StatefulWidget {
  final BodyMetric? existing;
  final void Function(BodyMetric) onSave;

  const _LogSheet({this.existing, required this.onSave});

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  late DateTime _date;
  late TextEditingController _weightCtrl;
  late TextEditingController _notesCtrl;
  late String _weightUnit;
  late List<String> _photoPaths;
  final List<String> _removedPaths = [];
  bool _pickingPhoto = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _date = e?.date ?? DateTime.now();
    _weightCtrl = TextEditingController(text: e?.weight?.toStringAsFixed(1) ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _weightUnit = e?.weightUnit ?? 'lbs';
    _photoPaths = List.from(e?.photoPaths ?? []);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final xfile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xfile == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final name = 'metric_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final saved = await File(xfile.path).copy('${dir.path}/$name');
      setState(() => _photoPaths.add(saved.path));
    } finally {
      setState(() => _pickingPhoto = false);
    }
  }

  void _removePhoto(String path) {
    setState(() {
      _photoPaths.remove(path);
      _removedPaths.add(path);
    });
  }

  Future<void> _save() async {
    final weight = double.tryParse(_weightCtrl.text);
    if (weight == null) return;

    // Delete removed photos from disk
    for (final path in _removedPaths) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }

    final metric = BodyMetric(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: _date,
      weight: weight,
      weightUnit: _weightUnit,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      photoPaths: List.from(_photoPaths),
    );
    widget.onSave(metric);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateLabel = '${months[_date.month - 1]} ${_date.day}, ${_date.year}';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.existing != null ? "Edit Entry" : "Log Weight",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.colors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: context.colors.textSecondary, size: 16),
                    const SizedBox(width: 10),
                    Text(dateLabel, style: const TextStyle(fontSize: 14)),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_down,
                        color: context.colors.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Weight row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.colors.inputBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: TextField(
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Weight",
                        hintStyle: TextStyle(color: context.colors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.inputBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _weightUnit,
                      dropdownColor: context.colors.card,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey, size: 18),
                      items: ['lbs', 'kg'].map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u, style: const TextStyle(fontSize: 14)),
                      )).toList(),
                      onChanged: (v) => setState(() => _weightUnit = v ?? 'lbs'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border),
              ),
              child: TextField(
                controller: _notesCtrl,
                style: const TextStyle(fontSize: 15),
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: "Notes (optional)",
                  hintStyle: TextStyle(color: context.colors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Photos row
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add photo button
                  GestureDetector(
                    onTap: _addPhoto,
                    child: Container(
                      width: 80, height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: context.colors.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.border,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _pickingPhoto
                          ? const Center(child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    color: context.colors.textSecondary, size: 22),
                                const SizedBox(height: 4),
                                Text("Photo",
                                    style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 10)),
                              ],
                            ),
                    ),
                  ),
                  // Existing photos
                  ..._photoPaths.map((path) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            width: 80, height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 80, height: 80,
                              color: context.colors.card2,
                              child: Icon(Icons.broken_image_outlined,
                                  color: context.colors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4, right: 12,
                        child: GestureDetector(
                          onTap: () => _removePhoto(path),
                          child: Container(
                            width: 20, height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Save
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.existing != null ? "Update" : "Save Entry",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final screens = [
    const HomeScreen(),
    const TrackScreen(),
    const _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: screens[currentIndex]),

            Padding(
              padding: const EdgeInsets.all(16),
              child: BottomNav(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() => currentIndex = index);
                },
              ),
            ),
          ],
        ),
      ),


    );
  }
}