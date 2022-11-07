// ignore_for_file: prefer_const_constructors

import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/screens/login.dart';
import 'package:banana_disease_detector/utils/authentication.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
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
              child: SignupForm(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Already here  ?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/signIn');
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

class SignupForm extends StatefulWidget {
  SignupForm({Key? key}) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();

  String? email;
  String? password;
  String? name;
  String? type = "FARMER";
  String? phone;
  double? lat;
  String? address;
  String? banana_type;
  double? long;

  bool _obscureText = false;
  late Position _currentPosition;
  final pass = new TextEditingController();

  // TextEditingController _controllerBlood = TextEditingController();
  // TextEditingController _controllerName = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getCurrentLocationMap();
    // _controllerBlood.text = widget.blood.toString();
    // _controllerName.text = widget.user.toString();
  }

  // _getCurrentLocation() async {
  //   print("***************current location of farmer&");
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) async {
  //     print(position.latitude.toString());
  //     return position;
  //   }).catchError((e) {
  //     print(e.toString());
  //     print(e);
  //   });
  // }

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

          space,
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Banana Type',
              prefixIcon: Icon(Icons.apps_outlined),
              border: border,
            ),
            onSaved: (val) {
              banana_type = val;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Type';
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

          // signUP button
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  Auth()
                      .signUp(email!, password!, name!, type!, address!, phone!,
                          banana_type!, long!, lat!)
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
