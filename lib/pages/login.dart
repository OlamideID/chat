import 'package:chat/components/mybutton.dart';
import 'package:chat/components/passtext.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class LoginPage extends ConsumerStatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailCntrl = TextEditingController();
  final TextEditingController passCntrl = TextEditingController();
  var riveUrl = 'assets/bunny_login.riv';
  SMITrigger? failTigger;
  SMITrigger? successTigger;
  SMIBool? isHandsup, isChecking;
  SMINumber? lookNum;
  StateMachineController? stateMachineController;
  Artboard? artboard;

  bool obscured = true;

  @override
  void initState() {
    super.initState();

    // Initialize RiveFile
    RiveFile.initialize().then((_) {
      rootBundle.load(riveUrl).then((value) {
        final file = RiveFile.import(value);
        final art = file.mainArtboard;
        stateMachineController =
            StateMachineController.fromArtboard(art, 'State Machine 1');
        if (stateMachineController != null) {
          art.addController(stateMachineController!);
          for (var element in stateMachineController!.inputs) {
            if (element.name == 'isFocus') {
              isChecking = element as SMIBool;
            } else if (element.name == 'IsPassword') {
              isHandsup = element as SMIBool;
            } else if (element.name == 'login_fail') {
              failTigger = element as SMITrigger;
            } else if (element.name == 'login_success') {
              successTigger = element as SMITrigger;
            } else if (element.name == 'eye_track') {
              lookNum = element as SMINumber;
            }
          }
        }
        setState(() {
          artboard = art;
        });
      });
    });
  }

  // Future<void> getDeviceToken() async {
  //   try {
  //     String? token = await FirebaseMessaging.instance.getToken();
  //     if (token != null) {
  //       debugPrint("Device Token: $token"); // Log the token for testing
  //       // Display the token in the UI only if the widget is mounted
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               'Device Token: $token',
  //             ),
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error fetching token: $e");
  //   }
  // }

  lookAround() {
    isChecking?.change(true);
    isHandsup?.change(false);
    lookNum?.change(0);
  }

  moveEyes(value) {
    lookNum?.change(value.length.toDouble());
  }

  coverEyes() {
    isHandsup?.change(true);
    isChecking?.change(false);
  }

  login(BuildContext context) async {
    final auth = Authservice();
    isChecking?.change(false);
    isHandsup?.change(false);
    try {
      successTigger?.fire();
      Future.delayed(
        Durations.short4,
      );
      // await getDeviceToken();
      await auth.signInWithEmailAndPassword(_emailCntrl.text, passCntrl.text);
    } catch (e) {
      failTigger?.fire();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() {});
  }

  void forgotPassword() async {
    final auth = Authservice();
    final firestore = FirebaseFirestore.instance;
    String email = _emailCntrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    try {
      // Check if the email exists in the Firestore users collection
      final userQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // User not found, show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found with this email.')),
        );
        return;
      }

      // Email exists, proceed to send password reset
      await auth.sendPasswordResetEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password reset email sent! Check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  togglePass() {
    setState(() {
      obscured = !obscured;
    });

    if (obscured == true) {
      coverEyes();
    } else {
      lookAround();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: const Color.fromARGB(155, 187, 222, 251),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (artboard != null)
                SizedBox(
                  height: 250,
                  width: 700,
                  child: Rive(artboard: artboard!),
                ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Welcome back you\'ve been missed',
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                    fontSize: 16),
              ),
              const SizedBox(
                height: 15,
              ),
              MyTextField(
                onChanged: moveEyes,
                onTap: lookAround,
                controller: _emailCntrl,
                hintText: 'Email',
                obscure: false,
              ),
              const SizedBox(
                height: 10,
              ),
              PassText(
                obscured: obscured,
                onPressed: togglePass,
                icon: obscured
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                controller: passCntrl,
                thing: 'Password',
                ontap: coverEyes,
              ),
              const SizedBox(
                height: 20,
              ),
              Button(
                text: 'Login',
                onTap: () {
                  login(context);
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a Member?'),
                    const SizedBox(
                      width: 25,
                    ),
                    InkWell(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: forgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey[200] : Colors.grey[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
