part of 'searcher_bloc.dart';

abstract class SearcherState extends Equatable {
  const SearcherState();
}

class SearcherInitial extends SearcherState {
  @override
  List<Object> get props => [];
}

class SearcherSuggestionsLoading extends SearcherState {

  const SearcherSuggestionsLoading();

  @override
  List<Object?> get props => [];
}

class SearcherSuggestionsDone extends SearcherState {
  final String formattedText;
  final Map<String, String> suggestions;

  const SearcherSuggestionsDone(this.formattedText, this.suggestions);

  @override
  List<Object?> get props => [this.suggestions, this.suggestions];
}

class SearcherSuggestionsClear extends SearcherState {
  const SearcherSuggestionsClear();

  @override
  List<Object?> get props => [];
}
