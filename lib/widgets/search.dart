import 'package:flutter/material.dart';
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/models/post.dart';

class SearchBarApp extends StatefulWidget{
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp>{
  bool isDark = false;
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
          appBar: AppBar(
            title:  Padding(
              padding: const EdgeInsets.all(0.0),
              child: SearchAnchor(

                  builder: (BuildContext context,  SearchController controller){
                    return SizedBox(
                      height: 35,
                      child:SearchBar(
                        hintText: "Search",
                        controller: controller,
                        padding: const MaterialStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0)
                        ),
                        onTap: (){
                          controller.openView();
                        },
                        onChanged: (_){
                          controller.openView();
                        },
                        leading: const Icon(Icons.search),
                        trailing: <Widget>[

                        ],
                      ),
                    );
                  }, suggestionsBuilder: (BuildContext context, SearchController controller){
                return List<ListTile>.generate(posts.length,(int index){
                  final Post  post = posts[index];
                  return ListTile(
                    title: Text(post.userName),
                    onTap:(){
                      setState(() {
                        controller.closeView(post.userName);
                      });
                    },
                  );

                });
              }
              ),
            ),
          ),
          body: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index ){
                final  post = posts[index];
                return GestureDetector(
                    onTap: (){
                      // Navigator.push(context,
                      // MaterialPageRoute(
                      //     builder:(context) =>
                      //         PostPage()
                      // ),
                      // );

                    },

                    child:   Container(
                      height: 50,
                      width: 50,
                      decoration:   BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.greenAccent),
                        image: post.imagePath != null
                            ?DecorationImage(
                          image: AssetImage(post.imagePath!),
                          fit: BoxFit.cover,
                        ) :null,

                      ),
                    )
                );
              }
          )

      ),
    );
  }
}