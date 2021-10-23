import 'package:flutter/material.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Screens/CreateProfile/createProfile.dart';
import 'package:squeez_game/Screens/Settings/privacy.dart';
import 'package:squeez_game/constants.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var _nameController;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * .1,
                  ),
                  Container(
                      height: size.height * .4,
                      width: size.width * .8,
                      decoration: BoxDecoration(
                          border: Border.all(color: kBackgroundColor, width: 4),
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/avatar-2.png'),
                            ),
                            title: Text(
                              "User Name",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/avatar-2.png'),
                            ),
                            title: Text(
                              "User Name",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/avatar-2.png'),
                            ),
                            title: Text(
                              "User Name",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Image.asset('assets/arrow.png'),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Image.asset('assets/arrow-2.png'),
                              )
                            ],
                          )
                        ],
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  CircleAvatar(
                    radius: size.height * .06,
                    backgroundColor: kBackgroundColor,
                    backgroundImage: AssetImage('assets/avatar-2.png'),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: size.height * .02),
                      child: Text(
                        "User name".toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Image.asset('assets/choose.png'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateProfile()));
                        },
                        child: Image.asset('assets/newButton.png'),
                      )
                    ],
                  )
                ],
              ),
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
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * .08, left: 15),
                child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/back.png')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
