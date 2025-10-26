import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utilities/artificial_intelligence/presentation/bloc/ai_chat_bloc.dart';
import 'package:utilities/artificial_intelligence/presentation/bloc/ai_chat_event.dart';
import 'package:utilities/artificial_intelligence/presentation/bloc/ai_chat_state.dart';

import '../../domain/entities/chat_message.dart';

import '../../ai_injection_container.dart';

part 'artificial_intelligence.dart';

class AiChatBase extends StatelessWidget {
  const AiChatBase({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AiChatBloc>(),
      child: _AiChatScreen(),
    );
  }
}
