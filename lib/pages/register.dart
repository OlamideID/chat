import 'package:chat/components/confirmpass.dart';
import 'package:chat/components/mybutton.dart';
import 'package:chat/components/passtext.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _emailCntrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passCntrl = TextEditingController();
  final TextEditingController confirmpassCntrl = TextEditingController();

  var riveUrl = 'assets/login_screen_character.riv';
  SMITrigger? failTrigger, successTrigger;
  SMIBool? isHandsup, isChecking;
  SMINumber? lookNum;
  StateMachineController? stateMachineController;
  Artboard? artboard;

  // Separate obscured states for password and confirm password
  bool passwordObscured = true;
  bool confirmPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    loadRiveFile();
  }

  void loadRiveFile() async {
    final data = await rootBundle.load(riveUrl);
    final file = RiveFile.import(data);
    final art = file.mainArtboard;
    stateMachineController =
        StateMachineController.fromArtboard(art, 'State Machine 1');
    if (stateMachineController != null) {
      art.addController(stateMachineController!);
      for (var element in stateMachineController!.inputs) {
        if (element.name == 'Check') {
          isChecking = element as SMIBool;
        } else if (element.name == 'hands_up') {
          isHandsup = element as SMIBool;
        } else if (element.name == 'fail') {
          failTrigger = element as SMITrigger;
        } else if (element.name == 'success') {
          successTrigger = element as SMITrigger;
        } else if (element.name == 'Look') {
          lookNum = element as SMINumber;
        }
      }
      setState(() => artboard = art);
    }
  }

  void lookAround() {
    isChecking?.change(true);
    isHandsup?.change(false);
    lookNum?.change(0);
  }

  void moveEyes(String value) {
    lookNum?.change(value.length.toDouble());
  }

  void coverEyes() {
    isHandsup?.change(true);
    isChecking?.change(false);
  }

  void togglePasswordVisibility() {
    setState(() {
      passwordObscured = !passwordObscured;
      passwordObscured ? coverEyes() : lookAround();
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      confirmPasswordObscured = !confirmPasswordObscured;
      confirmPasswordObscured ? coverEyes() : lookAround();
    });
  }

  Future<void> register(BuildContext context) async {
    final auth = Authservice();
    final firestore = FirebaseFirestore.instance;

    if (usernameCtrl.text.isEmpty) {
      showSnackbar(context, 'Username cannot be empty');
      return;
    }

    if (passCntrl.text != confirmpassCntrl.text) {
      showSnackbar(context, 'Passwords do not match');
      return;
    }

    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('username', isEqualTo: usernameCtrl.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        showSnackbar(context, 'Username is already taken');
      } else {
        successTrigger?.fire();
        await auth.signUpWithEmailAndUsername(
          _emailCntrl.text,
          passCntrl.text,
          usernameCtrl.text,
        );

        showSnackbar(context, 'Registration successful! You can now log in.');
      }
    } catch (e) {
      // Show a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(e.toString()), // The error message
          duration: const Duration(
              seconds: 3), // Duration the SnackBar will be visible
        ),
      );
      ;
    }
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              if (artboard != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    height: 300,
                    width: 500,
                    child: Rive(artboard: artboard!),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Let\'s create an account for you',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              MyTextField(
                onChanged: moveEyes,
                onTap: lookAround,
                controller: _emailCntrl,
                hintText: 'Email',
                obscure: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                onChanged: moveEyes,
                onTap: lookAround,
                controller: usernameCtrl,
                hintText: 'Username',
                obscure: false,
              ),
              const SizedBox(height: 10),
              PassText(
                obscured: passwordObscured,
                onPressed: togglePasswordVisibility,
                icon: passwordObscured
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                controller: passCntrl,
                thing: 'Password',
                ontap: coverEyes,
              ),
              const SizedBox(height: 10),
              ConfirmPass(
                obscured: confirmPasswordObscured,
                icon: confirmPasswordObscured
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                onPressed: toggleConfirmPasswordVisibility,
                ontap: coverEyes,
                controller: confirmpassCntrl,
                thing: 'Confirm Password',
              ),
              const SizedBox(height: 10),
              Button(
                text: 'Register',
                onTap: () => register(context),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
