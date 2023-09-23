import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/model/jam.dart';

import 'custom/rounded_button.dart';

class JamRoom extends StatefulWidget {
  Jam jam;
  JamRoom({Key? key, required this.jam}) : super(key: key);

  @override
  State<JamRoom> createState() => _JamRoomState();
}

class _JamRoomState extends State<JamRoom> {
  bool mic = true;
  int mJoined =1;
  List<dynamic> memberList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.9,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(false ) Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(24, 48, 75, 24),
                    child: Stack(
                      children: [
                        Text(
                          "${widget.jam.title}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 48.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 36,),
                  Container(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "${widget.jam.title}",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      "Started by ${widget.jam.startedBy}",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      "$mJoined Joined",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  if(memberList.length>0)Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.count(
                      childAspectRatio: 1,
                      crossAxisCount: 4, // Number of columns
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      crossAxisSpacing: 12,
                      children: List.generate(memberList.length, (index) {
                        // Replace with your band item widget
                        return ListTile(
                          title: Text("Band ${memberList[index]}"),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 100,)
                ],
              ),
            ),
            Container(
              height: 275,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.keyboard_arrow_down_rounded,size: 36,),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.symmetric(horizontal: 48.0,vertical: 32),
              child: Row(

                children: [
                  FloatingActionButton.extended(
                    backgroundColor: Colors.redAccent,
                    onPressed: () {
                      ConnectToChannel.leaveChannel();
                      Navigator.pop(context);
                    },
                    label: Text(
                      'Leave Jam',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  RoundedButton(
                    height: 42,
                    assetPath: mic ? "images/mic_on.png":"images/mic_off.png",
                    color: Colors.white,
                    bgColor: Colors.grey.shade800,
                    onPressed: () {
                      setState(() {
                        if(mic)
                        mic = false;
                        else mic = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.jam.jamId != ConnectToChannel.jam?.jamId)
    ConnectToChannel.joinRoom(widget.jam,false, (joined, userID) {
      print("$userID joinStatus $joined");
      getLiveDetails();
    },false,(val){

    },(userJoined){},(userLeft){},(rid,mute){},(rid,talking){});
    else
      getLiveDetails();
  }

  void getLiveDetails() {
    FirebaseDBOperations.getJamData(widget.jam.jamId??"",false).then((jam) {
      setState(() {
        memberList = jam.membersID??[];
        mJoined = jam.membersID?.length??0;
      });
    });
  }

}
