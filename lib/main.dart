import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/widgets/message_widget.dart';
import 'package:ismatov/widgets/inbox_message_widget.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/forms/createPost.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/search.dart';
import 'package:ismatov/widgets/notifications.dart';
import 'package:ismatov/forms/loginPage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:ismatov/services/local_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔕 background push: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  LocalNotificationService.initialize();
  // await setupFRM();

  await Hive.initFlutter();
  var authBox = await Hive.openBox('authBox');
  var userBox = await Hive.openBox('userBox');
  if (authBox.get('token_cleared') != true) {
    await authBox.clear();
    await userBox.clear();
    await authBox.put('token_cleared', true);
    print('Hive faqat bir marta tozalandi');
  }
  String? savedToken = authBox.get('auth_token');
  print("Hive ichidagi userToken: $savedToken");
  UserService().checkToken();
  runApp(
    ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (context, child) => MyApp(),
    ),
  );
}

Future<void> setupFRM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("📲 Firebase token: $token");
  if (token != null) {
    await ApiService().saveFCMToken(token);
  }
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground push: ${message.notification?.title}");
    LocalNotificationService.display(message);
  });
}

void checkHiveData() async {
  var box = await Hive.openBox('authBox');
  print("Hive ichida barcha malumotlar: ${box.toMap()}");
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapLife',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, primaryColor: Colors.white10),
      home: AuthHandler(),
    );
  }
}

class AuthHandler extends StatelessWidget {
  Future<bool> _isLoggedIn() async {
    var authBox = Hive.box('authBox');
    print("Hive ichidagi userToken: ${authBox.get('auth_token')}");
    String? token = authBox.get('auth_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data == true) {
            return MainApp();
          } else {
            return LoginPage();
          }
        });
  }
}

class MainApp extends StatefulWidget {
  @override
  final UserProfile? userProfile;
  MainApp({Key? key, this.userProfile}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  UserProfile? userProfile;
  late Future<List<UserProfile>> _friendProfileFuture;
  // List<UserProfile>friendProfiles = [];
  String? token;

  void logoutAndClearData(BuildContext context) async {
    final authBox = await Hive.openBox('authBox');
    final userBox = await Hive.openBox('userBox');
    await authBox.clear();
    await userBox.clear();
    print('Hive tozalandi');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    var authBox = Hive.box('authBox');
    print("Hive ichidagi userToken: ${authBox.get('userToken')}");
    String? fetchedToken = authBox.get('auth_token');
    print("Olingan token: $fetchedToken");
    setState(() {
      token = fetchedToken;
    });
    if (fetchedToken != null && fetchedToken.isNotEmpty) {
      await setupFRM();
    }
  }

  void _fetchUserProfile() async {
    String? token = await ApiService().getUserToken();
    if (token != null) {
      try {
        UserProfile profile = await UserService().fetchUserProfile(token);
        setState(() {
          userProfile = profile;
        });
      } catch (e) {
        print("User profile olishda xatolik:  $e");
      }
    } else {
      print('Foydalanuvchi login qilmagan');
    }
  }

  List<Widget> _pages(UserProfile userProfile) {
    return [
      HomePage(token: token!),
      SearchPage(userProfile: userProfile),
      CreatePostPage(),
      const Center(child: Text("hello")),
      ProfilePage(userProfile: userProfile),
    ];
  }

  void _onItemsTapped(int index) async {
    if (index == 2) {
      final newPost = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePostPage(),
        ),
      );
      if (newPost != null) {
        setState(() {
          userProfile?.posts.add(newPost);
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _selectedIndex == 0
            ? AppBar(
                title: Text('Snaplife'),
                actions: [
                  IconButton(
                      icon: Icon(Icons.favorite_outline_sharp),
                      onPressed: () async {
                        var authBox = await Hive.openBox('authBox');
                        String? currentToken = authBox.get('auth_token');
                        if (currentToken != null && currentToken.isNotEmpty) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    // FriendRequestScreen(token: token!
                                    NotificationsScreen(
                                  token: token!,
                                  userProfile: userProfile!,
                                ),
                              ));
                        } else {
                          print("Current token is null or Empty");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Authentication error. Please login again.")));
                        }
                      }),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/svgs/messager.svg',
                      height: 30,
                      width: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InboxMessageWidget(token: token!),
                          ));
                    },
                  ),
                ],
              )
            : null,
        body: userProfile == null
            ? Center(child: CircularProgressIndicator())
            : (_selectedIndex < _pages(userProfile!).length
                ? _pages(userProfile!)[_selectedIndex]
                : Center(
                    child: Text('notorgi index'),
                  )),
        bottomNavigationBar: BottomNavigationBar(
          unselectedIconTheme: const IconThemeData(
            size: 25,
          ),
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.ondemand_video), label: ''),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.circleUser),
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemsTapped,
        ));
  }
}
