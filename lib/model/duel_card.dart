import 'package:flutter/material.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/model/question.dart';


class DuelCard extends StatelessWidget {
  final Question question;

  const DuelCard(
      this.question, {
        Key? key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 475,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12),
            width: double.maxFinite,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade600,Colors.blue.shade800],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
             //RandomColorBackground(setColor: Colors.white),
                Text(
                  "${question.query}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    //fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),
         if(true) Container(
           height: 75,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 24),
            width: MediaQuery.of(context).size.width,
            child: Text(
              "#${question.category}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}