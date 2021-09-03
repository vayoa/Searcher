part of 'searcher_bloc.dart';

abstract class SearcherEvent extends Equatable {
  const SearcherEvent();
}

class ClearSuggestions extends SearcherEvent {

  const ClearSuggestions();

  @override
  List<Object?> get props => [];
}

class GetSuggestions extends SearcherEvent {
  final String text;

  const GetSuggestions(this.text);

  @override
  List<Object?> get props => [this.text];
}
