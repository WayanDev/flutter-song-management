import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class StorageService {
  static const _kLoggedIn = 'is_logged_in';
  static const _kSongs = 'songs';

  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kLoggedIn) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kLoggedIn, value);
  }

  Future<List<Song>> loadSongs() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kSongs);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => Song.fromJson(e)).toList();
  }

  Future<void> saveSongs(List<Song> songs) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(songs.map((s) => s.toJson()).toList());
    await sp.setString(_kSongs, raw);
  }
}
