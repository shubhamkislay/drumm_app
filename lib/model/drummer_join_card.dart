import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
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
  int drummerId;
  bool muted;
  bool talking;
  final Stream<Map<int, bool>> muteController;
  final Stream<Map<int, bool>> speechController;

  DrummerJoinCard(
      this.drummerId, this.muted, this.talking, this.muteController, this.speechController,{
        Key? key,
      }) : super(key: key);

  @override
  State<DrummerJoinCard> createState() => _DrummerJoinCardState();

}

class _DrummerJoinCardState extends State<DrummerJoinCard> {
  Drummer drummUser = Drummer();
  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.transparent,//COLOR_PRIMARY_DARK,
      child: Scaffold(
        backgroundColor:  Colors.transparent,//COLOR_PRIMARY_DARK,
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').where('rid', isEqualTo: widget.drummerId).snapshots(),//.doc(widget.drummerId).snapshots(),
            builder: (context,snapshot){

          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          //setState(() {
          List<Drummer> drumm =
          snapshot.data?.docs.map((doc) => Drummer.fromSnapshot(doc)).toList()??[];
          Drummer  drummer = drumm.elementAt(0);
        //  });
          return Column(
            children: [
              Expanded(
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
                            colors: (widget.talking)? [
                              Colors.blueAccent,
                              Colors.blue
                            ] : (!widget.muted) ? [
                              Colors.grey.shade700,
                              Colors.grey.shade700
                            ]:[
                              Colors.grey.shade900,
                              Colors.grey.shade900
                            ],
                          )
                      ),
                      child: Stack(
                        children: [
                          Container(
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
                                imageUrl: modifyImageUrl(drummer?.imageUrl ??"","300x300"), fit: BoxFit.cover,fadeInCurve: Curves.easeIn,placeholder: (context, url) => Container(color: Colors.grey.shade900,),),
                            ),
                          ),
                         if(widget.muted) Container(
                             alignment: Alignment.bottomRight,
                             padding: EdgeInsets.all(12),
                             child: Container(
                               height: 36,
                                 width: 36,
                                 decoration: BoxDecoration(
                                   color: Colors.grey.shade900.withOpacity(0.75),
                                   borderRadius: BorderRadius.circular(48),
                                 ),
                                 child: Icon(Icons.mic_off,size: 24,))),
                        ],
                      ),
                    )
                ),
              ),
              SizedBox(height: 4,),
              if(drummer.username!=null)Text("${drummer.username}",style: TextStyle(fontSize: 12,fontFamily: APP_FONT_MEDIUM,),),
            ],
          );
        }),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // getDrummer(widget.drummerId);
   // listenToJamState();
    widget.muteController.listen((statusMap) {
      if (statusMap.containsKey(widget.drummerId)) {
        // Update the mute status when the status changes
        if(mounted)
        setState(() {
          widget.muted = statusMap[widget.drummerId] ?? true;
        });
      }
    });

    widget.speechController.listen((statusMap) {
      if (statusMap.containsKey(widget.drummerId)) {
        // Update the mute status when the status changes
        if(mounted)
        setState(() {
          widget.talking = statusMap[widget.drummerId] ?? false;
        });
      }
    });

  }

  void getDrummer(int rid)  async{
    // FirebaseDBOperations.getDrummer(foundedBy!).then((value) {
    //   setState(() {
    //     drummer = value;
    //     print("is ${drummer.uid}  speaking ${drummer.speaking}");
    //   });
    // });

    FirebaseFirestore.instance.collection('users').where('rid', isEqualTo: rid).get().then((value) {
      setState(() {
        drummUser = Drummer.fromSnapshot(value);
        print("is ${drummUser.uid}  speaking ${drummUser.speaking}");
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


