import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/backbutton.dart';
import 'schma_details.dart';

class UpsertingPage extends StatefulWidget {
  const UpsertingPage({super.key});

  @override
  _UpsertingPageState createState() => _UpsertingPageState();
}

class _UpsertingPageState extends State<UpsertingPage> {
  final ValueNotifier<bool> isHoveredSocialPosts = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isHoveredDocuments = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isHoveredPeople = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfffff1e4),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      BackButtonWidget(color: Color(0xfff2c87e)),
                      SizedBox(width: 50),
                    ],
                  ),
                  Text(
                    "Select a schema to upsert data",
                    style: TextStyle(
                      color: Color(0xff7a8066),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOptionContainer("Social Posts"),
                        _buildOptionContainer("Documents"),
                        _buildOptionContainer("People"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildOptionContainer(String schema) {
    ValueNotifier<bool> hoverNotifier;
    String lottieAssetPath;

    switch (schema) {
      case "Social Posts":
        hoverNotifier = isHoveredSocialPosts;
        lottieAssetPath = 'web/assets/socialposts.json';
        break;
      case "Documents":
        hoverNotifier = isHoveredDocuments;
        lottieAssetPath = 'web/assets/documents.json';
        break;
      default:
        hoverNotifier = isHoveredPeople;
        lottieAssetPath = 'web/assets/people.json';
        break;
    }

    return ValueListenableBuilder<bool>(
      valueListenable: hoverNotifier,
      builder: (context, isHovered, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onHover: (value) => hoverNotifier.value = value,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SchemaDetailsPage(schema: schema)),
            ),
            child: Container(
              width: 350,
              height: 500,
              decoration: BoxDecoration(
                color: isHovered ? const Color(0xfff2c87e) : Colors.transparent,
                border: Border.all(color: const Color(0xff969d7b), width: 5),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: isHovered
                  ? Lottie.asset(lottieAssetPath, repeat: true)
                  : Center(
                      child: Text(
                        schema,
                        style: const TextStyle(
                            color: Color(0xffE7D192), fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
