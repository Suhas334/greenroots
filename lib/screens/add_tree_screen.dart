import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/tree_record.dart';

class AddTreeScreen extends StatefulWidget {
  final void Function(TreeRecord) onSave;
  const AddTreeScreen({super.key, required this.onSave});
  @override
  State<AddTreeScreen> createState() => _AddTreeScreenState();
}

class _AddTreeScreenState extends State<AddTreeScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      species = TextEditingController(),
      location = TextEditingController(),
      notes = TextEditingController(),
      height = TextEditingController();
  DateTime planted = DateTime.now();
  bool needsCare = false;
  @override
  void dispose() {
    name.dispose();
    species.dispose();
    location.dispose();
    notes.dispose();
    height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Add a Tree')),
      body: Form(
          key: form,
          child: ListView(padding: const EdgeInsets.all(22), children: [
            Container(
                height: 145,
                decoration: BoxDecoration(
                    color: const Color(0xFFE0EBD4),
                    borderRadius: BorderRadius.circular(22)),
                child: const Icon(Icons.nature, size: 88, color: forest)),
            const SizedBox(height: 20),
            TextFormField(
                controller: name,
                decoration: const InputDecoration(
                    labelText: 'Tree name *',
                    prefixIcon: Icon(Icons.eco_outlined)),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a tree name' : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: species,
                decoration: const InputDecoration(
                    labelText: 'Species',
                    prefixIcon: Icon(Icons.spa_outlined))),
            const SizedBox(height: 12),
            TextFormField(
                controller: location,
                decoration: const InputDecoration(
                    labelText: 'Plantation location',
                    prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 12),
            Card(
                child: ListTile(
                    leading: const Icon(Icons.calendar_month, color: forest),
                    title: const Text('Plantation date'),
                    subtitle:
                        Text('${planted.day}/${planted.month}/${planted.year}'),
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: planted,
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now());
                      if (d != null) setState(() => planted = d);
                    })),
            const SizedBox(height: 12),
            TextFormField(
                controller: height,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Height (cm)', prefixIcon: Icon(Icons.height)),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final h = double.tryParse(v);
                  return h == null || h < 0 ? 'Enter a valid height' : null;
                }),
            const SizedBox(height: 12),
            TextFormField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Notes', prefixIcon: Icon(Icons.notes))),
            SwitchListTile(
                title: const Text('Needs care'),
                value: needsCare,
                onChanged: (v) => setState(() => needsCare = v)),
            const SizedBox(height: 20),
            SizedBox(
                height: 54,
                child: FilledButton.icon(
                    onPressed: () {
                      if (!(form.currentState?.validate() ?? false)) return;
                      widget.onSave(TreeRecord(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          name: name.text.trim(),
                          species: species.text.trim(),
                          location: location.text.trim(),
                          notes: notes.text.trim(),
                          planted: planted,
                          height: double.tryParse(height.text) ?? 0,
                          needsCare: needsCare));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Save tree'))),
            const SizedBox(height: 32),
          ])));
}
