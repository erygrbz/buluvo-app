import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final p = await SharedPreferences.getInstance();
    karanlik.value = p.getBool('blv_dark') ?? false;
  } catch (e) {}
  runApp(BuluvoApp());
}

Future<void> temaDegistir(bool k) async {
  karanlik.value = k;
  try { final p = await SharedPreferences.getInstance(); await p.setBool('blv_dark', k); } catch (e) {}
}

// ============================================================
// SADE AURORA RENK PALETİ
// ============================================================
Color kBg = Color(0xFFF7F5FC);
Color kPanel = Color(0xFFFFFFFF);
Color kPanel2 = Color(0xFFFAF8FE);
Color kBorder = Color(0xFFECE6F7);
Color kText = Color(0xFF1C1A2B);
Color kMuted = Color(0xFF716D87);
Color kMuted2 = Color(0xFF938FB0);
final kMor = Color(0xFF9333EA);
final kPembe = Color(0xFFEC4899);
final kGrad = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kMor, kPembe]);

// ===== Dark / Açık mod =====
final karanlik = ValueNotifier<bool>(false);
void temaUygula(bool k) {
  if (k) {
    kBg = const Color(0xFF0E0D16);
    kPanel = const Color(0xFF191726);
    kPanel2 = const Color(0xFF221F33);
    kBorder = const Color(0xFF2E2A42);
    kText = const Color(0xFFECEAF6);
    kMuted = const Color(0xFFA7A3C0);
    kMuted2 = const Color(0xFF746F93);
  } else {
    kBg = const Color(0xFFF7F5FC);
    kPanel = const Color(0xFFFFFFFF);
    kPanel2 = const Color(0xFFFAF8FE);
    kBorder = const Color(0xFFECE6F7);
    kText = const Color(0xFF1C1A2B);
    kMuted = const Color(0xFF716D87);
    kMuted2 = const Color(0xFF938FB0);
  }
}

// Metin kısayollarını emojiye çevirir ( :) -> 🙂 )
String emojile(String s) {
  final harita = {
    ':-)': '🙂', ':)': '🙂', '(:': '🙂',
    ':-D': '😄', ':D': '😄',
    ':-(': '🙁', ':(': '🙁',
    ';-)': '😉', ';)': '😉',
    ':-P': '😛', ':P': '😛', ':p': '😛',
    ':-O': '😮', ':O': '😮', ':o': '😮',
    ':-*': '😘', ':*': '😘',
    "</3": '💔', '<3': '❤️',
    ':|': '😐', ":'(": '😢',
    'xD': '😆', 'XD': '😆',
    'B)': '😎', ':3': '😊', 'o/': '👋',
  };
  var out = s;
  harita.forEach((k, v) => out = out.replaceAll(k, v));
  return out;
}

// ============================================================
// SUNUCU / API
//   Gerçek giriş: /_api/token-al (mevcut giriş sayfası, Google+şifre)
//   token -> sessions -> her istekte Authorization: Bearer
// ============================================================
class Api {
  static final kBase = "https://buluvo.com";
  static final _anahtar = "blv_token";

  static Future<String?> token() async {
    try { final p = await SharedPreferences.getInstance(); return p.getString(_anahtar); } catch (e) { return null; }
  }

  static Future<void> tokenKaydet(String t) async {
    try { final p = await SharedPreferences.getInstance(); await p.setString(_anahtar, t); } catch (e) {}
  }

  static Future<void> tokenSil() async {
    try { final p = await SharedPreferences.getInstance(); await p.remove(_anahtar); } catch (e) {}
  }

