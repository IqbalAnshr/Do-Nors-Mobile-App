import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

List<String> imageList = [
  'assets/images/iklan.png',
  'assets/images/iklan.png',
  'assets/images/iklan.png',
  'assets/images/iklan.png',
  'assets/images/iklan.png',
];

class CarouselWithIndicator extends StatefulWidget {
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              viewportFraction: 1.00,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: imageList.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        i,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
        DotsIndicator(
          dotsCount: imageList.length,
          position: _currentIndex,
          decorator: DotsDecorator(
            activeColor: Color(0xFFFF2156),
            size: Size.square(8.0),
            activeSize: Size.square(10.0),
          ),
        ),
      ],
    );
  }
}
