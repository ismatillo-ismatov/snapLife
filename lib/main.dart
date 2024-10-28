import 'package:flutter/material.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/widgets/search.dart'as search;
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final UserProfile userProfile = UserProfile(
      userId: 1,
      userName: 'ismatilloismatov',
      userImage: "assets/images/ismatov.jpg",
      posts: [
        Post(
            id: 1,
            userName: "ismatov",
            profileImage: "assets/images/ismatov.jpg",
            imagePath: 'assets/images/2.jpg',
            postTitle: "hello",
            postText: "Agar matn uzun bo‘lsa va faqat boshlang‘ich ikkita qatorni ko‘rsatib, qolgan qismini Continue reading tugmasini bosganida ko‘rsatishni xohlasangiz, Text vidjetida maxLines va TextOverflow.ellipsis parametrlari bilan ishlash mumkin. Shuningdek, uzun matnni yashirish va ochish uchun bool qiymatidan foydalanasiz."
        ),
        Post(
          id: 2,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/3.jpg',
          postTitle: "hello",
          postText: "Agar matn uzun bo‘lsa va faqat boshlang‘ich ikkita qatorni ko‘rsatib, qolgan qismini Continue reading tugmasini bosganida ko‘rsatishni xohlasangiz, Text vidjetida maxLines va TextOverflow.ellipsis parametrlari bilan ishlash mumkin. Shuningdek, uzun matnni yashirish va ochish uchun bool qiymatidan foydalanasiz",
        ),
        Post(
          id: 3,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/3.jpg',
          postTitle: "hello",
          postText: "asdadwdasdawdasdawdasdawd",
        ),
        Post(
          id: 4,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/4.jpg',
          postTitle: "hello",
          postText: "asdadwdasdawdasdawdasdawd",
        ),
        Post(
          id: 1,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/2.jpg',
          postTitle: "hello",
          postText: "asdadwdasdawdasdawdasdawd",
        ),
        Post(
          id: 1,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/2.jpg',
          postTitle: "hello",
          postText: "asdadwdasdawdasdawdasdawd",
        ),
        Post(
          id: 1,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/2.jpg',
          postTitle: "hello",
          postText: "asdadwdasdawdasdawdasdawd",
        ),
        Post(
          id: 1,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/2.jpg',
          postTitle: "hello",
          postText: "asdadwdasdawdasdawdasdawd",
        ),
        Post(
          id: 1,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/2.jpg',
          postTitle: "hello",
          postText: "asdadwdasdawdasdawdasdawd",
        ),
        Post(
          id: 1,
          userName: "ismatov",
          profileImage: "assets/images/ismatov.jpg",
          imagePath: 'assets/images/2.jpg',
          postTitle: "hello",
          postText: "asdadwdasdawdasdawdasdawd",
        ),
      ]);
  List<Widget> _pages() {
    return [
      HomePage(),
      search.SearchBarApp(),
      const Center(child: Text("hello")),
      const Center(child: Text("hello")),
      ProfilePage(userProfile: userProfile),
    ];
  }

  void _onItemsTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, primaryColor: Colors.black),
      home: Scaffold(
        appBar: _selectedIndex == 0
            ? AppBar(
          title: Text('Snaplife'),
          actions: [
            IconButton(
              icon: Icon(Icons.favorite_outline_sharp),
              onPressed: () {},
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/svgs/messager.svg',
                height: 30,
                width: 30,
              ),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    // horizontal scroll
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Color(0xfff6f7f9),
                            border: Border.all(color: Colors.red),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/ismatov.jpg'),
                                fit: BoxFit.fill),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 40, left: 40),
                                child: IconButton(
                                  iconSize: 100.0,
                                  icon: SvgPicture.asset(
                                    'assets/svgs/plus.svg',
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              SizedBox(height: 12),
                              const Align(
                                alignment: Alignment(0.9, 1.5),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 5.0),
                                  child: Text(
                                    'your story',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                              color: Color(0xfff6f7f9),
                              border: Border.all(color: Colors.green),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                  AssetImage('assets/images/2.jpg'))),
                        ),
                        SizedBox(width: 5),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                              color: Color(0xfff6f7f9),
                              border: Border.all(color: Colors.green),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                  AssetImage('assets/images/3.jpg'))),
                        ),
                        SizedBox(width: 5),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                              color: Color(0xfff6f7f9),
                              border: Border.all(color: Colors.green),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                  AssetImage('assets/images/4.jpg'))),
                        ),
                        SizedBox(width: 5),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Color(0xfff6f7f9),
                            border: Border.all(color: Colors.green),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/5.jpg'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Divider(
                    color: Colors.black,
                    thickness: 2,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
        )
            : null,
        body: _pages()[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          unselectedIconTheme: const IconThemeData(
            size: 25,
          ),
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
              ),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.ondemand_video), label: ''),
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.circleUser,
                // size: 30.0,
              ),
              label: '',
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemsTapped,
        ),
      ),
    );
  }
}