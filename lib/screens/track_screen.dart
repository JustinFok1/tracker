import 'package:flutter/material.dart';
import '../data/vial_store.dart';
import '../data/schedule_store.dart';
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
  }

  @override
  void dispose() {
    VialStore.instance.removeListener(_refresh);
    ScheduleStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final vials = VialStore.instance.vials;
    final schedules = ScheduleStore.instance.schedules;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              _header(),
              const SizedBox(height: 20),

              /// ===== VIALS =====
              _sectionHeader("VIALS", "+ Add", _openAddVial),
              const SizedBox(height: 12),

            vials.isEmpty
                ? _bigEmptyCard(
              icon: Icons.opacity,
              title: "No vials yet",
              subtitle: "Add your first vial to start tracking",
              buttonText: "+ Add Vial",
              onPressed: _openAddVial,
            )
                : Column(
              children: _groupVials(vials).entries.map((entry) {
                return _ExpandableVialTile(
                  compound: entry.key,
                  vials: entry.value,
                  cardDecoration: _cardDecoration(),
                  onEdit: _editVial,
                  onDelete: _confirmDeleteVial,
                );
              }).toList(),
            ),

              const SizedBox(height: 24),

              /// ===== SCHEDULES =====
              _sectionHeader("SCHEDULES", "+ Schedule", _openAddSchedule),
              const SizedBox(height: 12),

              schedules.isEmpty
                  ? _bigEmptyCard(
                icon: Icons.calendar_today,
                title: "No schedules yet",
                subtitle:
                "Add a vial first to create your first schedule",
                buttonText: "+ Add Schedule",
                onPressed: _openAddSchedule,
              )
              : Column(
                children: _groupedSchedules(schedules).entries.map((entry) {
                  final compound = entry.key;
                  final grouped = entry.value;

                  return _ExpandableScheduleTile(
                    compound: compound,
                    schedules: grouped,
                    onEdit: _editSchedule,
                    onDelete: _confirmDeleteSchedule,
                    formatDays: _formatDays,
                    cardDecoration: _cardDecoration(),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              /// ===== STATS =====
              const Text(
                "Tracking Stats",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: const Text(
                  "No tracking data yet",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== HEADER =====
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Track",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Icon(Icons.flash_on, color: Colors.purple),
            SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.chat_bubble_outline),
            )
          ],
        )
      ],
    );
  }

  /// ===== SECTION HEADER =====
  Widget _sectionHeader(
      String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
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
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(action),
        ),
      ],
    );
  }

  /// ===== BIG EMPTY CARD (MATCHES YOUR DESIGN) =====
  Widget _bigEmptyCard({
    required IconData icon,
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
          Icon(icon, color: Colors.purple),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          /// BUTTON (FIXED STYLE)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A2A2A),
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// ===== VIAL CARD =====
  Widget _vialCard(Vial vial) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(vial.compoundName),
          Text("${vial.dosage}${vial.unit}"),
        ],
      ),
    );
  }

  String _formatDays(List<int> days) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days.map((d) => names[d - 1]).join(", ");
  }

  /// ===== SCHEDULE CARD =====
  Widget _scheduleCard(Schedule s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${s.compoundName} (${s.dosage}${s.unit})"),
          Text(_formatDays(s.daysOfWeek)), // assuming you're using days now
        ],
      ),
    );
  }

  /// ===== CARD STYLE =====
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF1A1A1A),
          Color(0xFF222222),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
    );
  }

  /// ===== NAVIGATION =====
  void _openAddVial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddVialScreen()),
    );
  }

  void _editVial(Vial vial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVialScreen(existingVial: vial),
      ),
    );
  }

  void _openAddSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddScheduleScreen()),
    );
  }

  /// ===== OPTIONS =====
  void _showVialOptions(Vial vial) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Edit"),
            onTap: () {
              Navigator.pop(context);
              _editVial(vial);
            },
          ),
          ListTile(
            title: const Text("Delete",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteVial(vial);
            },
          ),
        ],
      ),
    );
  }

  void _editSchedule(Schedule schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddScheduleScreen(existingSchedule: schedule),
      ),
    );
  }

  void _showScheduleOptions(Schedule s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Edit"),
            onTap: () {
              Navigator.pop(context);
              _editSchedule(s);
            },
          ),
          ListTile(
            title: const Text("Delete",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteSchedule(s);
            },
          ),
        ],
      ),
    );
  }

  /// ===== CONFIRM DELETE =====
  void _confirmDeleteVial(Vial vial) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Delete Vial"),
        content: Text("Remove ${vial.compoundName}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              VialStore.instance.removeVial(vial);
              Navigator.pop(context);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSchedule(Schedule s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Delete Schedule"),
        content: Text("Remove ${s.compoundName}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ScheduleStore.instance.removeSchedule(s);
              Navigator.pop(context);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
}

class _ExpandableVialTile extends StatefulWidget {
  final String compound;
  final List<Vial> vials;
  final BoxDecoration cardDecoration;
  final Function(Vial) onEdit;
  final Function(Vial) onDelete;

  const _ExpandableVialTile({
    required this.compound,
    required this.vials,
    required this.cardDecoration,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ExpandableVialTile> createState() =>
      _ExpandableVialTileState();
}

class _ExpandableVialTileState extends State<_ExpandableVialTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// MAIN TILE (compound name)
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: widget.cardDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.compound),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        /// EXPANDED DOSAGES
        if (expanded)
          Column(
            children: _groupByDosage(widget.vials).entries.map((entry) {
              final dosageKey = entry.key;
              final vials = entry.value;

              return Dismissible(
                key: Key("${widget.compound}_$dosageKey"),

                direction: DismissDirection.horizontal,

                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),

                secondaryBackground: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    widget.onEdit(vials.first);
                    return false;
                  } else {
                    widget.onDelete(vials.first);
                    return false;
                  }
                },

                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: 12, left: 8, right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: widget.cardDecoration,
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dosageKey),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Map<String, List<Vial>> _groupByDosage(List<Vial> vials) {
    final Map<String, List<Vial>> map = {};

    for (var v in vials) {
      final key = "${v.dosage}${v.unit}";
      map.putIfAbsent(key, () => []).add(v);
    }

    return map;
  }
}

class _ExpandableScheduleTile extends StatefulWidget {
  final String compound;
  final List<Schedule> schedules;
  final Function(Schedule) onEdit;
  final Function(Schedule) onDelete;
  final String Function(List<int>) formatDays;
  final BoxDecoration cardDecoration;

  const _ExpandableScheduleTile({
    required this.compound,
    required this.schedules,
    required this.onEdit,
    required this.onDelete,
    required this.formatDays,
    required this.cardDecoration,
  });

  @override
  State<_ExpandableScheduleTile> createState() =>
      _ExpandableScheduleTileState();
}

class _ExpandableScheduleTileState
    extends State<_ExpandableScheduleTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// MAIN TILE (UNCHANGED STYLE)
        GestureDetector(
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: widget.cardDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.compound),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        /// EXPANDED LIST
        if (expanded)
          Column(
            children: _groupByDosage(widget.schedules).entries.map((entry) {
              final dosageKey = entry.key;
              final schedules = entry.value;

              /// Merge all days for same dosage
              final allDays = schedules
                  .expand((s) => s.daysOfWeek)
                  .toSet()
                  .toList()
                ..sort();

              return Dismissible(
                key: Key("${widget.compound}_$dosageKey"),

                direction: DismissDirection.horizontal,

                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),

                secondaryBackground: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    widget.onEdit(schedules.first);
                    return false;
                  } else {
                    widget.onDelete(schedules.first);
                    return false;
                  }
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: widget.cardDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dosageKey),
                      Text(widget.formatDays(allDays)),
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