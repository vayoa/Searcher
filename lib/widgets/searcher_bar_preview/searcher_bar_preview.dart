import 'dart:math' as math show pi, min;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/states/blocs/searcher_bloc/searcher_bloc.dart';
import 'package:searcher_app/states/blocs/searcher_preview_bloc/searcher_preview_bloc.dart';
import 'package:searcher_app/states/provider/searcher_app_state.dart';
import 'package:searcher_app/widgets/searcher_bar/local_widgets/animated_waves.dart';
import 'package:searcher_app/widgets/searcher_bar_preview/local_widgets/searcher_bar_autocomplete.dart';

class SearcherBarPreview extends StatefulWidget {
  const SearcherBarPreview({
    Key? key,
  }) : super(key: key);

  @override
  _SearcherBarPreviewState createState() => _SearcherBarPreviewState();
}

class _SearcherBarPreviewState extends State<SearcherBarPreview> {
  bool previewTitleBarShown = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Provider.of<SearcherAppState>(context, listen: false).previewBloc,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxHeight = MediaQuery.of(context).size.height;
          final double height =
              math.min(maxHeight - (previewTitleBarShown ? 109 : 95), 410);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: height,
                      child: BlocConsumer<SearcherPreviewBloc,
                          SearcherPreviewState>(
                        listener: (context, state) {
                          setState(() {
                            previewTitleBarShown =
                                BlocProvider.of<SearcherPreviewBloc>(context)
                                        .previews
                                        .length >
                                    1;
                          });
                        },
                        builder: (context, state) => state.preview,
                      ),
                    ),
                    SearcherBarMobileAutocomplete(maxHeight: height),
                  ],
                ),
                PreviewTitleBar(
                  show: previewTitleBarShown,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SearcherBarMobileAutocomplete extends StatelessWidget {
  const SearcherBarMobileAutocomplete({
    Key? key,
    required this.maxHeight,
  }) : super(key: key);

  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearcherPreviewBloc, SearcherPreviewState>(
      builder: (context, state) {
        if (state is AutocompletePreview) return Container();
        return BlocBuilder<SearcherBloc, SearcherState>(
          bloc: Provider.of<SearcherAppState>(context).searcherBloc,
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => SizeFadeTransition(
                  sizeFraction: 0.8, animation: animation, child: child),
              child: state is SearcherSuggestionsDone ||
                      state is SearcherSuggestionsLoading
                  ? SizedBox(
                      height: math.min(maxHeight, 270),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 5.0,
                        ),
                        child: Container(
                          width: 840,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Stack(
                              children: [
                                Transform.rotate(
                                    angle: math.pi,
                                    alignment: Alignment.center,
                                    child: AnimatedWaves(incognito: true)),
                                SearcherBarAutocomplete(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            );
          },
        );
      },
    );
  }
}

class PreviewTitleBar extends StatelessWidget {
  const PreviewTitleBar({
    Key? key,
    required this.show,
  }) : super(key: key);

  final bool show;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: show
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  thickness: 2.0,
                  height: 1.0,
                ),
                Container(
                  height: 14.0,
                  color: Colors.black12,
                  child:
                      ImplicitlyAnimatedReorderableList<SearcherPreviewState>(
                    items: BlocProvider.of<SearcherPreviewBloc>(context,
                            listen: true)
                        .previews,
                    scrollDirection: Axis.horizontal,
                    removeItemBuilder: (context, animation, preview) =>
                        Reorderable(
                      key:
                          ValueKey(preview.title + preview.globalID.toString()),
                      child: SizeFadeTransition(
                        animation: animation,
                        sizeFraction: 0.7,
                        child: PreviewTitle(preview: preview, shown: false),
                      ),
                    ),
                    areItemsTheSame: (preview1, preview2) {
                      if (preview1.single != preview2.single)
                        return false;
                      else if (preview1.single)
                        return preview1.globalID == preview2.globalID;
                      else
                        return preview1.globalID == preview2.globalID;
                    },
                    onReorderFinished: (preview, from, to, newPreviews) {
                      BlocProvider.of<SearcherPreviewBloc>(context)
                          .add(MovePreview(from: from, to: to));
                    },
                    itemBuilder: (context, animation, preview, index) {
                      final bloc =
                          BlocProvider.of<SearcherPreviewBloc>(context);
                      return Reorderable(
                        key: ValueKey(
                            preview.title + preview.globalID.toString()),
                        child: ClipRect(
                          child: SlideTransition(
                            position: Tween<Offset>(
                                    begin: Offset(-1.0, 0.0), end: Offset.zero)
                                .animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut)),
                            child: PreviewTitle(
                              preview: preview,
                              shown: index == bloc.shown,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Container(height: 0, width: 0),
    );
  }
}

class PreviewTitle extends StatelessWidget {
  const PreviewTitle({
    Key? key,
    required this.preview,
    required this.shown,
  }) : super(key: key);

  final SearcherPreviewState preview;
  final bool shown;

  @override
  Widget build(BuildContext context) {
    final int count = preview.instanceID;
    String title = this.preview.title;
    if (count != 0) {
      title += ' ($count)';
    }
    return GestureDetector(
      onTap: () {
        BlocProvider.of<SearcherPreviewBloc>(context)
            .add(OpenPreview(preview: preview, instance: preview.globalID));
      },
      child: Handle(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10.0,
                color:
                    this.shown ? Colors.white.withOpacity(0.5) : Colors.black45,
              ),
            ),
            VerticalDivider(
              thickness: 1.0,
              width: 8.0,
              indent: 3.0,
              endIndent: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}
