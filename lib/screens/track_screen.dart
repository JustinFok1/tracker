import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/vial_store.dart';
import '../data/schedule_store.dart';
import '../data/dose_log_store.dart';
import '../data/vial_inventory_store.dart';
import '../models/vial.dart';
import '../models/schedule.dart';
import 'add_vial_screen.dart';
import 'add_schedule_screen.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  @override
  void initState() {
    super.initState();
    VialStore.instance.addListener(_refresh);
    ScheduleStore.instance.addListener(_refresh);
    DoseLogStore.instance.addListener(_refresh);
    VialInventoryStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    VialStore.instance.removeListener(_refresh);
    ScheduleStore.instance.removeListener(_refresh);
    DoseLogStore.instance.removeListener(_refresh);
    VialInventoryStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final vials = VialStore.instance.vials;
    final schedules = ScheduleStore.instance.schedules;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            _header(),
            const SizedBox(height: 24),

            /// ===== COMPOUNDS =====
            _sectionLabel("COMPOUNDS", action: "+ Add", onAction: _openAddVial),
            const SizedBox(height: 12),
            vials.isEmpty
                ? _emptyCard(
              icon: Icons.opacity,
              iconColor: Colors.purpleAccent,
              title: "No compounds yet",
              subtitle: "Add your first compound to start tracking",
              buttonText: "+ Add Compound",
              onPressed: _openAddVial,
            )
                : Column(
              children: _groupVials(vials).entries.map((entry) {
                return _ExpandableVialTile(
                  compound: entry.key,
                  vials: entry.value,
                  onEdit: _editVial,
                  onDelete: _confirmDeleteVial,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            /// ===== SCHEDULES =====
            _sectionLabel("SCHEDULES",
                action: "+ Schedule", onAction: _openAddSchedule),
            const SizedBox(height: 12),
            schedules.isEmpty
                ? _emptyCard(
              icon: Icons.calendar_today,
              iconColor: Colors.pinkAccent,
              title: "No schedules yet",
              subtitle: "Add a compound first, then create a schedule",
              buttonText: "+ Add Schedule",
              onPressed: _openAddSchedule,
            )
                : Column(
              children:
              _groupedSchedules(schedules).entries.map((entry) {
                return _ExpandableScheduleTile(
                  compound: entry.key,
                  schedules: entry.value,
                  onEdit: _editSchedule,
                  onDelete: _confirmDeleteSchedule,
                  formatDays: _formatDays,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            /// ===== STATS =====
            _sectionLabel("STATS"),
            const SizedBox(height: 12),
            _buildStats(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Track",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            _headerIcon(Icons.flash_on, Colors.purple),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerIcon(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  // ===== SECTION LABEL =====
  Widget _sectionLabel(String text, {String? action, VoidCallback? onAction}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.pink],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Spacer(),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Text(
                action,
                style: const TextStyle(
                    color: Colors.purpleAccent, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  // ===== EMPTY CARD =====
  Widget _emptyCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(buttonText,
                  style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ===== STATS =====
  Widget _buildStats() {
    final schedules = ScheduleStore.instance.schedules;
    final compoundKeys = schedules
        .map((s) => "${s.compoundName}_${s.dosage}_${s.unit}")
        .toSet()
        .toList();

    final dosesThisWeek = DoseLogStore.instance.dosesThisWeek(compoundKeys);
    final streak = DoseLogStore.instance.currentStreak(compoundKeys);
    final onCycle = schedules.map((s) => s.compoundName).toSet().toList();

    if (schedules.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Text(
          "Add a schedule to start tracking stats",
          style: TextStyle(color: context.colors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.check_circle_outline,
                label: "This Week",
                value: dosesThisWeek.toString(),
                unit: "doses",
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.local_fire_department,
                label: "Streak",
                value: streak.toString(),
                unit: "days",
                color: streak >= 7 ? Colors.orange : Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.science,
                        color: Colors.tealAccent, size: 15),
                  ),
                  const SizedBox(width: 10),
                  const Text("ON CYCLE",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          letterSpacing: 1.1)),
                ],
              ),
              const SizedBox(height: 14),
              onCycle.isEmpty
                  ? Text("None",
                  style: TextStyle(color: context.colors.textSecondary))
                  : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: onCycle.map((name) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.4)),
                    ),
                    child: Text(name,
                        style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 13)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 15),
              ),
              const SizedBox(width: 8),
              Text(label.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(unit,
              style:
              TextStyle(color: context.colors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  // ===== CARD STYLE =====
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [context.colors.card, context.colors.card2],
      ),
      borderRadius: BorderRadius.circular(18),
    );
  }

  // ===== NAVIGATION =====
  void _openAddVial() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const AddVialScreen()));

  void _editVial(Vial vial) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => AddVialScreen(existingVial: vial)));

  void _openAddSchedule() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const AddScheduleScreen()));

  void _editSchedule(Schedule s) => Navigator.push(context,
      MaterialPageRoute(
          builder: (_) => AddScheduleScreen(existingSchedule: s)));

  // ===== CONFIRM DELETE =====
  void _confirmDeleteVial(Vial vial) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Compound"),
        content: Text("Remove ${vial.compoundName}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: TextStyle(color: context.colors.textSecondary))),
          TextButton(
            onPressed: () {
              VialStore.instance.removeVial(vial);
              Navigator.pop(context);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSchedule(Schedule s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Schedule"),
        content: Text("Remove ${s.compoundName}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: TextStyle(color: context.colors.textSecondary))),
          TextButton(
            onPressed: () {
              ScheduleStore.instance.removeSchedule(s);
              Navigator.pop(context);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ===== GROUPING =====
  Map<String, List<Schedule>> _groupedSchedules(List<Schedule> schedules) {
    final Map<String, List<Schedule>> map = {};
    for (var s in schedules) {
      map.putIfAbsent(s.compoundName, () => []).add(s);
    }
    return map;
  }

  Map<String, List<Vial>> _groupVials(List<Vial> vials) {
    final Map<String, List<Vial>> map = {};
    for (var v in vials) {
      map.putIfAbsent(v.compoundName, () => []).add(v);
    }
    return map;
  }

  String _formatDays(List<int> days) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days.map((d) => names[d - 1]).join(", ");
  }
}

// ===== EXPANDABLE VIAL TILE =====
class _ExpandableVialTile extends StatefulWidget {
  final String compound;
  final List<Vial> vials;
  final Function(Vial) onEdit;
  final Function(Vial) onDelete;

  const _ExpandableVialTile({
    required this.compound,
    required this.vials,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ExpandableVialTile> createState() => _ExpandableVialTileState();
}

class _ExpandableVialTileState extends State<_ExpandableVialTile> {
  bool expanded = false;

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
    gradient: LinearGradient(
      colors: [context.colors.card, context.colors.card2],
    ),
    borderRadius: BorderRadius.circular(18),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header tile
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _cardDecoration(context),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.opacity,
                      color: Colors.purpleAccent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.compound,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "${widget.vials.length} compound${widget.vials.length != 1 ? 's' : ''}",
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expanded entries
        if (expanded)
          Column(
            children: widget.vials.asMap().entries.map((entry) {
              final index = entry.key;
              final vial = entry.value;
              final dosageKey = "${vial.dosage}${vial.unit}";

              return Dismissible(
                key: Key("vial_${widget.compound}_${index}_$dosageKey"),
                direction: DismissDirection.horizontal,
                background: _swipeBackground(
                    Colors.blue, Icons.edit, Alignment.centerLeft),
                secondaryBackground: _swipeBackground(
                    Colors.red, Icons.delete, Alignment.centerRight),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    widget.onEdit(vial);
                  } else {
                    widget.onDelete(vial);
                  }
                  return false;
                },
                child: _VialDosageRow(
                  vial: vial,
                  dosageKey: dosageKey,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

}

// ===== EXPANDABLE SCHEDULE TILE =====
class _ExpandableScheduleTile extends StatefulWidget {
  final String compound;
  final List<Schedule> schedules;
  final Function(Schedule) onEdit;
  final Function(Schedule) onDelete;
  final String Function(List<int>) formatDays;

  const _ExpandableScheduleTile({
    required this.compound,
    required this.schedules,
    required this.onEdit,
    required this.onDelete,
    required this.formatDays,
  });

  @override
  State<_ExpandableScheduleTile> createState() =>
      _ExpandableScheduleTileState();
}

class _ExpandableScheduleTileState extends State<_ExpandableScheduleTile> {
  bool expanded = false;

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
    gradient: LinearGradient(
      colors: [context.colors.card, context.colors.card2],
    ),
    borderRadius: BorderRadius.circular(18),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header tile
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _cardDecoration(context),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month,
                      color: Colors.pinkAccent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.compound,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "${widget.schedules.length} schedule${widget.schedules.length != 1 ? 's' : ''}",
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expanded schedules
        if (expanded)
          Column(
            children: _groupByDosage(widget.schedules).entries.map((entry) {
              final dosageKey = entry.key;
              final schedules = entry.value;
              final allDays = schedules
                  .expand((s) => s.daysOfWeek)
                  .toSet()
                  .toList()
                ..sort();

              return Dismissible(
                key: Key("sched_${widget.compound}_$dosageKey"),
                direction: DismissDirection.horizontal,
                background: _swipeBackground(
                    Colors.blue, Icons.edit, Alignment.centerLeft),
                secondaryBackground: _swipeBackground(
                    Colors.red, Icons.delete, Alignment.centerRight),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    widget.onEdit(schedules.first);
                  } else {
                    widget.onDelete(schedules.first);
                  }
                  return false;
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10, left: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.colors.cardAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.pink.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          color: Colors.pinkAccent, size: 8),
                      const SizedBox(width: 10),
                      Text(dosageKey,
                          style: const TextStyle(fontSize: 14)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.pink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.formatDays(allDays),
                          style: const TextStyle(
                              color: Colors.pinkAccent, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Map<String, List<Schedule>> _groupByDosage(List<Schedule> schedules) {
    final Map<String, List<Schedule>> map = {};
    for (var s in schedules) {
      final key = "${s.dosage}${s.unit}";
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }
}

// ===== VIAL DOSAGE ROW =====
class _VialDosageRow extends StatelessWidget {
  final Vial vial;
  final String dosageKey;

  const _VialDosageRow({required this.vial, required this.dosageKey});

  @override
  Widget build(BuildContext context) {
    final remaining = VialInventoryStore.instance.getRemaining(vial);

    Color stockColor = Colors.purple;
    String? stockLabel;

    if (remaining != null && vial.totalDoses != null) {
      final pct = remaining / vial.totalDoses!;
      if (pct <= 0.0) {
        stockColor = Colors.redAccent;
        stockLabel = "Empty";
      } else if (pct <= 0.2 || remaining <= 3) {
        stockColor = Colors.orange;
        stockLabel = "$remaining left";
      } else if (pct <= 0.5) {
        stockColor = Colors.amber;
        stockLabel = "$remaining left";
      } else {
        stockColor = context.colors.success;
        stockLabel = "$remaining left";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.cardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: stockColor, size: 8),
          const SizedBox(width: 10),
          Text(dosageKey, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          if (stockLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: stockColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                stockLabel,
                style: TextStyle(color: stockColor, fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.swipe, color: Colors.grey, size: 14),
        ],
      ),
    );
  }
}

// ===== SHARED SWIPE BACKGROUND =====
Widget _swipeBackground(
    Color color, IconData icon, AlignmentGeometry alignment) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10, left: 12),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    alignment: alignment,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );
}