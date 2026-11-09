import 'package:flutter/material.dart';

void main() => runApp(const BuluvoApp());

// ============================================================
// SADE AURORA RENK PALETİ
// ============================================================
const kBg = Color(0xFFF7F5FC);
const kPanel = Color(0xFFFFFFFF);
const kPanel2 = Color(0xFFFAF8FE);
const kBorder = Color(0xFFECE6F7);
const kText = Color(0xFF1C1A2B);
const kMuted = Color(0xFF716D87);
const kMuted2 = Color(0xFF938FB0);
const kMor = Color(0xFF9333EA);
const kPembe = Color(0xFFEC4899);
const kGrad = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kMor, kPembe]);

// ============================================================
// UYGULAMA DURUMU (bellek içi — API bağlanınca buradan beslenecek)
// ============================================================
class Kisi {
  final String ad;
  final int yas;
  final String sehir;
  final String mesafe;
  final int uyum;
  final bool cevrimici;
  final List<String> ilgi;
  final List<Color> renk;
  const Kisi(this.ad, this.yas, this.sehir, this.mesafe, this.uyum, this.cevrimici, this.ilgi, this.renk);
}

class Mesaj {
  final String metin;
  final bool benim;
  const Mesaj(this.metin, this.benim);
}

class Sohbet {
  final String ad;
  final String harf;
  final List<Color> renk;
  final ValueNotifier<List<Mesaj>> mesajlar;
  Sohbet(this.ad, this.harf, this.renk, List<Mesaj> ilk) : mesajlar = ValueNotifier<List<Mesaj>>(ilk);
  String get sonMesaj => mesajlar.value.isEmpty ? '' : mesajlar.value.last.metin;
}

class Durum {
  // Jeton bakiyesi
  final jeton = ValueNotifier<int>(120);
  // Beğenenler kilidi açık mı
  final begenenlerAcik = ValueNotifier<bool>(false);
  // Seni beğenenler sayısı
  final begenenSayisi = 12;

  // Keşfet destesi
  final deste = const <Kisi>[
    Kisi('Elif', 24, 'İzmir', '3 km uzakta', 92, true, ['🎵 Müzik', '✈️ Seyahat', '☕ Kahve'], [Color(0xFFF0ABFC), Color(0xFFA855F7)]),
    Kisi('Deniz', 27, 'İstanbul', '8 km uzakta', 88, false, ['📚 Kitap', '🎬 Sinema', '🏃 Spor'], [Color(0xFFFDA4AF), Color(0xFFFB7185)]),
    Kisi('Selin', 25, 'Ankara', '12 km uzakta', 85, true, ['🎨 Sanat', '🐶 Hayvanlar', '🍳 Yemek'], [Color(0xFF6EE7B7), Color(0xFF10B981)]),
    Kisi('Zeynep', 23, 'Bursa', '5 km uzakta', 90, true, ['📷 Fotoğraf', '🌱 Doğa', '🎮 Oyun'], [Color(0xFFFCD34D), Color(0xFFF59E0B)]),
    Kisi('Ece', 26, 'Antalya', '2 km uzakta', 87, false, ['💃 Dans', '🏖️ Deniz', '🎧 Podcast'], [Color(0xFF93C5FD), Color(0xFF6366F1)]),
  ];

  // Sohbetler
  late final List<Sohbet> sohbetler = [
    Sohbet('Elif', 'E', const [Color(0xFFF0ABFC), Color(0xFFA855F7)], const [
      Mesaj('Selam! Profilin çok ilgimi çekti 😊', false),
      Mesaj('Teşekkürler! Sen de kahve sever misin?', true),
      Mesaj('Bayılırım ☕ Hafta sonu bir yere gidelim mi?', false),
    ]),
    Sohbet('Deniz', 'D', const [Color(0xFFFDA4AF), Color(0xFFFB7185)], const [
      Mesaj('Merhaba 👋', false),
      Mesaj('Teşekkürler 😊', true),
    ]),
    Sohbet('Selin', 'S', const [Color(0xFF6EE7B7), Color(0xFF10B981)], const [
      Mesaj('Sana bir fotoğraf gönderdim', false),
    ]),
    Sohbet('Zeynep', 'Z', const [Color(0xFFFCD34D), Color(0xFFF59E0B)], const [
      Mesaj('Merhaba! Nasılsın?', false),
    ]),
  ];
}

final durum = Durum();

