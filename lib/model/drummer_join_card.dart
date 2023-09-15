import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/listener/connection_listener.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:drumm_app/profile_page.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/user_profile_page.dart';

class DrummerJoinCard extends StatefulWidget {
  String drummerId;

  DrummerJoinCard(
      this.drummerId, {
        Key? key,
      }) : super(key: key);

  @override
  State<DrummerJoinCard> createState() => _DrummerJoinCardState();
}

class _DrummerJoinCardState extends State<DrummerJoinCard> {
  Drummer drummer = Drummer();
  @override
  Widget build(BuildContext context) {

    return Container(
      color: COLOR_PRIMARY_DARK,
      child: Scaffold(
        backgroundColor: COLOR_PRIMARY_DARK,
        body: Column(
          children: [
           if(false) Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                          fromSearch: true,
                          drummer: drummer,
                        ),
                      ));
                },
                child:  Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(44),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: (drummer.speaking)? [
                      Colors.redAccent,
                      Colors.pinkAccent
                    ] : [
                          Colors.grey.withOpacity(0.5),
                          Colors.blueGrey.withOpacity(0.5)
                        ],
                    )
                  ),
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(44),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        errorWidget: (context,url,error){
                          return Container();
                        },
                          imageUrl: drummer.imageUrl ?? "", fit: BoxFit.cover,fadeInCurve: Curves.easeIn,placeholder: (context, url) => Container(color: Colors.grey.shade900,),),
                    ),
                  ),
                )
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(widget.drummerId).snapshots(),
                  builder: (context,snapshot){

                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                //setState(() {
                  drummer = Drummer.fromSnapshot(snapshot.data);
              //  });


                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage(
                              fromSearch: true,
                              drummer: drummer,
                            ),
                          ));
                    },
                    child:  Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(44),
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: (drummer.speaking)? [
                              Colors.greenAccent,
                              Colors.green
                            ] : [
                              Colors.grey.withOpacity(0.5),
                              Colors.blueGrey.withOpacity(0.5)
                            ],
                          )
                      ),
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(44),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CachedNetworkImage(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            errorWidget: (context,url,error){
                              return Container();
                            },
                            imageUrl: drummer.imageUrl ?? "", fit: BoxFit.cover,fadeInCurve: Curves.easeIn,placeholder: (context, url) => Container(color: Colors.grey.shade900,),),
                        ),
                      ),
                    )
                );
              }),
            ),

            SizedBox(height: 4,),
            if(drummer.username!=null)Text("${drummer.username}",style: TextStyle(fontSize: 12),),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDrummer(widget.drummerId);
   // listenToJamState();
  }

  void getDrummer(String? foundedBy) {
    FirebaseDBOperations.getDrummer(foundedBy!).then((value) {
      setState(() {
        drummer = value;
        print("is ${drummer.uid}  speaking ${drummer.speaking}");
      });
    });
  }

  // void listenToJamState() {
  //   ConnectionListener.onConnectionChangedinCard = (connected, jam, open) {
  //     // Handle the channelID change here
  //    //  print("onConnectionChangedinCard called in drummer join card");
  //     getDrummer(widget.drummerId);
  //   };
  // }
}
