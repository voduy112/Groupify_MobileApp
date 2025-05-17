import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/Carousel_view.dart';
import '../../authentication/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Center(
      child: Column(
        children: [
          MyCarouselView(),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Documents',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '${user?.username}',
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
