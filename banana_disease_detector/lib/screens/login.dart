// ignore_for_file: prefer_const_constructors

import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/models/instructor.model.dart';
import 'package:banana_disease_detector/repository/farmer.repo.dart';
import 'package:banana_disease_detector/repository/instructor.repo.dart';
import 'package:banana_disease_detector/screens/registerPageInstructor.dart';
import 'package:banana_disease_detector/screens/welcomInstructor.dart';
import 'package:banana_disease_detector/screens/welcome.screen.dart';
import 'package:banana_disease_detector/utils/authentication.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'registerPage.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundGreen, darkGreen],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.5, 0.9],
          ),
        ),
        child: Form(
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              SizedBox(height: 80),
              // logo
              Column(
                children: [
                  SizedBox(height: 50),
                  Text(
                    'Welcome back!',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),

              SizedBox(
                height: 50,
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LoginForm(),
              ),

              SizedBox(height: 20),

              Row(
                children: <Widget>[
                  SizedBox(width: 30),
                  Text('New here ? ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  GestureDetector(
                    onTap: () {
                      // Navigator.pushNamed(context, '/signup');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Signup()));
                    },
                    child: Text('Register as Farmer',
                        style: TextStyle(fontSize: 20, color: Colors.blue)),
                  )
                ],
              ),
              SizedBox(height: 20),

              Row(
                children: <Widget>[
                  SizedBox(width: 30),
                  Text('New here ? ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  GestureDetector(
                    onTap: () {
                      // Navigator.pushNamed(context, '/signup');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupInstructor()));
                    },
                    child: Text('Register as Instructor',
                        style: TextStyle(fontSize: 20, color: Colors.blue)),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String? email = "lahiru@gmail.com";
  String? password = "sanju.ad";

  bool _obscureText = true;

  bool _checkBoxSelected = false;

  final FarmerRepository repository = FarmerRepository();
  final InstructorRepository instructorRepository = InstructorRepository();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // email
          TextFormField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(100.0),
                ),
              ),
            ),
            validator: RequiredValidator(errorText: 'Email is required'),
            onSaved: (val) {
              email = val;
            },
          ),
          SizedBox(
            height: 20,
          ),

          // password
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  const Radius.circular(100.0),
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            obscureText: _obscureText,
            onSaved: (val) {
              password = val;
            },
            validator: RequiredValidator(errorText: 'password is required'),
          ),
          SizedBox(height: 15),
          CheckboxListTile(
            title: Text("Instructor Login"),
            value: _checkBoxSelected,
            onChanged: (newValue) {
              setState(() {
                _checkBoxSelected = newValue!;
                print(_checkBoxSelected);
              });
            },
            controlAffinity:
                ListTileControlAffinity.leading, //  <-- leading Checkbox
          ),
          SizedBox(height: 30),

          SizedBox(
            height: 54,
            width: 184,
            child: ElevatedButton(
              onPressed: () {
                // Respond to button press

                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (_checkBoxSelected) {
                    Auth()
                        .signIn(email: email!, password: password!)
                        .then((result) {
                      if (result != null) {
                        Auth().saveTokenToLocalStorage(result);
                        instructorRepository
                            .getInstructorDetails(result)
                            .then((Instructor m) {
                          print(m.toJson().toString());
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WelcomeInstructor(
                                        instructor: m,
                                      )));
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            result.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ));
                      }
                    });
                  } else {
                    Auth()
                        .signIn(email: email!, password: password!)
                        .then((result) {
                      if (result != null) {
                        Auth().saveTokenToLocalStorage(result);
                        repository.getFarmerDetails(result).then((Farmer m) {
                          print(m.toJson().toString());
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WelcomeScreen(
                                        farmer: m,
                                      )));
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            result.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ));
                      }
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24.0)))),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
