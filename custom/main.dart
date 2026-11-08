import 'package:flutter/material.dart';

void main() => runApp(const BuluvoApp());

// ===== Sade Aurora renk paleti =====
const kBg = Color(0xFFF7F5FC);
const kPanel = Color(0xFFFFFFFF);
const kBorder = Color(0xFFECE6F7);
const kText = Color(0xFF1C1A2B);
const kMuted = Color(0xFF716D87);
const kMor = Color(0xFF9333EA);
const kPembe = Color(0xFFEC4899);
const kGrad = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kMor, kPembe],
);

class BuluvoApp extends StatelessWidget {
  const BuluvoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buluvo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: kMor),
        useMaterial3: true,
      ),
      home: const GirisEkrani(),
    );
  }
}

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
                  // Logo amblem
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      gradient: kGrad,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: kPembe.withOpacity(0.45),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 18),
                  ShaderMask(
                    shaderCallback: (r) => kGrad.createShader(r),
                    child: const Text(
                      'Buluvo',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tekrar hoş geldin',
                      style: TextStyle(fontSize: 16, color: kMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 26),

                  // Sosyal kanıt + 3 adım bandı
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: kGrad,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: kPembe.withOpacity(0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            _Avatars(),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('50.000 kişi tanıştı',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                                  SizedBox(height: 2),
                                  Text('Sen de aramıza katıl.',
                                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            _Adim(no: '1', t: 'Kaydol'),
                            SizedBox(width: 10),
                            _Adim(no: '2', t: 'Profil'),
                            SizedBox(width: 10),
                            _Adim(no: '3', t: 'Eşleş'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Google butonu
                  _BeyazButon(
                    icon: const Text('G',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
                    text: 'Google ile devam et',
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),

                  // E-posta alanı
                  _Alan(hint: 'E-posta adresin'),
                  const SizedBox(height: 12),
                  _Alan(hint: 'Şifren', obscure: true),
                  const SizedBox(height: 16),

                  // Giriş butonu
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Giriş yakında backend\'e bağlanacak 👍')),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: kGrad,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('Giriş yap',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Buluvo · Native Android (Flutter)',
                      style: TextStyle(fontSize: 12, color: kMuted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatars extends StatelessWidget {
  const _Avatars();
  @override
  Widget build(BuildContext context) {
    final harfler = ['E', 'D', 'S', '+'];
    return SizedBox(
      width: 112,
      height: 34,
      child: Stack(
        children: [
          for (int i = 0; i < harfler.length; i++)
            Positioned(
              left: i * 26.0,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(harfler[i],
                      style: const TextStyle(color: kMor, fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Adim extends StatelessWidget {
  final String no, t;
  const _Adim({required this.no, required this.t});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Center(
                child: Text(no, style: const TextStyle(color: Color(0xFFA21CAF), fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 5),
            Text(t, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _BeyazButon extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;
  const _BeyazButon({required this.icon, required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDADCE0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(color: Color(0xFF1F1F1F), fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Alan extends StatelessWidget {
  final String hint;
  final bool obscure;
  const _Alan({required this.hint, this.obscure = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        obscureText: obscure,
        style: const TextStyle(color: kText, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF938FB0)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      ),
    );
  }
}