// ============================================================
// KÖK
// ============================================================
class BuluvoApp extends StatelessWidget {
  const BuluvoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buluvo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kMor),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const GirisEkrani(),
    );
  }
}

// ============================================================
// GİRİŞ EKRANI
// ============================================================
class GirisEkrani extends StatelessWidget {
  const GirisEkrani({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 92, height: 92,
                    decoration: BoxDecoration(
                      gradient: kGrad, borderRadius: BorderRadius.circular(26),
                      boxShadow: [BoxShadow(color: kPembe.withOpacity(.45), blurRadius: 34, offset: const Offset(0, 16))],
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 18),
                  ShaderMask(
                    shaderCallback: (r) => kGrad.createShader(r),
                    child: const Text('Buluvo',
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tekrar hoş geldin', style: TextStyle(fontSize: 16, color: kMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: kGrad, borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: kPembe.withOpacity(.35), blurRadius: 28, offset: const Offset(0, 14))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          _Avatars(),
                          SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('50.000 kişi tanıştı', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                            SizedBox(height: 2),
                            Text('Sen de aramıza katıl.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ])),
                        ]),
                        const SizedBox(height: 14),
                        Row(children: const [
                          _Adim(no: '1', t: 'Kaydol'), SizedBox(width: 10),
                          _Adim(no: '2', t: 'Profil'), SizedBox(width: 10),
                          _Adim(no: '3', t: 'Eşleş'),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _BeyazButon(
                    icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
                    text: 'Google ile devam et', onTap: () => _gir(context),
                  ),
                  const SizedBox(height: 14),
                  const _Alan(hint: 'E-posta adresin'),
                  const SizedBox(height: 12),
                  const _Alan(hint: 'Şifren', obscure: true),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _gir(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Text('Giriş yap',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Buluvo · Native Android (Flutter)', style: TextStyle(fontSize: 12, color: kMuted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _gir(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AnaKabuk()));
  }
}

// ============================================================
// ANA KABUK (alt menü)
// ============================================================
class AnaKabuk extends StatefulWidget {
  const AnaKabuk({super.key});
  @override
  State<AnaKabuk> createState() => _AnaKabukState();
}

class _AnaKabukState extends State<AnaKabuk> {
  int _i = 0;
  final _sayfalar = const [KesfetSayfasi(), BegenenlerSayfasi(), SohbetSayfasi(), ProfilSayfasi()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _i, children: _sayfalar)),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: kPanel, border: Border(top: BorderSide(color: kBorder))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _navOge(0, Icons.favorite, 'Keşfet'),
                _navOge(1, Icons.star, 'Beğeniler'),
                _navOge(2, Icons.chat_bubble, 'Sohbet'),
                _navOge(3, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navOge(int idx, IconData ikon, String etiket) {
    final aktif = _i == idx;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _i = idx),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 24, color: aktif ? kMor : kMuted2),
            const SizedBox(height: 3),
            Text(etiket, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: aktif ? kMor : kMuted2)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// KEŞFET (gerçek kart destesi + kaydırma)
// ============================================================
class KesfetSayfasi extends StatefulWidget {
  const KesfetSayfasi({super.key});
  @override
  State<KesfetSayfasi> createState() => _KesfetSayfasiState();
}

class _KesfetSayfasiState extends State<KesfetSayfasi> {
  int _idx = 0;

  void _sonraki(bool begendi, Kisi k) {
    if (begendi) {
      // %50 ihtimalle eşleşme animasyonu (demo)
      if (_idx.isEven) _eslesme(k);
    }
    setState(() => _idx = (_idx + 1) % durum.deste.length);
  }

  void _eslesme(Kisi k) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(26)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text('Eşleştiniz!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('${k.ad} de seni beğendi', style: const TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Text('Mesaj gönder', style: TextStyle(color: Color(0xFFA21CAF), fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = durum.deste[_idx];
    return Column(
      children: [
        _BaslikBar(baslik: 'Buluvo', jetonGoster: true),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
          child: Row(children: const [
            Icon(Icons.place_outlined, size: 18, color: kMuted),
            SizedBox(width: 8),
            Text('Yakınlarda · 25 km', style: TextStyle(color: kMuted, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(fit: StackFit.expand, children: [
                Container(decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: k.renk))),
                Positioned(left: 12, right: 12, top: 12, child: Row(children: [
                  for (int i = 0; i < durum.deste.length; i++) ...[
                    _Nokta(aktif: i == _idx),
                    if (i < durum.deste.length - 1) const SizedBox(width: 6),
                  ],
                ])),
                Container(decoration: const BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC14052A)]))),
                Positioned(left: 20, right: 20, bottom: 24, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (k.cevrimici)
                        const _Rozet(cocuk: Text('● Çevrimiçi', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                      if (k.cevrimici) const SizedBox(width: 8),
                      _Rozet(cocuk: Text('%${k.uyum} uyum', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                    ]),
                    const SizedBox(height: 10),
                    Text('${k.ad}, ${k.yas}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('${k.sehir} · ${k.mesafe}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [for (final i in k.ilgi) _Cip(t: i)]),
                  ],
                )),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _Aksiyon(ikon: Icons.close, renk: const Color(0xFFF43F5E), buyuk: true, onTap: () => _sonraki(false, k)),
            const SizedBox(width: 22),
            _Aksiyon(ikon: Icons.star, renk: const Color(0xFF0EA5E9), onTap: () => _sonraki(true, k)),
            const SizedBox(width: 22),
            _Aksiyon(ikon: Icons.favorite, gradient: true, onTap: () => _sonraki(true, k)),
          ]),
        ),
      ],
    );
  }
}

// ============================================================
// BEĞENENLER (buğulu kilit — jetonla açılır)
// ============================================================
class BegenenlerSayfasi extends StatelessWidget {
  const BegenenlerSayfasi({super.key});

  void _ac(BuildContext context) {
    if (durum.jeton.value < 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Yetersiz jeton — Jeton al sayfasından yükle'), backgroundColor: kMor));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JetonSayfasi()));
      return;
    }
    durum.jeton.value -= 100;
    durum.begenenlerAcik.value = true;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Beğenenler açıldı 🎉'), backgroundColor: kMor));
  }

  @override
  Widget build(BuildContext context) {
    final renkler = [
      [const Color(0xFFF0ABFC), const Color(0xFFA855F7)],
      [const Color(0xFFFDA4AF), const Color(0xFFFB7185)],
      [const Color(0xFF6EE7B7), const Color(0xFF10B981)],
      [const Color(0xFFFCD34D), const Color(0xFFF59E0B)],
    ];
    final adlar = ['Elif, 24', 'Deniz, 27', 'Selin, 25', 'Zeynep, 23'];
    final harfler = ['E', 'D', 'S', 'Z'];
    return Column(
      children: [
        const _BaslikBar(baslik: 'Beğenenler'),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: durum.begenenlerAcik,
            builder: (context, acik, _) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                if (!acik)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: kPembe.withOpacity(.4), blurRadius: 24, offset: const Offset(0, 12))]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Seni ${durum.begenenSayisi} kişi beğendi ❤', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Hepsini net görmek için aç.', style: TextStyle(color: Colors.white, fontSize: 13)),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => _ac(context),
                        child: Container(
                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
                          child: const Center(child: Text('🔒 100 jeton ile hepsini aç',
                              style: TextStyle(color: Color(0xFFA21CAF), fontWeight: FontWeight.w900, fontSize: 15))),
                        ),
                      ),
                    ]),
                  ),
                if (acik)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
                    child: Row(children: const [
                      Icon(Icons.lock_open, color: kMor),
                      SizedBox(width: 10),
                      Expanded(child: Text('Kilit açık — seni beğenenleri görüyorsun', style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 14))),
                    ]),
                  ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: .75,
                  children: [
                    for (int i = 0; i < renkler.length; i++)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(fit: StackFit.expand, children: [
                          Container(decoration: BoxDecoration(gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: renkler[i]))),
                          if (acik)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(gradient: LinearGradient(
                                  begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x99000000)])),
                              child: Text(adlar[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                            )
                          else
                            Container(color: kMor.withOpacity(.14), child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock, color: Colors.white, size: 30),
                                SizedBox(height: 8),
                                Text('Kilitli', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                              ],
                            )),
                        ]),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SOHBET (liste)
