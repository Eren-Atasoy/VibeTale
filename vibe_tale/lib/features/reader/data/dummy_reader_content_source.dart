import 'package:vibe_tale/features/reader/data/chunk_dto.dart';
import 'package:vibe_tale/features/reader/data/reader_content_source.dart';

/// Asset-URL scheme understood by `ReaderMedia`. Dummy ambiance points at
/// bundled assets; the backend will return real `http(s)://` storage URLs and
/// the same widgets handle both transparently.
const _rainAsset = 'asset://assets/audio/ambient_rain.mp3';
const _pianoAsset = 'asset://assets/audio/piano_serenade.mp3';
const _imageAsset = 'asset://assets/images/scene_landscape.jpg';

/// Per-chunk ambient audio — mirrors the backend, where every chunk carries its
/// own `audio_url`. With two demo tracks we map each scene to one so the audio
/// follows the chunk being read and crossfades at scene boundaries (rain for
/// the dark/cave scenes, piano for the gentle ones).
const _audioByIndex = <String>[
  _rainAsset, // 0  Yağmurlu mağara girişi
  _pianoAsset, // 1  Kristal orman
  _pianoAsset, // 2  Köyün uyarısı
  _rainAsset, // 3  Karanlıkta bir hışırtı
  _rainAsset, // 4  Taş kesilen bacaklar
  _rainAsset, // 5  Devin eli
  _rainAsset, // 6  Yorgun dev uyanıyor
  _pianoAsset, // 7  Titreyen itiraf
  _pianoAsset, // 8  Devin kahkahası
  _pianoAsset, // 9  Davet
  _pianoAsset, // 10 Korkuyla yüzleşme
  _rainAsset, // 11 Hikâye başlıyor
];

/// A single dummy chunk paired with its ambiance, in backend shape.
class _DummyChunk {
  const _DummyChunk({
    required this.chapter,
    required this.text,
    required this.scene,
    required this.emotion,
  });

  final int chapter;
  final String text;
  final String scene;
  final String emotion;
}

/// In-memory reader content that mirrors the backend contract exactly, so the
/// immersive reader can be built and demoed before the AI media pipeline is
/// wired. Every chunk advertises audio + image; ambiance returns the bundled
/// rain track and landscape image with a rotating emotion to drive the scene
/// atmosphere.
class DummyReaderContentSource implements ReaderContentSource {
  const DummyReaderContentSource();

