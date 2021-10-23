import 'dart:math';

import 'package:flutter/material.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/squeeze_can_List.dart';
import 'package:squeez_game/Screens/Lose/lose.dart';
import 'package:squeez_game/constants.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      double minScrollExtent1 = _scrollController.position.minScrollExtent;
      double maxScrollExtent1 = _scrollController.position.maxScrollExtent;
      //
      animateToMaxMin(maxScrollExtent1, minScrollExtent1, maxScrollExtent1, 300,
          _scrollController);
    });
  }

  animateToMaxMin(double max, double min, double direction, int seconds,
      ScrollController scrollController) {
    scrollController.animateTo(direction,
        duration: Duration(seconds: seconds), curve: Curves.linear);
    //     .then((value) {
    //   direction = direction == max ? min : max;
    //   animateToMaxMin(max, min, direction, seconds, scrollController);
    // });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //double legSize=0.5;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * .15),
                child: Image.asset(
                  'assets/conveyor.png',
                  fit: BoxFit.fitWidth,
                  width: size.width,
                ),
              ),
            ),
            Positioned(
                bottom: size.height*.5,
                left: size.width*.3,
                child: Image.asset('assets/leg.png')),
            Positioned(
              bottom: 0,
              child: Padding(
                  padding: EdgeInsets.only(bottom: size.height * .25),
                  child: Container(
                    width: size.width,
                    height: size.height * .15,
                    //decoration: BoxDecoration(color: kSecondaryColor),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: 99999,
                        
                        itemBuilder: (context, index) {
                          int result = 1 + Random().nextInt(5 - 1);
                          return Padding(
                            
                            padding: EdgeInsets.only(left: size.width * .15),
                            
                            child: Image.asset('assets/p${result}_can.png'),
                          );
                        }),
                  )),
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: size.height * .038, left: size.width * .6),
                  child: Container(
                      width: size.width * .3,
                      height: size.height * .1,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage('assets/score.png'))),
                      child: Center(
                          child: Text(
                        '   040990',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      )))),
            ),
          ],
        ),
      ),
    );
  }
}
