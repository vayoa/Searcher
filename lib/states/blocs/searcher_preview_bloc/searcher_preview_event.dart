part of 'searcher_preview_bloc.dart';

@immutable
abstract class SearcherPreviewEvent {
  const SearcherPreviewEvent();
}

class NextPreview extends SearcherPreviewEvent {}

class PreviousPreview extends SearcherPreviewEvent {}

class OpenPreview extends SearcherPreviewEvent {
  final SearcherPreviewState preview;
  final int instance;

  /// Constructs a new OpenPreview event.
  /// [preview] is the new preview to be opened.
  /// [instance] is optional, if specified and preview isn't a of single
  /// type we won't create a new preview but instead we'll focus on the
  /// instance of that preview.
  const OpenPreview({
    required this.preview,
    this.instance = -1,
  });
}

class ClosePreview extends SearcherPreviewEvent {
  final SearcherPreviewState preview;

  const ClosePreview({required this.preview});
}

class CloseCurrentPreview extends SearcherPreviewEvent {
  const CloseCurrentPreview();
}

class MovePreview extends SearcherPreviewEvent {
  final int from;
  final int to;

  const MovePreview({required this.from, required this.to});
}
