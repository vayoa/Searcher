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
      title: Container(
        color: Colors.red,
        child: SizedBox(
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
              SizedBox(
                width: 400,
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
            ],
          ),
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {},
        splashRadius: 18.0,
      ),
    );
  }
}
