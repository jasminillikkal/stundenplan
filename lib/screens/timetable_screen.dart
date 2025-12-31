import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'day_detail_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int selectedWeekday = 1; // Monday

  static const weekdayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Stundenplan')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(7, (i) {
                final wd = i + 1;
                final isSel = wd == selectedWeekday;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(weekdayNames[i]),
                    selected: isSel,
                    onSelected: (_) => setState(() => selectedWeekday = wd),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Tagesdetail: ${weekdayNames[selectedWeekday - 1]}'),
                    subtitle: const Text('Alle Termine dieses Tages anzeigen'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DayDetailScreen(weekday: selectedWeekday),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Wochenübersicht (als Liste pro Tag)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...List.generate(7, (i) {
                  final wd = i + 1;
                  final entries = state.entriesForWeekday(wd);
                  return Card(
                    child: ExpansionTile(
                      title: Text(weekdayNames[i]),
                      children: entries.isEmpty
                          ? [const ListTile(title: Text('Keine Termine für diesen Tag'))]
                          : entries.map((e) {
                              final lv = state.lvById(e.lvId);
                              return ListTile(
                                title: Text(lv?.title ?? 'Unbekannte LV'),
                                subtitle: Text('${_fmt(e.startMinutes)}–${_fmt(e.endMinutes)}  •  Raum: ${e.room.isEmpty ? '-' : e.room}'),
                              );
                            }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int mins) {
    final h = (mins ~/ 60).toString().padLeft(2, '0');
    final m = (mins % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}
