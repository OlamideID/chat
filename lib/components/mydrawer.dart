import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/reviews.dart';
import 'package:chat/pages/settings.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Mydrawer extends StatelessWidget {
  const Mydrawer({super.key});

  logout() {
    final auth = Authservice();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                    child:
                        Lottie.asset('assets/Animation - 1730054588410.json')),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListTile(
                  title: const Text('H O M E'),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListTile(
                  title: const Text('S E T T I N G S'),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListTile(
                  title: const Text('P R O F I L E'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListTile(
                  title: const Text('R E V I E W S'),
                  leading: const Icon(Icons.reviews),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReviewPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: ListTile(
              title: const Text('L O G O U T'),
              leading: const Icon(Icons.logout_outlined),
              onTap: () {
                logout();
              },
            ),
          )
        ],
      ),
    );
  }
}
