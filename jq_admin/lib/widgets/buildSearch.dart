import 'package:flutter/material.dart';

class LogItemWidget extends StatelessWidget {
  final Map<String, dynamic> log;

  const LogItemWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xff969d7b),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 130,
              )
            ],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Document ID: ${log['id']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Prompt: ${log['prompt']}',
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Response: ${log['response']}',
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Assuming buildMilvusDataText is a function that returns a Widget
              // and is available within the scope or passed to this widget
              buildMilvusDataText(log),
              Text(
                'Partition Name: ${log['partitionName']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Timestamp: ${log['timestamp']}',
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMilvusDataText(Map<String, dynamic> log) {
    // Placeholder for the actual implementation of buildMilvusDataText
    String milvusData = log['milvusData'] ?? '';
    return Text(
      'Milvus Data: $milvusData',
      style: const TextStyle(color: Colors.white),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
