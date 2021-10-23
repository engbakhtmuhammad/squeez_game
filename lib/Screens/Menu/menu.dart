import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Screens/CreateProfile/createProfile.dart';
import 'package:squeez_game/Screens/Game/game.dart';
import 'package:squeez_game/Screens/Settings/setting.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({ Key? key }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    // final player = AudioCache();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Padding(
            padding:  EdgeInsets.only(top: size.height*.2,),
            child: Text('Squeeze'.toUpperCase(), style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, fontSize: 60),),
          ),
          Text('can'.toUpperCase(), style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, fontSize: 60),),
           
          Padding(
            padding:  EdgeInsets.symmetric(vertical: size.height*.04),
            child: TextButton(onPressed: (){
              // player.play('button_click.mp3');
              Navigator.push(context, MaterialPageRoute(builder: (context)=>GamePage()));
            }, child: Image.asset('assets/game.png')),
          ),
           TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateProfile()));
          }, child: Image.asset('assets/newButton.png')),
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingPage()));
          }, child: Image.asset('assets/sett.png')),
            ],
          ),
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
      ),),
    );
  }
}