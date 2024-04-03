import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom/helper/firebase_db_operations.dart';
import 'custom/helper/image_uploader.dart';
import 'custom/rounded_button.dart';
import 'model/Drummer.dart';

class UserProfileIcon extends StatefulWidget {
  double? iconSize;
  UserProfileIcon({Key? key, this.iconSize}) : super(key: key);

  @override
  State<UserProfileIcon> createState() => _UserProfileIconState();
}

class _UserProfileIconState extends State<UserProfileIcon> {
  Drummer drummer = Drummer();
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        (drummer.imageUrl != null)
            ? Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              color: Colors.black),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
                width: widget.iconSize??30,
                height: widget.iconSize??30,
                imageUrl: modifyImageUrl(
                    drummer.imageUrl ?? "", "100x100"),
                fit: BoxFit.cover),
          ),
        )
            : RoundedButton(
            height: 26,
            width: 26,
            assetPath: "images/user_profile_active.png",
            color: Colors.white,
            bgColor: Colors.black,
            onPressed: () {})
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDrummer();
  }

  void getCurrentDrummer() async {
    Drummer curDrummer = await FirebaseDBOperations.getDrummer(
        FirebaseAuth.instance.currentUser?.uid ?? "");
    setState(() {
      drummer = curDrummer;
    });
  }
}
