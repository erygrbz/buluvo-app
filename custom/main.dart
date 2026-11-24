// Buluvo — Native WebView kabuğu (TAM sürüm).
// Tam ekran WebView (adres çubuğu yok) + native splash + geri tuşu + foto yükleme
// + dış link + native Google Play Billing köprüsü.
//
// Ödeme köprüsü: katman (BuluvoApp UA'sını tanıyınca) "Google Play ile öde"
//   butonunu window.BLVNative.postMessage(JSON{sku}) çağırır. Flutter native
//   satın almayı yapar, jetonu web'e verir (window.blvPlayDogrula), web
//   /_odeme/play/dogrula'ya (çerezle) gönderir, başarı ekranını gösterir.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

const String kSite = 'https://buluvo.com';
const String kUa =
    'Mozilla/5.0 (Linux; Android 13; Buluvo) AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/122.0.0.0 Mobile Safari/537.36 BuluvoApp/1.0';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF080810),
    systemNavigationBarColor: Color(0xFF080810),
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const BuluvoApp());
}

class BuluvoApp extends StatelessWidget {
  const BuluvoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buluvo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF080810)),
      home: const WebShell(),
    );
  }
}

class WebShell extends StatefulWidget {
  const WebShell({super.key});
  @override
  State<WebShell> createState() => _WebShellState();
}

class _WebShellState extends State<WebShell> {
  late final WebViewController _c;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _iapSub;
  bool _hazir = false;

  @override
  void initState() {
    super.initState();
    _webKur();
    _odemeKur();
  }

  @override
  void dispose() {
    _iapSub?.cancel();
    super.dispose();
  }

  void _webKur() {
    final c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF080810))
      ..setUserAgent(kUa)
      ..addJavaScriptChannel('BLVNative', onMessageReceived: _jsMesaj)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          _c.runJavaScript('window.BLVNativeReady=true;');
          if (!_hazir && mounted) setState(() => _hazir = true);
        },
        onWebResourceError: (_) {
          if (!_hazir && mounted) setState(() => _hazir = true);
        },
        onNavigationRequest: _navKarar,
      ))
      ..loadRequest(Uri.parse(kSite));

    if (c.platform is AndroidWebViewController) {
      final a = c.platform as AndroidWebViewController;
      a.setMediaPlaybackRequiresUserGesture(false);
      a.setOnShowFileSelector(_dosyaSec);
    }
    _c = c;
  }

  FutureOr<NavigationDecision> _navKarar(NavigationRequest req) async {
    final uri = Uri.tryParse(req.url);
    if (uri == null) return NavigationDecision.navigate;
    final host = uri.host;
    final icerde = host.isEmpty ||
        host == 'buluvo.com' ||
        host.endsWith('.buluvo.com') ||
        host.contains('google.com') ||
        host.contains('facebook.com') ||
        host.contains('gstatic.com');
    if (icerde && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NavigationDecision.navigate;
    }
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return NavigationDecision.prevent;
  }

  Future<List<String>> _dosyaSec(FileSelectorParams params) async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: params.mode == FileSelectorMode.openMultiple,
      );
      if (res == null) return <String>[];
      return res.files
          .where((f) => f.path != null)
          .map((f) => Uri.file(f.path!).toString())
          .toList();
    } catch (_) {
      return <String>[];
    }
  }

  // ---------------- Google Play Billing ----------------
  void _odemeKur() {
    _iapSub = _iap.purchaseStream.listen(_satinAlmaGuncelle, onError: (_) {});
    _iap.isAvailable();
  }

  void _jsMesaj(JavaScriptMessage m) async {
    try {
      final data = jsonDecode(m.message);
      final sku = (data is Map && data['sku'] != null)
          ? data['sku'].toString()
          : null;
      if (sku != null && sku.isNotEmpty) {
        await _satinAl(sku);
      }
    } catch (_) {}
  }

  Future<void> _satinAl(String sku) async {
    try {
      final bool varMi = await _iap.isAvailable();
      if (!varMi) {
        _webHata('Google Play ödemesi bu cihazda kullanılamıyor.');
        return;
      }
      final resp = await _iap.queryProductDetails({sku});
      if (resp.productDetails.isEmpty) {
        _webHata('Ürün bulunamadı (Play Console\'da etkin/yayılmış olmalı).');
        return;
      }
      final param = PurchaseParam(productDetails: resp.productDetails.first);
      await _iap.buyConsumable(purchaseParam: param, autoConsume: true);
    } catch (e) {
      _webHata(e.toString());
    }
  }

  void _satinAlmaGuncelle(List<PurchaseDetails> list) {
    for (final p in list) {
      if (p.status == PurchaseStatus.pending) continue;
      if (p.status == PurchaseStatus.error) {
        _webHata(p.error?.message ?? 'Satın alma hatası');
      } else if (p.status == PurchaseStatus.canceled) {
        _webHata('iptal');
      } else if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        final sku = jsonEncode(p.productID);
        final tok = jsonEncode(p.verificationData.serverVerificationData);
        _c.runJavaScript(
            'window.blvPlayDogrula && window.blvPlayDogrula($sku,$tok);');
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  void _webHata(String msg) {
    final j = jsonEncode(msg);
    _c.runJavaScript('window.blvPlayHata && window.blvPlayHata($j);');
  }

  // ---------------- UI ----------------
  Future<bool> _geri() async {
    if (await _c.canGoBack()) {
      _c.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final cikabilir = await _geri();
        if (cikabilir && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF080810),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              WebViewWidget(controller: _c),
              if (!_hazir) const _Splash(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080810),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 22),
            const Text('Buluvo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.4, color: Color(0xFF8B5CF6)),
            ),
          ],
        ),
      ),
    );
  }
}
