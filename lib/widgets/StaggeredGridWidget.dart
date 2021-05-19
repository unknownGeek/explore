import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StaggeredGridWidget extends StatelessWidget {

  @override
    Widget build(BuildContext context) => StaggeredGridView.countBuilder(
    staggeredTileBuilder: (index) =>
    index % 7 == 0 ? StaggeredTile.count(2, 2) : StaggeredTile.count(1, 1),
    // StaggeredTile.fit(2),
    crossAxisCount: 4,
    mainAxisSpacing: 1,
    crossAxisSpacing: 1,
    itemCount: 150,
    itemBuilder: (context, index) => buildImageCard(index),
  );

  Widget buildImageCard(int index) => Card(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Container(
      margin: EdgeInsets.all(3.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        // child: Image.network(
        //   'https://source.unsplash.com/random?sig=$index',
        //   fit: BoxFit.cover,
        // ),
        child: CachedNetworkImage(
          imageUrl: 'https://source.unsplash.com/random?sig=$index',
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // placeholder: (context, url) => circularProgress(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    ),
  );
}