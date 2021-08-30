import 'package:flutter/material.dart';

class SearcherButtons extends StatelessWidget {
  const SearcherButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SearcherButton(
          icon: Icons.close,
          onPressed: () {},
        ),
        VerticalDivider(
          thickness: 1.5,
          indent: 4.0,
          endIndent: 4.0,
        ),
        SearcherButton(
          icon: Icons.search,
          onPressed: () {},
        )
      ],
    );
  }
}

class SearcherButton extends StatelessWidget {
  SearcherButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super();
  final IconData icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        iconSize: 20.0,
        splashRadius: 20.0,
        icon: Icon(
          this.icon,
        ),
        onPressed: this.onPressed,
      ),
    );
  }
}