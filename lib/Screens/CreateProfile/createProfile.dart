import 'package:flutter/material.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Screens/Records/records.dart';
import 'package:squeez_game/Screens/Settings/privacy.dart';
import 'package:squeez_game/constants.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({Key? key}) : super(key: key);

  @override
  _CreateProfileState createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
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
              child: Column(children: [
                 SizedBox(height: size.height*.1,),
                Container(
                  height: size.height *.6,
                  width: size.width*.8,
                  decoration: BoxDecoration(
                   border: Border.all(
                     color: kBackgroundColor,
                     width: 4
                   ),
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
            
                    children: [
                     
                      Padding(
                        padding:  EdgeInsets.only(top: size.height*.1,bottom: size.height*.02),
                        child: Text("Make photo".toUpperCase(),
                  style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 30),),
                      ),
                      CircleAvatar(
                        radius: size.height*.07,
                        backgroundColor: kBackgroundColor,
                        backgroundImage: AssetImage('assets/avatar.png'),
                        child: IconButton(
                          icon: Icon(Icons.add,),
            
                          color: Colors.white,
                          onPressed: (){},
                        ),
                      ),
                       Padding(
                        padding:  EdgeInsets.only(top: size.height*.08,bottom: size.height*.02),
                        child: Text("give name".toUpperCase(),
                  style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 30),),
                      ),
                      Container(
                        height: size.height*.07,
                        width: size.width*.65,
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 3
                          ),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                          controller: _nameController,
                          
                          decoration: InputDecoration(
                            hintText: "USER_1",
                            hintStyle: TextStyle(color: Colors.white),
                            fillColor: Colors.white,
                            border: InputBorder.none),
                        ),
                      ),
                      
                    ],
                  ),
                ),
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RecordPage()));
                },child: Image.asset('assets/readyButton.png'),)
                       
              ],),
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
                    }, child: Image.asset('assets/back.png')),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
