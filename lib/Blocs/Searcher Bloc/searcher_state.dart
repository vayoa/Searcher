part of 'searcher_bloc.dart';

abstract class SearcherState extends Equatable {
  const SearcherState();
}

class SearcherInitial extends SearcherState {
  @override
  List<Object> get props => [];
}

class SearcherSuggestionsLoading extends SearcherState {
  final SearcherMode searcherMode;

  const SearcherSuggestionsLoading(this.searcherMode);

  @override
  List<Object?> get props => [this.searcherMode];
}

class SearcherSuggestionsDone extends SearcherState {
  final SearcherMode searcherMode;
  final String formattedText;
  final Map<String, String> suggestions;

  const SearcherSuggestionsDone(
      this.searcherMode, this.formattedText, this.suggestions);

  @override
  List<Object?> get props =>
      [this.searcherMode, this.suggestions, this.suggestions];
}
