// ==========================================
// 1. KÜTÜPHANELERİM 
// ==========================================
// 'material.dart': Figma'da çizdiğim UI bileşenlerini (Buton, Grid, Text) DOM'a basmak için Flutter'ın çekirdek UI kitini çağırıyorum.
import 'package:flutter/material.dart';

// 'dart:convert': API'den string olarak gelecek ham JSON datasını parse edip (JSON.parse) JavaScript objesine çevirebilmek için eklediğim kütüphane.
import 'dart:convert';

// Uygulamanın çalışmaya başladığı index.js (Entry Point) dosyam.
// runApp diyerek ana Component'imi (MiniKatalogApp) DOM'a render ediyorum (çizdiriyorum).
void main() {
  runApp(const MiniKatalogApp());
}

// ==========================================
// 2. GLOBAL STATE (Redux / Context API Simülasyonum)
// ==========================================
// Sepet verilerini sayfalar arası (Keşfet -> Detay -> Sepet) taşımak için ağır bir paket (Redux vs.) kurmak yasak olduğu için,
// bellekte (RAM) yaşayan basit bir global Array (dizi) tanımladım. Detay sayfasından 'push' yapıp, Sepet'ten map'leyeceğim.
List<Urun> globalSepet = [];

// ==========================================
// 3. GLOBAL AYARLAR (Root Component ve CSS)
// ==========================================
// Burası benim genel "style.css" dosyam ve projenin ana Router (yönlendirici) kabuğu.
// İçinde kendi kendine değişen dinamik bir state (durum) tutmadığı için "Stateless" kullanmayı seçtim.
class MiniKatalogApp extends StatelessWidget {
  const MiniKatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki o sinir bozucu kırmızı DEBUG etiketini CSS ile display:none yaptım.
      title: 'Mini Katalog',
      theme: ThemeData(
        // body { background-color: #FAFAFC; } -> Tam beyaz yerine çok açık, şık bir gri seçtim ki beyaz kartlarım (BoxShadow ile) öne çıksın.
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
        primaryColor: Colors.black, // --primary-color: black;
        fontFamily: 'Roboto', // Tüm uygulamanın global tipografisini (font-family) ayarladım.
      ),
      home: const DiscoverSayfasi(), // Uygulama ilk açıldığında ekrana render edilecek ilk rotam (Sayfam).
    );
  }
}

// ==========================================
// 4. VERİ MODELİM (TypeScript Interface Mantığım)
// ==========================================
// API'den gelecek veriyi, sistemin hatasız okuyabilmesi için kuralları belli bir objeye (Interface/Model) zorluyorum.
class Urun {
  final String ad;
  final String fiyat;
  final String gorselUrl;
  final String aciklama;
  final List<String> etiketler; // Ürünün özelliklerini tutacağım etiket (Badge) dizim.

  // Constructor (Kurucu). Ben bu class'ı çağırırken bu props'ların hepsini vermek zorundayım (required) diyorum.
  Urun({
    required this.ad,
    required this.fiyat,
    required this.gorselUrl,
    required this.aciklama,
    required this.etiketler,
  });

  // Ham JSON datasını alıp, yukarıdaki Urun formatına dönüştüren "fromJSON" adlı ayrıştırıcı (Parser) fonksiyonum.
  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      ad: json['ad'],
      fiyat: json['fiyat'],
      gorselUrl: json['gorselUrl'],
      aciklama: json['aciklama'],
      // JSON'daki etiketler Array'ini okuyup Dart'ın "List<String>" formatına güvenle (Type Casting) çeviriyorum.
      etiketler: List<String>.from(json['etiketler'] ?? []),
    );
  }
}

// ==========================================
// 5. ANA SAYFA: KEŞFET (Stateful Component)
// ==========================================
// İçine dışarıdan veri çekeceğim ve arayüz sonradan güncelleneceği için, React'teki "useState" yapısına denk gelen "Stateful" mimariyi kullandım.
class DiscoverSayfasi extends StatefulWidget {
  const DiscoverSayfasi({super.key});

  @override
  State<DiscoverSayfasi> createState() => _DiscoverSayfasiState();
}

class _DiscoverSayfasiState extends State<DiscoverSayfasi> {
  // Başlangıçta boş olan ürünler dizim (State'im). API'den gelen veriler buraya dolacak.
  List<Urun> urunler = [];

