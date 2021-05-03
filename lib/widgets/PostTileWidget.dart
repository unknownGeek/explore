import 'package:cached_network_image/cached_network_image.dart';
import 'package:explore/pages/PostScreenPage.dart';
import 'package:explore/widgets/PostWidget.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {

  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreenPage(
              postId: post.postId,
              userId: post.ownerId,
            )));
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child:
      Container(
        height: 200.0,
        width: 350.0,
        child: CachedNetworkImage(
          imageUrl: post.url,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
      onTap: () => showPost(context),
    );
  }
}
