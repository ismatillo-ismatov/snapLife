import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/forms/loginPage.dart';
import 'package:ismatov/api/user_service.dart';


class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();

}

class _RegisterFormState extends State<RegisterForm>{
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _email = '';
  String _password1 = '';
  String _password2 = '';
  bool _isPasswordVisible1 = false;
  bool _isPasswordVisible2 = false;

  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();


  void _submitForm() async {
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      UserService userService = UserService();
      // ApiService apiService = ApiService();
      bool success = await userService.registerUser(
        _username,
        _email,
        _passwordController1.text,
        _passwordController2.text,
      );

      if (success) {
        Navigator.pushReplacement(
            context,
          MaterialPageRoute(builder: (context) => LoginPage())
        );
        print("Registration  successful");
      } else{
        print("Register failed");
      }

      print("Username:$_username");
      print("Email:$_email");
      print("Password1:${_passwordController1.text}");
      print("Password2:${_passwordController2.text}");

    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Form'),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "username"),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "Please enter a username";
                  }
                  return null;
                },
                onSaved: (value)=> _username = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText:"Email" ),
                keyboardType: TextInputType.emailAddress,
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "please enter email";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value)=> _email = value!,
              ),
              TextFormField(
                controller: _passwordController1,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                      icon:Icon(
                        _isPasswordVisible1 ? Icons.visibility: Icons.visibility_off,
                      ),
                    onPressed: () {
                        setState(() {
                          _isPasswordVisible1 = !_isPasswordVisible1;
                        });
                    },
                  ),

                ),
                obscureText: !_isPasswordVisible1,
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "please enter a password";
                  }
                  if (value.length < 6){
                    return 'password must be at least 6 characters long';
                  }
                  return null;
                },
                onSaved: (value) => _password1 = value!,
              ),
              TextFormField(
                controller: _passwordController2,
                decoration: InputDecoration(
                    labelText: "Confirm Password",
                    suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible2 ? Icons.visibility : Icons.visibility_off,
                        ),
                      onPressed: (){
                          setState(() {
                            _isPasswordVisible2 = !_isPasswordVisible2;
                          });
                      },
                    ),
                ),
                obscureText: !_isPasswordVisible2,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "please confirm your password";
                  }
                  if (value != _passwordController1.text){
                    return "password do not match";
                  }
                  return null;
                },
                // onSaved: (value) => _password2 = value!,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: _submitForm,
                  child: Text('Register'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
