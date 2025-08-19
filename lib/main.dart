import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ismatov/forms/loginPage.dart';
import 'package:ismatov/forms/createPost.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/widgets/message_widget.dart';
import 'package:ismatov/widgets/inbox_message_widget.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/widgets/notifications.dart';
import 'package:ismatov/widgets/comments_widget.dart';
import 'package:ismatov/widgets/user_page.dart';
import 'package:ismatov/widgets/search.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:ismatov/services/local_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔕 Background push: ${message.messageId}, Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void handleNotificationNavigation(RemoteMessage message) async {
    final data = message.data;
    print("Notification data: $data");
    final notificationType = data['notification_type'];

    if (notificationType == null) {
      print("Xato: notification_type mavjud emas");
      return;
    }

    final apiService = ApiService();
    String? token = await apiService.getUserToken();
    if (token == null) {
      print("Token topilmadi, login sahifasiga o‘tish");
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    if (notificationType == 'message') {
      final senderId = int.tryParse(data['sender_id']?.toString() ?? '');
      final receiverId = int.tryParse(data['receiver_id']?.toString() ?? '');
      if (senderId != null && receiverId != null) {
        print("Chat sahifasiga o‘tish: sender=$senderId, receiver=$receiverId");
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ChatPage(sender: senderId, receiver: receiverId),
          ),
        );
      } else {
        print("Xato: sender_id yoki receiver_id noto‘g‘ri: sender_id=${data['sender_id']}, receiver_id=${data['receiver_id']}");
      }
    } else if (notificationType == 'comment' || notificationType == 'reply') {
      final postId = int.tryParse(data['post_id']?.toString() ?? '');
      final commentId = int.tryParse(data['comment_id']?.toString() ?? '');
      if (postId != null) {
        print("Comments sahifasiga o‘tish: post_id=$postId, comment_id=$commentId");
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => CommentsPage(
              postId: postId,
              token: token,
              scrollCommentId: commentId,
            ),
          ),
        );
      } else {
        print("Xato: post_id noto‘g‘ri");
      }
    } else if (notificationType == 'like' || notificationType == 'comment_like') {
      final postId = int.tryParse(data['post_id']?.toString() ?? '');
      if (postId != null) {
        print("Post sahifasiga o‘tish: post_id=$postId");
        try {
          final userProfile = await UserService().fetchUserProfile(token);
          final post = await PostService().fetchPost(postId, token);
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => PostPage(
                userProfile: userProfile,
                post: post,
                initialIndex: 0,
                token: token,
              ),
            ),
          );
        } catch (e) {
          print("Post sahifasiga o‘tishda xato: $e");
          ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
            SnackBar(content: Text("Postni yuklashda xato: $e")),
          );
        }
      } else {
        print("Xato: post_id noto‘g‘ri");
      }
    }
  }


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
    LocalNotificationService.initialize(MyApp.navigatorKey); // navigatorKey ni uzatish
  }
  void _setupPushNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground push: ${message.notification?.title} - ${message.notification?.body}");
      print("Data: ${message.data}");
      LocalNotificationService.display(message);
      // MyApp.handleNotificationNavigation(message);
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Bildirishnoma bosildi: ${message.notification?.title} - ${message.notification?.body}");
      print("Data: ${message.data}");
      MyApp.handleNotificationNavigation(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("Ilova terminated holatda ochildi: ${message.data}");
        MyApp.handleNotificationNavigation(message);
      }
    });


    String? token = await FirebaseMessaging.instance.getToken();
    print("📲 Firebase token: $token");
    if (token != null) {
      await _apiService.saveFCMToken(token);
    }
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SnapLife',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white10,
      ),
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
      },
    );
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
  String? token;

  void logoutAndClearData(BuildContext context) async {
    final authBox = await Hive.openBox('authBox');
    final userBox = await Hive.openBox('userBox');
    await authBox.clear();
    await userBox.clear();
    print('Hive tozalandi');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
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
    print("Hive ichidagi userToken: ${authBox.get('auth_token')}");
    String? fetchedToken = authBox.get('auth_token');
    print("Olingan token: $fetchedToken");
    setState(() {
      token = fetchedToken;
    });
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
        print("User profile olishda xatolik: $e");
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
      UserPage(token: token!),
      // const Center(),
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
                    builder: (context) => NotificationsScreen(
                      token: token!,
                      userProfile: userProfile!,
                    ),
                  ),
                );
              } else {
                print("Current token is null or Empty");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Authentication error. Please login again."),
                  ),
                );
              }
            },
          ),
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
                  builder: (context) => InboxMessageWidget(token: token!),
                ),
              );
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
        child: Text('noto‘g‘ri index'),
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
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind), label: ''),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.circleUser),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemsTapped,
      ),
    );
  }
}


