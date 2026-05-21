import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_minutes/repository/screens/AuthScreens/loginscreen.dart';
import 'package:in_minutes/repository/screens/location/locationScreen.dart';
import 'package:in_minutes/repository/screens/myOrder/my_order.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({Key? key}) : super(key: key);

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    if (user == null) {
      setState(() {
        isLoading = false;
        nameController.text = 'Guest';
      });
      return;
    }

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = data['name'] ?? user!.displayName ?? '';
          emailController.text = data['email'] ?? user!.email ?? '';
          phoneController.text = data['phone'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          emailController.text = user!.email ?? '';
          nameController.text = user!.displayName ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    if (user == null) return;

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
          });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Update failed')));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Log out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Log out'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logout failed')));
      }
    }
  }

  // Small helper for initials
  String _initials(String name, String email) {
    final n = name.trim();
    if (n.isNotEmpty) {
      final parts = n.split(' ');
      if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (email.isNotEmpty) return email[0].toUpperCase();
    return 'G';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final drawerWidth = mq.size.width * (mq.size.width > 800 ? 0.5 : 0.85);

    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => Navigator.pop(context),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: drawerWidth,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SafeArea(
                      child: Column(
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xfff7cb43), Color(0xff8ec5ff)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(18),
                                topLeft: Radius.circular(0),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: mq.size.width > 700 ? 36 : 28,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    _initials(
                                      nameController.text,
                                      emailController.text,
                                    ),
                                    style: TextStyle(
                                      fontSize: mq.size.width > 700 ? 22 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nameController.text.isEmpty
                                            ? 'Guest User'
                                            : nameController.text,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        emailController.text,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[800]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Content
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Edit Details',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        // Name
                                        TextFormField(
                                          controller: nameController,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            labelText: 'Full name',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator:
                                              (v) =>
                                                  (v == null ||
                                                          v.trim().length < 2)
                                                      ? 'Enter a valid name'
                                                      : null,
                                        ),
                                        const SizedBox(height: 12),

                                        // Email (read only)
                                        TextFormField(
                                          controller: emailController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            border: const OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: emailController.text,
                                                  ),
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Email copied',
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.copy),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        // Phone
                                        TextFormField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: const InputDecoration(
                                            labelText: 'Mobile number',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (v) {
                                            final val = v?.trim() ?? '';
                                            if (val.isEmpty) return null;
                                            if (!RegExp(
                                              r'^[0-9]{7,15}$',
                                            ).hasMatch(val))
                                              return 'Enter valid number';
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 18),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed:
                                                    isSaving
                                                        ? null
                                                        : () => Navigator.pop(
                                                          context,
                                                        ),
                                                child: const Text('Cancel'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed:
                                                    isSaving
                                                        ? null
                                                        : updateUserData,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFFF7CB43,
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: SizedBox(
                                                  height: 46,
                                                  child: Center(
                                                    child:
                                                        isSaving
                                                            ? const CircularProgressIndicator(
                                                              color:
                                                                  Colors.black,
                                                            )
                                                            : const Text(
                                                              'Save changes',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  const Divider(),

                                  // Quick links
                                  ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.shopping_bag),
                                    ),
                                    title: const Text('My orders'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const MyOrdersScreen(),
                                          ),
                                        ),
                                  ),

                                  ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.location_on),
                                    ),
                                    title: const Text('Change address'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LocationScreen(),
                                          ),
                                        ),
                                  ),

                                  ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.help_outline),
                                    ),
                                    title: const Text('Help & Support'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      // open support
                                    },
                                  ),

                                  const SizedBox(height: 18),

                                  // Logout
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        'Log out',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: logout,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
