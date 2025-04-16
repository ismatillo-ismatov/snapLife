import 'package:flutter/cupertino.dart';
import 'package:ismatov/models/friends.dart';
import 'package:ismatov/models/friendsList.dart';
import 'package:ismatov/widgets/friendListItem.dart';

class FriendList extends StatelessWidget {
  final List<Friend> friends;
  final Function(Friend)? onFriendTap;

  const FriendList({
    Key? key,
    required this.friends,
    this.onFriendTap,
}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      itemBuilder: (context,index){
      final friend = friends[index];
      return FriendListItem(
        friend:friend,
        onTap: () => onFriendTap?.call(friend),
      );
      }
    );
  }
}