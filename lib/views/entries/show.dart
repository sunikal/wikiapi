import 'package:flutter/material.dart';

import '../../models/entry.dart';

import '../shared/entries_helper.dart' as entriesHelper;
import '../shared/drawer.dart';
import './shared/section_outline_tiles.dart';

class EntriesShow extends StatefulWidget {
  final String title; // NOTE TODO TO-REFINE, actually this may be encoded title or not
  final Entry entry;

  EntriesShow({Key key, this.entry, this.title}) : super(key: key);

  @override
  _EntriesShowState createState() => new _EntriesShowState();
}

class _EntriesShowState extends State<EntriesShow> {
  Entry entry;

  @override
  void initState() {
    super.initState();

    // prefer passed-in existing entry than fetching via title
    if ( widget.entry != null ) {
      setState((){ this.entry = widget.entry; });
    } else {
      Entry.fetch(title: widget.title).then( (Entry fetchedEntry) {
        setState((){
          this.entry = fetchedEntry;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = ( entry == null ) ? (
                             new SliverFillRemaining(
                               child: new Center(
                                 child: new CircularProgressIndicator()
                               )
                             )
                           ) : (
                             new SliverList(
                               delegate: new SliverChildListDelegate(_contentsList(context))
                             )
                           );

    return new Scaffold(

      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 256.0,
            floating: true,
            // snap: true,
            flexibleSpace: new FlexibleSpaceBar(
              title: _buildTitle(),
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildCoverImg(),
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
          content
        ]
      ),
    );
  }

  Widget _buildTitle() {
    final titleStyle = Theme.of(context).textTheme.title.copyWith(color: Colors.white, fontFamily: 'Serif'); // TODO shared style; TODO use specific font
    final text = ( entry != null ) ? entry.displayTitle : widget.title;
    return new Text(text, style: titleStyle);
  }



  Widget _buildCoverImg() {
    if (entry != null && entry.coverImgSrc != null) {
      print("entry.coverImgSrc ${entry.coverImgSrc}");
      var parts = entry.coverImgSrc.split(':');
      var suffix = parts.sublist(1).join(':').trim();
      print("prefix ${suffix}");
      return Image.network(suffix,fit: BoxFit.cover,scale: 1.0,);
    } else {
      // TODO shared assets helper
      return new Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
      print("came here");
    }
  }

  List<Widget> _contentsList(BuildContext context) {
    List<Widget> widgetsList = [];

    // description
    if (entry.description != null) {
      widgetsList.add(
        new entriesHelper.HintTile(
          text: entry.description,
          icon: const Icon(Icons.format_quote),
          botPadding: false,
        )
      );
    }

    // hatnotes
    for (String hatnote in entry.hatnotes) {
      widgetsList.add(
        new entriesHelper.HintTile.withHtmlStr(
          htmlStr: hatnote,
          botPadding: false,
        )
      );
    }

    // main section
    widgetsList
      ..add(
        new Container(
          padding: const EdgeInsets.all(16.0),
          child: new entriesHelper.SectionHtmlWrapper(entry: entry, sectionId: 0))
        )
      ..add(const Divider());// TODO should not show divider if there're actually no sections outline

    // remaining sections list
    widgetsList.addAll(_remainingSectionsOutline());

    return widgetsList;
  }

  List<Widget> _remainingSectionsOutline () {
    if (entry.sections.length < 1) { return []; }

    return sectionOutlineTiles(entry, rootSectionId: 0, inDrawer: false);
  }
}
