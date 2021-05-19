import 'package:cached_network_image/cached_network_image.dart';
import 'package:explore/pages/PostScreenPage.dart';
import 'package:explore/widgets/PostWidget.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class StaggeredPostTileWidget extends StatelessWidget {
  List<Post> postsList;
  final int index;

  StaggeredPostTileWidget(this.index, this.postsList);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreenPage(
              postId: postsList[index].postId,
              userId: postsList[index].ownerId,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          margin: EdgeInsets.all(3.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: postsList[index].url,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
              placeholder: (context, url) => circularProgress(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
      onTap: () => showPost(context),
    );
  }
}
