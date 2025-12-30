import 'dart:math';
import 'package:flutter/material.dart';
import '../models/song.dart';

class SongFormScreen extends StatefulWidget {
  final List<String> genres;
  final Song? initial;

  const SongFormScreen({super.key, required this.genres, this.initial});

  @override
  State<SongFormScreen> createState() => _SongFormScreenState();
}

class _SongFormScreenState extends State<SongFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleC;
  late final TextEditingController singerC;
  String? genre;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.initial?.title ?? '');
    singerC = TextEditingController(text: widget.initial?.singer ?? '');
    genre = widget.initial?.genre ?? (widget.genres.isNotEmpty ? widget.genres.first : null);
  }

  @override
  void dispose() {
    titleC.dispose();
    singerC.dispose();
    super.dispose();
  }

  String _id() =>
      '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}';

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final song = Song(
      id: widget.initial?.id ?? _id(),
      title: titleC.text.trim(),
      singer: singerC.text.trim(),
      genre: genre ?? widget.genres.first,
    );

    Navigator.pop(context, song);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final w = MediaQuery.of(context).size.width;
    final cardWidth = w > 520 ? 520.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Lagu' : 'Tambah Lagu'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    width: cardWidth,
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    child: Icon(
                                      isEdit ? Icons.edit : Icons.add,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isEdit ? 'Ubah data lagu' : 'Tambah lagu baru',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Lengkapi judul, penyanyi, dan genre.',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              TextFormField(
                                controller: titleC,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Judul Lagu',
                                  hintText: 'Contoh: Love Story',
                                  prefixIcon: Icon(Icons.music_note),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Judul wajib diisi'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              TextFormField(
                                controller: singerC,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Penyanyi',
                                  hintText: 'Contoh: Taylor Swift',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Penyanyi wajib diisi'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              DropdownButtonFormField<String>(
                                initialValue: genre,
                                items: widget.genres
                                    .map((g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => genre = v),
                                decoration: const InputDecoration(
                                  labelText: 'Genre',
                                  prefixIcon: Icon(Icons.local_offer),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 18),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.arrow_back),
                                      label: const Text('Batal'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: _submit,
                                      icon: const Icon(Icons.save),
                                      label: Text(isEdit ? 'Simpan' : 'Tambah'),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Text(
                                isEdit
                                    ? 'Perubahan akan langsung tersimpan setelah disimpan.'
                                    : 'Lagu baru akan muncul di daftar setelah ditambahkan.',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
