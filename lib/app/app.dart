import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/app_router.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/repository/login_repository.dart';
import 'package:primamobile/repository/user_session_repository.dart';
import 'package:primamobile/repository/user_repository.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';
import 'package:primamobile/repository/report_repository.dart';
import 'package:primamobile/repository/report_detail_repository.dart';
import 'package:primamobile/repository/logout_repository.dart'; // Add this import

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
    final reportRepository = ReportRepository();
    final reportDetailRepository = ReportDetailRepository();
    final logoutRepository = LogoutRepository(); // Add this line

    // Create an instance of AuthenticationBloc with dependencies
    final authenticationBloc = AuthenticationBloc(
      loginRepository: loginRepository,
      userSessionRepository: userSessionRepository,
      logoutRepository: logoutRepository, // Add this line
    )..add(AppStarted());

    // Pass dependencies to AppRouter
    final appRouter = AppRouter(
      authenticationBloc: authenticationBloc,
      userRepository: userRepository,
      transactionRepository: transactionRepository,
      transactionDetailRepository: transactionDetailRepository,
      reportRepository: reportRepository,
      reportDetailRepository: reportDetailRepository,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: loginRepository),
        RepositoryProvider.value(value: userSessionRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: transactionRepository),
        RepositoryProvider.value(value: transactionDetailRepository),
        RepositoryProvider.value(value: reportRepository),
        RepositoryProvider.value(value: reportDetailRepository),
        RepositoryProvider.value(value: logoutRepository), // Add this line
      ],
      child: BlocProvider.value(
        value: authenticationBloc,
        child: MaterialApp(
          title: 'PrimaMobile',
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: const ColorScheme.light(
              primary: Colors.lightBlue,
              secondary: Colors.lightBlue,
              onSecondary: Colors.white,
            ),
            primaryColor: Colors.lightBlue,
            primarySwatch: Colors.lightBlue,
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.lightBlue),
              ),
            ),
            buttonTheme: const ButtonThemeData(
              buttonColor: Colors.lightBlue,
              textTheme: ButtonTextTheme.primary,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.lightBlue,
              selectionColor: Color(0x4D03A9F4),
              selectionHandleColor: Colors.lightBlue,
            ),
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
