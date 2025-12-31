import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class DayDetailScreen extends StatelessWidget {
  final int weekday;
  const DayDetailScreen({super.key, required this.weekday});

  static const weekdayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entries = state.entriesForWeekday(weekday);

    return Scaffold(
      appBar: AppBar(title: Text('Tagesdetail: ${weekdayNames[weekday - 1]}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEntry(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: entries.isEmpty
            ? [const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Keine Termine')))]
            : entries.map((e) {
                final lv = state.lvById(e.lvId);
                return Card(
                  child: ListTile(
                    title: Text(lv?.title ?? 'Unbekannte LV'),
                    subtitle: Text('${_fmt(e.startMinutes)}–${_fmt(e.endMinutes)} • Raum: ${e.room.isEmpty ? '-' : e.room}\nReminder: ${_remText(context, e)}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => state.deleteEntry(e.id),
                    ),
                    onTap: () => _openEditEntry(context, e),
                  ),
                );
              }).toList(),
      ),
    );
  }

  String _fmt(int mins) {
    final h = (mins ~/ 60).toString().padLeft(2, '0');
    final m = (mins % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _remText(BuildContext context, ScheduleEntry e) {
    final st = context.read<AppState>();
    switch (e.reminderMode) {
      case ReminderMode.off:
        return 'Aus';
      case ReminderMode.defaultTime:
        return 'Default (${st.settings.defaultReminderMinutes} min vorher)';
      case ReminderMode.custom:
        return 'Custom (${e.customReminderMinutes ?? st.settings.defaultReminderMinutes} min vorher)';
    }
  }

  Future<void> _openAddEntry(BuildContext context) async {
    final st = context.read<AppState>();
    if (st.lvs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte zuerst eine LV anlegen (Tab "LVs").')),
      );
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EntryEditor(weekday: weekday),
    );
  }

  Future<void> _openEditEntry(BuildContext context, ScheduleEntry e) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EntryEditor(weekday: weekday, entry: e),
    );
  }
}

class _EntryEditor extends StatefulWidget {
  final int weekday;
  final ScheduleEntry? entry;
  const _EntryEditor({required this.weekday, this.entry});

  @override
  State<_EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<_EntryEditor> {
  late String lvId;
  late TimeOfDay start;
  late TimeOfDay end;
  final roomCtrl = TextEditingController();

  ReminderMode reminderMode = ReminderMode.defaultTime;
  final customCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final st = context.read<AppState>();
    final e = widget.entry;

    lvId = e?.lvId ?? st.lvs.first.id;
    start = _fromMinutes(e?.startMinutes ?? 8 * 60);
    end = _fromMinutes(e?.endMinutes ?? 9 * 60);
    roomCtrl.text = e?.room ?? '';
    reminderMode = e?.reminderMode ?? ReminderMode.defaultTime;
    customCtrl.text = (e?.customReminderMinutes ?? '').toString();
    if (customCtrl.text == 'null') customCtrl.clear();
  }

  @override
  void dispose() {
    roomCtrl.dispose();
    customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final padding = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: padding.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.entry == null ? 'Termin hinzufügen' : 'Termin bearbeiten',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: lvId,
                decoration: const InputDecoration(labelText: 'LV'),
                items: st.lvs
                    .map((lv) => DropdownMenuItem(value: lv.id, child: Text(lv.title)))
                    .toList(),
                onChanged: (v) => setState(() => lvId = v!),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: start);
                        if (t != null) setState(() => start = t);
                      },
                      child: Text('Start: ${start.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: end);
                        if (t != null) setState(() => end = t);
                      },
                      child: Text('Ende: ${end.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: roomCtrl,
                decoration: const InputDecoration(labelText: 'Raum (optional)'),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<ReminderMode>(
                value: reminderMode,
                decoration: const InputDecoration(labelText: 'Reminder'),
                items: const [
                  DropdownMenuItem(value: ReminderMode.off, child: Text('Aus')),
                  DropdownMenuItem(value: ReminderMode.defaultTime, child: Text('Default')),
                  DropdownMenuItem(value: ReminderMode.custom, child: Text('Custom')),
                ],
                onChanged: (v) => setState(() => reminderMode = v!),
              ),
              if (reminderMode == ReminderMode.custom) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: customCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minuten vorher (z.B. 10)'),
                )
              ],

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Speichern'),
                      onPressed: () async {
                        final sm = _toMinutes(start);
                        final em = _toMinutes(end);
                        if (em <= sm) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ende muss nach Start sein.')),
                          );
                          return;
                        }

                        final custom = int.tryParse(customCtrl.text.trim());

                        if (widget.entry == null) {
                          final entry = ScheduleEntry(
                            id: '${DateTime.now().millisecondsSinceEpoch}',
                            lvId: lvId,
                            weekday: widget.weekday,
                            startMinutes: sm,
                            endMinutes: em,
                            room: roomCtrl.text.trim(),
                            reminderMode: reminderMode,
                            customReminderMinutes: reminderMode == ReminderMode.custom ? custom : null,
                          );
                          await st.addEntry(entry);
                        } else {
                          final e = widget.entry!;
                          e.lvId = lvId;
                          e.startMinutes = sm;
                          e.endMinutes = em;
                          e.room = roomCtrl.text.trim();
                          e.reminderMode = reminderMode;
                          e.customReminderMinutes = reminderMode == ReminderMode.custom ? custom : null;
                          await st.updateEntry(e);
                        }

                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  TimeOfDay _fromMinutes(int mins) => TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}
    