  static const _chunks = <_DummyChunk>[
    _DummyChunk(
      chapter: 1,
      scene: 'Yağmurlu mağara girişi',
      emotion: 'wonder',
      text:
          'Keloğlan, mağaranın derinliklerindeki gizemli parıltıya doğru ilerledi. '
          'Dışarıda yağmur durmadan yağıyor, damlalar kayalara çarptıkça mağaranın '
          'içinde yumuşak bir uğultu yankılanıyordu. Elindeki değneğin ışığı, nemli '
          'duvarlardaki tuhaf sembolleri aydınlatıyordu. Kalbi heyecanla çarparken, '
          'onu bekleyen sırrın büyüklüğünü hissedebiliyordu.',
    ),
    _DummyChunk(
      chapter: 1,
      scene: 'Kristal orman',
      emotion: 'wonder',
      text:
          'Mağaranın içi, dışarıdan göründüğünden çok daha genişti. Tavanından sarkan '
          'dev sarkıtlar, kristal bir orman gibi parıldıyordu. Her adımda ayaklarının '
          'altındaki taş, boş ve derin bir sesin yankısını gönderiyordu derinliklere. '
          'Keloğlan duraksadı; o sesin ne kadar aşağılara indiğini hesaplamaya çalıştı, '
          'ama yankı hiç bitmiyordu sanki.',
    ),
    _DummyChunk(
      chapter: 1,
      scene: 'Köyün uyarısı',
      emotion: 'melancholic',
      text:
          'Köyde büyükler hep demişti: "Mağaraya girme, Keloğlan! Orada uyuyan bir dev '
          'var, üç yüz yıldır uykuda. Kim onu uyandırırsa, o kişi ya bir kahraman olur '
          'ya da yok olup gider." Keloğlan gülmüştü o zamanlar. Şimdi ise o gülüş, '
          'boğazında bir düğüme dönüşmüştü.',
    ),
    _DummyChunk(
      chapter: 1,
      scene: 'Karanlıkta bir hışırtı',
      emotion: 'tense',
      text:
          'Birden, sol taraftan garip bir ses duydu. Bir hışırtı mıydı, yoksa rüzgârın '
          'kayalara çarpmasından mı kaynaklanıyordu, anlayamadı. Değneğini o yöne '
          'doğrulttu. Karanlık, ışığını yutuyordu adeta. Ardından her şey durdu; ses, '
          'hareket, hatta zamanın kendisi bile soluklanmayı bıraktı sanki.',
    ),
    _DummyChunk(
      chapter: 1,
      scene: 'Taş kesilen bacaklar',
      emotion: 'tense',
      text:
          'Keloğlan geri adım atmak istedi, ama bacakları taş kesilmişti. O an, '
          'mağaranın tabanından tırmanan bir titreşim hissetti. Hafif, ama kararlı. '
          'Bir nesnenin uyanışının sesi miydi bu? Yoksa sadece kendi kalbinin deli gibi '
          'çarptığı mıydı?',
    ),
    _DummyChunk(
      chapter: 1,
      scene: 'Devin eli',
      emotion: 'mysterious',
      text:
          'Gözlerini kırpıştırarak önüne odaklandı. Işığın erişebildiği son noktada, '
          'kocaman, kıllı bir el duruyordu. Parmakları, bir insanın kolundan kalındı. '
          'Ve o el, yavaş yavaş açılıp kapanmaya başlıyordu.',
    ),
    _DummyChunk(
      chapter: 2,
      scene: 'Yorgun dev uyanıyor',
      emotion: 'mysterious',
      text:
          '"Yine mi geldiniz?" dedi dev, sesi mağaranın duvarlarında yankılanan kısık '
          'bir gürültüyle. "Kaç yüzyıldır kimse gelmemişti buraya." Keloğlan dili '
          'tutulmuş gibi baktı. Büyükler, devin kükreyeceğini söylemişti. Oysa bu ses, '
          'yorgundu. Neredeyse hüzünlüydü.',
    ),
    _DummyChunk(
      chapter: 2,
      scene: 'Titreyen itiraf',
      emotion: 'melancholic',
      text:
          '"Ben..." dedi Keloğlan, sesi titreyerek. "Ben sizi uyandırmak istemedim, '
          'efendim. Sadece yolumu kaybettim." Dev, gözlerini açtı. Gözleri, iki küçük '
          'ay gibiydi; sarı ve sakin. Uzun bir süre Keloğlan\'a baktı.',
    ),
    _DummyChunk(
      chapter: 2,
      scene: 'Devin kahkahası',
      emotion: 'hopeful',
      text:
          'Sonra güldü. Güldü ve mağaranın tavanından birkaç sarkıt düşerek paramparça '
          'oldu. "Yolunu kaybeden biri," dedi dev, "benim için en iyi misafirdir. Çünkü '
          'yolunu bulmuş olanlar asla gelmez buraya."',
    ),
    _DummyChunk(
      chapter: 2,
      scene: 'Davet',
      emotion: 'calm',
      text:
          'Keloğlan, değneğini tutmayı bile unuttu. Dev, yerinden kalkmaya başlamıştı. '
          'O kadar büyüktü ki, doğrulurken başı tavana değdi ve bir sarkıtı daha kırdı. '
          'Tozu, Keloğlan\'ın gözlerine doldu. "Otur," dedi dev, taş bir blok göstererek. '
          '"Sana bir hikâye anlatacağım."',
    ),
    _DummyChunk(
      chapter: 2,
      scene: 'Korkuyla yüzleşme',
      emotion: 'hopeful',
      text:
          'Keloğlan yutkundu. Köye dönmek, annesinin sıcak çorbasını içmek istedi bir an '
          'için. Ama sonra, hayatında ilk kez, bir şeyin peşinden gitmenin korkusunun ta '
          'kendisi olduğunu anladı. Oturdu.',
    ),
    _DummyChunk(
      chapter: 2,
      scene: 'Hikâye başlıyor',
      emotion: 'wonder',
      text:
          'Dev gülümsedi. Mağaranın dışındaki yağmur, sanki anlatılacak hikâyeyi dinlemek '
          'için yavaşladı. Ve dev, üç yüz yıldır kimseye söylemediği o hikâyeyi anlatmaya '
          'başladı.',
    ),
  ];

  @override
  Future<List<ChunkDto>> getChunks(String bookId) async {
    // Simulate a small network latency so loading states are exercised.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return [
      for (var i = 0; i < _chunks.length; i++)
        ChunkDto(
          chunkId: 'dummy-$i',
          sequence: i,
          content: _chunks[i].text,
          chapterId: 'dummy-ch-${_chunks[i].chapter}',
          chapterNumber: _chunks[i].chapter,
          hasAudio: true,
          hasImage: true,
        ),
    ];
  }

  @override
  Future<AmbianceDto> getAmbiance(String chunkId) async {
    final index = int.tryParse(chunkId.split('-').last) ?? 0;
    final chunk = _chunks[index.clamp(0, _chunks.length - 1)];
    return AmbianceDto(
      chunkId: chunkId,
      scene: chunk.scene,
      emotion: chunk.emotion,
      audioUrl: _audioByIndex[index.clamp(0, _audioByIndex.length - 1)],
      imageUrl: _imageAsset,
    );
  }
}
