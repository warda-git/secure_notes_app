import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  runApp(SecureNotesApp());
}

class SecureNotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Notes System',
      theme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}

//////////////////////////////
// 🔐 LOGIN PAGE
//////////////////////////////

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedUser = prefs.getString("user");
    String? savedPass = prefs.getString("pass");

    if (userController.text == savedUser &&
        passController.text == savedPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NotesHome()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login 🔐")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Login")),
            TextButton(
              child: Text("Create Account"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

//////////////////////////////
// 🆕 SIGNUP PAGE
//////////////////////////////

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();

  Future<void> signup() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("user", userController.text);
    await prefs.setString("pass", passController.text);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signup, child: Text("Create Account"))
          ],
        ),
      ),
    );
  }
}

//////////////////////////////
// 🔐 SECURE NOTES PAGE
//////////////////////////////

class NotesHome extends StatefulWidget {
  @override
  _NotesHomeState createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  List<String> notes = [];
  TextEditingController controller = TextEditingController();

  final key = encrypt.Key.fromLength(32);
  final iv = encrypt.IV.fromLength(16);
  late final encrypter = encrypt.Encrypter(encrypt.AES(key));

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  String encryptText(String text) {
    return encrypter.encrypt(text, iv: iv).base64;
  }

  String decryptText(String text) {
    return encrypter.decrypt64(text, iv: iv);
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs.getStringList('notes') ?? [];
    });
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', notes);
  }

  void addNote() {
    if (controller.text.isEmpty) return;

    setState(() {
      notes.add(encryptText(controller.text));
      controller.clear();
    });

    saveNotes();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    saveNotes();
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Secure Notes 🔐"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Write secure note...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(onPressed: addNote, child: Text("Add"))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(decryptText(notes[index])),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteNote(index),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}