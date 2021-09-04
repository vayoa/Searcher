import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/states/blocs/searcher_preview_bloc/searcher_preview_bloc.dart';
import 'package:searcher_app/states/provider/searcher_app_state.dart';

class SearcherBarPreview extends StatefulWidget {
  const SearcherBarPreview({
    Key? key,
  }) : super(key: key);

  @override
  _SearcherBarPreviewState createState() => _SearcherBarPreviewState();
}

class _SearcherBarPreviewState extends State<SearcherBarPreview> {
  List<PreviewTitle> previewTitles = [];
  List<GlobalKey<_PreviewTitleState>> keys = [];

  @override
  void initState() {
    _fillLists(previewTitles, keys);
    super.initState();
  }

  _fillLists(
      List<PreviewTitle> titles, List<GlobalKey<_PreviewTitleState>> keys) {
    final bloc =
        Provider.of<SearcherAppState>(context, listen: false).previewBloc;
    for (var i = 0; i < bloc.previews.length; i++) {
      final preview = bloc.previews[i];
      /* TODO: If adding the ability of multiple instances of the same preview
          type, make sure this is either changed or accounted for. */
      final key = GlobalKey<_PreviewTitleState>();
      keys.add(key);
      titles.add(PreviewTitle(key: key, title: preview.title, shown: i == 0));
    }
  }

  updateShownFlag() {
    final List<PreviewTitle> newList = [];
    keys = [];
    _fillLists(newList, keys);
    previewTitles = newList;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Provider.of<SearcherAppState>(context, listen: false).previewBloc,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxHeight = MediaQuery.of(context).size.height;
          final double height = min(maxHeight - 116, 410);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height,
                  child: BlocBuilder<SearcherPreviewBloc, SearcherPreviewState>(
                    builder: (context, state) => state.preview,
                  ),
                ),
                Divider(
                  thickness: 2.0,
                  height: 1.0,
                ),
                Container(
                  height: 14.0,
                  color: Colors.transparent,
                  child:
                      BlocConsumer<SearcherPreviewBloc, SearcherPreviewState>(
                    listener: (context, state) {
                      final bloc =
                          BlocProvider.of<SearcherPreviewBloc>(context);
                      if (state is UpdatingPreview) {
                        final preview = previewTitles[state.from];
                        final previous = previewTitles[state.to];
                        previewTitles[state.from] = previous;
                        previewTitles[state.to] = preview;
                      } else if (state is RemovedPreview) {
                        keys[state.from].currentState!.reverse();
                        previewTitles.removeAt(state.from);
                      } else if (state is AddedPreview) {
                        final key = GlobalKey<_PreviewTitleState>();
                        keys.insert(state.to, key);
                        previewTitles.insert(
                            state.to,
                            PreviewTitle(
                                key: key,
                                title: state.title,
                                shown: state.to == 0));
                        key.currentState!.forward();
                      }
                      updateShownFlag();
                    },
                    builder: (context, state) {
                      final bloc =
                          BlocProvider.of<SearcherPreviewBloc>(context);
                      return ReorderableListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bloc.previews.length,
                        itemBuilder: (context, index) => previewTitles[index],
                        onReorder: (int oldIndex, int newIndex) {
                          if (newIndex == bloc.previews.length) newIndex--;
                          bloc.add(MovePreview(from: oldIndex, to: newIndex));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PreviewTitle extends StatefulWidget {
  const PreviewTitle({
    Key? key,
    required this.title,
    required this.shown,
    this.last = false,
  }) : super(key: key);

  final String title;
  final bool shown;
  final bool last;

  @override
  _PreviewTitleState createState() => _PreviewTitleState();
}

class _PreviewTitleState extends State<PreviewTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    super.initState();
  }

  forward() => _animationController.forward();

  reverse() => _animationController.reverse();

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_animationController),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            this.widget.title,
            style: TextStyle(
              fontSize: 10.0,
              color: this.widget.shown
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black45,
            ),
          ),
          widget.last
              ? Container(width: 0, height: 0)
              : VerticalDivider(
                  thickness: 1.0,
                  width: 8.0,
                  indent: 3.0,
                  endIndent: 2.0,
                ),
        ],
      ),
    );
  }
}
