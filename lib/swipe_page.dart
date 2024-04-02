

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/SearchProfessionDropdown.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/model/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/SearchDesignationsDropdown.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/profession.dart';

class SwipePage extends StatefulWidget {
  SwipePage({Key? key}) : super(key: key);

  @override
  State<SwipePage> createState() => SwipePageState();
}

class SwipePageState extends State<SwipePage>
    with SingleTickerProviderStateMixin {
  //final CardSwiperController controller = CardSwiperController();
  var cards = [];
  bool loadCards = false;
  late PageController pageController;
  List<String> selectedHooks = [];

  List<String> hookList = [];
  int page = 0;
  TextEditingController questionTextController= TextEditingController(
      text: ""
  );
  String question = "";
  String topicHead = "";

  String selectedHook = "";

  List<Profession> professions = [];

  Profession selectedProfession = Profession();

  String selectedDesignation = "";

  Widget selectedItem = Container();


  @override
  void initState() {
    // TODO: implement initState
    pageController = PageController();
    super.initState();
    getHooks();
    getProfessions();
    observeText();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.5,
      decoration: BoxDecoration(
        //color: Colors.grey.shade900,
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
              Colors.blue.shade900
            ]
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16, top: 12),
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      Vibrate.feedback(FeedbackType.selection);
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 42,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(right: 16, top: 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Flexible(
                         child: Text(
                          topicHead,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                                               ),
                       ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                       SingleChildScrollView(
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.white,
                          maxLines: null,
                          autofocus: true,
                          maxLength: 60,
                          cursorHeight: 32,
                          cursorWidth: 5,
                          textAlign: TextAlign.center,
                          controller: questionTextController,
                          onChanged: (val){
                            setState(() {
                              question = val;
                            });
                          },
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(
                              hintText: 'Ask anything...', fillColor: Colors.transparent),
                        ),
                      ),
                      const SizedBox(), // Add some space at the bottom for better visibility
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      if (professions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SearchProfessionDropdown(
                            colorTheme: Colors.black,
                            professions: professions,
                            hintText: "Field of expertise",
                            professionSelectedCallback: (Profession profession) {
                              setState(() {
                                selectedProfession = profession;
                                selectedDesignation = "";
                                selectedItem = Container();
                                setWidget();

                              });
                            },

                          ),
                        ),
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: selectedItem
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if(true)   Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(child: Text("Expertise: ",style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),),),
                            Flexible(
                              child: Text((selectedDesignation.isNotEmpty)? "${selectedDesignation} in ${selectedProfession.departmentName}": "${selectedProfession.departmentName}",
                                textAlign: TextAlign.left,
                                maxLines: 3,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                            fontSize: 26,
                        ),),
                      ),
                      const SizedBox(height: 16,),
                    // Add some space at the bottom for better visibility
                    ],
                  ),
                ],
                onPageChanged: (page){
                  if(page==0){
                    setState(() {
                      topicHead = "";
                    });
                  } else if(page == 1){
                    setState(() {
                      topicHead = "Ask an expert";
                    });
                  } else if(page == 2){

                      setState(() {
                      topicHead = "Post";
                    });

                  }

                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              if(page>0)  Container(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: (){
                        FocusScope.of(context).unfocus();
                        setState(() {
                          page-=1;
                        });

                        pageController.animateToPage(page, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                      },
                      child: Icon(Icons.arrow_circle_left_rounded,size: 64,)),
                ),
                if(page==0)
                  Container(),
                if(page==0 && question.length>2 || page==1&&selectedProfession.departmentName!=null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      FocusScope.of(context).unfocus();
                      setState(() {

                        if(page<2) {
                          page+=1;
                        }
                      });

                      pageController.animateToPage(page, duration: Duration(milliseconds: 200), curve: Curves.easeIn);

                    },
                      child: Icon(Icons.arrow_circle_right_rounded,size: 64,)),
                ),
                if(page==2)
                GestureDetector(
                  onTap: (){
                    postQuestion();
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.check_circle_rounded,size: 60,),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getHooks() async {
    List<String> bandHooks = await FirebaseDBOperations.getBandHooks();
    setState(() {
      hookList = bandHooks;
    });
  }

  void observeText() {
    questionTextController.addListener(() {
      setState(() {
        question = questionTextController.text;
      });
    });
  }

  void setWidget() async{

    Future.delayed(Duration(milliseconds: 100),(){
      setState(() {
        selectedItem = (selectedProfession.designations!.length>0) ? SearchDesignationDropdown(
          colorTheme: Colors.black,
          hintText: "Role of the expert",
          designations: selectedProfession.designations??[],
          designationsSelectedCallback: (String designation) {

            setState(() {
              selectedDesignation = designation;
            });
          },

        ):
        SearchDesignationDropdown(
          colorTheme: Colors.black,
          hintText: "Role of the expert",
          designations: selectedProfession.designations??[],
          designationsSelectedCallback: (String designation) {

            setState(() {
              selectedDesignation = designation;
            });
          },

        );

      });

    });
  }

  void postQuestion() async{

    DocumentReference questionRef =
    FirebaseFirestore.instance.collection("questions").doc();
    String pushId = questionRef.id;

    Question newQuestion = Question();
    newQuestion.query = question;
    newQuestion.departmentName = selectedProfession.departmentName;
    newQuestion.designation = selectedDesignation;
    newQuestion.uid = FirebaseAuth.instance.currentUser?.uid;
    newQuestion.createdTime =  Timestamp.now();
    newQuestion.qid = pushId;

    FirebaseDBOperations.postQuestion(newQuestion);

  }

  void getProfessions() async {
    List<Profession> fetchProfessions =
    await FirebaseDBOperations.getProfessions();
    setState(() {
      professions = fetchProfessions;
    });
  }


}
