/// Lightweight book model used across Library, BookDetails, and Reader screens.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.coverUrl,
    this.series,
    this.rating = 0.0,
    this.pageCount = 0,
    this.isNew = false,
    this.isFeatured = false,
    this.synopsis = '',
    this.readingProgress = 0.0,
  });

  final String id;
  final String title;
  final String author;
  final String genre;
  final String coverUrl;
  final String? series;
  final double rating;
  final int pageCount;
  final bool isNew;
  final bool isFeatured;
  final String synopsis;

  /// 0.0 – 1.0 reading progress (used on Okuyorum tab)
  final double readingProgress;
}

/// Dummy dataset used until the REST API is wired up.
abstract final class DummyBooks {
  // ── Discovery ──────────────────────────────────────────────────────────────

  static const featured = Book(
    id: 'keloglan-masallari',
    title: 'KELOĞLAN MASALLARI',
    author: 'Anonim',
    genre: 'Klasik',
    series: 'Klasik Eserler Dizisi',
    coverUrl: 'https://picsum.photos/seed/keloglan/400/600',
    rating: 4.8,
    pageCount: 180,
    isFeatured: true,
    synopsis:
        'Anadolu\'nun sevilen halk kahramanı Keloğlan\'ın zekası, kurnazlığı '
        've şansıyla devlerin üstesinden geldiği, padişahın kızıyla evlendiği '
        've fakirlikten zengin olduğu birbirinden eğlenceli ve öğretici '
        'masalları bu kitapta bulacaksınız.',
  );

  static const haftaninOnerileri = <Book>[
    Book(
      id: 'nasrettin-hoca',
      title: 'Nasrettin Hoca',
      author: 'Anonim',
      genre: 'Halk Edebiyatı',
      coverUrl: 'https://picsum.photos/seed/nasrettin/300/440',
    ),
    Book(
      id: 'alfanin-secimi',
      title: 'Alfa\'nın Seçimi',
      author: 'Lara Güneş',
      genre: 'Romantik',
      coverUrl: 'https://picsum.photos/seed/alfa/300/440',
      isNew: true,
    ),
    Book(
      id: 'lunanin-kaderi',
      title: 'Luna\'nın Kaderi',
      author: 'Mia Yıldız',
      genre: 'Fantastik',
      coverUrl: 'https://picsum.photos/seed/luna/300/440',
    ),
    Book(
      id: 'karanlik-orman',
      title: 'Karanlık Orman',
      author: 'Can Demir',
      genre: 'Macera',
      coverUrl: 'https://picsum.photos/seed/karanlikorman/300/440',
    ),
  ];

  static const karanlikGecmis = <Book>[
    Book(
      id: 'gece-yarisi',
      title: 'Gece Yarısı',
      author: 'Selin Arslan',
      genre: 'Gizem',
      coverUrl: 'https://picsum.photos/seed/gece/300/440',
    ),
    Book(
      id: 'karanlik-siir',
      title: 'Karanlık Şiir',
      author: 'Deniz Kaya',
      genre: 'Şiir',
      coverUrl: 'https://picsum.photos/seed/siir/300/440',
      isNew: true,
    ),
    Book(
      id: 'sessiz-ev',
      title: 'Sessiz Ev',
      author: 'Orhan Pamuk',
      genre: 'Roman',
      coverUrl: 'https://picsum.photos/seed/sessiz/300/440',
    ),
  ];

  static const popularYazarlar = <Book>[
    Book(
      id: 'kar',
      title: 'Kar',
      author: 'Orhan Pamuk',
      genre: 'Roman',
      coverUrl: 'https://picsum.photos/seed/kar/300/440',
    ),
    Book(
      id: 'ince-memed',
      title: 'İnce Memed',
      author: 'Yaşar Kemal',
      genre: 'Epik',
      coverUrl: 'https://picsum.photos/seed/memed/300/440',
      isNew: true,
    ),
    Book(
      id: 'saatleri-ayarlama',
      title: 'Saatleri Ayarlama',
      author: 'Ahmet Hamdi Tanpınar',
      genre: 'Klasik',
      coverUrl: 'https://picsum.photos/seed/saatler/300/440',
    ),
    Book(
      id: 'istanbul-hatirasi',
      title: 'İstanbul Hatırası',
      author: 'Ahmet Ümit',
      genre: 'Polisiye',
      coverUrl: 'https://picsum.photos/seed/istanbul/300/440',
    ),
  ];

  // ── Personal Library (Dummy) ───────────────────────────────────────────────

  /// Currently reading — with progress
  static const currentlyReading = <Book>[
    Book(
      id: 'nasrettin-hoca',
      title: 'Nasrettin Hoca',
      author: 'Anonim',
      genre: 'Halk Edebiyatı',
      coverUrl: 'https://picsum.photos/seed/nasrettin/300/440',
      pageCount: 240,
      readingProgress: 0.42,
    ),
    Book(
      id: 'alfanin-secimi',
      title: 'Alfa\'nın Seçimi',
      author: 'Lara Güneş',
      genre: 'Romantik',
      coverUrl: 'https://picsum.photos/seed/alfa/300/440',
      pageCount: 320,
      readingProgress: 0.17,
      isNew: true,
    ),
  ];

  /// Completed books
  static const completed = <Book>[
    Book(
      id: 'keloglan-masallari',
      title: 'Keloğlan Masalları',
      author: 'Anonim',
      genre: 'Klasik',
      coverUrl: 'https://picsum.photos/seed/keloglan/300/440',
      pageCount: 180,
      readingProgress: 1.0,
    ),
    Book(
      id: 'sessiz-ev',
      title: 'Sessiz Ev',
      author: 'Orhan Pamuk',
      genre: 'Roman',
      coverUrl: 'https://picsum.photos/seed/sessiz/300/440',
      pageCount: 336,
      readingProgress: 1.0,
    ),
    Book(
      id: 'kar',
      title: 'Kar',
      author: 'Orhan Pamuk',
      genre: 'Roman',
      coverUrl: 'https://picsum.photos/seed/kar/300/440',
      pageCount: 478,
      readingProgress: 1.0,
    ),
    Book(
      id: 'gece-yarisi',
      title: 'Gece Yarısı',
      author: 'Selin Arslan',
      genre: 'Gizem',
      coverUrl: 'https://picsum.photos/seed/gece/300/440',
      pageCount: 290,
      readingProgress: 1.0,
    ),
  ];

  /// Saved / bookmarked books
  static const saved = <Book>[
    Book(
      id: 'lunanin-kaderi',
      title: 'Luna\'nın Kaderi',
      author: 'Mia Yıldız',
      genre: 'Fantastik',
      coverUrl: 'https://picsum.photos/seed/luna/300/440',
      pageCount: 412,
    ),
    Book(
      id: 'ince-memed',
      title: 'İnce Memed',
      author: 'Yaşar Kemal',
      genre: 'Epik',
      coverUrl: 'https://picsum.photos/seed/memed/300/440',
      pageCount: 544,
    ),
    Book(
      id: 'istanbul-hatirasi',
      title: 'İstanbul Hatırası',
      author: 'Ahmet Ümit',
      genre: 'Polisiye',
      coverUrl: 'https://picsum.photos/seed/istanbul/300/440',
      pageCount: 388,
    ),
  ];
}
