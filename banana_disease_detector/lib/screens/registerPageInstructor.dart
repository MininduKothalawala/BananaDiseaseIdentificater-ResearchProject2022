// ignore_for_file: prefer_const_constructors

import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/screens/login.dart';
import 'package:banana_disease_detector/utils/authentication.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SignupInstructor extends StatefulWidget {
  SignupInstructor({Key? key}) : super(key: key);
  @override
  _SignupInstructorState createState() => _SignupInstructorState();
}

class _SignupInstructorState extends State<SignupInstructor> {
  @override
  void initState() {
    super.initState();
  }

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
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            SizedBox(height: 50),
            Text(
              'Welcome!',
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SignupInstructorForm(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Already here  ?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/signInInstructor');
                  },
                  child: Text(' Get Logged in Now!',
                      style: TextStyle(fontSize: 20, color: Colors.blue)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignupInstructorForm extends StatefulWidget {
  SignupInstructorForm({Key? key}) : super(key: key);

  @override
  _SignupInstructorFormState createState() => _SignupInstructorFormState();
}

class _SignupInstructorFormState extends State<SignupInstructorForm> {
  final _formKey = GlobalKey<FormState>();
  late FirebaseMessaging messaging;
  late String token;
  @override
  void initState() {
    super.initState();
    _getCurrentLocationMap();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print(value);
      token = value!;
    });
  }

  String? email;
  String? password;
  String? name;
  String? type = "INSTRUCTOR";
  String? phone;
  double? lat;
  String? address;
  double? long;
  late Position _currentPosition;
  bool _obscureText = false;

  _getCurrentLocationMap() async {
    print("currrrr&&&&&&&&&&&&&&&&");
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        lat = position.latitude;
        long = position.longitude;
      });
    }).catchError((e) {
      print(e);
    });
  }

  final pass = new TextEditingController();

  // TextEditingController _controllerBlood = TextEditingController();
  // TextEditingController _controllerName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.all(
        const Radius.circular(100.0),
      ),
    );

    var space = SizedBox(height: 10);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextFormField(
            // controller: _controllerName,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.account_circle),
              border: border,
            ),
            onSaved: (val) {
              name = val;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
          ),

          // space,
          // TextFormField(
          //   decoration: InputDecoration(
          //     labelText: 'Latitude',
          //     prefixIcon: Icon(Icons.apps_outlined),
          //     border: border,
          //   ),
          //   onSaved: (val) {
          //     lat = double.parse(val!);
          //   },
          //   validator: (value) {
          //     if (value!.isEmpty) {
          //       return 'Please enter Latitude';
          //     }
          //     return null;
          //   },
          // ),
          // space,
          // TextFormField(
          //   decoration: InputDecoration(
          //     labelText: 'Longitude',
          //     prefixIcon: Icon(Icons.apps_outlined),
          //     border: border,
          //   ),
          //   onSaved: (val) {
          //     long = double.parse(val!);
          //   },
          //   validator: (value) {
          //     if (value!.isEmpty) {
          //       return 'Please enter Longitude';
          //     }
          //     return null;
          //   },
          // ),
          space,
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.location_city),
              border: border,
            ),
            onSaved: (val) {
              address = val;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
          ),
          space,
          TextFormField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                labelText: 'PhoneNo',
                border: border),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter phone no';
              }
              return null;
            },
            onSaved: (val) {
              phone = val;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          space,
          TextFormField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
                border: border),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter email';
              }
              return null;
            },
            onSaved: (val) {
              email = val;
            },
            keyboardType: TextInputType.emailAddress,
          ),

          space,

          // password
          TextFormField(
            controller: pass,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: border,
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
            onSaved: (val) {
              password = val;
            },
            obscureText: !_obscureText,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please password';
              }
              return null;
            },
          ),
          space,
          // confirm passwords
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: border,
            ),
            obscureText: true,
            validator: (value) {
              if (value != pass.text) {
                return 'password not match';
              }
              return null;
            },
          ),

          // Row(
          //   children: <Widget>[
          //     Checkbox(
          //       onChanged: (_) {
          //         setState(() {
          //           agree = !agree;
          //         });
          //       },
          //       value: agree,
          //     ),
          //     Flexible(
          //       child: Text(
          //           'By creating account, I agree to Terms & Conditions and Privacy Policy.'),
          //     ),
          //   ],
          // ),
          SizedBox(
            height: 10,
          ),

          // SignupInstructor button
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  Auth()
                      .signUpInstructor(email!, password!, name!, address!,
                          phone!, token, long!, lat!)
                      .then((result) {
                    if (result == null) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    } else {
                      print(result.toString());
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          result,
                          style: TextStyle(fontSize: 16),
                        ),
                      ));
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24.0)))),
              child: Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}
