import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/app_router.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/repository/login_repository.dart';
import 'package:primamobile/repository/user_session_repository.dart';
import 'package:primamobile/repository/user_repository.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart'; // Added
import 'package:primamobile/repository/transaction_detail_repository.dart'; // Added

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Create instances of repositories
    final loginRepository = LoginRepository();
    final userSessionRepository = UserSessionRepository();
    final userRepository = UserRepository();
    final productRepository = ProductRepository();
    final transactionRepository = TransactionRepository();
    final transactionDetailRepository = TransactionDetailRepository();

    // Create an instance of AuthenticationBloc with dependencies
    final authenticationBloc = AuthenticationBloc(
      loginRepository: loginRepository,
      userSessionRepository: userSessionRepository,
    )..add(AppStarted());

    // Pass dependencies to AppRouter
    final appRouter = AppRouter(
      authenticationBloc: authenticationBloc,
      userRepository: userRepository,
      transactionRepository: transactionRepository,
      transactionDetailRepository: transactionDetailRepository,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: loginRepository),
        RepositoryProvider.value(value: userSessionRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: transactionRepository),
        RepositoryProvider.value(value: transactionDetailRepository),
      ],
      child: BlocProvider.value(
        value: authenticationBloc,
        child: MaterialApp(
          title: 'PrimaMobile',
          theme: ThemeData(
            brightness: Brightness.light,
            // colorScheme: ColorScheme.fromSwatch().copyWith(
            //   secondary:
            //       Colors.lightBlue, // Change the secondary color to green
            // ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Colors.lightBlue,
            ),
            fontFamily: 'Montserrat',
          ),
          initialRoute: '/',
          onGenerateRoute: appRouter.onGenerateRoutes,
          debugShowCheckedModeBanner: false,

          // Device Preview
          builder: DevicePreview.appBuilder,
          locale: DevicePreview.locale(context),
        ),
      ),
    );
  }
}
