import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainscreen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}



FirebaseAuth auth = FirebaseAuth.instance;


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  late String loginState;
  late SharedPreferences loginData;
  bool newUser = false;
  bool _isHidden = true;


  bool hasInternet = false;
  ConnectivityResult result = ConnectivityResult.none;


  Future<void> internet() async {
    //print("the connectivity is now $result """"""""""""""""""""""""""""""""""""""""""""""""""");
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        //print("the connectivity eeeeeeeeeeeeeeeeeee  is now $result """"""""""""""""""""""""""""""""""""""""""""""""""");
        this.result = result;
      });
    });

    InternetConnectionChecker().onStatusChange.listen((status) async {
      final hasInternet = status == InternetConnectionStatus.connected;
      setState(() {
        this.hasInternet = hasInternet;
      });
    });
    hasInternet = await InternetConnectionChecker().hasConnection;
    result = await Connectivity().checkConnectivity();
  }



  @override
  void initState() {

    // Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());
    //check_if_already_login();

    email = TextEditingController();
    pass = TextEditingController();
    super.initState();
  }


  void check_if_already_login() async {
    loginData = await SharedPreferences.getInstance();
    newUser = (loginData.getBool('login') ?? true);
    // print(newUser);
    if (newUser == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }


  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height * 1.0,
          width: width * 1.0,
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(
                'images/log_anim.svg',
              ),
              SizedBox(
                height: height * 0.020,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40.0,vertical: 05.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Login" ,style: Theme.of(context).textTheme.headline4,),
                    SvgPicture.asset(
                      'images/clouds.svg',
                    ),
                  ],),
              ),
              Center(
                child: Container(
                  width: width * 0.81,
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: email,
                        cursorColor: Colors.orange,
                        style: Theme.of(context).textTheme.bodyText2,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder : Theme.of(context).inputDecorationTheme.enabledBorder,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          hintText: "Username",
                          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                          // focusedBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(
                          //       color: Colors.black, width: width * 0.001),
                          //   borderRadius: BorderRadius.circular(10.0),
                          // ),
                          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.030,
                      ),
                      TextField(
                        controller: pass,
                        obscureText: _isHidden,
                        cursorColor: Colors.orange,
                        style: Theme.of(context).textTheme.bodyText2,
                        decoration: InputDecoration(
                          suffix: InkWell(
                            onTap: _togglePasswordView,
                            child: Icon(
                              _isHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off, color: Colors.grey,
                            ),
                          ),
                          errorBorder: InputBorder.none,
                          disabledBorder : InputBorder.none,
                          enabledBorder : Theme.of(context).inputDecorationTheme.enabledBorder,
                          border: InputBorder.none ,
                          filled: true,
                          fillColor: Colors.transparent,
                          hintText: "Password",
                          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.020,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              //print("$hasInternet inetrnet is available or not_____________________------------------");
                              hasInternet = await InternetConnectionChecker().hasConnection;
                              result = await Connectivity().checkConnectivity();
                              //print("$hasInternet inetrnet is after pressing the button  ++++++++++++++");
                              if(hasInternet) {
                                try {
                                  await auth.signInWithEmailAndPassword(email: "t@t.in",password: "123456");
                                  loginData = await SharedPreferences.getInstance();
                                  await loginData.clear();
                                  setState(() {
                                    loginData.setBool('login', false);
                                    loginData.setString('username', email.text);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MainScreen()));
                                    // loginState = "logedin succesfully";
                                    // print(
                                    //     "curent user = ${Firebase.auth.UserProfile}");
                                  });
                                } catch (e) {
                                  setState(() {
                                    loginState = "Access denied";
                                  });
                                }
                              }
                              else{
                                showSimpleNotification(
                                  Text("No Network",
                                    style: TextStyle(color: Colors.white),),
                                  background: Colors.red,
                                );
                              }

                            },
                            child: Text(
                              "Demo Login",
                              style: Theme.of(context).textTheme.button,
                              // GoogleFonts.inter(
                              //     fontSize: height * 0.016,
                              //     color: Colors.white60,
                              //     fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                              onTap: () async {
                                //print("$hasInternet inetrnet is available or not_____________________------------------");

                                hasInternet = await InternetConnectionChecker().hasConnection;
                                result = await Connectivity().checkConnectivity();
                                //print("$hasInternet inetrnet is after pressing the button  ++++++++++++++");

                                if(hasInternet) {
                                  try {
                                    await auth.signInWithEmailAndPassword(email: email.text,password: pass.text);
                                    loginData = await SharedPreferences.getInstance();
                                    await loginData.clear();
                                    setState(() {
                                      loginData.setBool('login', false);
                                      //loginData.setString('username', email.text);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MainScreen()));
                                      // loginState = "logedin succesfully";
                                      // print(
                                      //     "curent user = ${Firebase.auth.UserProfile}");
                                    });
                                  } catch (e) {
                                    setState(() {
                                      loginState = "Incorrect Password or Email";
                                      final snackBar = SnackBar(
                                        content: Text(loginState),
                                        backgroundColor: Colors.red,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    });
                                  }
                                }
                                else{
                                  showSimpleNotification(
                                    Text("No Network",
                                      style: TextStyle(color: Colors.white),),
                                    background: Colors.red,
                                  );
                                }
                              },
                              child:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Sign In",
                                    style:Theme.of(context).textTheme.bodyText2,
                                  ),
                                  SizedBox(
                                    width:width * 0.03,
                                  ),
                                  CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      child: Icon(Icons.arrow_forward_ios_rounded,color: Colors.white, )),
                                ],
                              )
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.020,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // CircleAvatar(
                      //   backgroundColor: Color.fromRGBO(247, 179, 28, 1.0),radius: 50,
                      // ),
                      CircleAvatar(
                        radius: 75,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).backgroundColor,),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Color.fromRGBO(247, 179, 28, 1.0),
                                  //Colors.black,
                                  Theme.of(context).backgroundColor,
                                ],
                                stops: [
                                  0.1,0.6
                                ]
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).backgroundColor,radius: 40,
                      ),
                    ],
                  ),
                 // Image(
                 //    image: AssetImage('images/logo1.png'),
                 //    height: height * 0.06,
                 //  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // CircleAvatar(
                      //   backgroundColor: Color.fromRGBO(247, 179, 28, 1.0),radius: 50,
                      // ),
                      CircleAvatar(
                        radius: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).backgroundColor,),
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(247, 179, 28, 1.0),
                                  Theme.of(context).backgroundColor,
                                ],
                                stops: [
                                  0.1,0.8
                                ]
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).backgroundColor,radius: 25,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
