import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class LvEditScreen extends StatefulWidget {
  final String? lvId;
  const LvEditScreen({super.key, this.lvId});

  @override
  State<LvEditScreen> createState() => _LvEditScreenState();
}

class _LvEditScreenState extends State<LvEditScreen> {
  final titleCtrl = TextEditingController();
  final lectCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final st = context.read<AppState>();
    final lv = widget.lvId == null ? null : st.lvById(widget.lvId!);
    if (lv != null) {
      titleCtrl.text = lv.title;
      lectCtrl.text = lv.lecturer;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    lectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.read<AppState>();
    final editing = widget.lvId != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'LV bearbeiten' : 'LV hinzufügen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Titel (Pflicht)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lectCtrl,
              decoration: const InputDecoration(labelText: 'Dozent (optional)'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Speichern'),
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bitte Titel eingeben.')),
                    );
                    return;
                  }

                  if (!editing) {
                    await st.addLv(title: title, lecturer: lectCtrl.text.trim());
                  } else {
                    final lv = st.lvById(widget.lvId!);
                    if (lv != null) {
                      lv.title = title;
                      lv.lecturer = lectCtrl.text.trim();
                      await st.updateLv(lv);
                    }
                  }

                  if (context.mounted) Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
