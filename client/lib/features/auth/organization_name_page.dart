import 'package:flutter/material.dart';

class OrganizationNamePage extends StatefulWidget {
  const OrganizationNamePage({super.key});

  @override
  State<OrganizationNamePage> createState() => _OrganizationNamePageState();
}

class _OrganizationNamePageState extends State<OrganizationNamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'hey im an org name screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