// ============================================================
class SohbetSayfasi extends StatelessWidget {
  const SohbetSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BaslikBar(baslik: 'Sohbet'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: durum.sohbetler.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final s = durum.sohbetler[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SohbetDetay(sohbet: s))),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
                  child: Row(children: [
                    _Harf(harf: s.harf, renk: s.renk),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.ad, style: const TextStyle(fontWeight: FontWeight.w800, color: kText, fontSize: 15)),
                      const SizedBox(height: 3),
                      ValueListenableBuilder<List<Mesaj>>(
                        valueListenable: s.mesajlar,
                        builder: (_, m, __) => Text(m.isEmpty ? '' : m.last.metin,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 13)),
                      ),
                    ])),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SohbetDetay extends StatefulWidget {
  final Sohbet sohbet;
  const SohbetDetay({super.key, required this.sohbet});
  @override
  State<SohbetDetay> createState() => _SohbetDetayState();
}

class _SohbetDetayState extends State<SohbetDetay> {
  final _kontrol = TextEditingController();
  final _kaydir = ScrollController();

  void _gonder() {
    final t = _kontrol.text.trim();
    if (t.isEmpty) return;
    final liste = List<Mesaj>.from(widget.sohbet.mesajlar.value)..add(Mesaj(t, true));
    widget.sohbet.mesajlar.value = liste;
    _kontrol.clear();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_kaydir.hasClients) _kaydir.animateTo(_kaydir.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _kontrol.dispose();
    _kaydir.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
        title: Row(children: [
          _Harf(harf: widget.sohbet.harf, renk: widget.sohbet.renk, boyut: 38),
          const SizedBox(width: 10),
          Text(widget.sohbet.ad, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        ]),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ValueListenableBuilder<List<Mesaj>>(
              valueListenable: widget.sohbet.mesajlar,
              builder: (_, mesajlar, __) => ListView(
                controller: _kaydir,
                padding: const EdgeInsets.all(16),
                children: [for (final m in mesajlar) _Balon(metin: m.metin, benim: m.benim)],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: kPanel,
            child: Row(children: [
              Expanded(child: Container(
                decoration: BoxDecoration(color: kPanel2, borderRadius: BorderRadius.circular(999), border: Border.all(color: kBorder)),
                child: TextField(
                  controller: _kontrol,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _gonder(),
                  style: const TextStyle(color: kText, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Mesaj yaz…', hintStyle: TextStyle(color: kMuted2),
                    border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  ),
                ),
              )),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _gonder,
                child: Container(width: 46, height: 46, decoration: const BoxDecoration(gradient: kGrad, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 20)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ============================================================
// PROFİL
// ============================================================
class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BaslikBar(baslik: 'Profilim'),
        Expanded(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: Column(children: [
              Container(width: 96, height: 96, decoration: const BoxDecoration(gradient: kGrad, shape: BoxShape.circle),
                  child: const Center(child: Text('E', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)))),
              const SizedBox(height: 12),
              const Text('Eray, 28', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kText)),
              const Text('İstanbul', style: TextStyle(color: kMuted, fontSize: 14)),
              const SizedBox(height: 14),
              ValueListenableBuilder<int>(
                valueListenable: durum.jeton,
                builder: (_, j, __) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(color: kMor.withOpacity(.1), borderRadius: BorderRadius.circular(999)),
                  child: Text('🪙 $j jeton', style: const TextStyle(color: kMor, fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ])),
            const SizedBox(height: 22),
            _menu(context, Icons.edit, 'Profili düzenle', const DuzenleSayfasi()),
            _menu(context, Icons.visibility, 'Profiline bakanlar', const BakanlarSayfasi()),
            _menu(context, Icons.monetization_on, 'Jeton al', const JetonSayfasi()),
            _menu(context, Icons.settings, 'Ayarlar', const AyarlarSayfasi()),
            _menu(context, Icons.help_outline, 'Teknik destek', const DestekSayfasi()),
            _menuCikis(context),
          ],
        )),
      ],
    );
  }

  Widget _menu(BuildContext context, IconData ikon, String metin, Widget hedef) => GestureDetector(
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => hedef)),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Row(children: [
        Icon(ikon, color: kMor, size: 22), const SizedBox(width: 14),
        Text(metin, style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
        const Spacer(), const Icon(Icons.chevron_right, color: kMuted2),
      ]),
    ),
  );

