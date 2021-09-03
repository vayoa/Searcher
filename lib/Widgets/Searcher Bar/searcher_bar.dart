import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/States/Blocs/Searcher%20Bloc/searcher_bloc.dart';
import 'package:searcher_app/States/Provider/searcher_app_state.dart';
import 'package:searcher_app/Widgets/Searcher%20Bar/local%20widgets/searcher_buttons.dart';
import 'local widgets/animated_waves.dart';
import 'local widgets/group_chip.dart';

class SearcherBar extends StatefulWidget {
  const SearcherBar({
    Key? key,
  }) : super(key: key);

  @override
  _SearcherBarState createState() => _SearcherBarState();
}

class _SearcherBarState extends State<SearcherBar> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _searchBarFocusNode = FocusNode();
  final FocusNode _suggestionsFocusNode = FocusNode();

  @override
  void dispose() {
    _searchBarFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 850, minWidth: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<SearcherAppState>(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 12,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GroupChip(selected: false),
                        ],
                      ),
                    ),
                  ),
                ),
                builder: (context, state, child) {
                  return Material(
                    elevation: 15.0,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25.0),
                    child: SizedBox(
                      height: 65,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedWaves(),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                color: state.incognito
                                    ? Colors.grey[800]!.withOpacity(0.64)
                                    : Colors.grey[400]!.withOpacity(0.64),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 8.0),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ShiftRightFixer(
                                              suggestionsFocusNode:
                                                  _suggestionsFocusNode,
                                              child: BlocListener<SearcherBloc,
                                                  SearcherState>(
                                                bloc: state.searcherBloc,
                                                listener: (context, state) {
                                                  if (state
                                                      is SearcherSuggestionsClear) {
                                                    _textEditingController
                                                        .clear();
                                                    _searchBarFocusNode
                                                        .requestFocus();
                                                  }
                                                },
                                                child: TextField(
                                                  controller:
                                                      _textEditingController,
                                                  autofocus: true,
                                                  focusNode:
                                                      _searchBarFocusNode,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  style: TextStyle(
                                                      color: state.incognito
                                                          ? Colors.grey[200]
                                                          : Colors.black),
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: 'Search...',
                                                    hintStyle: const TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                  onSubmitted: (query) =>
                                                      state.run(query),
                                                  onChanged: (query) => state
                                                      .getSuggestions(query),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SearcherButtons(
                                            initialSearcherMode:
                                                state.currentSearcherMode,
                                            clear: () => state.searcherBloc
                                                .add(ClearSuggestions()),
                                            submit: () => state.run(
                                                _textEditingController.text),
                                          ),
                                        ],
                                      ),
                                    ),
                                    child!,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            LayoutBuilder(builder: (context, constraints) {
              final double maxHeight = MediaQuery.of(context).size.height;
              final double height = min(maxHeight - 95, 410);
              return SizedBox(
                height: height,
                child: BlocBuilder<SearcherBloc, SearcherState>(
                  bloc: Provider.of<SearcherAppState>(context, listen: false)
                      .searcherBloc,
                  builder: (context, state) {
                    if (state is SearcherSuggestionsDone) {
                      final suggestionsMap = state.suggestions;
                      final formattedQuery = state.formattedText;
                      print(formattedQuery);
                      final List<String> suggestionsList =
                          suggestionsMap.keys.toList();
                      final List<String> descriptionsList =
                          suggestionsMap.values.toList();
                      final bolded = formattedQuery.toLowerCase();
                      if (bolded.isNotEmpty && suggestionsList.isNotEmpty) {
                        return Focus(
                          focusNode: _suggestionsFocusNode,
                          child: ListView.builder(
                            itemCount: suggestionsList.length,
                            itemExtent: 50.0,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final hasDescription =
                                  descriptionsList[index].isNotEmpty;
                              final suggestion = suggestionsList[index];
                              final boldedIndex = suggestion.indexOf(bolded);
                              RichText title;
                              if (boldedIndex == -1) {
                                title = RichText(
                                    text: TextSpan(
                                        text: suggestion,
                                        style: TextStyle(
                                            color: Colors.grey[300])));
                              } else if (boldedIndex == 0) {
                                final remainder =
                                    suggestion.substring(bolded.length);
                                title = RichText(
                                  text: TextSpan(
                                      text: bolded,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[300]),
                                      children: [
                                        TextSpan(
                                            text: remainder,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal))
                                      ]),
                                );
                              } else if (boldedIndex !=
                                  suggestion.length - bolded.length) {
                                final left =
                                    suggestion.substring(0, boldedIndex);
                                final right = suggestion
                                    .substring(boldedIndex + bolded.length);
                                title = RichText(
                                  text: TextSpan(
                                      text: left,
                                      style: TextStyle(color: Colors.grey[300]),
                                      children: [
                                        TextSpan(
                                            text: bolded,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text: right,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal))
                                      ]),
                                );
                              } else {
                                final remainder =
                                    suggestion.substring(0, boldedIndex);
                                title = RichText(
                                    text: TextSpan(
                                        text: remainder,
                                        style:
                                            TextStyle(color: Colors.grey[300]),
                                        children: [
                                      TextSpan(
                                          text: bolded,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ]));
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: Container(
                                  child: ListTile(
                                    title: title,
                                    subtitle: hasDescription
                                        ? Text(descriptionsList[index],
                                            style: TextStyle(
                                                color: Colors.grey[500]))
                                        : null,
                                    visualDensity: VisualDensity.compact,
                                    dense: hasDescription,
                                    minVerticalPadding: 0.0,
                                    hoverColor: Colors.black12,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    onTap: () => Provider.of<SearcherAppState>(
                                            context,
                                            listen: false)
                                        .runInCurrentMode(suggestion),
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black26))),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    }
                    return SizedBox(width: 0, height: 0);
                  },
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}

final Map<String, String> searcherCommands = {
  'incognito': 'Switches whether Chrome will open in incognito mode or not.',
  'note': 'Save a new note.',
  'notes': 'Display all of your saved notes.',
};

// Code from:
// https://github.com/flutter/flutter/issues/75675#issuecomment-831581709.
class ShiftRightFixer extends StatefulWidget {
  ShiftRightFixer({
    required this.child,
    required this.suggestionsFocusNode,
  });

  final Widget child;
  final FocusNode suggestionsFocusNode;

  @override
  State<StatefulWidget> createState() => _ShiftRightFixerState();
}

class _ShiftRightFixerState extends State<ShiftRightFixer> {
  final FocusNode focus =
      FocusNode(skipTraversal: true, canRequestFocus: false);

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focus,
      onKey: (_, RawKeyEvent event) {
        if (event.physicalKey == PhysicalKeyboardKey.numpad2 ||
            event.physicalKey == PhysicalKeyboardKey.arrowDown) {
          print('hey');
          widget.suggestionsFocusNode.nextFocus();
          // widget.suggestionsFocusNode.requestFocus();
          return KeyEventResult.handled;
        }
        return event.physicalKey == PhysicalKeyboardKey.shiftRight
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
