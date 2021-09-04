part of 'searcher_preview_bloc.dart';

@immutable
abstract class SearcherPreviewEvent {
  const SearcherPreviewEvent();
}

class NextPreview extends SearcherPreviewEvent {}

class PreviousPreview extends SearcherPreviewEvent {}

class OpenPreview extends SearcherPreviewEvent {
  final SearcherPreviewState preview;

  const OpenPreview({required this.preview});
}

class ClosePreview extends SearcherPreviewEvent {
  final SearcherPreviewState preview;

  const ClosePreview({required this.preview});
}
