import 'package:flutter/material.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Screens/Settings/privacy.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
                'settings'.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 30),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/vibro.png'),
                SizedBox(
                  width: 40,
                ),
                GestureDetector(
                    onTap: () {}, child: Image.asset('assets/on.png'))
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * .04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/en.png'),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {}, child: Image.asset('assets/choose.png'))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * .02),
              child: TextButton(
                  onPressed: () {
                     showDialog(
                       
                context: context,
                builder: (ctx) => AlertDialog(
                    
                    //title: Text("Alert Dialog Box"),
                    content: Text("Delete all profile and application results"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset('assets/yesButton.png'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset('assets/noButton.png'),
                      ),
                    ],
                  ),
              
              );
                  },
                  child: Image.asset('assets/deleteButton.png')),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PrivacyPage()));
                },
                child: Image.asset('assets/privacyButton.png')),
           
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
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * .08, left: 15),
                child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, child: Image.asset('assets/back.png')),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
