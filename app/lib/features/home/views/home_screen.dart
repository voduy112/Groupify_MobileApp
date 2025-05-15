import 'package:flutter/material.dart';
import '../../../models/user.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/bottom_navi.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Welcome ${user.username}'),
            CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                autoPlay: true,
              ),
              items: [1, 2, 3, 4, 5].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Text(
                          'text $i',
                          style: TextStyle(fontSize: 16.0),
                        ));
                  },
                );
              }).toList(),
            )
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }
}
