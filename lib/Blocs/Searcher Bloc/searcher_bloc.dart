import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:process_run/shell.dart';
import 'package:searcher_app/Widgets/Searcher%20Bar/searcher_bar.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:http/http.dart' as http;

part 'searcher_event.dart';

part 'searcher_state.dart';

class SearcherBloc extends Bloc<SearcherEvent, SearcherState> {
  SearcherBloc() : super(SearcherInitial());

  bool incognito = true;

  @override
  Stream<SearcherState> mapEventToState(
    SearcherEvent event,
  ) async* {
    if (event is TextChanged) {
      final trim = event.text.trim();
      if (trim.startsWith('!>')) {
        // TODO: Think about whether calling loading here is necessary.
        yield SearcherSuggestionsLoading(SearcherMode.searcherCommand);
        final command = trim.substring(2).trim();
        final Map<String, String> newSuggestions = {};
        for (String searcherCommand in searcherCommands.keys) {
          final double matchPercentage =
              StringSimilarity.compareTwoStrings(searcherCommand, command);
          if (searcherCommand.contains(command) || matchPercentage >= 0.5)
            newSuggestions[searcherCommand] =
                searcherCommands[searcherCommand]!;
        }
        yield SearcherSuggestionsDone(
            SearcherMode.searcherCommand, command, newSuggestions);
      } else if (trim.startsWith('>>')) {
        // TODO: Maybe Implement some terminal suggestions.
        yield SearcherSuggestionsLoading(SearcherMode.terminal);
        final command = trim.substring(2).trim();
        yield SearcherSuggestionsDone(SearcherMode.terminal, command, const {});
      } else {
        yield SearcherSuggestionsLoading(SearcherMode.search);
        List<String> newSuggestions = await getAutocompleteSuggestions(trim);
        final Map<String, String> suggestions =
            Map.fromIterable(newSuggestions, value: (e) => '');
        yield SearcherSuggestionsDone(SearcherMode.search, trim, suggestions);
      }
    }
    else if (event is TextSubmitted) {
      SearcherMode newMode;
      final trim = event.text.trim();
      if (trim.startsWith('!>')) {
        newMode = SearcherMode.searcherCommand;
        final command = trim.substring(2).trim();
        switch (command) {
          case 'incognito':
              incognito = !incognito;
            break;
        }
      } else if (trim.startsWith('>>')) {
        newMode = SearcherMode.terminal;
        final command = trim.substring(2).trim();
        await runCommand(command);
      } else {
        newMode = SearcherMode.search;
        await search(trim);
      }
      yield SearcherSuggestionsDone(newMode, '', const {});
      // _textEditingController.clear();
      // _searchBarFocusNode.requestFocus();
    }
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

  Future<void> runCommand(String command) async {
    var shell = Shell();
    await shell.run(command);
    shell.kill();
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
    shell.kill();
  }

}
