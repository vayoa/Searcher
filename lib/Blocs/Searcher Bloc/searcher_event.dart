part of 'searcher_bloc.dart';

abstract class SearcherEvent extends Equatable {
  const SearcherEvent();
}

class TextSubmitted extends SearcherEvent {
  final String text;

  const TextSubmitted(this.text);

  @override
  List<Object?> get props => [this.text];
}

class TextChanged extends SearcherEvent {
  final String text;

  const TextChanged(this.text);

  @override
  List<Object?> get props => [this.text];
}