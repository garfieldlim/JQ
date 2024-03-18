import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: canGoBack ? onPrevious : null,
        ),
        Text('Page $currentPage', style: const TextStyle(color: Colors.white)),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios,
              size: 20, color: Colors.white),
          onPressed: canGoForward ? onNext : null,
        ),
      ],
    );
  }
}
