import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/widgets/search.dart'as search;
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/forms/loginPage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  var userBox = Hive.box('userbox');
  bool isLoggedIn = userBox.containsKey('userProfile');
  runApp(
      ScreenUtilInit(
      designSize: const Size(414,896),
      builder: (context, child) => MyApp(),
      ),
      );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapLife',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, primaryColor: Colors.white10),
      home: AuthHandler(),
    );
  }


}
class AuthHandler extends StatelessWidget{
  Future<bool>_isLoggedIn() async{
    var userBox = Hive.box('userBox');
    String? token = userBox.get('userToken');
    return token != null && token.isNotEmpty;
  }
  @override
  Widget build(BuildContext context){
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        } else if(snapshot.data == true) {
          return MainApp();
        } else {
          return LoginPage();
        }
      }
    );
  }
}
class MainApp extends StatefulWidget{
  @override
  final UserProfile? userProfile;
  MainApp({Key? key, this.userProfile}): super(key:key);

  @override
  _MainAppState createState() => _MainAppState();

}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  UserProfile? userProfile;

  @override
  void initState(){
    super.initState();
    _fetchUserProfile();
  }



  void _fetchUserProfile() async {
    String? token = await ApiService().getUserToken();
    if(token != null){
      try{
        UserProfile profile = await ApiService().fetchUserProfile(token);
        setState(() {
          userProfile = profile;
        });
      } catch(e){
        print("User profile olishda xatolik:  $e");
      }
    }else{
      print('Foydalanuvchi login qilmagan');
    }

  }


  List<Widget> _pages(UserProfile userProfile) {
    return [
      // HomePage(),
      // search.SearchBarApp(),
      const Center(child: Text("hello")),
      const Center(child: Text("hello")),
      const Center(child: Text("hello")),
      const Center(child: Text("hello")),
      ProfilePage(userProfile: userProfile ),
    ];
  }

  void _onItemsTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: _selectedIndex == 0
            ? AppBar(
          title: Text('Snaplife'),

          actions: [
            Builder(
                builder: (context) => IconButton(
                icon: Icon(FontAwesomeIcons.solidCircleUser),
                onPressed: () {
                  Navigator.push(
                      context,
                    MaterialPageRoute(
                        builder:(context) => LoginPage(
                        ),
                    ),
                  );
                },


      ),
            ),
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
                          height: 80.h,
                          width: 80.w,
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
        body: userProfile == null
            ? Center(child: CircularProgressIndicator())
            : (_selectedIndex < _pages(userProfile!).length
            ? _pages(userProfile!)[_selectedIndex]
            : Center(child: Text('notorgi index'),)

        // body: userProfile == null
        //   ? Center(child: CircularProgressIndicator())
        //   : _pages(userProfile!)[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          unselectedIconTheme: const IconThemeData(
            size: 25,
          ),
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home),label:''),
            BottomNavigationBarItem(icon: Icon(Icons.search),label:''),
            BottomNavigationBarItem(icon: Icon(Icons.add),label:''),
            BottomNavigationBarItem(icon: Icon(Icons.ondemand_video),label:''),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.circleUser),
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemsTapped,
        )
    );




  }
}
