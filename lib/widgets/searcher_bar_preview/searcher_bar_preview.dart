import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
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
                    listener: (context, state) {},
                    builder: (context, state) {
                      return ImplicitlyAnimatedReorderableList<
                          SearcherPreviewState>(
                        items: BlocProvider.of<SearcherPreviewBloc>(context,
                                listen: true)
                            .previews,
                        scrollDirection: Axis.horizontal,
                        removeItemBuilder: (context, animation, preview) =>
                            Reorderable(
                          key: ValueKey(
                              preview.title + preview.globalID.toString()),
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
                                        begin: Offset(-1.0, 0.0),
                                        end: Offset.zero)
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
