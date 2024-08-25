import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_movie_data_base/locator.dart';
import 'package:the_movie_data_base/services/rest.dart';
import 'package:the_movie_data_base/ui/screens/forgot_password.dart';

import '../ui.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback showSignUpScreen;
  const SignInScreen({super.key, required this.showSignUpScreen});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SignInFormController controller = SignInFormController();

  handleSignIn() async {
    if (await controller.validate()) {
      try {
        locate<ProgressIndicatorController>().show();
        await locate<RestService>().signInUser(email: controller.value.uName!, password: controller.value.pwd!);
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Logged In",
            subtitle: "User Logged In Successfully",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
      } on UserNotFoundException catch (e) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: e.message,
            subtitle: e.message.length <= 20 ? "Please Try again" : '',
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } on WrongPasswordException catch (e) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: e.message,
            subtitle: e.message.length <= 20 ? "Please Try again" : '',
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } on InvalidCredentialException catch (e) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: e.message,
            subtitle: e.message.length <= 20 ? "Please Try again" : '',
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } catch (err) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Something went wrong",
            subtitle: "Sorry, something went wrong here",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } finally {
        locate<ProgressIndicatorController>().hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 0.7,
                child: BackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'The Movie DataBase',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Colors.deepPurple,
                      ),
                ),
              ),
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SignInForm(controller: controller),
              ),
              const SizedBox(height: 20),
              CustomButton(
                  onPressed: () => handleSignIn(), padding: 30, height: 50, text: 'SIGNIN', isBig: true, icon: null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                      },
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: widget.showSignUpScreen,
                    child: Text(
                      'Register Now',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.blueAccent,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SignInForm extends StatefulFormWidget<SignInFormValue> {
  const SignInForm({
    Key? key,
    required SignInFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> with FormMixin {
  TextEditingController uNameTextEditingController = TextEditingController();
  TextEditingController pWDTextEditingController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0, bottom: 2.0),
                child: TextField(
                  controller: uNameTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: GoogleFonts.lato(color: const Color(0xFF616161)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Email",
                    hintStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    errorText: formValue.getError("uName"),
                    prefixIcon:
                        const Icon(Icons.email_outlined,),
                  ),
                  onChanged: (value) => widget.controller.setValue(
                    widget.controller.value..uName = value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0, bottom: 2.0),
                child: TextField(
                  controller: pWDTextEditingController,
                  obscureText: _isObscure,
                  autocorrect: false,
                  style: GoogleFonts.lato(color: const Color(0xFF616161)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Password",
                    hintStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    errorText: formValue.getError("pwd"),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) => widget.controller.setValue(
                    widget.controller.value..pwd = value,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SignInFormValue extends FormValue {
  String? uName;
  String? pwd;

  SignInFormValue({this.uName, this.pwd});
}

class SignInFormController extends FormController<SignInFormValue> {
  SignInFormController() : super(initialValue: SignInFormValue(pwd: "", uName: ""));

  @override
  Future<bool> validate() async {
    value.errors.clear();

    String? uName = value.uName;
    if (FormValidators.isEmpty(uName)) {
      value.errors.addAll({"uName": "Email is required"});
    } else {
      try {
        FormValidators.email(uName!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"uName": err.message});
      }
    }

    String? password = value.pwd;
    if (FormValidators.isEmpty(password)) {
      value.errors.addAll({"pwd": "Password is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}
