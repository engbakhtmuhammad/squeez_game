import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              bottom: MediaQuery.of(context).size.height * .1,
              left: 20,
              child: Row(
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Image.asset('assets/back.png')),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Image.asset('assets/update.png'))
                ],
              )),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*.1,),
              ListTile(
                title: Text("Privacy Policy"),
                subtitle: Text(
                    "Ghanshyam Acharya built the Squeeze Сan app as a Freemium app. This SERVICE is provided by Indrani Dhiraj Bobal at no cost and is intended for use as is.This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service. If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy. The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Ringer Roader unless otherwise defined in this Privacy Policy."),
              ),
              ListTile(
                  title: Text("Information Collection and Use"),
                  subtitle: Text(
                      "For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to device ID and advertise ID. The information that I request will be retained on your device and is not collected by me in any way. The app does use third party services that may collect information used to identify you. Link to privacy policy of third party service providers used by the app\nGoogle Play Services\nAdMob\nGoogle Analytics for Firebase\nFacebook")),
              ListTile(
                title: Text("Log Data"),
                subtitle: Text(
                    "I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics."),
              )
            ],
          )
        ],
      ),
    );
  }
}