  /// /_api/ozet -> durum'u gerçek veriyle doldurur. Başarılıysa true.
  static Future<bool> ozetYukle() async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return false;
      final r = await http
          .get(Uri.parse("$kBase/_api/ozet"), headers: {"Authorization": "Bearer $t", "accept": "application/json"})
          .timeout(Duration(seconds: 12));
      if (r.statusCode != 200) return false;
      final j = jsonDecode(r.body);
      if (j is Map && j["ok"] == true) {
        if (j["jeton"] != null) durum.jeton.value = (j["jeton"] as num).toInt();
        if (j["ad"] is String && (j["ad"] as String).trim().isNotEmpty) durum.ad.value = j["ad"];
        if (j["harf"] is String && (j["harf"] as String).trim().isNotEmpty) durum.harf.value = j["harf"];
        if (j["begenenSayisi"] != null) durum.begenenSayisi.value = (j["begenenSayisi"] as num).toInt();
        if (j["begenenlerAcik"] == true) durum.begenenlerAcik.value = true;
        durum.gercek.value = true;
        return true;
      }
      return false;
    } catch (e) { return false; }
  }

  /// /_api/kesfet -> gerçek üye listesi. Boş/başarısızsa null (demo'ya düşülür).
  static Future<List<Kisi>?> kesfetYukle() async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return null;
      final r = await http
          .get(Uri.parse("$kBase/_api/kesfet"), headers: {"Authorization": "Bearer $t", "accept": "application/json"})
          .timeout(Duration(seconds: 12));
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body);
      if (j is Map && j["ok"] == true && j["liste"] is List) {
        final gradlar = [
          [Color(0xFFF0ABFC), Color(0xFFA855F7)],
          [Color(0xFFFDA4AF), Color(0xFFFB7185)],
          [Color(0xFF6EE7B7), Color(0xFF10B981)],
          [Color(0xFFFCD34D), Color(0xFFF59E0B)],
          [Color(0xFF93C5FD), Color(0xFF6366F1)],
        ];
        final List<Kisi> out = [];
        int i = 0;
        for (final e in (j["liste"] as List)) {
          if (e is! Map) continue;
          final ad = (e["ad"] ?? "").toString();
          final sehir = (e["sehir"] ?? "").toString();
          final foto = e["foto"] == null ? null : "$kBase${e["foto"]}";
          out.add(Kisi(ad, 0, sehir, '', 0, false, [], gradlar[i % gradlar.length], foto: foto, uid: e["id"]?.toString()));
          i++;
        }
        return out.isEmpty ? null : out;
      }
      return null;
    } catch (e) { return null; }
  }

  /// /_api/begenenler -> {acik, sayi, jeton, liste:[{ad,foto}]} veya null
  static Future<Map?> begenenlerYukle() async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return null;
      final r = await http
          .get(Uri.parse("$kBase/_api/begenenler"), headers: {"Authorization": "Bearer $t", "accept": "application/json"})
          .timeout(Duration(seconds: 12));
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body);
      if (j is Map && j["ok"] == true) return j;
      return null;
    } catch (e) { return null; }
  }

  /// /_api/begenenler-ac -> {ok, acik, jeton} / {ok:false, hata:'yetersiz'} veya null
  static Future<Map?> begenenlerAc() async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return null;
      final r = await http
          .post(Uri.parse("$kBase/_api/begenenler-ac"), headers: {"Authorization": "Bearer $t", "accept": "application/json"})
          .timeout(Duration(seconds: 12));
      final j = jsonDecode(r.body);
      if (j is Map) return j;
      return null;
    } catch (e) { return null; }
  }

  /// /_api/sohbetler -> List<Sohbet> (gerçek eşleşmeler) veya null
  static Future<List<Sohbet>?> sohbetlerYukle() async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return null;
      final r = await http
          .get(Uri.parse("$kBase/_api/sohbetler"), headers: {"Authorization": "Bearer $t", "accept": "application/json"})
          .timeout(Duration(seconds: 12));
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body);
      if (j is Map && j["ok"] == true && j["liste"] is List) {
        final grad = [
          [Color(0xFFF0ABFC), Color(0xFFA855F7)],
          [Color(0xFFFDA4AF), Color(0xFFFB7185)],
          [Color(0xFF6EE7B7), Color(0xFF10B981)],
          [Color(0xFFFCD34D), Color(0xFFF59E0B)],
        ];
        final out = <Sohbet>[];
        int i = 0;
        for (final e in (j["liste"] as List)) {
          if (e is! Map) continue;
          final ad = (e["ad"] ?? "").toString();
          final harf = ad.trim().isNotEmpty ? ad.trim()[0].toUpperCase() : "?";
          final foto = e["foto"] == null ? null : "$kBase${e["foto"]}";
          final son = (e["son"] ?? "").toString();
          out.add(Sohbet(ad, harf, grad[i % grad.length], son.isEmpty ? [] : [Mesaj(son, false)],
              mid: e["mid"]?.toString(), foto: foto));
          i++;
        }
        return out;
      }
      return null;
    } catch (e) { return null; }
  }

  /// /_api/mesajlar?m=<mid> -> List<Mesaj> veya null
  static Future<List<Mesaj>?> mesajlarYukle(String mid) async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return null;
      final r = await http
          .get(Uri.parse("$kBase/_api/mesajlar?m=${Uri.encodeQueryComponent(mid)}"), headers: {"Authorization": "Bearer $t", "accept": "application/json"})
          .timeout(Duration(seconds: 12));
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body);
      if (j is Map && j["ok"] == true && j["liste"] is List) {
        return [for (final e in (j["liste"] as List)) if (e is Map) Mesaj((e["metin"] ?? "").toString(), e["benim"] == true)];
      }
      return null;
    } catch (e) { return null; }
  }

  /// /_api/swipe -> {ok, eslesme} veya null
  static Future<Map?> swipe(String target, String action) async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return null;
      final r = await http
          .post(Uri.parse("$kBase/_api/swipe"),
              headers: {"Authorization": "Bearer $t", "content-type": "application/json"},
              body: jsonEncode({"target": target, "action": action}))
          .timeout(Duration(seconds: 12));
      final j = jsonDecode(r.body);
      if (j is Map) return j;
      return null;
    } catch (e) { return null; }
  }

  /// /_api/profil -> {ad,yas,sehir,bio,gender,foto,jeton,premium} veya null
  static Future<Map?> profilYukle() async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return null;
      final r = await http
          .get(Uri.parse("$kBase/_api/profil"), headers: {"Authorization": "Bearer $t", "accept": "application/json"})
          .timeout(Duration(seconds: 12));
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body);
      if (j is Map && j["ok"] == true) return j;
      return null;
    } catch (e) { return null; }
  }

  /// /_api/profil-guncelle -> true/false
  static Future<bool> profilGuncelle({String? ad, String? bio, String? sehir}) async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return false;
      final r = await http
          .post(Uri.parse("$kBase/_api/profil-guncelle"),
              headers: {"Authorization": "Bearer $t", "content-type": "application/json"},
              body: jsonEncode({if (ad != null) "ad": ad, if (bio != null) "bio": bio, if (sehir != null) "sehir": sehir}))
          .timeout(Duration(seconds: 12));
      final j = jsonDecode(r.body);
      return j is Map && j["ok"] == true;
    } catch (e) { return false; }
  }

  /// /_api/mesaj-gonder -> true/false
  static Future<bool> mesajGonder(String mid, String metin) async {
    try {
      final t = await token();
      if (t == null || t.isEmpty) return false;
      final r = await http
          .post(Uri.parse("$kBase/_api/mesaj-gonder"),
              headers: {"Authorization": "Bearer $t", "content-type": "application/json"},
              body: jsonEncode({"m": mid, "metin": metin}))
          .timeout(Duration(seconds: 12));
      final j = jsonDecode(r.body);
      return j is Map && j["ok"] == true;
    } catch (e) { return false; }
  }

  static Future<void> cikis() async {
    try {
      final t = await token();
      if (t != null) {
        await http
            .post(Uri.parse("$kBase/_api/cikis"), headers: {"Authorization": "Bearer $t"})
            .timeout(Duration(seconds: 8));
      }
    } catch (e) {}
    await tokenSil();
  }
}

