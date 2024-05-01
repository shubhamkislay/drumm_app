

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/SearchProfessionDropdown.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/model/algolia_article.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/SearchDesignationsDropdown.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/article.dart';
import 'model/profession.dart';

class AskQuestionPage extends StatefulWidget {
  AskQuestionPage({Key? key}) : super(key: key);

  @override
  State<AskQuestionPage> createState() => AskQuestionPageState();
}

class AskQuestionPageState extends State<AskQuestionPage>
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
  List<Article> fetchedArticles = [];

  List<String> fetchedAMAQuestions = [];

  String selectedDesignation = "";

  Widget selectedItem = Container();
  var nameTxt = TextEditingController();
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument = null;
  DocumentSnapshot<Map<String, dynamic>>? _startDocument = null;
  AlgoliaArticles? algoliaArticles = AlgoliaArticles();


  @override
  void initState() {
    // TODO: implement initState
    pageController = PageController();
    super.initState();
    getHooks();
    getProfessions();
    observeText();
    //getArticleQuestion();
    getAMAQuestions();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height*0.5,
      decoration: BoxDecoration(
        //color: Colors.grey.shade900,
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              // Colors.blue.shade400,
              // Colors.blue.shade700,
              // Colors.blue.shade900,
              COLOR_ARTICLE_BACKGROUND,
              COLOR_ARTICLE_BACKGROUND,
            ]
        ),
      ),
      child: SafeArea(
        bottom: false,
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
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
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
                    if(false)
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

                       (fetchedAMAQuestions.isNotEmpty)?
                       Expanded(
                         child: ListView.builder(
                           itemCount: fetchedAMAQuestions.length,
                           itemBuilder: (context, index) {
                           return GestureDetector(
                             onTap: (){
                               FocusScope.of(context).unfocus();
                               setState(() {
                                 question = "${fetchedAMAQuestions.elementAt(index)}";
                                 if (question.isNotEmpty && page < 2) {
                                 page += 1;
                                 pageController.animateToPage(
                                     page, duration: Duration(milliseconds: 200),
                                     curve: Curves.easeIn);
                                 }
                               });
                         
                         
                             },
                             child: Container(
                               padding: EdgeInsets.symmetric(vertical: 18,horizontal: 4),
                               margin: EdgeInsets.symmetric(horizontal: 12),

                               width: double.maxFinite,
                               decoration: BoxDecoration(
                                   color: Colors.transparent,
                                 border: Border(
                                   bottom: BorderSide(
                                     color: Colors.grey.withOpacity(0.05),

                                   )
                                 )
                               ),
                               child: Row(
                                 children: [
                                   Expanded(
                                     child: Text("${fetchedAMAQuestions.elementAt(index)}",style: TextStyle(
                                       fontSize: 17,
                                       fontFamily: APP_FONT_BOLD,
                                       color: Colors.white70
                                     ),),
                                   ),
                                   Icon(Icons.transit_enterexit_rounded,color: Colors.white70,),
                                 ],
                               ),
                             ),
                           );
                         },),
                       ):const SizedBox(),
                      Container(
                        color: COLOR_BACKGROUND,
                        width: double.maxFinite,
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 2),
                        child: SafeArea(
                          top: false,
                          child: TextField(
                            controller: questionTextController,
                            autofocus: true,
                            maxLength: 60,

                            decoration: InputDecoration(
                                hintText: "Ask anything...",
                                hoverColor: Colors.white,
                                fillColor: COLOR_BACKGROUND,
                                hintStyle: TextStyle(
                                  color: Colors.white24,
                                  fontFamily: APP_FONT_MEDIUM,
                                )),
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: APP_FONT_MEDIUM,
                              color: Colors.white,
                            ),
                            textInputAction: TextInputAction.done,
                            onChanged: (value){
                              setState(() {
                                question = value;
                              });
                            },
                            onEditingComplete: (){
                              FocusScope.of(context).unfocus();
                              if(question.length>2) {

                                setState(() {
                                  questionTextController.text = question;
                                  if (page < 2) {
                                    page += 1;
                                  }
                                });

                                pageController.animateToPage(
                                    page, duration: Duration(milliseconds: 200),
                                    curve: Curves.easeIn);
                              }
                            },
                          ),
                        ),
                      ),// Add some space at the bottom for better visibility
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
                            isLight: true,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 0,),


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
                      if(true)   Container(
                        padding: const EdgeInsets.all(12.0),
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(child: Text("Ask an Expert",style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),),),
                            Flexible(
                              child: Text((selectedDesignation.isNotEmpty)? "${selectedDesignation} in ${selectedProfession.departmentName}": "${selectedProfession.departmentName}",
                                textAlign: TextAlign.center,
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
                      topicHead = "Post your Question";
                    });

                  }

                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(page==1)  SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                        onTap: (){
                          FocusScope.of(context).unfocus();
                          setState(() {
                            page-=1;
                          });
                  
                          pageController.animateToPage(page, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                        },
                        child: Icon(Icons.arrow_back_ios_rounded,size: 32,)),
                  ),
                ),
                if(page==0)
                  Container(),
                if(//page==0 && question.length>2 ||
                    page==1&&selectedProfession.departmentName!=null)
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
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
                          child: Icon(Icons.arrow_forward_ios_rounded,size: 32,)),
                    ),
                  ),
                // if(page==2&&false)
                // GestureDetector(
                //   onTap: (){
                //     postQuestion();
                //     Navigator.pop(context);
                //   },
                //   child: const Padding(
                //     padding: EdgeInsets.all(8.0),
                //     child: Icon(Icons.camera_rear,size: 60,),
                //   ),
                // ),

                if(page==2)
                  Expanded(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12,right: 12,bottom: 8),
                        child: SwipeButton.expand(
                          thumbPadding: const EdgeInsets.all(4),
                          height: 64,
                          thumb: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'images/audio-waves.png',
                              fit: BoxFit.contain,
                              color: Colors.blue,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(22),
                          child:  Text(
                            "Swipe right to post",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.white.withOpacity(0.175),
                          onSwipe: () {
                            Vibrate.feedback(FeedbackType.success);
                            postQuestion();
                            Navigator.pop(context);
                      
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  getArticleQuestion() async{
    AlgoliaArticles fetchAlgoliaArticles = await FirebaseDBOperations.getArticlesData(
        _startDocument, _lastDocument, false);
    algoliaArticles = fetchAlgoliaArticles;
    setState(() {
      fetchedArticles = algoliaArticles?.articles??[];
    });


  }

  getAMAQuestions() async{
    List<String> askQuestions = await FirebaseDBOperations.getGeneratedAMAQuestions();

    setState(() {
      fetchedAMAQuestions = askQuestions;
    });

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
          isLight: true,
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
          isLight: true,
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
