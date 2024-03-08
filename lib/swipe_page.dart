

import 'package:drumm_app/custom/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/helper/firebase_db_operations.dart';

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



  @override
  void initState() {
    // TODO: implement initState
    pageController = PageController();
    super.initState();
    getHooks();
    observeText();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.75,
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
                  padding: const EdgeInsets.only(right: 0, top: 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        topicHead,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
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
                          maxLength: 120,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      runSpacing: 12.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 12,
                      alignment: WrapAlignment.center,
                      children: hookList
                          .map(
                            (hook) => GestureDetector(
                          onTap: () {

                            // List<String> tempHooks = selectedHooks;
                            // if (tempHooks.contains(hook)) {
                            //   tempHooks.remove(hook);
                            // } else {
                            //   tempHooks.add(hook);
                            // }
                            //
                            // setState(() {
                            //   selectedHooks = tempHooks;
                            // });


                            setState(() {
                              selectedHook = hook;
                                page+=1;
                            });

                            pageController.animateToPage(page, duration: Duration(milliseconds: 200), curve: Curves.easeIn);

                          },
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                            decoration: BoxDecoration(
                              color: selectedHooks.contains(hook)
                                  ? Colors.white
                                  : Colors.transparent,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Text(
                              hook,
                              style: TextStyle(
                                fontSize: 16,
                                  color: selectedHooks.contains(hook)
                                      ? Colors.blue
                                      : Colors.white,
                                fontWeight: selectedHooks.contains(hook)
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Hook: ",style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              )),
                              Text(selectedHook,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),),
                            ],
                          ), // Add some space at the bottom for better visibility
                        ],
                      ),
                      SizedBox(),
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
                      topicHead = "Select a hook";
                    });
                  } else if(page == 2){
                    setState(() {
                      topicHead = "Post question";
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
                if(page==0 && question.length>2)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      FocusScope.of(context).unfocus();
                      setState(() {

                        if(page<2)
                          page+=1;
                      });

                      pageController.animateToPage(page, duration: Duration(milliseconds: 200), curve: Curves.easeIn);

                    },
                      child: Icon(Icons.arrow_circle_right_rounded,size: 64,)),
                ),
                if(page==2)
                GestureDetector(
                  onTap: (){
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


}
