import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class SearcherNotesPreview extends StatelessWidget {
  const SearcherNotesPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Note(
            child: Text('Hey'),
          ),
          Note(
            child: Text('Hey'),
          ),
        ],
      ),
    );
  }
}

class Note extends StatelessWidget {
  const Note({
    Key? key,
    required this.child,
    this.title = '',
  }) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 170, minWidth: 170),
          child: GlassContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(this.title),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 20.0,
              splashRadius: 18.0,
              color: Colors.white.withOpacity(0.6),
              icon: Icon(Icons.delete),
              onPressed: () {},
            )
          ],
        )
      ],
    );
  }
}