  Widget _menuCikis(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GirisEkrani()), (r) => false),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Row(children: const [
        Icon(Icons.logout, color: Color(0xFFF43F5E), size: 22), SizedBox(width: 14),
        Text('Çıkış yap', style: TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.w700, fontSize: 15)),
      ]),
    ),
  );
}

// ============================================================
// JETON AL
// ============================================================
class JetonSayfasi extends StatelessWidget {
  const JetonSayfasi({super.key});

  void _satinAl(BuildContext context, int adet, String fiyat) {
    durum.jeton.value += adet;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$adet jeton eklendi (demo — gerçek ödeme API bağlanınca aktif olacak)'),
      backgroundColor: kMor, duration: const Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    final paketler = [
      [100, '₺49,99', ''],
      [300, '₺129,99', 'En popüler'],
      [700, '₺249,99', 'En avantajlı'],
    ];
    return Scaffold(
      appBar: AppBar(backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
          title: const Text('Jeton al', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(20)),
              child: ValueListenableBuilder<int>(
                valueListenable: durum.jeton,
                builder: (_, j, __) => Row(children: [
                  const Text('🪙', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Mevcut bakiyen', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('$j jeton', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            for (final p in paketler)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: (p[2] as String).isNotEmpty ? kMor : kBorder, width: (p[2] as String).isNotEmpty ? 2 : 1)),
                child: Row(children: [
                  const Text('🪙', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${p[0]} jeton', style: const TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 17)),
                    if ((p[2] as String).isNotEmpty)
                      Text(p[2] as String, style: const TextStyle(color: kMor, fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _satinAl(context, p[0] as int, p[1] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(12)),
                      child: Text(p[1] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ),
                ]),
              ),
            const SizedBox(height: 8),
            const Text('Ödemeler Google Play üzerinden güvenle alınır.',
                textAlign: TextAlign.center, style: TextStyle(color: kMuted2, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BASİT ALT SAYFALAR
// ============================================================
class BakanlarSayfasi extends StatelessWidget {
  const BakanlarSayfasi({super.key});
  @override
  Widget build(BuildContext context) => _basitSayfa('Profiline bakanlar', Icons.visibility,
      'Son 7 günde profiline 34 kişi baktı.\nTamamını görmek için premium gerekli.');
}

class DuzenleSayfasi extends StatelessWidget {
  const DuzenleSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
          title: const Text('Profili düzenle', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: const [
        _DuzenleAlan(etiket: 'Ad', deger: 'Eray'),
        _DuzenleAlan(etiket: 'Yaş', deger: '28'),
        _DuzenleAlan(etiket: 'Şehir', deger: 'İstanbul'),
        _DuzenleAlan(etiket: 'Hakkımda', deger: 'Kahve, müzik ve iyi sohbet.'),
      ])),
    );
  }
}

class AyarlarSayfasi extends StatelessWidget {
  const AyarlarSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    final ogeler = ['Bildirimler', 'Gizlilik', 'Konum', 'Hesap', 'Gizlilik sözleşmesi', 'Kullanım koşulları'];
    return Scaffold(
      appBar: AppBar(backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
          title: const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        for (final o in ogeler)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
            child: Row(children: [
              Text(o, style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(), const Icon(Icons.chevron_right, color: kMuted2),
            ]),
          ),
      ])),
    );
  }
}

class DestekSayfasi extends StatelessWidget {
  const DestekSayfasi({super.key});
  @override
  Widget build(BuildContext context) => _basitSayfa('Teknik destek', Icons.help_outline,
      'Sorularını destek@buluvo.com adresine iletebilirsin.\nGenelde 24 saat içinde dönüş yapıyoruz.');
}

Widget _basitSayfa(String baslik, IconData ikon, String metin) {
  return Scaffold(
    appBar: AppBar(backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
        title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.w800))),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72, decoration: BoxDecoration(color: kMor.withOpacity(.1), shape: BoxShape.circle),
                child: Icon(ikon, color: kMor, size: 34)),
            const SizedBox(height: 18),
            Text(metin, textAlign: TextAlign.center, style: const TextStyle(color: kMuted, fontSize: 15, height: 1.5)),
          ]),
        ),
      ),
    ),
  );
}