  // Vanilla JS'teki 'window.onload' veya React'teki 'useEffect(..., [])' mantığım.
  // Sayfa DOM'a çizilmeden hemen önce sadece bir kere çalışsın diye verileriYukle() fonksiyonunu burada tetikliyorum.
  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  void verileriYukle() {
    // API simülasyonum: Kırık linkler temizlendi, tüm görseller %100 çalışan güncel linklerle değiştirildi.
    String sahteJson = '''
    [
      {
        "ad": "AirPods Pro", 
        "fiyat": "£249", 
        "gorselUrl": "https://images.unsplash.com/photo-1608156639585-b3a032ef9689?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Aktif Gürültü Engelleme (ANC) teknolojisi ile dış dünyayı tamamen kapatın veya Şeffaf Mod sayesinde çevrenizle anında bağlantı kurun. Yepyeni H2 çip sayesinde daha önce hiç duymadığınız kadar kusursuz bir akustik deneyim ve başınızı takip eden uzamsal ses (Spatial Audio) sunar. Dört farklı boyuttaki esnek silikon kulaklık uçları mükemmel yalıtım sağlarken, MagSafe şarj kutusu ile 30 saate kadar kesintisiz müzik dinleme özgürlüğü elde edersiniz.",
        "etiketler": ["Kulak İçi", "ANC", "H2 Çip", "MagSafe"]
      },
      {
        "ad": "AirPods Max", 
        "fiyat": "£549", 
        "gorselUrl": "https://images.unsplash.com/photo-1613040809024-b4ef7ba99bc3?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Kusursuz ses kalitesi sunan, yüksek kaliteli kafa üstü kulaklık devrimi. Özel akustik tasarımı ve hafızalı köpükten üretilen kulaklık yastıkları, kulağınızı sararak olağanüstü bir yalıtım sağlar. Özel sürücüler yüksek frekanslı sesleri kristal netliğinde duyururken, derin basların her notasını hissetmenizi sağlar. Smart Case içine koyduğunuzda ultra düşük güç moduna geçerek pil ömrünü korur.",
        "etiketler": ["Kafa Üstü", "Premium", "ANC", "Hi-Fi"]
      },
      {
        "ad": "HomePod", 
        "fiyat": "£299", 
        "gorselUrl": "https://images.unsplash.com/photo-1543512214-318c7553f230?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Ev için baştan aşağı yeniden tasarlanmış, akıllı ve inanılmaz derecede güçlü ses asistanı. İleri düzey bilişimsel ses teknolojisi, odanın akustiğini otomatik olarak algılar ve sesi bulunduğunuz ortama göre optimize eder. Kusursuz Siri entegrasyonu sayesinde sadece sesinizi kullanarak akıllı ev aletlerinizi yönetebilir, alarm kurabilir veya favori Apple Music çalma listelerinizi anında başlatabilirsiniz.",
        "etiketler": ["Akıllı Ev", "Siri", "360° Ses"]
      },
      {
        "ad": "HomePod Mini", 
        "fiyat": "£99", 
        "gorselUrl": "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Küçük boyutuyla evinizin her odasına mükemmel uyum sağlayan, ancak boyutundan beklenmeyecek kadar devasa bir 360 derece ses veren akıllı hoparlör. Birden fazla HomePod Mini cihazını birbirine bağlayarak tüm evde aynı anda müzik çalabilir (Multi-room audio) veya aile üyelerinize seslenmek için interkom özelliği olarak kullanabilirsiniz.",
        "etiketler": ["Kompakt", "Siri", "İnterkom"]
      },
      {
        "ad": "Beats Studio", 
        "fiyat": "£349", 
        "gorselUrl": "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Stüdyo kalitesinde ses deneyimi arayan profesyoneller ve müzik tutkunları için özel olarak tasarlandı. Saf uyarlanabilir gürültü önleme (Pure ANC) özelliği, dış sesleri anında engeller ve müziğin gerçek duygusunu korumak için saniyede binlerce kez gerçek zamanlı ses kalibrasyonu yapar. Etkileyici bas performansı ile ritmi içinizde hissedin.",
        "etiketler": ["Stüdyo", "Derin Bass", "Pure ANC"]
      },
      {
        "ad": "Sony XM5", 
        "fiyat": "£399", 
        "gorselUrl": "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Sektör lideri gürültü engelleme performansıyla tanışın. Gelişmiş çoklu mikrofon sensörleri ve yepyeni özel işlemcisi sayesinde uçak motoru uğultusundan ofis gürültüsüne kadar her şeyi filtreler. Ultra hafif tasarımı, yumuşak deri kulak yastıkları ve tek şarjla 30 saat süren devasa pil ömrüyle uzun uçak yolculuklarının vazgeçilmezi.",
        "etiketler": ["30s Pil", "Lider ANC", "Hafif"]
      },
      {
        "ad": "Apple Watch", 
        "fiyat": "£399", 
        "gorselUrl": "https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Kişisel sağlık ve fitness asistanınız her an bileğinizde. Gelişmiş sensörleri ile istediğiniz zaman EKG çekin, kandaki oksijen seviyenizi ölçün ve uyku düzeninizi analiz edin. Suya dayanıklı yapısı sayesinde yüzerken veya şiddetli antrenman yaparken tüm verilerinizi kusursuzca takip edip telefonunuza senkronize eder.",
        "etiketler": ["Sağlık", "Oksijen Sensörü", "Su Geçirmez"]
      },
      {
        "ad": "MacBook Air", 
        "fiyat": "£999", 
        "gorselUrl": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Yeni nesil Apple silikon çip (M serisi) ile güçlendirilmiş, fansız, tamamen sessiz çalışan, inanılmaz ince ve hafif tasarım harikası. Güçlü performansı sayesinde video kurgu ve yazılım işlerinizi zorlanmadan yaparken, 18 saate varan muazzam pil ömrüyle şarj aletini evde bırakmanızı sağlar.",
        "etiketler": ["İnce", "M-Çip", "18s Pil"]
      },
      {
        "ad": "iPad Pro", 
        "fiyat": "£799", 
        "gorselUrl": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Dizüstü bilgisayarlara kafa tutan masaüstü sınıfı performans, şimdi sadece birkaç milimetre inceliğinde. Büyüleyici Liquid Retina XDR ekran, muhteşem renk doğruluğu ve 120Hz ProMotion teknolojisi sunar. Apple Pencil desteğiyle çizerken, Magic Keyboard ile kod yazarken yaratıcılığınızı sınır tanımadan serbest bırakın.",
        "etiketler": ["Tablet", "Retina", "Çizim"]
      },
      {
        "ad": "Magic Mouse", 
        "fiyat": "£79", 
        "gorselUrl": "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500&auto=format&fit=crop&q=80", 
        "aciklama": "Masajı tamamen kablosuz ve pürüzsüz bir deneyime dönüştüren şarj edilebilir tasarım harikası. Alt kısmında pil kapağı veya çıkıntı olmadığı için masa üzerinde yağ gibi kayar. Üst kısmındaki Multi-Touch yüzeyi sayesinde web sayfaları arasında geri gitmek veya uzun belgeleri kaydırmak sadece küçük bir parmak hareketiyle gerçekleşir.",
        "etiketler": ["Kablosuz", "Multi-Touch", "Ergonomik"]
      }
    ]
    ''';

    List<dynamic> cozulmusJson = jsonDecode(sahteJson);

    // İŞTE EN KRİTİK NOKTA: setState! (React'teki setUrunler() mantığı)
    // "Veri API'den geldi, DOM'u eski haliyle bırakma, arayüzü yeni 10 ürünlük state dizime göre baştan çiz!" emrimi veriyorum.
    setState(() {
      urunler = cozulmusJson.map((json) => Urun.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold benim Figma'daki en büyük çalışma tuvalim (Frame'im). Header (AppBar) ve Body (İçerik) kısımlarını kendi ayırıyor.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        title: const Text(
          'Discover',
          style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {
              // React-Router (window.location.href) mantığım. İkona tıklanınca Navigator ile Sepet sayfasına pushluyorum (Geçiş yapıyorum).
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SepetSayfasi()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // padding: 0 16px; (İçerikler ekrana yapışmasın diye iç boşluk).
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // CSS Flexbox: align-items: flex-start;
          children: [
            const SizedBox(height: 8), // margin-top: 8px; niyetine koyduğum hayalet boşluk kutum.
            const Text(
              'Find your perfect device',
              style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // GÜNCELLENEN BANNER GÖRSELİM (Gift Store Kısmı)
            // ==========================================
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF4F4F6), // Eğer resim sağdan soldan boşluk bırakırsa altı şık dursun diye bir gri arka plan attım.
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16), // CSS: overflow: hidden & border-radius: 16px
                child: Image.network(
                  'https://wantapi.com/assets/banner.png',
                  width: double.infinity, // width: 100%; (Genişliği sonuna kadar doldur).
                  // DİKKAT: 'cover' yerine 'contain' yaptım ki, resim kutuya zorla sığmak için kenarlarından kırpılmasın. Böylece Gift Store yazısı uzaklaştı ve ekrana tam oturdu.
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // ÜRÜN LİSTESİ (CSS Grid Sistemim)
            // ==========================================
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Yan yana 2 kolon olsun.
                  crossAxisSpacing: 16, // Sütunlar arası boşluk (column-gap: 16px)
                  mainAxisSpacing: 16, // Satırlar arası boşluk (row-gap: 16px)
                  childAspectRatio: 0.58, // Ürün altına etiketler (badge) sığsın diye kartın dikey (aspect-ratio) boyunu baya uzattım.
                ),
                itemCount: urunler.length,
                itemBuilder: (context, index) {
                  // Döngüdeki sıradaki veriyi (objeyi) alıp, Figma'da modellediğim UrunKarti Component'ime Props olarak paslıyorum.
                  return UrunKarti(urun: urunler[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. UI COMPONENT (Hata Korumalı Ürün Kartım)
// ==========================================
// HTML'de her ürün için aynı divleri amele gibi tekrar yazmamak için oluşturduğum harika Component yapım.
class UrunKarti extends StatelessWidget {
  final Urun urun; // Bu Component çalışmak için dışarıdan bu Props'u almak ZORUNDA.

  const UrunKarti({super.key, required this.urun});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Tıklanınca detay sayfasına yönlendiriyorum ve elimdeki mevcut "urun" objesini de yanımda götürüyorum.
        Navigator.push(context, MaterialPageRoute(builder: (context) => UrunDetaySayfasi(urun: urun)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // Apple tasarımlarındaki o derinlik katan, çok yumuşak BoxShadow gölgem.
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RESİM ALANI (Flex: 1)
            // Resim alanının kalan tüm dikey boşluğu yutması için Expanded içine aldım.
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Hero(
                  tag: urun.ad, // Hero animasyonunun sayfa geçişlerinde resmi bulması için koyduğum benzersiz kimlik.

                  // HATA KORUMASI (Fallback UI)
                  // Geçen seferki kırmızı çarpı işaretli hata ekranı gelmesin diye, eğer API'den gelen resim bozuksa
                  // program çökmesi yerine bana gri renkte şık bir "Resim Yok" ikonu (Fallback Component) çizdiriyorum.
                  child: Image.network(
                    urun.gorselUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                      );
                    },
                  ),
                ),
              ),
            ),

            // YAZI VE ETİKET ALANI
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urun.ad,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1C1C1E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // white-space: nowrap; text-overflow: ellipsis; (Yazı uzarsa 2. satıra geçip tasarımı bozmasın, sonuna 3 nokta koysun).
                  ),
                  const SizedBox(height: 4),
                  Text(
                    urun.fiyat,
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // ETİKETLER (Badges) ALANI
                  // Wrap demek, CSS'teki "flex-wrap: wrap" demektir. Etiketler yan yana sığmazsa otomatik alta atsın istedim.
                  Wrap(
                    spacing: 4, // Etiketler arası margin
                    runSpacing: 4,
                    // Array içindeki ilk 2 etiketi alıp (fazlası taşırmasın diye) HTML'deki span'lara (Container) çeviriyorum. (React .map() mantığı)
                    children: urun.etiketler.take(2).map((etiket) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          etiket,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. ÜRÜN DETAY SAYFASI
// ==========================================
class UrunDetaySayfasi extends StatelessWidget {
  final Urun urun; // Keşfet sayfasından bana yollanan Props verisi.

  const UrunDetaySayfasi({super.key, required this.urun});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Resim sayfanın en tepesine kadar çıkıp tam ekran dursun diye navbar arkasını şeffaf yaptım.
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      extendBodyBehindAppBar: true, // CSS: position: absolute; top: 0;

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En üstteki devasa Hero görselim. Sayfa geçişinde resim buraya uçarak (transition) geliyor.
          SizedBox(
            height: 400, // Resmi 400px yüksekliğe sabitledim.
            width: double.infinity,
            child: Hero(
              tag: urun.ad,
              child: Image.network(
                urun.gorselUrl,
                fit: BoxFit.cover, // Resim mekanı tam doldursun.
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 80)),
                ),
              ),
            ),
          ),

          // Yazıların olduğu alanı hafif yukarı çekip (-20px) köşelerini yuvarlayarak modern bir BottomSheet (Açılır Alt Panel) illüzyonu yarattım.
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve Fiyatı yan yana itmek için (justify-content: space-between) Flexbox Row kullandım.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            urun.ad,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                        ),
                        Text(
                          urun.fiyat,
                          style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // DETAY SAYFASI ETİKETLERİ
                    // Burada ürünün kaç etiketi varsa hepsini kısıtlamadan sığdığı kadar listeliyorum.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: urun.etiketler.map((etiket) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            etiket,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),

                    // Metinler (Açıklamalar) yeni JSON ile çok uzun olduğu için, alt kısımdaki butonu ekrandan dışarı itip uygulamayı çökertmesin diye,
                    // metni "SingleChildScrollView" içine aldım (CSS: overflow-y: auto). Sadece bu yazı alanı kendi içinde kaydırılabilir oldu.
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          urun.aciklama,
                          style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.6), // line-height: 1.6;
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SEPETE EKLE BUTONUM
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // O an bulunduğum sayfadaki ürün props'unu "globalSepet" adlı global State dizime pushluyorum. (Sepete eklendi)
                          globalSepet.add(urun);

                          // JS'teki Alert() veya Bootstrap Toast mesajı mantığı. Alt taraftan süzülerek gelen geçici bildirim.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${urun.ad} added to your cart!'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.black87,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. SEPET (CART) SAYFASI VE CHECKOUT MODALI
// ==========================================
class SepetSayfasi extends StatefulWidget {
  const SepetSayfasi({super.key});

  @override
  State<SepetSayfasi> createState() => _SepetSayfasiState();
}

class _SepetSayfasiState extends State<SepetSayfasi> {
  // YENİ EKLENEN ÖZELLİK: ÖDEME PENCERESİ (Modal/Dialog)
  // Checkout butonuna basıldığında tetiklenecek fonksiyon. Bootstrap Modal veya React Dialog component'inin Flutter versiyonu.
  void odemePenceresiniAc() {
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı pencere dışına tıklarsa kapanmasın, illa iptal/devam seçsin.
      builder: (BuildContext context) {
        // AlertDialog ile ekranda şık, yuvarlak köşeli bir pop-up çizdiriyorum.
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.security, color: Colors.green),
              SizedBox(width: 8),
              Text('Secure Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'Güvenli ödeme sayfasına yönlendiriliyorsunuz. Lütfen bekleyin...',
            style: TextStyle(color: Colors.black87, height: 1.5),
          ),
          actions: [
            // İPTAL BUTONU
            TextButton(
              onPressed: () {
                Navigator.pop(context); // DOM'dan (ekrandan) bu modalı sil, pop yap.
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            // DEVAM ET BUTONU
            ElevatedButton(
              onPressed: () {
                // Burada normalde ödeme API'sine istek atardım (Stripe, Iyzico vs.)
                Navigator.pop(context); // Modalı kapat

                // Sepeti temizleyip State'i yeniliyorum ki ekran tekrar boş sepet moduna dönsün.
                setState(() {
                  globalSepet.clear();
                });

                // Kullanıcıya teşekkür eden bir toast mesajı göster.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment successful! Your order is processing.'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Proceed', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Cart', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // IF/ELSE mantığım: Sepet dizisi (global array) boş mu?
        child: globalSepet.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Your cart is empty', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        )
        // ELSE (Sepet Doluysa): Sepetteki verileri DOM'a döngüyle bas (.map() mantığı).
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: globalSepet.length,
                itemBuilder: (context, index) {
                  final sepettekiUrun = globalSepet[index];
                  // Listedeki her bir elemanı arkaplanı beyaz modern bir Card (div) içine alıyorum.
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12), // margin-bottom: 12px;
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      // Ürünün ufak resmi (Thumbnail).
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          sepettekiUrun.gorselUrl,
                          width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60, height: 60, color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                          ),
                        ),
                      ),
                      title: Text(sepettekiUrun.ad, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Text(sepettekiUrun.fiyat, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          // Çöp kutusuna basınca elemanı diziden (splice) silip setState ile arayüzü tekrar çizdiriyorum (re-render).
                          setState(() {
                            globalSepet.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // ==========================================
            // YENİ Checkout Butonu ve Tıklama Event'i
            // ==========================================
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // Butona tıklandığında yukarıda tanımladığım Modal/Dialog açma fonksiyonunu çağırıyorum!
                onPressed: odemePenceresiniAc,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
