import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/weight_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';
import '../data/theme_store.dart';
import '../data/body_metric_store.dart';
import '../data/data_service.dart';
import '../services/auth_service.dart';
import '../models/body_metric.dart';
import 'home_screen.dart';
import 'calender_screen.dart';
import 'history_screen.dart';
import 'body_metrics_screen.dart';
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

  void _refresh() { if (mounted) setState(() {}); }


  List<BodyMetric> get _metrics => BodyMetricStore.instance.metrics;
  BodyMetric? get _latest => _metrics.isNotEmpty ? _metrics.first : null;
  BodyMetric? get _previous => _metrics.length > 1 ? _metrics[1] : null;

  double? _trendDelta(int? days) {
    final latest = _latest;
    if (latest?.weight == null) return null;
    BodyMetric? reference;
    if (days == null) {
      reference = _metrics.lastWhere((m) => m.weight != null,
          orElse: () => latest!);
    } else {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final older =
          _metrics.where((m) => m.weight != null && m.date.isBefore(cutoff));
      if (older.isEmpty) return null;
      reference = older.first;
    }
    if (reference == latest) return null;
    return latest!.weight! - reference.weight!;
  }

  void _showSignedInPopup(BuildContext context, User? user) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _SignedInPopup(user: user),
    );
    // Auto-dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (context.mounted) Navigator.of(context, rootNavigator: true).maybePop();
    });
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

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
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

            // Anonymous upgrade banner
            if (AuthService.isAnonymous) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Local mode — data not backed up",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Sign in with Google to sync & secure your data.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final result = await AuthService.signInWithGoogle();
                          if (result != null && mounted) {
                            _showSignedInPopup(context, result.user);
                          }
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Sign-in failed. Please try again.")),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
                          color: delta > 0
                              ? (context.isDark ? Colors.redAccent : const Color(0xFFCC2222))
                              : context.colors.success,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} ${latest!.weightUnit}",
                          style: TextStyle(
                            fontSize: 12,
                            color: delta > 0
                                ? (context.isDark ? Colors.redAccent : const Color(0xFFCC2222))
                                : context.colors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Weight chart + trend bars
            if (_metrics.where((m) => m.weight != null).length >= 2) ...[
              const SizedBox(height: 16),
              WeightChart(metrics: _metrics),
              const SizedBox(height: 10),
              _trendBars(),
            ],

            // History shortcut
            if (_metrics.isNotEmpty) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BodyMetricsScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          color: context.colors.textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "View Full History (${_metrics.length} entries)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right,
                          color: context.colors.textSecondary, size: 16),
                    ],
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
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.logout,
              iconColor: Colors.redAccent,
              title: "Sign Out",
              subtitle: AuthService.isAnonymous
                  ? "Not signed in"
                  : (AuthService.currentUser?.email ?? "Google account"),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.colors.card,
                    title: const Text("Sign Out?"),
                    content: Text(
                        AuthService.isAnonymous
                            ? "You are in local mode. Signing out will delete your local data permanently."
                            : "Your data is saved to the cloud and will be here when you sign back in."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Sign Out",
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) await AuthService.signOut();
                // MyApp's authStateChanges listener handles navigation back to sign-in.
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _trendBars() {
    final unit = _latest?.weightUnit ?? 'lbs';
    final periods = [
      (label: '7 DAYS',   days: 7),
      (label: '30 DAYS',  days: 30),
      (label: '90 DAYS',  days: 90),
      (label: 'ALL TIME', days: null as int?),
    ];

    return Row(
      children: [
        for (int i = 0; i < periods.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < periods.length - 1 ? 8 : 0),
              child: _trendCard(periods[i].label, _trendDelta(periods[i].days), unit),
            ),
          ),
      ],
    );
  }

  Widget _trendCard(String label, double? delta, String unit) {
    final hasData = delta != null;
    final isLoss = hasData && delta < 0;
    final isGain = hasData && delta > 0;

    final greenColor = context.colors.success;
    final redColor   = context.isDark ? Colors.redAccent   : const Color(0xFFCC2222);
    final color = isLoss ? greenColor : isGain ? redColor : Colors.grey;

    final icon = isLoss
        ? Icons.arrow_downward
        : isGain ? Icons.arrow_upward : Icons.remove;

    final valueStr = hasData
        ? '${delta.abs().toStringAsFixed(1)} $unit'
        : '—';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: hasData
            ? color.withValues(alpha: 0.08)
            : context.colors.cardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasData
              ? color.withValues(alpha: 0.25)
              : context.colors.border2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, color: color, size: 11),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  valueStr,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
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

}

// ===== SIGNED IN POPUP =====
class _SignedInPopup extends StatelessWidget {
  final User? user;
  const _SignedInPopup({this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'Google Account';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with green check badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            photoUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _initials(name),
                          ),
                        )
                      : _initials(name),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Signed in!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                email,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done_rounded,
                      color: Color(0xFF2ECC71), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "Your data is now backed up",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(String name) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
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
  bool _saving = false;

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

  Widget _photoWidget(String path, double size) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: size, height: size,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : SizedBox(
                width: size, height: size,
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (_, _, _) => SizedBox(
            width: size, height: size,
            child: Icon(Icons.broken_image_outlined,
                color: context.colors.textSecondary)),
      );
    }
    return Image.file(
      File(path),
      width: size, height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => SizedBox(
          width: size, height: size,
          child: Icon(Icons.broken_image_outlined,
              color: context.colors.textSecondary)),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final weight = double.tryParse(_weightCtrl.text);
    if (weight == null) return;

    setState(() => _saving = true);
    try {
      final id = widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Upload any new local photos to Firebase Storage; keep existing URLs.
      final finalPaths = <String>[];
      for (final path in _photoPaths) {
        if (path.startsWith('http')) {
          finalPaths.add(path);
        } else {
          final url = await BodyMetricStore.instance.uploadPhoto(path, id);
          finalPaths.add(url);
        }
      }

      // Delete removed photos (from Storage or disk).
      for (final path in _removedPaths) {
        await BodyMetricStore.instance.deletePhoto(path);
      }

      final metric = BodyMetric(
        id: id,
        date: _date,
        weight: weight,
        weightUnit: _weightUnit,
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        photoPaths: finalPaths,
      );
      widget.onSave(metric);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                          child: _photoWidget(path, 80),
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
              onTap: _saving ? null : _save,
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
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          widget.existing != null ? "Update" : "Save Entry",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
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

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const HistoryScreen(),
      const _ProfileScreen(),
    ];

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