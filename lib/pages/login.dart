import 'package:chat/components/mybutton.dart';
import 'package:chat/components/passtext.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailCntrl = TextEditingController();
  final TextEditingController passCntrl = TextEditingController();
  var riveUrl = 'assets/animated_login_character.riv';
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
            StateMachineController.fromArtboard(art, 'Login Machine');
        if (stateMachineController != null) {
          art.addController(stateMachineController!);
          for (var element in stateMachineController!.inputs) {
            if (element.name == 'isChecking') {
              isChecking = element as SMIBool;
            } else if (element.name == 'isHandsUp') {
              isHandsup = element as SMIBool;
            } else if (element.name == 'trigFail') {
              failTigger = element as SMITrigger;
            } else if (element.name == 'trigSuccess') {
              successTigger = element as SMITrigger;
            } else if (element.name == 'numLook') {
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
      successTigger!.fire();
      Future.delayed(Durations.short4);
      await auth.signInWithEmailAndPassword(_emailCntrl.text, passCntrl.text);
      // successTigger?.fire();
    } catch (e) {
      failTigger!.fire();
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(child: Text('Error')),
          content: Text(e.toString()),
        ),
      );
    }
    setState(() {});
  }

  void forgotPassword() async {
    final auth = Authservice();
    String email = _emailCntrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    try {
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(155, 187, 222, 251),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (artboard != null)
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Rive(artboard: artboard!),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Welcome back you\'ve been missed',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
                const SizedBox(height: 15), // Add spacing between elements
                InkWell(
                  onTap: forgotPassword, // Call forgotPassword method
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
