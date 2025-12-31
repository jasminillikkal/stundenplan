import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'lv_edit_screen.dart';

class LvsScreen extends StatelessWidget {
  const LvsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('LVs')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LvEditScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: st.lvs.isEmpty
            ? [const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Noch keine LVs.')))]
            : st.lvs.map((lv) {
                return Card(
                  child: ListTile(
                    title: Text(lv.title),
                    subtitle: Text(lv.lecturer.isEmpty ? '—' : lv.lecturer),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => st.deleteLv(lv.id),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LvEditScreen(lvId: lv.id),
                      ));
                    },
                  ),
                );
              }).toList(),
      ),
    );
  }
}
