import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/models/comments.dart';
import 'package:ismatov/widgets/comments_widget.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/video_player_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostItem extends StatefulWidget {
  final UserProfile? userProfile;
  final Post post;
  final String token;
  final void Function(Post)? onLikeToggle;
  const PostItem({
    Key? key,
    required this.post,
    required this.token,
    this.userProfile,
    this.onLikeToggle,

  }) : super(key:key);

  @override
  State<PostItem> createState() => _PostItemState();
}
class _PostItemState extends State<PostItem>{
  bool isLiked = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.liked;
  }

  void handleLike() async {
    if (widget.token.isEmpty) return;
    try {
      bool wasLiked = widget.post.liked;
      final updatePost = await PostService().toggleLike(
          postId: widget.post.id,
          isLiked: widget.post.liked,
          token: widget.token
      );
      setState(() {
        widget.post.liked = updatePost.liked;
        widget.post.likeId =  updatePost.likeId;
        if (!wasLiked && updatePost.liked) {
          widget.post.likeCount += 1;
        } else if (wasLiked && !updatePost.liked) {
          widget.post.likeCount -= 1;
        }
      });
      widget.onLikeToggle?.call(widget.post);
    } catch (e) {
      print("Error Like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final hasVideo = post.postVideo != null;
    final hasImage = post.postImage != null;
    final userName = post.userName.isNotEmpty ? post.userName : 'default';
    final profileImage = post.ownerProfileImage?.isNotEmpty == true
    ? post.ownerProfileImage
    : null;


    return SingleChildScrollView(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8 ),
          child: Row(
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundImage: profileImage != null
                      ? NetworkImage(profileImage)
                      : const AssetImage('assets/images/nouser.png')
                  as ImageProvider,
                ),
                const SizedBox(width: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ]
          )

      ),
      if (hasVideo)
        SizedBox(
    width: double.infinity,
    height: 06.sh,
    child: VideoPost(
    url: post.postVideo.toString(),
    id: post.id.toString(),
    )
        )

    else if (hasImage)
    Image.network(
    post.postImage!,
    fit: BoxFit.cover,
    width: 1.sw,
    height: 0.6.sh,
    )
    else
    Container(
      width: double.infinity,
    height: 400.h,
    color: Colors.black12,
    ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content ?? "",
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black54, fontWeight: FontWeight.bold,
              ),
            ),
        if ((post.content?.length ?? 0) > 100)
          TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              }, child: Text(
            isExpanded ? "Show less": "Continue reading"
          )),


        Row(
          children: [
            IconButton(
                onPressed: handleLike,
                icon: Icon(
                  widget.post.liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.post.liked ? Colors.red : Colors.black54,
                  size: 35,
                )
            ),
            Text("${widget.post.likeCount}",
                style: const TextStyle(color: Colors.black)),
            IconButton(
              icon: SvgPicture.asset(
                'assets/svgs/comment.svg',
                height: 35,
                width: 35,
              ),
              onPressed: () => _showComments(context, post.id),
            ),
            Text("${widget.post.comments.length}",
            style: const TextStyle(color: Colors.black),
            )
            
            // IconButton(
            //   icon: SvgPicture.asset(
            //     'assets/svgs/share.svg',
            //     height: 35,
            //     width: 35,
            //   ),
            //   onPressed: (){},
            // ),
        ]
        ),
    ],

      ),
      )
    ],
    )

            );

  }

  void _showComments(BuildContext context, int postId) async {
    final isCommentAdded = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.white,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: CommentsPage(
                      token: widget.token,
                      postId: postId,
                    onCommentAdded: () {
                        Navigator.pop(context, true);
                    },
                  ),

                ),
              ),
          );


        }

    );
    // if (isCommentAdded == true) {
    //   setState(() {
    //     widget.post.comments.add(Comment(id: widget.post.comments.));
    //   });
    // }

  }


}