import 'package:chat/components/confirmpass.dart';
import 'package:chat/components/mybutton.dart';
import 'package:chat/components/passtext.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailCntrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();

  final TextEditingController passCntrl = TextEditingController();

  final TextEditingController confirmpassCntrl = TextEditingController();

  var riveUrl = 'assets/animated_login_character.riv';
  SMITrigger? failTigger, successTigger;
  SMIBool? isHandsup, isChecking;
  SMINumber? lookNum;
  StateMachineController? stateMachineController;
  Artboard? artboard;
  bool obscured = true;

  @override
  void initState() {
    super.initState();
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
          } else if (element.name == 'trigSuccess') {
            failTigger = element as SMITrigger;
          } else if (element.name == 'numLook') {
            lookNum = element as SMINumber;
          }
          setState(() {
            artboard = art;
          });
        }
      }
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

  
register(BuildContext context) async {
  final auth = Authservice();
  final firestore = FirebaseFirestore.instance; // Firestore instance to query usernames

  // Check if username field is empty
  if (usernameCtrl.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Username cannot be empty',
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
    return;
  }

  // Check if passwords match
  if (passCntrl.text == confirmpassCntrl.text) {
    try {
      // Check if the username already exists
      var querySnapshot = await firestore
          .collection('Users')
          .where('username', isEqualTo: usernameCtrl.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If username is taken, show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Username is already taken',
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
      } else {
        // Proceed with registration if the username is available
        await auth.signUpWithEmailAndUsername(
            _emailCntrl.text, passCntrl.text, usernameCtrl.text);

        // Show a success SnackBar without sending verification email
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful! You can now log in.',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        // Optionally, navigate to the login or home screen
        // Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(child: Text('Error')),
          content: Text(e.toString()),
        ),
      );
    }
  } else {
    // Show error if passwords do not match
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Passwords do not match',
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
}


  togglePass() {
    setState(() {
      obscured = !obscured;
    });
    obscured ? coverEyes() : lookAround() && moveEyes(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(155, 187, 222, 251),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              if (artboard != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    height: 300,
                    width: 700,
                    child: Rive(
                      artboard: artboard!,
                    ),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Let\'s create an account for you',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 16),
              ),
              const SizedBox(
                height: 25,
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
              MyTextField(
                onChanged: moveEyes,
                onTap: lookAround,
                controller: usernameCtrl,
                hintText: 'Username',
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
                height: 10,
              ),
              ConfirmPass(
                  ontap: coverEyes,
                  controller: confirmpassCntrl,
                  thing: 'Confirm Password'),
              const SizedBox(
                height: 10,
              ),
              Button(
                text: 'Register',
                onTap: () {
                  register(context);
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
