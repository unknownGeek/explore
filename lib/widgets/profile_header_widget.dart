import 'package:cached_network_image/cached_network_image.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/ActivityPage.dart';
import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final User user;

  const ProfileHeaderWidget({
    @required this.user,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),//25
            bottomRight: Radius.circular(30),
          ),
        ),
        height: 50,
        padding: EdgeInsets.all(1).copyWith(left: 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackButton(color: Colors.white),
                GestureDetector(
                  onTap: () => showProfile(context, profileId: user.id),
                  child: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url), backgroundColor: Colors.grey, radius: 16,),
                ),
                Padding(padding: EdgeInsets.all(10).copyWith(left: 0)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => showProfile(context, profileId: user.id),
                    child: Text(
                      user.profileName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildIcon(Icons.call),
                    SizedBox(width: 12),
                    buildIcon(Icons.videocam),
                  ],
                ),
                SizedBox(width: 4),
              ],
            )
          ],
        ),
      );

  Widget buildIcon(IconData icon) => Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white54,
        ),
        child: Icon(icon, size: 25, color: Colors.white),
      );
}
