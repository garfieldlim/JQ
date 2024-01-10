import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FacebookPostsList extends StatefulWidget {
  final List<dynamic> posts;

  const FacebookPostsList({Key? key, required this.posts}) : super(key: key);

  @override
  _FacebookPostsListState createState() => _FacebookPostsListState();
}

class _FacebookPostsListState extends State<FacebookPostsList> {
  String selectedUsername = 'All';
  List<dynamic> filteredPosts = [];

  @override
  void initState() {
    super.initState();

    // Print the posts data to console for debugging
    print("Loaded posts: ${widget.posts}");

    // Initially display all posts
    filteredPosts = widget.posts;
  }

  void filterPosts(String username) {
    if (username == 'All') {
      setState(() {
        filteredPosts = widget.posts;
      });
    } else {
      setState(() {
        filteredPosts =
            widget.posts.where((post) => post['username'] == username).toList();
      });
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
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
          DropdownButton<String>(
            value: selectedUsername,
            onChanged: (String? newValue) {
              setState(() {
                selectedUsername = newValue!;
              });
              filterPosts(selectedUsername); // Filter posts on selection
            },
            items: <String>[
              'All',
              'FORWARD Publications',
              'University of San Jose- Recoletos',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(
            height: 550.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return GestureDetector(
                  onTap: () => _launchURL(post['post_url']),
                  child: Card(
                    color: const Color(0xff969d7b),
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(35.0),
                      child: IntrinsicWidth(
                        child: Row(
                          children: [
                            if (post['image_lowquality'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  post['image_lowquality'],
                                  fit: BoxFit.cover,
                                  height: 200.0,
                                  width: 200.0,
                                ),
                              ),
                            Container(
                              width: 400.0,
                              padding: const EdgeInsets.all(35.0),
                              child: Text(
                                post['text'] ?? 'No text available',
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xfffff1e4),
                                ),
                              ),
                            ),
                          ],
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
