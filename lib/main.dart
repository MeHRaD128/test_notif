import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? fcmToken;

  // بررسی پلتفرم‌های موبایل و وب برای اجرای فایربیس واقعی
  if (defaultTargetPlatform == TargetPlatform.android || 
      defaultTargetPlatform == TargetPlatform.iOS || 
      kIsWeb) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await FirebaseMessaging.instance.requestPermission();
      fcmToken = await FirebaseMessaging.instance.getToken();
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          messengerKey.currentState?.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xCC1C1C1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              content: Text(
                '🔔 ${message.notification!.title}\n${message.notification!.body}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          );
        }
      });
    } catch (e) {
      // در صورت بروز خطا در امولاتور بدون گوگل‌پلی
      fcmToken = "Error_GooglePlayServices_Missing: $e";
    }
  } else {
    // شبیه‌سازی توکن در حالت اجرای مستقیم روی لینوکس دسکتاپ (کالی) جهت تست پنل شیشه‌ای
    fcmToken = "Mock_FCM_Token_Linux_Env_09132667318_MoshirElearningFCMKey";
  }

  runApp(MyApp(fcmToken: fcmToken));
}

class MyApp extends StatelessWidget {
  final String? fcmToken;
  const MyApp({super.key, this.fcmToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Moshir Premium',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B11),
        primaryColor: const Color(0xFF0A84FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A84FF),
          surface: Color(0x1AFFFFFF),
        ),
      ),
      home: MoshirLoginScreen(fcmToken: fcmToken),
    );
  }
}

// ================= صفحه لاگین شیشه‌ای iOS =================
class MoshirLoginScreen extends StatefulWidget {
  final String? fcmToken;
  const MoshirLoginScreen({super.key, this.fcmToken});

  @override
  State<MoshirLoginScreen> createState() => _MoshirLoginScreenState();
}

class _MoshirLoginScreenState extends State<MoshirLoginScreen> {
  final _mobileController = TextEditingController(text: '09132667318');
  final _usernameController = TextEditingController(text: 'h.mehraban');
  final _passwordController = TextEditingController(text: '6330110476');
  bool _isLoggingIn = false;
  String? _loginError;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    final dio = Dio();
    const String tokenUrl = 'https://api.moshir.ir/api/Token/Token';