// ============================================================
// UYGULAMA DURUMU (bellek içi; API bağlanınca gerçek veriyle dolar)
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
  final String? foto;
  final String? uid;
  Kisi(this.ad, this.yas, this.sehir, this.mesafe, this.uyum, this.cevrimici, this.ilgi, this.renk, {this.foto, this.uid});
}

class Mesaj {
  final String metin;
  final bool benim;
  Mesaj(this.metin, this.benim);
}

class Sohbet {
  final String ad;
  final String harf;
  final List<Color> renk;
  final String? mid;
  final String? foto;
  final ValueNotifier<List<Mesaj>> mesajlar;
  Sohbet(this.ad, this.harf, this.renk, List<Mesaj> ilk, {this.mid, this.foto}) : mesajlar = ValueNotifier<List<Mesaj>>(ilk);
}

class Durum {
  final jeton = ValueNotifier<int>(120);
  final ad = ValueNotifier<String>("Eray");
  final harf = ValueNotifier<String>("E");
  final begenenSayisi = ValueNotifier<int>(12);
  final begenenlerAcik = ValueNotifier<bool>(false);
  final gercek = ValueNotifier<bool>(false); // gerçek veriye bağlı mı

  final deste = <Kisi>[
    Kisi('Elif', 24, 'İzmir', '3 km uzakta', 92, true, ['🎵 Müzik', '✈️ Seyahat', '☕ Kahve'], [Color(0xFFF0ABFC), Color(0xFFA855F7)]),
    Kisi('Deniz', 27, 'İstanbul', '8 km uzakta', 88, false, ['📚 Kitap', '🎬 Sinema', '🏃 Spor'], [Color(0xFFFDA4AF), Color(0xFFFB7185)]),
    Kisi('Selin', 25, 'Ankara', '12 km uzakta', 85, true, ['🎨 Sanat', '🐶 Hayvanlar', '🍳 Yemek'], [Color(0xFF6EE7B7), Color(0xFF10B981)]),
    Kisi('Zeynep', 23, 'Bursa', '5 km uzakta', 90, true, ['📷 Fotoğraf', '🌱 Doğa', '🎮 Oyun'], [Color(0xFFFCD34D), Color(0xFFF59E0B)]),
    Kisi('Ece', 26, 'Antalya', '2 km uzakta', 87, false, ['💃 Dans', '🏖️ Deniz', '🎧 Podcast'], [Color(0xFF93C5FD), Color(0xFF6366F1)]),
  ];

  late final List<Sohbet> sohbetler = [
    Sohbet('Elif', 'E', [Color(0xFFF0ABFC), Color(0xFFA855F7)], [
      Mesaj('Selam! Profilin çok ilgimi çekti 😊', false),
      Mesaj('Teşekkürler! Sen de kahve sever misin?', true),
      Mesaj('Bayılırım ☕ Hafta sonu bir yere gidelim mi?', false),
    ]),
    Sohbet('Deniz', 'D', [Color(0xFFFDA4AF), Color(0xFFFB7185)], [
      Mesaj('Merhaba 👋', false),
      Mesaj('Teşekkürler 😊', true),
    ]),
    Sohbet('Selin', 'S', [Color(0xFF6EE7B7), Color(0xFF10B981)], [
      Mesaj('Sana bir fotoğraf gönderdim', false),
    ]),
    Sohbet('Zeynep', 'Z', [Color(0xFFFCD34D), Color(0xFFF59E0B)], [
      Mesaj('Merhaba! Nasılsın?', false),
    ]),
  ];
}

final durum = Durum();

// ============================================================
// KÖK
// ============================================================
class BuluvoApp extends StatelessWidget {
  BuluvoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: karanlik,
      builder: (context, k, _) {
        temaUygula(k);
        return MaterialApp(
          title: 'Buluvo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: kBg,
            colorScheme: ColorScheme.fromSeed(seedColor: kMor, brightness: k ? Brightness.dark : Brightness.light),
            fontFamily: 'Roboto',
            useMaterial3: true,
          ),
          home: Baslangic(),
        );
      },
    );
  }
}

// Açılışta token varsa doğrudan ana ekrana, yoksa girişe.
class Baslangic extends StatefulWidget {
  Baslangic({super.key});
  @override
  State<Baslangic> createState() => _BaslangicState();
}

class _BaslangicState extends State<Baslangic> {
  @override
  void initState() {
    super.initState();
    _kontrol();
  }

  Future<void> _kontrol() async {
    final t = await Api.token();
    if (!mounted) return;
    if (t != null && t.isNotEmpty) {
      Api.ozetYukle();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AnaKabuk()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GirisEkrani()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator(color: kMor)),
    );
  }
}

