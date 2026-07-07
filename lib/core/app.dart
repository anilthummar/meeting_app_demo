import 'package:flutter/material.dart';
import 'package:flutter_amazon_chime/chime_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../bloc/meeting/meeting_bloc.dart';
import '../repository/meeting_repository.dart';
import '../core/api_constants.dart';
import '../screens/home_screen.dart';
import '../services/chime_meeting_service.dart';
import '../services/meeting_service.dart';

class MeetingApp extends StatelessWidget {
  const MeetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChimeSession()),
        RepositoryProvider(
          create: (_) => MeetingRepository(
            MeetingService(apiKey: ApiConstants.apiKey),
          ),
        ),
        ProxyProvider2<MeetingRepository, ChimeSession, ChimeMeetingService>(
          update: (_, repository, session, previous) =>
              ChimeMeetingService(session),
        ),
        BlocProvider(
          create: (context) => MeetingBloc(
            context.read<MeetingRepository>(),
            context.read<ChimeMeetingService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Meeting App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
