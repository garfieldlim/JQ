import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final double width;
  final Color backgroundColor;
  final Color buttonColor;

  const SearchWidget({
    Key? key,
    required this.searchController,
    required this.onSearch,
    this.width = double.infinity,
    this.backgroundColor = const Color(0xffe7dba9),
    this.buttonColor = const Color(0xfff2c87e),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search a log',
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      onSearch();
                    },
                  ),
                ),
                onSubmitted: (_) => onSearch(),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search, color: Colors.white),
              label:
                  const Text('Search', style: TextStyle(color: Colors.white)),
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
