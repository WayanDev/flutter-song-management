import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'song_form_screen.dart';

enum SortBy { title, singer }

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final storage = StorageService();
  final searchC = TextEditingController();

  List<Song> _songs = [];
  String _genreFilter = 'Semua';
  SortBy _sortBy = SortBy.title;

  final genres = const ['Semua', 'Pop', 'Rock', 'Jazz'];

  @override
  void initState() {
    super.initState();
    _load();
    searchC.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await storage.loadSongs();
    setState(() => _songs = data);
  }

  Future<void> _save() async {
    await storage.saveSongs(_songs);
  }

  Future<void> _logout() async {
    await storage.setLoggedIn(false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showSnack(String message, {required bool success}) {
    final bg = success ? Colors.green : Colors.red;
    final icon = success ? Icons.check_circle : Icons.error;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  List<Song> get _filtered {
    final q = searchC.text.trim().toLowerCase();

    var list = _songs.where((s) {
      final matchSearch = q.isEmpty || s.title.toLowerCase().contains(q);
      final matchGenre = _genreFilter == 'Semua' || s.genre == _genreFilter;
      return matchSearch && matchGenre;
    }).toList();

    list.sort((a, b) {
      if (_sortBy == SortBy.title) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      return a.singer.toLowerCase().compareTo(b.singer.toLowerCase());
    });

    return list;
  }

  Future<void> _addSong() async {
    final created = await Navigator.push<Song?>(
      context,
      MaterialPageRoute(
        builder: (_) => SongFormScreen(
          genres: genres.where((g) => g != 'Semua').toList(),
        ),
      ),
    );

    if (created != null) {
      setState(() => _songs.add(created));
      await _save();
      if (!mounted) return;
      _showSnack('Lagu berhasil ditambahkan.', success: true);
    }
  }

  Future<void> _editSong(Song old) async {
    final updated = await Navigator.push<Song?>(
      context,
      MaterialPageRoute(
        builder: (_) => SongFormScreen(
          genres: genres.where((g) => g != 'Semua').toList(),
          initial: old,
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        final idx = _songs.indexWhere((x) => x.id == old.id);
        if (idx != -1) _songs[idx] = updated;
      });
      await _save();
      if (!mounted) return;
      _showSnack('Lagu berhasil diperbarui.', success: true);
    }
  }

  Future<void> _deleteSong(Song s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
          contentPadding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Row(
            children: const [
              Icon(Icons.delete_forever_rounded, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text('Hapus Lagu?', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          content: Text(
            'Kamu akan menghapus:\n\n"${s.title}"\n\nTindakan ini tidak dapat dibatalkan.',
            style: TextStyle(color: Colors.grey[800], height: 1.35),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.delete_rounded),
              label: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      setState(() => _songs.removeWhere((x) => x.id == s.id));
      await _save();
      if (!mounted) return;
      _showSnack('Lagu berhasil dihapus.', success: true);
    }
  }


  Color _genreColor(String genre) {
    switch (genre) {
      case 'Pop':
        return Colors.blue;
      case 'Rock':
        return Colors.deepOrange;
      case 'Jazz':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _sortLabel(SortBy v) => v == SortBy.title ? 'Judul' : 'Penyanyi';

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Lagu'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSong,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchC,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Cari judul lagu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final fieldWidth = (constraints.maxWidth - 10) / 2;

                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              SizedBox(
                                width: fieldWidth,
                                child: DropdownButtonFormField<String>(
                                  value: _genreFilter,
                                  items: genres
                                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _genreFilter = v ?? 'Semua'),
                                  decoration: const InputDecoration(
                                    labelText: 'Genre',
                                    isDense: true,                 
                                    prefixIcon: Icon(Icons.filter_alt, size: 18),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: DropdownButtonFormField<SortBy>(
                                  value: _sortBy,
                                  items: const [
                                    DropdownMenuItem(value: SortBy.title, child: Text('Judul')),
                                    DropdownMenuItem(value: SortBy.singer, child: Text('Penyanyi')),
                                  ],
                                  onChanged: (v) => setState(() => _sortBy = v ?? SortBy.title),
                                  decoration: const InputDecoration(
                                    labelText: 'Urutkan',
                                    isDense: true,                 
                                    prefixIcon: Icon(Icons.sort, size: 18),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: genres.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final g = genres[i];
                            final selected = _genreFilter == g;
                            final color = _genreColor(g);

                            return ChoiceChip(
                              label: Text(g),
                              selected: selected,
                              onSelected: (_) => setState(() => _genreFilter = g),
                              avatar: Icon(
                                Icons.local_offer,
                                size: 16,
                                color: selected ? Colors.white : color,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ${items.length} lagu - Sorting: ${_sortLabel(_sortBy)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                          if (searchC.text.trim().isNotEmpty || _genreFilter != 'Semua')
                            TextButton.icon(
                              onPressed: () {
                                searchC.clear();
                                setState(() {
                                  _genreFilter = 'Semua';
                                  _sortBy = SortBy.title;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: items.isEmpty
                    ? _EmptyState(
                        onAdd: _addSong,
                        isFiltered: searchC.text.trim().isNotEmpty || _genreFilter != 'Semua',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final s = items[i];
                          final tagColor = _genreColor(s.genre);

                          return Card(
                            elevation: 1,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: tagColor,
                                child: const Icon(Icons.music_note, color: Colors.white),
                              ),
                              title: Text(
                                s.title,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.person, size: 16),
                                        const SizedBox(width: 4),
                                        Text(s.singer),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: tagColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        s.genre,
                                        style: TextStyle(
                                          color: tagColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Wrap(
                                spacing: 6,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editSong(s),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus',
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteSong(s),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final bool isFiltered;

  const _EmptyState({required this.onAdd, required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    final title = isFiltered ? 'Tidak ada hasil' : 'Belum ada lagu';
    final desc = isFiltered
        ? 'Coba ubah pencarian atau filter genre.'
        : 'Tambahkan lagu pertama kamu untuk mulai mengelola daftar lagu.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music, size: 64, color: Colors.grey[500]),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Lagu'),
            ),
          ],
        ),
      ),
    );
  }
}
