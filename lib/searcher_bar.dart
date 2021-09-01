import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'package:searcher_app/searcher_buttons.dart';
import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';
import 'group_chip.dart';

enum SearcherMode {
  search,
  searcherCommand,
  terminal,
}

class SearcherBar extends StatefulWidget {
  const SearcherBar({
    Key? key,
  }) : super(key: key);

  @override
  _SearcherBarState createState() => _SearcherBarState();
}

class _SearcherBarState extends State<SearcherBar> {
  final double padding = 14.0;
  final TextEditingController _textEditingController = TextEditingController();
  ValueNotifier<Map<String, String>> suggestions = ValueNotifier(const {});
  bool incognito = true;
  FocusNode _searchBarFocusNode = FocusNode();
  String formattedQuery = '';
  SearcherMode mode = SearcherMode.search;

  @override
  void dispose() {
    _searchBarFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 26.0, left: 8.0, right: 8.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 850, minWidth: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    elevation: 15.0,
                    color: incognito ? Colors.grey[800] : Colors.grey[400],
                    borderRadius: BorderRadius.circular(32.0),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 8.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 65,
                          minHeight: 65,
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: padding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ShiftRightFixer(
                                      child: TextField(
                                        controller: _textEditingController,
                                        autofocus: true,
                                        focusNode: _searchBarFocusNode,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: TextStyle(
                                            color: incognito
                                                ? Colors.grey[200]
                                                : Colors.black),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Search...',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                        onSubmitted: (query) async {
                                          SearcherMode newMode;
                                          final trim = query.trim();
                                          if (trim.startsWith('!>')) {
                                            newMode =
                                                SearcherMode.searcherCommand;
                                            final command =
                                                trim.substring(2).trim();
                                            switch (command) {
                                              case 'incognito':
                                                setState(() {
                                                  incognito = !incognito;
                                                });
                                                break;
                                            }
                                          } else if (trim.startsWith('>>')) {
                                            newMode = SearcherMode.terminal;
                                            final command =
                                                trim.substring(2).trim();
                                            await runCommand(command);
                                          } else {
                                            newMode = SearcherMode.search;
                                            await search(query);
                                          }
                                          suggestions.value = const {};
                                          _textEditingController.clear();
                                          _searchBarFocusNode.requestFocus();
                                          updateMode(newMode);
                                        },
                                        onChanged: (newQuery) async {
                                          final trim = newQuery.trim();
                                          if (trim.startsWith('!>')) {
                                            final command =
                                                trim.substring(2).trim();
                                            final Map<String, String>
                                                newSuggestions = {};
                                            for (String searcherCommand
                                                in searcherCommands.keys) {
                                              final double matchPercentage =
                                                  StringSimilarity
                                                      .compareTwoStrings(
                                                          searcherCommand,
                                                          command);
                                              if (searcherCommand
                                                      .contains(command) ||
                                                  matchPercentage >= 0.5)
                                                newSuggestions[
                                                        searcherCommand] =
                                                    searcherCommands[
                                                        searcherCommand]!;
                                            }
                                            formattedQuery = command;
                                            suggestions.value = newSuggestions;
                                            updateMode(
                                                SearcherMode.searcherCommand);
                                          } else if (trim.startsWith('>>')) {
                                            final command =
                                                trim.substring(2).trim();
                                            formattedQuery = command;
                                            updateMode(SearcherMode.terminal);
                                          } else {
                                            formattedQuery = newQuery;
                                            List<String> newSuggestions =
                                                await getAutocompleteSuggestions(
                                                    newQuery);
                                            if (newSuggestions.isNotEmpty) {
                                              suggestions.value =
                                                  Map.fromIterable(
                                                      newSuggestions,
                                                      value: (e) => '');
                                            }
                                            updateMode(SearcherMode.search);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  SearcherButtons(initialSearcherMode: mode),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: padding,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    final double maxHeight = MediaQuery.of(context).size.height;
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxHeight - 94),
                      child: ValueListenableBuilder<Map<String, String>>(
                        valueListenable: suggestions,
                        builder: (context, suggestionsMap, child) {
                          final List<String> suggestionsList =
                              suggestionsMap.keys.toList();
                          final List<String> descriptionsList =
                              suggestionsMap.values.toList();
                          final bolded = formattedQuery.toLowerCase();
                          if (bolded.isNotEmpty && suggestionsList.isNotEmpty) {
                            return ListView.builder(
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
                                                  fontWeight:
                                                      FontWeight.normal))
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
                                        style:
                                            TextStyle(color: Colors.grey[300]),
                                        children: [
                                          TextSpan(
                                              text: bolded,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: right,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal))
                                        ]),
                                  );
                                } else {
                                  final remainder =
                                      suggestion.substring(0, boldedIndex);
                                  title = RichText(
                                      text: TextSpan(
                                          text: remainder,
                                          style: TextStyle(
                                              color: Colors.grey[300]),
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
                                          ? Text(
                                              descriptionsList[index],
                                              style: TextStyle(
                                                  color: Colors.grey[500]),
                                            )
                                          : null,
                                      visualDensity: VisualDensity.compact,
                                      dense: hasDescription,
                                      minVerticalPadding: 0.0,
                                      hoverColor: Colors.black12,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      onTap: () => search(suggestion),
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black26))),
                                  ),
                                );
                              },
                            );
                          } else
                            return Container();
                        },
                      ),
                    );
                  })
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  updateMode(SearcherMode newMode) {
    if (mode != newMode) {
      setState(() {
        mode = newMode;
      });
    }
  }

  Future<void> runCommand(String command) async {
    var shell = Shell();
    await shell.run(command);
  }

  Future<void> search(String query, {List<String> websites = const []}) async {
    var shell = Shell();
    String process = 'start chrome ';
    if (incognito) {
      process += '--incognito "? ';
    } else {
      process += '"? ';
    }
    websites.asMap().forEach((key, value) {
      process += 'site:$value ';
      if (key != websites.length - 1) {
        process += 'OR ';
      }
    });
    process += '$query"';
    await shell.run(process);
  }

  Future<List<String>> getAutocompleteSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://www.google.com/complete/search?q=$query&hl=en&client=chrome'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return List.generate(
          json[1].length, (index) => json[1][index].toString());
    }
    return [];
  }
}

final Map<String, String> searcherCommands = {
  'incognito': 'Switches whether Chrome will open in incognito mode or not.'
};

// Code from:
// https://github.com/flutter/flutter/issues/75675#issuecomment-831581709.
class ShiftRightFixer extends StatefulWidget {
  ShiftRightFixer({required this.child});

  final Widget child;

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
        return event.physicalKey == PhysicalKeyboardKey.shiftRight
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
