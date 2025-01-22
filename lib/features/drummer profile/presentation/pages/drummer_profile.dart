import 'dart:math';
import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_event.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrummerProfile extends StatelessWidget {
  const DrummerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
      ),
      body: _buildBody(),
    );
  }

  _buildBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${Random().nextInt(450)}",style: TextStyle(fontSize: 50),),
        BlocProvider<RemoteDrummerBloc>(
          create: (BuildContext context) => s1()..add(GetDrummer()),
          child: BlocBuilder<RemoteDrummerBloc,RemoteDrummerState>(
            builder: (context, state) {
              if(state is RemoteDrummerLoading) {
                return const Center(child: CupertinoActivityIndicator(),);
              }
              if(state is RemoteDrummerError){
                return const Center(child: Icon(Icons.refresh),);
              }
              if(state is RemoteDrummerDone){
                return  Center(child: Text("User: ${state.drummerEntity?.name} loaded" ),);
              }

              return const SizedBox();
            },

          ),
        ),
      ],
    );
  }

}
