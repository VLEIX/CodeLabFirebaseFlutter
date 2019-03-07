import 'package:flutter/material.dart';
import 'cloud_firestone/survey_baby_name_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final List<String> topics = [
    'Cloud Firestone',
    'Authentication',
    'Realtime Database',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firebase'),
        ),
        body: ListView.builder(
          itemCount: topics.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(topics[index]),
              onTap: () {
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SurveyBabyNamePage()),
                    );
                    break;
                  case 1:
                    break;
                  case 2:
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}
