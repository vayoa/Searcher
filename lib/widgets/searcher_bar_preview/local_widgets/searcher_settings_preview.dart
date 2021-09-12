import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/modals/searcher_group.dart';
import 'package:searcher_app/states/provider/searcher_app_state.dart';

class SearcherSettingsPreview extends StatelessWidget {
  const SearcherSettingsPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearcherAppState>(
      builder: (context, state, child) {
        return ListView.builder(
          itemCount: state.searcherGroups.length,
          itemBuilder: (context, index) =>
              SearcherGroupEditor(searcherGroup: state.searcherGroups[index]),
        );
      },
    );
  }
}

class SearcherGroupEditor extends StatelessWidget {
  const SearcherGroupEditor({
    Key? key,
    required this.searcherGroup,
  }) : super(key: key);

  final SearcherGroup searcherGroup;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 0.0,
      contentPadding: EdgeInsets.zero,
      title: SizedBox(
        height: 50,
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: Text(
                searcherGroup.title,
                style: TextStyle(color: Colors.grey[300]),
              ),
            ),
            VerticalDivider(indent: 10.0, endIndent: 10.0),
            SizedBox(
              width: 500,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searcherGroup.websites.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text(searcherGroup.websites[index]),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_rounded),
              splashRadius: 18.0,
              color: Colors.white.withOpacity(0.4),
              onPressed: () {},
            ),
            VerticalDivider(indent: 10.0, endIndent: 10.0),
          ],
        ),
      ),
      trailing: SizedBox(
        width: 80.0,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded),
              splashRadius: 18.0,
              color: Colors.white.withOpacity(0.4),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.delete_rounded),
              splashRadius: 18.0,
              color: Colors.white.withOpacity(0.4),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
