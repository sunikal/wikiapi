import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class PagesHome extends StatefulWidget {
  const PagesHome({ Key key }) : super(key: key);

  @override
  _PagesHomeState createState() => new _PagesHomeState();
}

class _PagesHomeState extends State<PagesHome> {
  final _searchFetcher = new _Fetcher();
  String _searchingQuery = ''; // TODO VENDOR flutter's TextEditing's onchange callback doesn't expose oldValue for now
  List<_EntryWithSummary> _fetchedSearchingEntries = []; // NOTE use `null` to represent loading

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _fetchedSearchingEntries.clear();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Wiki"),
        centerTitle: true,
      ),
        body: new CustomScrollView(
            slivers: <Widget>[

              new SliverList(
                  delegate: new SliverChildListDelegate([_searchBar()])
              ),
              _buildContent(context),
            ]
        )
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_fetchedSearchingEntries == null) { // NOTE which means loading
      return new SliverFillRemaining(
          child: new Center(
              child: new CircularProgressIndicator()
          )
      );
    }

    return new SliverList(
        delegate: new SliverChildListDelegate(_buildEntriesList(context))
    );
  }

  Widget _searchBar(){
    return new Container(
        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
        child: new Card(
            child: new Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: new TextField(
                  onChanged: _handleSearchTextChanged,
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.search),
                  ),
                )
            )
        )
    );
  }

  void _handleSearchTextChanged(String str) {
    if (str == _searchingQuery) { return; }
    if (str == '') { return; }

    setState((){
      _searchingQuery = str;
      _fetchedSearchingEntries = null;
    });

    _searchFetcher.search(str).then((List<_EntryWithSummary> fetchedSearchingEntries){
      setState((){
        _fetchedSearchingEntries = fetchedSearchingEntries;
      });
    });
  }

  List<Widget> _buildEntriesList (BuildContext context) {
    List<Widget> list = [];

    if ( _fetchedSearchingEntries.isNotEmpty ) {
      for ( _EntryWithSummary data in _fetchedSearchingEntries ) {
        list
          ..add(
            new ListTile(
                dense: true,
                title: new Text(data.title,),
                onTap: (){ Navigator.pushNamed(context, "/entries/${data.title}"); }
            ),
          )
          ..add( const Divider() );
      }

      list.removeLast(); // remove last divider
    }

    return [
      new Container(
          margin: const EdgeInsets.all(8.0),
          child: new Card(
            child: new Column(
                children: list
            ),
          )
      )
    ];
  }
}

class _Fetcher {
  http.Client client = new http.Client();

  Future<List<_EntryWithSummary>> search(String str) async {
    // TODO NOTE
    // there will be some unhandled `Connection closed before full header was received` exception
    // that's by design, yet still should be properly handled.
    // TODO wrap in WikiClient?

    client.close();

    client = new http.Client();

    final String url = "https://en.wikipedia.org/w/api.php?action=opensearch&format=json&errorformat=bc&search=$str&namespace=0&limit=10&suggest=1&utf8=1&formatversion=2";

    final List fetched = json.decode( await client.read(url) ) as List;

    client.close();


    List<_EntryWithSummary> entries = [];
    for (var i = 0; i < (fetched[1] as List).length; i ++ ) {
      entries.add(
          new _EntryWithSummary(
              title: fetched[1][i],
              summary: fetched[2][i]
          )
      );
    }

    return entries;
  }
}

class _EntryWithSummary {
  final String title;
  final String summary;
  _EntryWithSummary({this.title, this.summary});
}

class _AnimatedTitleText extends StatefulWidget {
  const _AnimatedTitleText({ Key key }) : super(key: key);

  @override
  _AnimatedTitleTextState createState() => new _AnimatedTitleTextState();
}

class _AnimatedTitleTextState extends State<_AnimatedTitleText> {
  final String fullText = "Wiki Flutter";
  String _currentString = "";
  Timer _timer;

  @override
  void initState() {
    super.initState();

    new Timer(
        const Duration(milliseconds: 1024),
        _start
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Text(
      _currentString,
      style: Theme.of(context).textTheme.display1.copyWith(color: Colors.white, fontFamily: 'Serif'), // TODO specific font
    );
  }

  void _start(){
    _timer = new Timer.periodic(const Duration(milliseconds: 64), (Timer timer){
      final newLength = _currentString.length + 1;
      if ( newLength > fullText.length ) {
        _stop();
      } else {
        setState((){
          _currentString = fullText.substring(0, newLength);
        });
      }
    });
  }

  void _stop(){
    _timer.cancel();
  }
}


class Post {
  final int pageid;
  final int ns;
  final String title;
  final String extract;

  Post({this.pageid, this.ns, this.title, this.extract});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      pageid: json['pageid'],
      ns: json['ns'],
      title: json['title'],
      extract: json['extract'],
    );
  }
}
