import 'package:flutter/material.dart';

class StoryDetailPagePro extends StatelessWidget {
  final String id;
  const StoryDetailPagePro({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('This is pro with $id')));
  }
}
