import 'package:flutter/material.dart';

typedef void OptionCallback(bool option);

class AutoJoinOption extends StatefulWidget {
  OptionCallback? optionCallback;

  AutoJoinOption({Key? key, required this.optionCallback}) : super(key: key);

  @override
  State<AutoJoinOption> createState() => _AutoJoinOptionState();
}

class _AutoJoinOptionState extends State<AutoJoinOption> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey.shade900,
      child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Do you want to auto listen open drumms while swiping?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                      color: Colors.white, fontWeight: FontWeight.normal),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.optionCallback!(false);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 42,vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "No",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.optionCallback!(true);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 42,vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Yes",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
