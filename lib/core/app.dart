import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => MeetingRepository(
            MeetingService(apiKey: ApiConstants.apiKey),
          ),
        ),
        RepositoryProvider(create: (_) => ChimeMeetingService()),
      ],
      child: BlocProvider(
        create: (context) => MeetingBloc(
          context.read<MeetingRepository>(),
          context.read<ChimeMeetingService>(),
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Meeting App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
