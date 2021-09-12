class SearcherGroup {
  final String title;

  late final List<String> websites = [];

  SearcherGroup({required this.title, required List<String> websites}) {
    for (var i = 0; i < websites.length; i++) {
      final RegExp _exp = RegExp(r'(^(https:\/\/)|(www.))|(\/$)');
      final String website = websites[i].replaceAll(_exp, '');
      this.websites.add(website);
    }
  }
}
