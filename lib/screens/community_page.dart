import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecoeden/models/post.dart';
import 'package:ecoeden/models/feedsArticle.dart';
import 'package:ecoeden/services/webservice.dart';
import 'package:geolocator/geolocator.dart';
import "package:threading/threading.dart";

import 'feeds_page.dart';

class CommunityPageState extends State<CommunityPage> {
  List<FeedsArticle> _newsArticles = List<FeedsArticle>();
  bool showHeartOverlay = false;
  bool isLoading = false;
  bool _insideFeed = true;
  Position myLoc;

  ScrollController _scrollController = new ScrollController();
  // ignore: non_constant_identifier_names
  static final String NEWS_PLACEHOLDER_IMAGE_ASSET_URL =
      'assets/placeholder.png';
  @override
  void initState() {
    print("Inside Feed");
    super.initState();
    locationTracker();
    FeedsPageState.nextPage = 'https://api.ecoeden.xyz/community/';
    _populateNewsArticles();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          FeedsPageState.nextPage != null) {
        _populateNewsArticles();
        var val = _newsArticles.map((x) => x.id).toList();
        print("It's Feed Show Time !!!");
        print(val);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _insideFeed = false;
    super.dispose();
  }

  void locationTracker() async {
    print("Inside tracker");
    var thread = new Thread(_getLocation);
    await thread.start();
    await thread.join();
  }

  Future _getLocation() async {
    while (_insideFeed) {
      await Thread.sleep(3000);
      myLoc = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("Upgraded Location !!");
    }
  }

  void _populateNewsArticles() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      List<FeedsArticle> newsArticles =
      await Webservice().load(FeedsArticle.all);
      setState(() {
        isLoading = false;
        _newsArticles.addAll(newsArticles);
      });
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
                child: Image.asset(
                  'assets/wave.png',
                  fit: BoxFit.fitWidth,
                )),
            showPost(context),
          ],
        ));
  }

  Widget showPost(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 25, 0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 28, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 0, 0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Municipality',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0,
                    fontFamily: "SegoeUI",
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.left,
              )),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0.0, 30.0, 4.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 50,
              height: 50,
              child: Image.asset('assets/EcoEden-Logo-withoutText.png'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _newsArticles.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _newsArticles.length) {
                return _buildProgressIndicator();}
//              } else if (_newsArticles[index].verified.collected == true) return Container();
              else {
                print("Index : " + index.toString());
                return Post(
                    showHeartOverlay: showHeartOverlay,
                    description: _newsArticles[index].description,
                    imageUrl: _newsArticles[index].image,
                    lat: _newsArticles[index].lat,
                    lng: _newsArticles[index].lng,
                    scale: _newsArticles[index].scale,
                    id: _newsArticles[index].id,
                    user: _newsArticles[index].user,
                    voted: _newsArticles[index].voted,
                    verified: _newsArticles[index].verified,
                    is_indoors: _newsArticles[index].is_indoors,
                );
              }
            },
            controller: _scrollController,
          ),
        )
      ],
    );
  }
}

class CommunityPage extends StatefulWidget {
  @override
  createState() => CommunityPageState();
}