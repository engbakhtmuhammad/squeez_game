import 'dart:math';

import 'package:flutter/material.dart';

class SqueezeCanList extends StatelessWidget {
  final ScrollController scrollController;

  const SqueezeCanList({
    Key? key,
    required this.scrollController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height * .2,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          shrinkWrap: true,
          itemCount: 999999,
          itemBuilder: (context, index) {
            int result = 1 + Random().nextInt(5 - 1);
            return Padding(
              padding: EdgeInsets.only(left: size.width * .1),
              child: Image.asset('assets/p${result}_can.png'),
            );
          }),
    );
    // return Container(
    //   width: size.width,
    //   height: size.height,
    //   child: ListView.builder(
    //       controller: scrollController,
    //       scrollDirection: Axis.horizontal,
    //       shrinkWrap: true,
    //       itemCount: 99999,
    //       itemBuilder: (context, index) {
    //         return Container(
    //           margin: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(25),
    //           ),
    //           child: ClipRRect(
    //             borderRadius: BorderRadius.circular(25),
    //             child: Image.asset(
    //               'assets/${images[index]}',
    //               width: 150,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //         );
    //       }),
    // );
  }
}
