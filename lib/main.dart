import 'package:flutter/material.dart';
import 'models/hostel_models.dart';
import 'screens/role_select_screen.dart';
import 'screens/student_login_screen.dart';
import 'screens/student_shell.dart';
import 'screens/warden_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HostelMateApp());
}

class HostelMateApp extends StatelessWidget {
  const HostelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HostelMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF0F766E),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      initialRoute: RoleSelectScreen.routeName,
      routes: {
        RoleSelectScreen.routeName: (_) => const RoleSelectScreen(),
        StudentLoginScreen.routeName: (_) => const StudentLoginScreen(),
        WardenShell.routeName: (_) => const WardenShell(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == StudentShell.routeName) {
          final student = settings.arguments as StudentUser?;
          return MaterialPageRoute(
            builder: (_) => StudentShell(student: student),
          );
        }
        return null;
      },
    );
  }
}
