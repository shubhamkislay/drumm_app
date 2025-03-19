import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/custom/helper/circular_reveal_clipper.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

import '../../../user page/presentation/pages/user_profile_page.dart';

class DrummerJoinCard extends StatefulWidget {
  final int drummerId;
  final bool muted;
  final bool talking;
  DrummerJoinCard({
      required this.drummerId,required this.muted,required this.talking,
        Key? key,
      }) : super(key: key);

  @override
  State<DrummerJoinCard> createState() => _DrummerJoinCardState();

}

class _DrummerJoinCardState extends State<DrummerJoinCard> {
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
          List<DrummerEntity> drumm =
          snapshot.data?.docs.map((doc) => DrummerEntity.fromSnapshot(doc)).toList()??[];
          DrummerEntity  drummer = drumm.elementAt(0);
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
                              drummer: drummer, currentUser: drummer.uid==FirebaseAuth.instance.currentUser?.uid?true:false,
                            ),
                          ));
                    },
                    child:  Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors:  (!widget.muted) ? (widget.talking)? [
                              Colors.blueAccent,
                              Colors.blue
                            ] : [
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
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
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
                                   borderRadius: BorderRadius.circular(56),
                                 ),
                                 child: Icon(Icons.mic_off,size: 24,color: Colors.white,))),
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

  }
}


