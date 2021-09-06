import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:searcher_app/modals/searcher_commands.dart';
import 'package:searcher_app/states/blocs/searcher_preview_bloc/searcher_preview_bloc.dart';
import 'package:searcher_app/states/provider/searcher_app_state.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:http/http.dart' as http;

part 'searcher_event.dart';

part 'searcher_state.dart';

class SearcherBloc extends Bloc<SearcherEvent, SearcherState> {
  SearcherBloc(this.appState) : super(SearcherInitial());

  final SearcherAppState appState;

  @override
  Stream<SearcherState> mapEventToState(
    SearcherEvent event,
  ) async* {
    if (event is GetSuggestions) {
      yield SearcherSuggestionsLoading();
      final trim = event.text.trim();
      switch (appState.currentSearcherMode) {
        case SearcherMode.searcherCommand:
          final String command;
          if (trim.startsWith('!>')) {
            command = trim.substring(2).trim();
          } else {
            command = trim;
          }
          final Map<String, String> suggestions =
              _getSearcherCommandSuggestions(command);
          yield SearcherSuggestionsDone(command, suggestions);
          break;
        case SearcherMode.terminal:
          final String command;
          if (trim.startsWith('>>')) {
            command = trim.substring(2).trim();
          } else {
            command = trim;
          }
          yield SearcherSuggestionsDone(command, const {});
          break;
        case SearcherMode.search:
          Map<String, String> suggestions = await _getSearchSuggestions(trim);
          yield SearcherSuggestionsDone(trim, suggestions);
          break;
      }
    } else if (event is ClearSuggestions) {
      yield SearcherSuggestionsClear();
    }
  }

  Future<Map<String, String>> _getSearchSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://www.google.com/complete/search?q=$query&hl=en&client=chrome'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final suggestions =
          List.generate(json[1].length, (index) => json[1][index].toString());
      return Map.fromIterable(suggestions, value: (e) => '');
    }
    return const {};
  }

  Map<String, String> _getSearcherCommandSuggestions(String command) {
    final Map<String, String> newSuggestions = {};
    for (String searcherCommand in SearcherCommands.all.keys) {
      final double matchPercentage =
          StringSimilarity.compareTwoStrings(searcherCommand, command);
      if (searcherCommand.contains(command) || matchPercentage >= 0.5)
        newSuggestions[searcherCommand] =
            SearcherCommands.all[searcherCommand]!.description;
    }
    return newSuggestions;
  }

}
