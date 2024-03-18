import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomSlidableList extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String selectedPartition;
  final List<String> tableFields;
  final Future<bool> Function(String uuid, String partition) onDeleteItem;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String partition, {String? searchQuery, int? page}) fetchData;

  const CustomSlidableList({
    Key? key,
    required this.data,
    required this.selectedPartition,
    required this.tableFields,
    required this.onDeleteItem,
    required this.onEdit,
    required this.fetchData,
  }) : super(key: key);

  @override
  State<CustomSlidableList> createState() => _CustomSlidableListState();
}

class _CustomSlidableListState extends State<CustomSlidableList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          final item = widget.data[index];
          return DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 2.0),
              ),
            ),
            child: Slidable(
              key: ValueKey(item['uuid']),
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => widget.onEdit(item),
                    backgroundColor: const Color(0xFFA7C7E7),
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      bool success = await widget.onDeleteItem(item['uuid'], widget.selectedPartition);
                      if (success) {
                        setState(() {
                          widget.data.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item successfully deleted')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to delete the item.')),
                        );
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: Row(
                children: widget.tableFields.map((field) {
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: field == 'text'
                          ? Text(item[field]?.toString() ?? '') // Replace with your ExpandableText if necessary
                          : Text(item[field]?.toString() ?? ''),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
