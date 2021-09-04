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
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();

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
                    builder: (context, state) {
                      return state.preview;
                    },
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
                      if (state is UpdatingPreview) {
                        _animatedListKey.currentState!.removeItem(
                            state.from,
                            (context, animation) =>
                                PreviewTitle(title: state.title, shown: false));
                        _animatedListKey.currentState!.insertItem(state.to);
                      } else if (state is RemovedPreview) {
                        _animatedListKey.currentState!.removeItem(
                            state.from,
                            (context, animation) =>
                                PreviewTitle(title: state.title, shown: false));
                      } else if (state is AddedPreview) {
                        _animatedListKey.currentState!.insertItem(state.to);
                      }
                    },
                    builder: (context, state) {
                      final bloc =
                          BlocProvider.of<SearcherPreviewBloc>(context);
                      return AnimatedList(
                        key: _animatedListKey,
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        initialItemCount: bloc.previews.length,
                        itemBuilder: (context, index, animation) {
                          return PreviewTitle(
                            title: bloc.previews[index].title,
                            shown: index == 0,
                            last: index == bloc.previews.length - 1,
                          );
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

class PreviewTitle extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          this.title,
          style: TextStyle(
            fontSize: 10.0,
            color: this.shown ? Colors.white.withOpacity(0.5) : Colors.black45,
          ),
        ),
        last
            ? Container(width: 0, height: 0)
            : VerticalDivider(
                thickness: 1.0,
                width: 8.0,
                indent: 3.0,
                endIndent: 2.0,
              ),
      ],
    );
  }
}
