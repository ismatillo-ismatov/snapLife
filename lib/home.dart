import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart/';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/home.dart';


class Post {
  final int id;
  final String userName;
  final String profileImage;
  final String postTitle;
  final String imagePath;
  final String postText;
  bool isLiked;
  bool save;
  Post({
    required this.id,
    required this.userName,
    required this.profileImage,
    required this.postTitle,
    required this.imagePath,
    required this.postText,
    this.isLiked =  false,
    this.save = false

  });
}
class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();

  }

class _HomePageState extends State<HomePage> {
  List<Post> posts = [
    Post(
        id: 1,
        profileImage: 'assets/images/ismatov.jpg',
        userName: "ismatov",
        imagePath: 'assets/images/3.jpg',
        postTitle: "hello everyone",
        postText: "Agar matn uzun bo‘lsa va faqat boshlang‘ich ikkita qatorni ko‘rsatib, qolgan qismini 'Continue reading' tugmasini bosganida ko‘rsatishni xohlasangiz, Text vidjetida maxLines va TextOverflow.ellipsis parametrlari bilan ishlash mumkin. Shuningdek, uzun matnni yashirish va ochish uchun bool qiymatidan foydalanasiz."),
    Post(
        id: 2,
        profileImage: 'assets/images/5.jpg',
        userName: 'johongir',
        imagePath: 'assets/images/5.jpg',
        postTitle: "hello everyone",
        postText: "Agar matn uzun bo‘lsa va faqat boshlang‘ich ikkita qatorni ko‘rsatib, qolgan qismini 'Continue reading' tugmasini bosganida ko‘rsatishni xohlasangiz, Text vidjetida maxLines va TextOverflow.ellipsis parametrlari bilan ishlash mumkin. Shuningdek, uzun matnni yashirish va ochish uchun bool qiymatidan foydalanasiz"),
    Post(id: 3,
        profileImage: 'assets/images/4.jpg',
        userName: 'qodirov',
        imagePath: 'assets/images/4.jpg',
        postTitle: "hello everyone",
        postText: "hello qodirov"),
  ];
  void _toggleLike(int  id){
    setState(() {
      Post post = posts.firstWhere((post) => post.id == id);
      post.isLiked = !post.isLiked;
    });

  }
  void _toggleSave(int id){
    setState(() {
      Post post = posts.firstWhere((post) => post.id ==id);
      post.save = !post.save;
    });
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
          child:Column(
          children: posts.map((post){
            bool isExpended = false;
            return Column(
            children: [
             Container(
                height: 510,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.greenAccent),
                  image:  DecorationImage(
                      image: AssetImage(post.imagePath),
                      fit: BoxFit.cover
                  ),
                ),

               child: Align(
                 alignment: Alignment.topLeft,
                 child: Stack(
                 children:[
                   Padding(
                     padding: const EdgeInsets.only(
                       left: 80,
                       top: 20,
                     ),
                     child: Text(post.userName,
                       style: TextStyle(color: Colors.white),
                     ),
                   ),

                 Container(
                   margin: EdgeInsets.all(20),
                   width: 50,
                   height: 50,

                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     border: Border.all(color: Colors.white,width: 2),
                     image: DecorationImage(
                         image: AssetImage(post.profileImage),
                       fit: BoxFit.cover,
                     ),
                   ),


                 ),

              ],
                 ),
               ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right:180,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isLiked ? Icons.favorite: Icons.favorite_outline_sharp,
                        size:35,
                        color: post.isLiked ? Colors.red :Colors.black,

                      ),
                      onPressed: (){
                      _toggleLike(post.id);
                      },

                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/svgs/comment.svg',
                        height: 35,
                        width: 35,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/svgs/share.svg',
                        height: 25,
                        width: 28,
                      ),
                      onPressed: () {},
                    ),

                  ],

                ),


              ),
              Transform.translate(
                offset: Offset(160,-50),
            child:IconButton(
                icon: Icon(
                  post.save ? Icons.bookmarks_rounded:Icons.bookmarks_outlined,
                  // Icons.bookmarks_outlined,
                size:35,
                ),
              onPressed:() {
                  _toggleSave(post.id);

              },

            ),
                  ),
            Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  // top:10.0
                ),
              child: StatefulBuilder(
                  builder:(BuildContext context,setState){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                        offset: Offset(0,-40),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(post.userName),
                        Text(
                          post.postText,
                          maxLines: isExpended ? null :2,
                          overflow: isExpended
                            ? TextOverflow.visible
                            :  TextOverflow.ellipsis,
                        ),
                        GestureDetector(
                    onTap: () {
                      setState((){
                        isExpended = !isExpended;
                    });
                    },
                    child: Text(
                    isExpended ? 'Show less': 'Continue reading',
                    style: TextStyle(color: Colors.blue)
                    )
                        ),
                        ],
                    ),
                    ),
                      ],
                    );
                  }
              ),
            ),



            ],


  );


            }).toList()


        ),



    );

  }
}

