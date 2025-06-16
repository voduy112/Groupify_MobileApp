import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MyCarouselView extends StatelessWidget {
  const MyCarouselView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imageList = [
      'assets/image/banner_1.png',
      'assets/image/banner_2.png',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: [1, 2].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Colors.amber),
              child: Image.asset(
                imageList[i - 1],
                fit: BoxFit.fitHeight,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
