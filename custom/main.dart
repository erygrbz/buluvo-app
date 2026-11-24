// Buluvo — Native WebView kabuğu (MINIMAL v1: sadece tam ekran WebView).
// Amaç: kesin derlenen, adres çubuğu olmayan bir uygulama. Ödeme/foto/geri-tuşu
// sonraki sürümlerde test edilerek eklenecek.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  bool _hazir = false;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF080810))
      ..setUserAgent(kUa)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _hazir = true);
        },
        onWebResourceError: (_) {
          if (mounted) setState(() => _hazir = true);
        },
      ))
      ..loadRequest(Uri.parse(kSite));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
