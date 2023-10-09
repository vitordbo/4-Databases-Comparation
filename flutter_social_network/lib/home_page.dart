import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostList extends StatefulWidget {
  PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final auth = FirebaseAuth.instance;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _getName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('post').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var posts = snapshot.data?.docs;

          return ListView.builder(
            itemCount: posts?.length,
            itemBuilder: (context, index) {
              var post = posts![index].data();
              var postText = post['text'];
              var author = post['author'];
              var timestamp = post['timestamp'].toDate();

              return ListTile(
                title: Text(postText),
                subtitle: Text('Por: $author em: $timestamp'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewPost(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _createNewPost(BuildContext context) {
    TextEditingController postTextController = TextEditingController();

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user == null) {
      // Se o usuário não estiver autenticado, trate o caso adequadamente
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: postTextController,
                decoration: InputDecoration(labelText: 'Texto do Post'),
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (postTextController.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('post').add({
                    'text': postTextController.text,
                    'author': _userName,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Postar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getName() async {
    final user = auth.currentUser;
    if (user != null) {
      final userEmail = user.email;

      try {
        final querySnapshot =
            await usersCollection.where('email', isEqualTo: userEmail).get();
        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs[0].data() as Map<String, dynamic>;
          final userName = userData[
              'name']; // Substitua 'name' pelo nome do campo que armazena o nome do usuário no Firestore
          setState(() {
            // Atualize o nome na interface do usuário
            _userName = userName;
          });
        }
      } catch (e) {
        print('Erro ao buscar dados do usuário: $e');
      }
    }
  }
}
