import 'package:flutter/material.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/profile_page.dart';
import 'package:drumm_app/user_profile_page.dart';


class PeopleCard extends StatelessWidget {
  final Drummer drummer;

  PeopleCard(this.drummer, {Key? key, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: Container(
        margin: EdgeInsets.all(4),
        width: 250,
        color: Colors.grey.shade900,
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width*0.75,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                  ),
                ),
                child: Text(
                  "${drummer.name}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      //fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            if (true)
              Container(
                color: Colors.cyan,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 24),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "${drummer.badges} Badges",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            if (true)
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 24),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "${drummer.username}",
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
