// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_social_network/login-reg-firebase/login_view.dart';
import 'package:validatorless/validatorless.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  late String _status = "";

  Future<void> _onClickEmailCreate() async {
    String email = _email.text;
    String password = _password.text;
    String name = _name.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      // Verifica se o usuário foi criado com sucesso
      if (user != null) {
        String userId = user.uid;

        Map<String, dynamic> userData = {
          'name': name,
          'email': email,
          'timestamp':
              FieldValue.serverTimestamp(), // Para registrar a hora atual
        };

        // Acesse a coleção 'users' e crie um novo documento com o ID do usuário
        // vamos criar outra coleção dentro dessa de user que vai ter email e nome
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(userData);

        setState(() {
          _status = "Sucesso! E-mail: $email, Nome: $name";
        });
      } else {
        setState(() {
          _status = "Erro: Usuário não criado.";
        });
      }
    } catch (error) {
      setState(() {
        _status = "Erro no create: $error";
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      body: Container(
        color: Colors.black,
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("A Rede Social"),
              const SizedBox(
                height: 80,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      // name
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _name,
                        validator: Validatorless.multiple(
                          [
                            Validatorless.required('Nome é Obrigatório'),
                          ],
                        ),
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          labelText: 'Nome',
                        ),
                      ),
                    ),
                    Padding(
                      // email
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _email,
                        validator: Validatorless.multiple([
                          Validatorless.email('Não é um email Valido'),
                          Validatorless.required('E-mail é obrigaório'),
                        ]),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    Padding(
                      // senha
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _password,
                        validator: Validatorless.multiple([
                          Validatorless.required('Senha é obrigatório'),
                          Validatorless.compare(
                              _confirmPassword, 'A senhas diferentes'),
                        ]),
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          labelText: 'Senha',
                        ),
                      ),
                    ),
                    Padding(
                      // confirmar senha
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _confirmPassword,
                        validator: Validatorless.multiple([
                          Validatorless.required('Senha é obrigatório'),
                          Validatorless.compare(
                              _password, 'A senhas diferentes'),
                        ]),
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_reset),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          labelText: 'Confirmar senha',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // if para verificar se é valido e se confirmar e senha são iguais
                      if (_formKey.currentState!.validate()) {
                        _onClickEmailCreate();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.amber[600])),
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black),
                    ),
                  ),
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}