    try {
      final tokenResponse = await dio.get(
        tokenUrl,
        queryParameters: {
          'MobileNumber': _mobileController.text.trim(),
          'Username': _usernameController.text.trim(),
          'Password': _passwordController.text.trim(),
        },
      );

      String? retrievedToken;

      if (tokenResponse.statusCode == 200) {
        final responseData = tokenResponse.data;
        if (responseData is List && responseData.isNotEmpty) {
          retrievedToken = responseData[0]['result']?.toString().trim();
        } else if (responseData is Map) {
          retrievedToken = responseData['result']?.toString().trim();
        }
        retrievedToken = retrievedToken?.replaceAll('"', '').trim();
      }

      if (retrievedToken != null && retrievedToken.isNotEmpty && retrievedToken != 'null') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MoshirGlassDashboard(
              token: retrievedToken!,
              fcmToken: widget.fcmToken,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        throw Exception("اطلاعات کاربری نادرست است.");
      }
    } catch (e) {
      setState(() {
        _loginError = "خطا در ورود! مشخصات خود را بررسی کنید.";
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A84FF).withOpacity(0.2),
                // blurRadius: 100,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5E5CE6).withOpacity(0.15),
                // blurRadius: 100,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0A84FF).withOpacity(0.12),
                            ),
                            child: const Icon(Icons.lock_person_rounded, size: 45, color: Color(0xFF0A84FF)),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'ورود به سامانه مشیر',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'پلتفرم هوشمند مدیریت آموزش',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                          ),
                          const SizedBox(height: 35),
                          _buildGlassTextField(
                            controller: _mobileController,
                            hint: 'شماره موبایل',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 18),
                          _buildGlassTextField(
                            controller: _usernameController,
                            hint: 'نام کاربری',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 18),
                          _buildGlassTextField(
                            controller: _passwordController,
                            hint: 'رمز عبور',
                            icon: Icons.lock_outline_rounded,
                            isObscure: true,
                          ),
                          if (_loginError != null) ...[
                            const SizedBox(height: 15),
                            Text(_loginError!, style: const TextStyle(color: Color(0xFFFF453A), fontSize: 13)),
                          ],
                          const SizedBox(height: 35),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoggingIn ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A84FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _isLoggingIn
                                  ? const CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(Colors.white))
                                  : const Text('ورود به حساب کاربری', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ================= داشبورد شیشه‌ای محتوا =================
class MoshirGlassDashboard extends StatefulWidget {
  final String token;
  final String? fcmToken;
  const MoshirGlassDashboard({super.key, required this.token, this.fcmToken});

  @override
  State<MoshirGlassDashboard> createState() => _MoshirGlassDashboardState();
}

class _MoshirGlassDashboardState extends State<MoshirGlassDashboard> {
  List<dynamic> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dio = Dio();
    const String dataUrl = 'https://api.moshir.ir/api/Education/getall';

    try {
      final dataResponse = await dio.get(
        dataUrl,
        queryParameters: {'customerId': '-1', 'staffId': '-1'},
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      if (dataResponse.statusCode == 200) {
        setState(() {
          _items = dataResponse.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "خطا در دریافت لیست محتوا";
        _isLoading = false;
      });
    }
  }

  Future<void> _playVideo(String url) async {
    final Uri videoUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(videoUri)) {
        await launchUrl(videoUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(videoUri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('امکان پخش ویدیو روی این دستگاه وجود ندارد.')),
      );
    }
  }

  void _showTokenBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: const Color(0xCC161F30),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security_rounded, color: Color(0xFFFFD60A), size: 26),
                      SizedBox(width: 10),
                      Text(
                        'FCM Token (Firebase)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: SelectableText(
                      widget.fcmToken ?? "توکن فایربیس بر روی این دستگاه ست نشده است",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF30D158), height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A84FF).withOpacity(0.15),
                // blurRadius: 120,
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(Color(0xFF0A84FF))))
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFFF453A))))
                  : Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 140, left: 16, right: 16, bottom: 120),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final videoUrl = item['videoURL']?.toString() ?? '';
                          final hasVideo = videoUrl.isNotEmpty;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: hasVideo ? () => _playVideo(videoUrl) : null,
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              item['picName'] ?? 'https://api.moshir.ir/Images/_default_elearning.jpg',
                                              height: 210,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, o, s) => Container(
                                                height: 210,
                                                color: Colors.white.withOpacity(0.03),
                                                child: const Icon(Icons.image_not_supported_rounded, size: 40, color: Colors.grey),
                                              ),
                                            ),
                                            if (hasVideo)
                                              Positioned.fill(
                                                child: Container(
                                                  color: Colors.black.withOpacity(0.35),
                                                  child: Center(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(50),
                                                      child: BackdropFilter(
                                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                        child: Container(
                                                          padding: const EdgeInsets.all(15),
                                                          color: Colors.white.withOpacity(0.15),
                                                          child: const Icon(Icons.play_circle_fill_rounded, size: 50, color: Color(0xFFFFD60A)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(22.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'] ?? '',
                                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
                                            ),
                                            const SizedBox(height: 10),
                                            Html(
                                              data: item['description'] ?? '',
                                              style: {
                                                "p": Style(
                                                  fontSize: FontSize(14.5),
                                                  color: Colors.white.withOpacity(0.7),
                                                  lineHeight: const LineHeight(1.6),
                                                ),
                                                "li": Style(
                                                  fontSize: FontSize(14.5),
                                                  color: Colors.white.withOpacity(0.7),
                                                ),
                                                "strong": Style(color: const Color(0xFFFF453A)),
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  color: const Color(0xCC070B11).withOpacity(0.7),
                  padding: const EdgeInsets.only(top: 60, bottom: 18, left: 22, right: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'پلیر آموزشی مشیر',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Material(
                          color: Colors.white.withOpacity(0.06),
                          child: IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0A84FF), size: 26),
                            onPressed: fetchData,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD60A).withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _showTokenBottomSheet,
                      icon: const Icon(Icons.key_rounded, size: 20),
                      label: const Text(
                        'نمایش توکن فایربیس',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: -0.2),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD60A),
                        foregroundColor: const Color(0xFF070B11),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
