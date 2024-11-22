import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http ;
import 'package:ismatov/api/api_service.dart';
import 'package:flutter/material.dart';
import "package:ismatov/forms/registerForm.dart";
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/widgets/profile.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage>{
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();
  final ApiService apiService  = ApiService();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      try{
        UserProfile userProfile = await apiService.loginUser(_username, _password);
        print('Login successful');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(userProfile: userProfile),)
        );
        print("Login successful");
      } catch(e){
        print('Login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("login failed"),
            ),

        );
      }
    };


      }
      // if(loginSuccessful){
      //   void _onLoginSuccessful(UserProfile userProfile){
      //     print('Login successful');
      //     Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => ProfilePage(userProfile: userProfile),)
      //     );
      //     print("Login successful");
      //   }
      // } else{
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Login failed")),
      //   );
      // }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("login"),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 50,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText:"Username" ),
                  // keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },

                  onSaved: (value) => _username = value!,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      labelText: "Password",
                    suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility: Icons.visibility_off,
                        ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return "please enter a password";
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _login,
                    child: Text("Login"),
                ),
                Text.rich(
                    TextSpan(
                      text: 'Register',
                      style: TextStyle(
                        color:Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                      ..onTap = (){
                        Navigator.push(
                        context,
                          MaterialPageRoute(
                              builder: (context)  => RegisterForm()
                          ),
                        );
                    }
                    ),
                )
              ],
            )
        ),
      ),
    );
  }
}


