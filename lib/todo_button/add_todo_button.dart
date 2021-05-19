import 'package:explore/widgets/StaggeredGridWidget.dart';
import 'package:flutter/material.dart';

import 'custom_rect_tween.dart';
import 'hero_dialog_route.dart';

/// {@template add_todo_button}
/// Button to add a new [Todo].
///
/// Opens a [HeroDialogRoute] of [_AddTodoPopupCard].
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class AddTodoButton extends StatelessWidget {
  /// {@macro add_todo_button}
  const AddTodoButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // final User user = User(
    //   id: '1',
    //   profileName: 'One',
    //   username: 'one@1',
    //   url: 'www.google.com',
    //   email: 'one1@one.com',
    //   bio: '1one1',
    //   state: 1,
    // );

    return Padding(
      padding: const EdgeInsets.all(.1),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return _AddTodoPopupCard();
          }));
        },
        child: Hero(
          tag: _heroAddTodo,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Material(
            color: Colors.deepPurple,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: const Icon(
              Icons.face,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tag-value used for the add todo popup button.
const String _heroAddTodo = 'add-todo-hero';

/// {@template add_todo_popup_card}
/// Popup card to add a new [Todo]. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class _AddTodoPopupCard extends StatelessWidget {
  /// {@macro add_todo_popup_card}
  _AddTodoPopupCard({
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 80.0, right: 1.0,),
        child: Hero(
          tag: _heroAddTodo,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: StaggeredGridWidget(),
          // child: Material(
          //   color: Colors.deepPurple,
          //   elevation: 2,
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          //   child: SingleChildScrollView(
          //     child: Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'New todo',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'Write a note',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //             maxLines: 6,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'New todo',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'Write a note',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //             maxLines: 6,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'New todo',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'Write a note',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //             maxLines: 6,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'New todo',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'Write a note',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //             maxLines: 6,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'New todo',
          //               border: InputBorder.none,
          //               hintStyle: TextStyle(color: Colors.white),
          //             ),
          //             cursorColor: Colors.white,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           const TextField(
          //             decoration: InputDecoration(
          //               hintText: 'Write a note',
          //               hintStyle: TextStyle(color: Colors.white),
          //               border: InputBorder.none,
          //             ),
          //             cursorColor: Colors.white,
          //             maxLines: 6,
          //           ),
          //           const Divider(
          //             color: Colors.white,
          //             thickness: 0.2,
          //           ),
          //           FlatButton(
          //             onPressed: () {},
          //             child: const Text('Add', style: TextStyle(color: Colors.white),),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}
