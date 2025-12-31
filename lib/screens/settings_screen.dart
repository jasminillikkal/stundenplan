import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              value: st.settings.darkMode,
              onChanged: (v) => st.setDarkMode(v),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Default Reminder (Minuten vorher)'),
              subtitle: Text('${st.settings.defaultReminderMinutes} Minuten'),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final res = await _pickMinutes(context, st.settings.defaultReminderMinutes);
                if (res != null) st.setDefaultReminder(res);
              },
            ),
          ),
          const SizedBox(height: 12),
          Text('Backup/Restore', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup erstellen'),
              subtitle: const Text('Speichert stundenplan_backup.json im Dokumente-Ordner'),
              onTap: () async {
                final path = await st.backup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup gespeichert: $path')),
                  );
                }
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore aus Backup'),
              subtitle: const Text('Lädt stundenplan_backup.json aus dem Dokumente-Ordner'),
              onTap: () async {
                try {
                  await st.restore();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restore erfolgreich.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restore fehlgeschlagen: $e')),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<int?> _pickMinutes(BuildContext context, int current) async {
    final ctrl = TextEditingController(text: current.toString());
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Default Reminder'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Minuten (z.B. 15)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              if (v == null || v < 0) return;
              Navigator.pop(context, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
