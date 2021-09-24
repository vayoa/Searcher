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

class SearcherGroupEditor extends StatefulWidget {
  const SearcherGroupEditor({
    Key? key,
    required this.searcherGroup,
  }) : super(key: key);

  final SearcherGroup searcherGroup;

  @override
  _SearcherGroupEditorState createState() => _SearcherGroupEditorState();
}

class _SearcherGroupEditorState extends State<SearcherGroupEditor> {
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
                widget.searcherGroup.title,
                style: TextStyle(color: Colors.grey[300]),
              ),
            ),
            VerticalDivider(indent: 10.0, endIndent: 10.0),
            SizedBox(
              width: 500,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.searcherGroup.websites.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text(widget.searcherGroup.websites[index]),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_rounded),
              splashRadius: 18.0,
              color: Colors.white.withOpacity(0.4),
              onPressed: () async {
                final TextEditingController _textEditingController =
                    new TextEditingController();
                final String? newWebsite = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Add a website to the Searcher Group'),
                    backgroundColor: Colors.grey[800]!.withOpacity(0.9),
                    content: TextField(
                      controller: _textEditingController,
                      onSubmitted: (value) => Navigator.of(context).pop(value),
                      decoration: InputDecoration(hintText: "Website Domain"),
                    ),
                  ),
                );
              },
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
