
import 'package:flutter/material.dart';

import '../../shared/entries_helper.dart' as entriesHelper;

import '../../../models/entry.dart';

import '../../shared/drawer.dart';
import '../shared/section_outline_tiles.dart';

class EntriesSectionsShow extends StatelessWidget {
  final Entry entry;
  final Section section;

  EntriesSectionsShow({ Key key, this.entry, this.section }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // build content widgets

    print("section ${section}");
    List<Widget> contentWidgets = [];

    // hatnotes
    for (var hatnote in section.hatnotes) {
      contentWidgets.add(
        new entriesHelper.HintTile.withHtmlStr(htmlStr: hatnote, botPadding: false)
      );
    }

    contentWidgets.add(
      new Container(
        padding: const EdgeInsets.all(16.0),
        child: new entriesHelper.SectionHtmlWrapper(entry: entry, sectionId: section.id,)
      )
    );

    contentWidgets
      ..add(const Divider()) // TODO should not show divider if there're actually no sections outline
      ..addAll(sectionOutlineTiles(entry, rootSectionId: section.id, inDrawer: false));

    return new Scaffold(
      //drawer: new WikiFlutterDrawer(currentEntry: entry, currentSectionId: section.id),
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 256.0,
            floating: true,
            // snap: true,
            flexibleSpace: new FlexibleSpaceBar(
              title: new Text(section.title),
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                 //new Image(image:  new AssetImage('assets/images/placeholder.jpg'),fit: BoxFit.cover),
                  // NOTE use this to distinguish white image from white text
                  new Container(
                    color: Colors.black.withAlpha(64) // TODO use a shared const var
                  ),
                ]
              )
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]
          ),
          new SliverList(
            delegate: new SliverChildListDelegate( contentWidgets )
          )
        ]
      )
    );
  }
}