// ============================================================
// GİRİŞ EKRANI
// ============================================================
class GirisEkrani extends StatelessWidget {
  GirisEkrani({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 92, height: 92,
                    decoration: BoxDecoration(
                      gradient: kGrad, borderRadius: BorderRadius.circular(26),
                      boxShadow: [BoxShadow(color: kPembe.withOpacity(.45), blurRadius: 34, offset: Offset(0, 16))],
                    ),
                    child: Icon(Icons.favorite, color: Colors.white, size: 44),
                  ),
                  SizedBox(height: 18),
                  ShaderMask(
                    shaderCallback: (r) => kGrad.createShader(r),
                    child: Text('Buluvo',
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                  ),
                  SizedBox(height: 8),
                  Text('Google veya e-posta ile güvenli giriş', style: TextStyle(fontSize: 15, color: kMuted, fontWeight: FontWeight.w600)),
                  SizedBox(height: 26),
                  Container(
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: kGrad, borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: kPembe.withOpacity(.35), blurRadius: 28, offset: Offset(0, 14))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _Avatars(),
                          SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('50.000 kişi tanıştı', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                            SizedBox(height: 2),
                            Text('Sen de aramıza katıl.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ])),
                        ]),
                        SizedBox(height: 14),
                        Row(children: [
                          _Adim(no: '1', t: 'Kaydol'), SizedBox(width: 10),
                          _Adim(no: '2', t: 'Profil'), SizedBox(width: 10),
                          _Adim(no: '3', t: 'Eşleş'),
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(height: 22),
                  _BeyazButon(
                    icon: Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
                    text: 'Google ile devam et', onTap: () => _gir(context),
                  ),
                  SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _gir(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Text('E-posta ile giriş yap',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
                    ),
                  ),
                  SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AnaKabuk())),
                    child: Text('Demo olarak gez →', style: TextStyle(fontSize: 14, color: kMuted2, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: 14),
                  Text('Buluvo · Native Android (Flutter)', style: TextStyle(fontSize: 12, color: kMuted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _gir(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => WebGiris()));
  }
}

// ============================================================
// WEBVIEW GİRİŞ — mevcut gerçek giriş sayfası, token yakalar
// ============================================================
class WebGiris extends StatefulWidget {
  WebGiris({super.key});
  @override
  State<WebGiris> createState() => _WebGirisState();
}

class _WebGirisState extends State<WebGiris> {
  late final WebViewController _c;
  bool _bitti = false;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) { if (mounted) setState(() => _yukleniyor = false); },
        onNavigationRequest: (req) {
          if (req.url.startsWith("buluvo://")) {
            final uri = Uri.tryParse(req.url);
            final tok = uri?.queryParameters["token"];
            if (tok != null && tok.isNotEmpty && !_bitti) {
              _bitti = true;
              _tamamla(tok);
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse("${Api.kBase}/_api/token-al"));
  }

  Future<void> _tamamla(String tok) async {
    await Api.tokenKaydet(tok);
    await Api.ozetYukle();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => AnaKabuk()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
        title: Text('Giriş', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Stack(children: [
          WebViewWidget(controller: _c),
          if (_yukleniyor) Center(child: CircularProgressIndicator(color: kMor)),
        ]),
      ),
    );
  }
}

// ============================================================
// ANA KABUK (alt menü)
// ============================================================
class AnaKabuk extends StatefulWidget {
  AnaKabuk({super.key});
  @override
  State<AnaKabuk> createState() => _AnaKabukState();
}

class _AnaKabukState extends State<AnaKabuk> {
  int _i = 0;
  final _sayfalar = [KesfetSayfasi(), BegenenlerSayfasi(), SohbetSayfasi(), ProfilSayfasi()];

  @override
  void initState() {
    super.initState();
    Api.ozetYukle(); // gerçek veri varsa tazele
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _i, children: _sayfalar)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: kPanel, border: Border(top: BorderSide(color: kBorder))),
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
            SizedBox(height: 3),
            Text(etiket, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: aktif ? kMor : kMuted2)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// KEŞFET (kart destesi + kaydırma)
// ============================================================
class KesfetSayfasi extends StatefulWidget {
  KesfetSayfasi({super.key});
  @override
  State<KesfetSayfasi> createState() => _KesfetSayfasiState();
}

class _KesfetSayfasiState extends State<KesfetSayfasi> {
  int _idx = 0;
  List<Kisi> _liste = durum.deste;

  @override
  void initState() {
    super.initState();
    Api.kesfetYukle().then((g) {
      if (g != null && g.isNotEmpty && mounted) setState(() { _liste = g; _idx = 0; });
    });
  }

  void _sonraki(bool begendi, Kisi k) {
    final hedef = k.uid;
    if (hedef != null) {
      // gerçek üye: sunucuya kaydet; sadece gerçek karşılıklı beğenide eşleşme göster
      Api.swipe(hedef, begendi ? 'like' : 'pass').then((j) {
        if (j != null && j["eslesme"] == true && mounted) _eslesme(k);
      });
    } else if (begendi && _idx.isEven) {
      _eslesme(k); // demo davranışı
    }
    setState(() => _idx = (_idx + 1) % _liste.length);
  }

  void _eslesme(Kisi k) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(26)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('🎉', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text('Eşleştiniz!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
            SizedBox(height: 6),
            Text('${k.ad} de seni beğendi', style: TextStyle(color: Colors.white70, fontSize: 15)),
            SizedBox(height: 18),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Text('Mesaj gönder', style: TextStyle(color: Color(0xFFA21CAF), fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = _liste[_idx];
    return Column(
      children: [
        _BaslikBar(baslik: 'Buluvo', jetonGoster: true),
        Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
          child: Row(children: [
            Icon(Icons.place_outlined, size: 18, color: kMuted),
            SizedBox(width: 8),
            Text('Yakınlarda · 25 km', style: TextStyle(color: kMuted, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(fit: StackFit.expand, children: [
                Container(decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: k.renk))),
                if (k.foto != null)
                  Image.network(k.foto!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => SizedBox.shrink(),
                      loadingBuilder: (c, w, p) => p == null ? w : SizedBox.shrink()),
                Positioned(left: 12, right: 12, top: 12, child: Row(children: [
                  for (int i = 0; i < _liste.length && i < 8; i++) ...[
                    _Nokta(aktif: i == _idx),
                    if (i < _liste.length - 1 && i < 7) SizedBox(width: 6),
                  ],
                ])),
                Container(decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC14052A)]))),
                Positioned(left: 20, right: 20, bottom: 24, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (k.cevrimici || k.uyum > 0)
                      Row(children: [
                        if (k.cevrimici)
                          _Rozet(cocuk: Text('● Çevrimiçi', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                        if (k.cevrimici && k.uyum > 0) SizedBox(width: 8),
                        if (k.uyum > 0)
                          _Rozet(cocuk: Text('%${k.uyum} uyum', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                      ]),
                    if (k.cevrimici || k.uyum > 0) SizedBox(height: 10),
                    Text(k.yas > 0 ? '${k.ad}, ${k.yas}' : k.ad, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text(k.mesafe.isNotEmpty ? '${k.sehir} · ${k.mesafe}' : k.sehir, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    if (k.ilgi.isNotEmpty) SizedBox(height: 12),
                    if (k.ilgi.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: [for (final i in k.ilgi) _Cip(t: i)]),
                  ],
                )),
              ]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _Aksiyon(ikon: Icons.close, renk: Color(0xFFF43F5E), buyuk: true, onTap: () => _sonraki(false, k)),
            SizedBox(width: 22),
            _Aksiyon(ikon: Icons.star, renk: Color(0xFF0EA5E9), onTap: () => _sonraki(true, k)),
            SizedBox(width: 22),
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
class BegenenlerSayfasi extends StatefulWidget {
  BegenenlerSayfasi({super.key});
  @override
  State<BegenenlerSayfasi> createState() => _BegenenlerSayfasiState();
}

class _BegenenlerSayfasiState extends State<BegenenlerSayfasi> {
  static final _renkler = [
    [Color(0xFFF0ABFC), Color(0xFFA855F7)],
    [Color(0xFFFDA4AF), Color(0xFFFB7185)],
    [Color(0xFF6EE7B7), Color(0xFF10B981)],
    [Color(0xFFFCD34D), Color(0xFFF59E0B)],
  ];
  bool _yuklendi = false;
  bool _acik = false;
  int _sayi = 0;
  List<Map> _liste = [];
  bool _aciliyor = false;

  @override
  void initState() {
    super.initState();
    _acik = durum.begenenlerAcik.value;
    _sayi = durum.begenenSayisi.value;
    _tazele();
  }

  Future<void> _tazele() async {
    final j = await Api.begenenlerYukle();
    if (j == null || !mounted) return;
    setState(() {
      _yuklendi = true;
      _acik = j["acik"] == true;
      if (j["sayi"] != null) _sayi = (j["sayi"] as num).toInt();
      _liste = (j["liste"] is List) ? List<Map>.from((j["liste"] as List).whereType<Map>()) : [];
    });
    if (j["jeton"] != null) durum.jeton.value = (j["jeton"] as num).toInt();
    durum.begenenSayisi.value = _sayi;
    durum.begenenlerAcik.value = _acik;
  }

  Future<void> _ac() async {
    if (_aciliyor) return;
    setState(() => _aciliyor = true);
    final j = await Api.begenenlerAc();
    if (!mounted) return;
    setState(() => _aciliyor = false);
    if (j == null) {
      // backend yoksa yerel demo davranışı
      if (durum.jeton.value < 100) { _jetonYonlendir(); return; }
      durum.jeton.value -= 100;
      setState(() => _acik = true);
      durum.begenenlerAcik.value = true;
      return;
    }
    if (j["ok"] == true && j["acik"] == true) {
      if (j["jeton"] != null) durum.jeton.value = (j["jeton"] as num).toInt();
      durum.begenenlerAcik.value = true;
      await _tazele();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Beğenenler açıldı 🎉'), backgroundColor: kMor));
      return;
    }
    if (j["hata"] == "yetersiz") { _jetonYonlendir(); return; }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Açılamadı, tekrar dene'), backgroundColor: kMor));
  }

  void _jetonYonlendir() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yetersiz jeton — Jeton al sayfasından yükle'), backgroundColor: kMor));
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => JetonSayfasi()));
  }

  @override
  Widget build(BuildContext context) {
    // Izgara için öğe sayısı: açık+gerçek liste varsa onun kadar, yoksa 4 (demo/buğulu)
    final int adet = (_acik && _yuklendi) ? (_liste.isEmpty ? 0 : _liste.length) : 4;
    return Column(
      children: [
        _BaslikBar(baslik: 'Beğenenler'),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              if (!_acik)
                Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: kPembe.withOpacity(.4), blurRadius: 24, offset: Offset(0, 12))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Seni $_sayi kişi beğendi ❤', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6),
                    Text('Hepsini net görmek için aç.', style: TextStyle(color: Colors.white, fontSize: 13)),
                    SizedBox(height: 14),
                    GestureDetector(
                      onTap: _aciliyor ? null : _ac,
                      child: Container(
                        width: double.infinity, padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
                        child: Center(child: Text(_aciliyor ? 'Açılıyor…' : '🔒 100 jeton ile hepsini aç',
                            style: TextStyle(color: Color(0xFFA21CAF), fontWeight: FontWeight.w900, fontSize: 15))),
                      ),
                    ),
                  ]),
                ),
              if (_acik)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
                  child: Row(children: [
                    Icon(Icons.lock_open, color: kMor),
                    SizedBox(width: 10),
                    Expanded(child: Text('Kilit açık — seni beğenenleri görüyorsun', style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 14))),
                  ]),
                ),
              SizedBox(height: 16),
              if (_acik && _yuklendi && _liste.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text('Henüz seni beğenen olmadı.', style: TextStyle(color: kMuted, fontSize: 15))),
                )
              else
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: .75,
                  children: [
                    for (int i = 0; i < adet; i++)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(fit: StackFit.expand, children: [
                          Container(decoration: BoxDecoration(gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _renkler[i % _renkler.length]))),
                          if (_acik && _yuklendi && _liste[i]["foto"] != null)
                            Image.network("${Api.kBase}${_liste[i]["foto"]}", fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => SizedBox.shrink(),
                                loadingBuilder: (c, w, p) => p == null ? w : SizedBox.shrink()),
                          if (_acik && _yuklendi)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(gradient: LinearGradient(
                                  begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x99000000)])),
                              child: Text((_liste[i]["ad"] ?? "").toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                            )
                          else
                            Container(color: kMor.withOpacity(.14), child: Column(
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
      ],
    );
  }
}

// ============================================================
// SOHBET (liste)
// ============================================================
class SohbetSayfasi extends StatefulWidget {
  SohbetSayfasi({super.key});
  @override
  State<SohbetSayfasi> createState() => _SohbetSayfasiState();
}

class _SohbetSayfasiState extends State<SohbetSayfasi> {
  List<Sohbet> _liste = durum.sohbetler;
  bool _yuklendi = false;

  @override
  void initState() {
    super.initState();
    Api.sohbetlerYukle().then((g) {
      if (g != null && mounted) setState(() { _liste = g; _yuklendi = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BaslikBar(baslik: 'Sohbet'),
        Expanded(
          child: (_yuklendi && _liste.isEmpty)
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text('Henüz eşleşmen yok.\nKeşfet’ten beğenmeye başla 💜',
                        textAlign: TextAlign.center, style: TextStyle(color: kMuted, fontSize: 15, height: 1.5)),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _liste.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final s = _liste[i];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SohbetDetay(sohbet: s))),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
                        child: Row(children: [
                          _SohbetAvatar(s: s),
                          SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.ad, style: TextStyle(fontWeight: FontWeight.w800, color: kText, fontSize: 15)),
                            SizedBox(height: 3),
                            ValueListenableBuilder<List<Mesaj>>(
                              valueListenable: s.mesajlar,
                              builder: (_, m, __) => Text(m.isEmpty ? '' : m.last.metin,
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: kMuted, fontSize: 13)),
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

class _SohbetAvatar extends StatelessWidget {
  final Sohbet s;
  _SohbetAvatar({required this.s});
  @override
  Widget build(BuildContext context) {
    if (s.foto != null) {
      return ClipOval(
        child: SizedBox(
          width: 52, height: 52,
          child: Image.network(s.foto!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Harf(harf: s.harf, renk: s.renk)),
        ),
      );
    }
    return _Harf(harf: s.harf, renk: s.renk);
  }
}

class SohbetDetay extends StatefulWidget {
  final Sohbet sohbet;
  SohbetDetay({super.key, required this.sohbet});
  @override
  State<SohbetDetay> createState() => _SohbetDetayState();
}

class _SohbetDetayState extends State<SohbetDetay> {
  final _kontrol = TextEditingController();
  final _kaydir = ScrollController();

  @override
  void initState() {
    super.initState();
    final mid = widget.sohbet.mid;
    if (mid != null) {
      Api.mesajlarYukle(mid).then((m) {
        if (m != null && mounted) {
          widget.sohbet.mesajlar.value = m;
          _enAlta();
        }
      });
    }
  }

  void _enAlta() {
    Future.delayed(Duration(milliseconds: 80), () {
      if (_kaydir.hasClients) _kaydir.animateTo(_kaydir.position.maxScrollExtent, duration: Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  void _gonder() {
    final t = emojile(_kontrol.text.trim());
    if (t.isEmpty) return;
    final liste = List<Mesaj>.from(widget.sohbet.mesajlar.value)..add(Mesaj(t, true));
    widget.sohbet.mesajlar.value = liste;
    _kontrol.clear();
    final mid = widget.sohbet.mid;
    if (mid != null) Api.mesajGonder(mid, t); // gerçek gönder (arka planda)
    _enAlta();
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
          SizedBox(width: 10),
          Text(widget.sohbet.ad, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        ]),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ValueListenableBuilder<List<Mesaj>>(
              valueListenable: widget.sohbet.mesajlar,
              builder: (_, mesajlar, __) => ListView(
                controller: _kaydir,
                padding: EdgeInsets.all(16),
                children: [for (final m in mesajlar) _Balon(metin: m.metin, benim: m.benim)],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            color: kPanel,
            child: Row(children: [
              Expanded(child: Container(
                decoration: BoxDecoration(color: kPanel2, borderRadius: BorderRadius.circular(999), border: Border.all(color: kBorder)),
                child: TextField(
                  controller: _kontrol,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _gonder(),
                  style: TextStyle(color: kText, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Mesaj yaz…', hintStyle: TextStyle(color: kMuted2),
                    border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  ),
                ),
              )),
              SizedBox(width: 10),
              GestureDetector(
                onTap: _gonder,
                child: Container(width: 46, height: 46, decoration: BoxDecoration(gradient: kGrad, shape: BoxShape.circle),
                    child: Icon(Icons.send, color: Colors.white, size: 20)),
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
class ProfilSayfasi extends StatefulWidget {
  ProfilSayfasi({super.key});
  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  Map? _p;

  @override
  void initState() {
    super.initState();
    Api.profilYukle().then((j) { if (j != null && mounted) setState(() => _p = j); });
  }

  Widget _harfAvatar() => ValueListenableBuilder<String>(
    valueListenable: durum.harf,
    builder: (_, h, __) => Container(width: 96, height: 96, decoration: BoxDecoration(gradient: kGrad, shape: BoxShape.circle),
        child: Center(child: Text(h, style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)))),
  );

  @override
  Widget build(BuildContext context) {
    final foto = _p?["foto"] == null ? null : "${Api.kBase}${_p!["foto"]}";
    final yas = (_p?["yas"] is num) ? (_p!["yas"] as num).toInt() : 0;
    final sehir = (_p?["sehir"] ?? "").toString();
    return Column(
      children: [
        _BaslikBar(baslik: 'Profilim'),
        Expanded(child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Center(child: Column(children: [
              foto != null
                  ? ClipOval(child: SizedBox(width: 96, height: 96,
                      child: Image.network(foto, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _harfAvatar())))
                  : _harfAvatar(),
              SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: durum.ad,
                builder: (_, a, __) => Text(yas > 0 ? '$a, $yas' : a, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kText)),
              ),
              if (sehir.isNotEmpty) Text(sehir, style: TextStyle(color: kMuted, fontSize: 14)),
              SizedBox(height: 4),
              ValueListenableBuilder<bool>(
                valueListenable: durum.gercek,
                builder: (_, g, __) => Text(g ? 'Gerçek hesabına bağlı' : 'Demo mod', style: TextStyle(color: kMuted2, fontSize: 12)),
              ),
              SizedBox(height: 14),
              ValueListenableBuilder<int>(
                valueListenable: durum.jeton,
                builder: (_, j, __) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(color: kMor.withOpacity(.1), borderRadius: BorderRadius.circular(999)),
                  child: Text('🪙 $j jeton', style: TextStyle(color: kMor, fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ])),
            SizedBox(height: 22),
            _menu(context, Icons.edit, 'Profili düzenle', DuzenleSayfasi()),
            _menu(context, Icons.visibility, 'Profiline bakanlar', BakanlarSayfasi()),
            _menu(context, Icons.monetization_on, 'Jeton al', JetonSayfasi()),
            _menu(context, Icons.settings, 'Ayarlar', AyarlarSayfasi()),
            _menu(context, Icons.help_outline, 'Teknik destek', DestekSayfasi()),
            _menuCikis(context),
          ],
        )),
      ],
    );
  }

  Widget _menu(BuildContext context, IconData ikon, String metin, Widget hedef) => GestureDetector(
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => hedef)),
    child: Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Row(children: [
        Icon(ikon, color: kMor, size: 22), SizedBox(width: 14),
        Text(metin, style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
        Spacer(), Icon(Icons.chevron_right, color: kMuted2),
      ]),
    ),
  );

  Widget _menuCikis(BuildContext context) => GestureDetector(
    onTap: () async {
      await Api.cikis();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => GirisEkrani()), (r) => false);
    },
    child: Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Row(children: [
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
  JetonSayfasi({super.key});

  void _satinAl(BuildContext context, int adet, String fiyat) {
    durum.jeton.value += adet;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$adet jeton eklendi (demo — gerçek ödeme API bağlanınca aktif olacak)'),
      backgroundColor: kMor, duration: Duration(seconds: 3)));
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
          title: Text('Jeton al', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(20)),
              child: ValueListenableBuilder<int>(
                valueListenable: durum.jeton,
                builder: (_, j, __) => Row(children: [
                  Text('🪙', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mevcut bakiyen', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('$j jeton', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ]),
                ]),
              ),
            ),
            SizedBox(height: 20),
            for (final p in paketler)
              Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: (p[2] as String).isNotEmpty ? kMor : kBorder, width: (p[2] as String).isNotEmpty ? 2 : 1)),
                child: Row(children: [
                  Text('🪙', style: TextStyle(fontSize: 26)),
                  SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${p[0]} jeton', style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 17)),
                    if ((p[2] as String).isNotEmpty)
                      Text(p[2] as String, style: TextStyle(color: kMor, fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                  Spacer(),
                  GestureDetector(
                    onTap: () => _satinAl(context, p[0] as int, p[1] as String),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(12)),
                      child: Text(p[1] as String, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ),
                ]),
              ),
            SizedBox(height: 8),
            Text('Ödemeler Google Play üzerinden güvenle alınır.',
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
  BakanlarSayfasi({super.key});
  @override
  Widget build(BuildContext context) => _basitSayfa('Profiline bakanlar', Icons.visibility,
      'Son 7 günde profiline 34 kişi baktı.\nTamamını görmek için premium gerekli.');
}

class DuzenleSayfasi extends StatefulWidget {
  DuzenleSayfasi({super.key});
  @override
  State<DuzenleSayfasi> createState() => _DuzenleSayfasiState();
}

class _DuzenleSayfasiState extends State<DuzenleSayfasi> {
  final _ad = TextEditingController();
  final _sehir = TextEditingController();
  final _bio = TextEditingController();
  bool _yuklendi = false;
  bool _kaydediyor = false;

  @override
  void initState() {
    super.initState();
    Api.profilYukle().then((j) {
      if (j != null && mounted) {
        setState(() {
          _ad.text = (j["ad"] ?? "").toString();
          _sehir.text = (j["sehir"] ?? "").toString();
          _bio.text = (j["bio"] ?? "").toString();
          _yuklendi = true;
        });
      } else if (mounted) {
        setState(() => _yuklendi = true);
      }
    });
  }

  Future<void> _kaydet() async {
    if (_kaydediyor) return;
    setState(() => _kaydediyor = true);
    final ok = await Api.profilGuncelle(ad: _ad.text.trim(), bio: _bio.text.trim(), sehir: _sehir.text.trim());
    if (ok) { durum.ad.value = _ad.text.trim().isEmpty ? durum.ad.value : _ad.text.trim(); }
    if (!mounted) return;
    setState(() => _kaydediyor = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Profil kaydedildi ✅' : 'Kaydedilemedi, tekrar dene'), backgroundColor: kMor));
    if (ok) Navigator.of(context).pop();
  }

  @override
  void dispose() { _ad.dispose(); _sehir.dispose(); _bio.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
          title: Text('Profili düzenle', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: !_yuklendi
            ? Center(child: CircularProgressIndicator(color: kMor))
            : ListView(padding: EdgeInsets.all(16), children: [
                _DuzenleAlan(etiket: 'Ad', kontrol: _ad),
                _DuzenleAlan(etiket: 'Şehir', kontrol: _sehir),
                _DuzenleAlan(etiket: 'Hakkımda', kontrol: _bio),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _kaydediyor ? null : _kaydet,
                  child: Container(
                    width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text(_kaydediyor ? 'Kaydediliyor…' : 'Kaydet',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                  ),
                ),
              ]),
      ),
    );
  }
}

class AyarlarSayfasi extends StatelessWidget {
  AyarlarSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    final ogeler = ['Bildirimler', 'Gizlilik', 'Konum', 'Hesap', 'Gizlilik sözleşmesi', 'Kullanım koşulları'];
    return Scaffold(
      appBar: AppBar(backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
          title: Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(child: ListView(padding: EdgeInsets.all(16), children: [
        // Karanlık mod aç/kapa
        Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
          child: Row(children: [
            Icon(Icons.dark_mode, color: kMor, size: 22), SizedBox(width: 14),
            Text('Karanlık mod', style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
            Spacer(),
            ValueListenableBuilder<bool>(
              valueListenable: karanlik,
              builder: (_, k, __) => Switch(value: k, activeColor: kMor, onChanged: (v) => temaDegistir(v)),
            ),
          ]),
        ),
        for (final o in ogeler)
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
            child: Row(children: [
              Text(o, style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
              Spacer(), Icon(Icons.chevron_right, color: kMuted2),
            ]),
          ),
      ])),
    );
  }
}

class DestekSayfasi extends StatelessWidget {
  DestekSayfasi({super.key});
  @override
  Widget build(BuildContext context) => _basitSayfa('Teknik destek', Icons.help_outline,
      'Sorularını destek@buluvo.com adresine iletebilirsin.\nGenelde 24 saat içinde dönüş yapıyoruz.');
}

Widget _basitSayfa(String baslik, IconData ikon, String metin) {
  return Scaffold(
    appBar: AppBar(backgroundColor: kPanel, elevation: 0, foregroundColor: kText,
        title: Text(baslik, style: TextStyle(fontWeight: FontWeight.w800))),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72, decoration: BoxDecoration(color: kMor.withOpacity(.1), shape: BoxShape.circle),
                child: Icon(ikon, color: kMor, size: 34)),
            SizedBox(height: 18),
            Text(metin, textAlign: TextAlign.center, style: TextStyle(color: kMuted, fontSize: 15, height: 1.5)),
          ]),
        ),
      ),
    ),
  );
}

class _DuzenleAlan extends StatelessWidget {
  final String etiket;
  final TextEditingController kontrol;
  _DuzenleAlan({required this.etiket, required this.kontrol});
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(etiket, style: TextStyle(color: kMuted, fontWeight: FontWeight.w700, fontSize: 13)),
      SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
        child: TextField(
          controller: kontrol,
          maxLines: etiket == 'Hakkımda' ? 3 : 1,
          style: TextStyle(color: kText, fontSize: 15),
          decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
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
  _BaslikBar({required this.baslik, this.jetonGoster = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 12, 16, 12),
      child: Row(children: [
        ShaderMask(shaderCallback: (r) => kGrad.createShader(r),
            child: Text(baslik, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))),
        Spacer(),
        if (jetonGoster)
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JetonSayfasi())),
            child: ValueListenableBuilder<int>(
              valueListenable: durum.jeton,
              builder: (_, j, __) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: kMor, borderRadius: BorderRadius.circular(999)),
                child: Text('🪙 $j', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
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
  _Harf({required this.harf, this.boyut = 52, this.renk});
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
  _Balon({required this.metin, required this.benim});
  @override
  Widget build(BuildContext context) => Align(
    alignment: benim ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .72),
      decoration: BoxDecoration(
        gradient: benim ? kGrad : null,
        color: benim ? null : kPanel,
        border: benim ? null : Border.all(color: kBorder),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18), topRight: Radius.circular(18),
          bottomLeft: Radius.circular(benim ? 18 : 4), bottomRight: Radius.circular(benim ? 4 : 18),
        ),
      ),
      child: Text(metin, style: TextStyle(color: benim ? Colors.white : kText, fontSize: 15)),
    ),
  );
}

class _Rozet extends StatelessWidget {
  final Widget cocuk;
  _Rozet({required this.cocuk});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.5), borderRadius: BorderRadius.circular(10)),
    child: cocuk,
  );
}

class _Cip extends StatelessWidget {
  final String t;
  _Cip({required this.t});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.4), borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.4))),
    child: Text(t, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
  );
}

class _Nokta extends StatelessWidget {
  final bool aktif;
  _Nokta({this.aktif = false});
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
  _Aksiyon({required this.ikon, this.renk, this.buyuk = false, this.gradient = false, this.onTap});
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
          boxShadow: gradient ? [BoxShadow(color: kPembe.withOpacity(.5), blurRadius: 20, offset: Offset(0, 8))] : null,
        ),
        child: Icon(ikon, color: gradient ? Colors.white : renk, size: gradient ? 30 : 26),
      ),
    );
  }
}

class _Avatars extends StatelessWidget {
  _Avatars();
  @override
  Widget build(BuildContext context) {
    final harfler = ['E', 'D', 'S', '+'];
    return SizedBox(width: 112, height: 34, child: Stack(children: [
      for (int i = 0; i < harfler.length; i++)
        Positioned(left: i * 26.0, child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          child: Center(child: Text(harfler[i], style: TextStyle(color: kMor, fontWeight: FontWeight.w900, fontSize: 15))),
        )),
    ]));
  }
}

class _Adim extends StatelessWidget {
  final String no, t;
  _Adim({required this.no, required this.t});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(.3))),
    child: Column(children: [
      Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(child: Text(no, style: TextStyle(color: Color(0xFFA21CAF), fontWeight: FontWeight.w900, fontSize: 13)))),
      SizedBox(height: 5),
      Text(t, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  ));
}

class _BeyazButon extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;
  _BeyazButon({required this.icon, required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFFDADCE0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6, offset: Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        icon, SizedBox(width: 12),
        Text(text, style: TextStyle(color: Color(0xFF1F1F1F), fontSize: 15, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}
