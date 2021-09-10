import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/states/provider/searcher_app_state.dart';

class SearcherButtons extends StatelessWidget {
  const SearcherButtons({
    Key? key,
    required this.initialSearcherMode,
    required this.clear,
    required this.submit,
  }) : super(key: key);

  final SearcherMode initialSearcherMode;
  final void Function() clear;
  final void Function() submit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SearcherButton(
          icon: Icons.close,
          onPressed: this.clear,
        ),
        VerticalDivider(
          thickness: 1.5,
          indent: 4.0,
          endIndent: 4.0,
        ),
        MainSearcherButton(
          onPressed: this.submit,
        ),
      ],
    );
  }
}

class SearcherButton extends StatelessWidget {
  const SearcherButton({
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
        focusNode: FocusNode(canRequestFocus: false, skipTraversal: true),
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
    required this.onPressed,
  }) : super(key: key);

  final void Function() onPressed;

  @override
  _MainSearcherButtonState createState() => _MainSearcherButtonState();
}

class _MainSearcherButtonState extends State<MainSearcherButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late SearcherMode _currentMode;
  late SearcherMode _newMode;

  IconData _getButtonIcon(SearcherMode mode) {
    switch (mode) {
      case SearcherMode.search:
        return Icons.search;
      case SearcherMode.searcherCommand:
        return Icons.adjust_outlined;
      case SearcherMode.terminal:
        return Icons.double_arrow_outlined;
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    this._currentMode = Provider.of<SearcherAppState>(context, listen: false)
        .currentSearcherMode;
    _newMode = _currentMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    return ClipRect(
      child: Selector<SearcherAppState, SearcherMode>(
          selector: (_, state) => state.currentSearcherMode,
          builder: (context, switchedMode, _) {
            SearcherMode switchedMode =
                Provider.of<SearcherAppState>(context, listen: false)
                    .currentSearcherMode;
            if (_currentMode != switchedMode) {
              _newMode = switchedMode;
              _animationController.forward().then((value) {
                _animationController.value = 0.0;
                setState(() {
                  _currentMode = _newMode;
                });
              });
            }
            return Stack(
              children: [
                FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                      CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(0.0, 0.3))),
                  child: SlideTransition(
                    position:
                        Tween<Offset>(begin: Offset.zero, end: Offset(1.0, 0.0))
                            .animate(curvedAnimation),
                    child: SearcherButton(
                      icon: _getButtonIcon(_currentMode),
                      onPressed: widget.onPressed,
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(0.3, 1.0))),
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(-1.0, 0.0), end: Offset.zero)
                        .animate(curvedAnimation),
                    child: IgnorePointer(
                      child: SearcherButton(
                        icon: _getButtonIcon(_newMode),
                        onPressed: widget.onPressed,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
