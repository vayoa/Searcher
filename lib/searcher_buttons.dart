import 'package:flutter/material.dart';
import 'package:searcher_app/searcher_bar.dart';

class SearcherButtons extends StatelessWidget {
  const SearcherButtons({
    Key? key,
    required this.initialSearcherMode,
  }) : super(key: key);

  final SearcherMode initialSearcherMode;

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
        MainSearcherButton(
          initialSearcherMode: initialSearcherMode,
          onPressed: () {},
        ),
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

class MainSearcherButton extends StatefulWidget {
  const MainSearcherButton({
    Key? key,
    required this.initialSearcherMode,
    required this.onPressed,
  }) : super(key: key);

  final SearcherMode initialSearcherMode;
  final void Function() onPressed;

  @override
  _MainSearcherButtonState createState() => _MainSearcherButtonState();
}

class _MainSearcherButtonState extends State<MainSearcherButton> {
  late SearcherMode _searcherMode;

  @override
  void initState() {
    _searcherMode = widget.initialSearcherMode;
    super.initState();
  }

  IconData _getButtonIcon() {
    switch (_searcherMode) {
      case SearcherMode.search:
        return Icons.search;
      case SearcherMode.searcherCommand:
        return Icons.adjust_outlined;
      case SearcherMode.terminal:
        return Icons.double_arrow_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    /* TODO: Switch the icon based on the current searcher mode with a
        slide-fade animation. */
    return SearcherButton(
      icon: _getButtonIcon(),
      onPressed: widget.onPressed,
    );
  }
}
