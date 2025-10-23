import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utilities/artificial_intelligence/presentation/view/artificial_intelligence.dart';

import '../../ai_injection_container.dart';
import '../bloc/ai_chat_bloc.dart';

class AiChatBase extends StatelessWidget {
  const AiChatBase({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AiChatBloc>(),
      child: AiChatScreen(),
    );
  }
}