class _DuzenleAlan extends StatelessWidget {
  final String etiket, deger;
  const _DuzenleAlan({required this.etiket, required this.deger});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(etiket, style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
        child: TextField(
          controller: TextEditingController(text: deger),
          style: const TextStyle(color: kText, fontSize: 15),
          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
        ),
      ),
    ]),
  );
}

// ============================================================
// ORTAK WIDGET'LAR
// ============================================================
class _BaslikBar extends StatelessWidget {
  final String baslik;
  final bool jetonGoster;
  const _BaslikBar({required this.baslik, this.jetonGoster = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 16, 12),
      child: Row(children: [
        ShaderMask(shaderCallback: (r) => kGrad.createShader(r),
            child: Text(baslik, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))),
        const Spacer(),
        if (jetonGoster)
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JetonSayfasi())),
            child: ValueListenableBuilder<int>(
              valueListenable: durum.jeton,
              builder: (_, j, __) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: kMor, borderRadius: BorderRadius.circular(999)),
                child: Text('🪙 $j', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Harf extends StatelessWidget {
  final String harf;
  final double boyut;
  final List<Color>? renk;
  const _Harf({required this.harf, this.boyut = 52, this.renk});
  @override
  Widget build(BuildContext context) => Container(
    width: boyut, height: boyut,
    decoration: BoxDecoration(
      gradient: renk != null ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: renk!) : kGrad,
      shape: BoxShape.circle,
    ),
    child: Center(child: Text(harf, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: boyut * .42))),
  );
}

