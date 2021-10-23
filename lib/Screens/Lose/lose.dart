import 'package:flutter/material.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Screens/Game/game.dart';
import 'package:squeez_game/Screens/Menu/menu.dart';

class GameOverPage extends StatefulWidget {
  const GameOverPage({Key? key}) : super(key: key);

  @override
  _GameOverPageState createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(children: [
              Padding(
              padding: EdgeInsets.only(
                top: size.height * .23,
                bottom: size.height*.05
              ),
              child: Text(
                'Game Over'.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 30),
              ),
            ),
            Container(
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
                      ))),
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * .02),
              child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>GamePage()));
                  },
                  child: Image.asset('assets/restartButton.png')),
            ),
            
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MenuPage()));
                },
                child: Image.asset('assets/mainMenuButton.png')),
           
            ],),
             Positioned(
               bottom: 0,
               child: Padding(
                padding: EdgeInsets.only(bottom: size.height * .06),
                child: Image.asset(
                  'assets/conveyor.png',
                  fit: BoxFit.fitWidth,
                  width: size.width,
                ),
                         ),
             ),
            
          ],
        ),
      ),
    );
  }
}
