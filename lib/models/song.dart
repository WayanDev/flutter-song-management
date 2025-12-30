class Song {
  final String id;       
  final String title;
  final String singer;
  final String genre;

  Song({
    required this.id,
    required this.title,
    required this.singer,
    required this.genre,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'singer': singer,
    'genre': genre,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'],
    title: json['title'],
    singer: json['singer'],
    genre: json['genre'],
  );
}
