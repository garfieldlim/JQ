import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FacebookPostsList extends StatelessWidget {
  final List<dynamic> posts;

  const FacebookPostsList({Key? key, required this.posts}) : super(key: key);

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Could not launch the URL, handle the error in your app
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff2c87e),
      child: ExpansionTile(
        leading: const Icon(
          Icons.newspaper_rounded,
          color: Colors.white,
        ),
        title: const Text(
          'Headlines',
          style: TextStyle(color: Colors.white),
        ),
        children: <Widget>[
          SizedBox(
            height: 150.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () => _launchURL(
                      post['url']), // Assuming 'link' is the key for the URL
                  child: Card(
                    color: const Color(0xffdcd8b0),
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        post['text'] ?? 'No text available',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Color(0xff333333),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
