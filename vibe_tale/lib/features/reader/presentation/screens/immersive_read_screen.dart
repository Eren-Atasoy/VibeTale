import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';

class ImmersiveReadScreen extends StatefulWidget {
  final String bookId;

  const ImmersiveReadScreen({super.key, required this.bookId});

  @override
  State<ImmersiveReadScreen> createState() => _ImmersiveReadScreenState();
}

class _ImmersiveReadScreenState extends State<ImmersiveReadScreen> {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0.0;

  // Göz yormayan kitap kurgu metni (Dummy Data)
  final String _dummyStoryContent = """
Gece, şehri yutmuş bir mürekkep damlası gibi yavaşça yayılırken, yağmur damlaları pencere camıma vurmaya devam ediyordu. Her damla, sanki anlatılamamış bir hikayenin gözyaşlarıydı. Sokak lambalarının sarı ışığı, ıslak asfaltta kırılıyor ve eski mahallenin melankolik ruhunu bir kez daha ortaya çıkarıyordu.

O eski kitapçının önünden geçerken hissettiğim garip ürperti henüz geçmemişti. Kitapların tozlu sayfalarında saklı kalan o koku, insanı bir anda yüz yıl geriye götürebilecek kadar güçlüydü. İçeride, ahşap rafların ardında duran yaşlı adam, bana sanki bir sırrı devretmek ister gibi bakmıştı. Elime tutuşturduğu o eski deri kaplı kitap, sadece bir nesne değil, adeta yaşayan bir organizmaydı.

Eve döndüğümde kitabın sayfalarını ilk açtığım an, odanın içerisindeki hava aniden değişti. Kelimeler sıradan bir kağıt üzerinde durmuyor, zihnimin en derin yankı odalarına fısıldıyordu. Her satır, kendi içinde bir labirentti. Bir zamanlar var olmuş, belki de sadece bir yazarın hayal gücünde can bulmuş karakterler, şimdi benim gerçekliğimi ele geçiriyordu.

Sayfalar ilerledikçe zaman kavramını yitirmeye başladım. Gözlerim kelimelerin üzerinde hızla kayıyor, zihnim ise sahneleri kusursuz bir sinema perdesi gibi önüme seriyordu. Kahraman, korkularıyla yüzleşmek için karanlık ormana girdiğinde, nefesimi tuttuğumu fark ettim. Kitap, beni sadece okuyucu yapmıyor, aynı zamanda hikayenin içindeki görünmez bir yol arkadaşına dönüştürüyordu.

Sabahın ilk ışıkları ufukta belirirken, kitabın son sayfasına ulaştım. Gözlerimde tatlı bir yorgunluk, kalbimde ise tarifsiz bir tamamlanmışlık hissi vardı. O eski kitapçının neden bana bu kitabı verdiğini artık çok iyi biliyordum. Bazı kitaplar sadece okunmak için değil, yaşanmak ve içselleştirilmek için yazılırdı. Ve ben o gece, sadece bir kitap okumamış, koca bir hayat yaşamıştım.
""";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll > 0) {
        setState(() {
          _progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tamamen immersive bir deneyim için statusBar'ı saydam yapıyoruz
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: ThemedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // Background'un görünmesi için
          extendBodyBehindAppBar: true, // İçeriğin appbar'ın altına geçmesi için
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // ── Ana Okuma Alanı ──
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Okuma yaparken kaydırıldığında gizlenen zarif AppBar
                    SliverAppBar(
                      floating: true,
                      backgroundColor: context.isDark 
                          ? AppColors.backgroundDeep.withValues(alpha: 0.95)
                          : const Color(0xFFF4F6F5).withValues(alpha: 0.95),
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: context.vColors.textPrimary),
                        onPressed: () => context.pop(),
                      ),
                      title: Text(
                        '1. Bölüm: Yağmurun Fısıltısı', // Dummy Title
                        style: AppTypography.titleLarge.copyWith(
                          color: context.vColors.textPrimary,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      centerTitle: true,
                      // Kullanıcı isteği üzerine sağ üstte kaydedici/opsiyon ikonu yok.
                    ),
                    
                    // Metin İçeriği
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.screenPaddingH * 1.5, // Rahat okuma boşluğu
                          vertical: AppDimensions.spaceLG,
                        ),
                        child: Column(
                          children: [
                            // Büyük bölüm başlığı
                            Text(
                              "Bölüm 1",
                              style: AppTypography.displayMedium.copyWith(
                                color: context.vColors.textPrimary,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.spaceXXL),
                            
                            // Akıcı hikaye metni (Uzunluğu simüle etmek için tekrarlıyoruz)
                            Text(
                              _dummyStoryContent + '\n\n' + _dummyStoryContent + '\n\n' + _dummyStoryContent,
                              style: AppTypography.readingBody.copyWith(
                                color: context.vColors.textPrimary,
                                height: 1.9, // Daha geniş satır aralığı
                                fontSize: 18, // Rahat okuma için hafif büyük punto
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            
                            const SizedBox(height: 120), // Alt çubuğa kadar olan boşluk
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // ── İlerleme Çubuğu (Bottom Progress Indicator) ──
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50 + MediaQuery.of(context).padding.bottom,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
                          Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 12,
                      left: AppDimensions.screenPaddingH,
                      right: AppDimensions.screenPaddingH,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        children: [
                          Text(
                            '%${(_progress * 100).toInt()}',
                            style: AppTypography.labelSmall.copyWith(
                              color: context.vColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spaceMD),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: context.vColors.glassBorder,
                                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