class _Balon extends StatelessWidget {
  final String metin;
  final bool benim;
  const _Balon({required this.metin, required this.benim});
  @override
  Widget build(BuildContext context) => Align(
    alignment: benim ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .72),
      decoration: BoxDecoration(
        gradient: benim ? kGrad : null,
        color: benim ? null : kPanel,
        border: benim ? null : Border.all(color: kBorder),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(benim ? 18 : 4), bottomRight: Radius.circular(benim ? 4 : 18),
        ),
      ),
      child: Text(metin, style: TextStyle(color: benim ? Colors.white : kText, fontSize: 15)),
    ),
  );
}

class _Rozet extends StatelessWidget {
  final Widget cocuk;
  const _Rozet({required this.cocuk});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.5), borderRadius: BorderRadius.circular(10)),
    child: cocuk,
  );
}

class _Cip extends StatelessWidget {
  final String t;
  const _Cip({required this.t});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.4), borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.4))),
    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
  );
}

class _Nokta extends StatelessWidget {
  final bool aktif;
  const _Nokta({this.aktif = false});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(height: 3, decoration: BoxDecoration(
        color: aktif ? Colors.white : Colors.white.withOpacity(.4), borderRadius: BorderRadius.circular(9))),
  );
}

class _Aksiyon extends StatelessWidget {
  final IconData ikon;
  final Color? renk;
  final bool buyuk, gradient;
  final VoidCallback? onTap;
  const _Aksiyon({required this.ikon, this.renk, this.buyuk = false, this.gradient = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    final boyut = gradient ? 64.0 : (buyuk ? 60.0 : 50.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: boyut, height: boyut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient ? kGrad : null,
          color: gradient ? null : kPanel,
          border: gradient ? null : Border.all(color: kBorder),
          boxShadow: gradient ? [BoxShadow(color: kPembe.withOpacity(.5), blurRadius: 20, offset: const Offset(0, 8))] : null,
        ),
        child: Icon(ikon, color: gradient ? Colors.white : renk, size: gradient ? 30 : 26),
      ),
    );
  }
}

class _Avatars extends StatelessWidget {
  const _Avatars();
  @override
  Widget build(BuildContext context) {
    final harfler = ['E', 'D', 'S', '+'];
    return SizedBox(width: 112, height: 34, child: Stack(children: [
      for (int i = 0; i < harfler.length; i++)
        Positioned(left: i * 26.0, child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          child: Center(child: Text(harfler[i], style: const TextStyle(color: kMor, fontWeight: FontWeight.w900, fontSize: 15))),
        )),
    ]));
  }
}

class _Adim extends StatelessWidget {
  final String no, t;
  const _Adim({required this.no, required this.t});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(.3))),
    child: Column(children: [
      Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(child: Text(no, style: const TextStyle(color: Color(0xFFA21CAF), fontWeight: FontWeight.w900, fontSize: 13)))),
      const SizedBox(height: 5),
      Text(t, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  ));
}

class _BeyazButon extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;
  const _BeyazButon({required this.icon, required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDADCE0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        icon, const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Color(0xFF1F1F1F), fontSize: 15, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

class _Alan extends StatelessWidget {
  final String hint;
  final bool obscure;
  const _Alan({required this.hint, this.obscure = false});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
    child: TextField(
      obscureText: obscure,
      style: const TextStyle(color: kText, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: kMuted2),
        border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    ),
  );
}
