import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_movie_data_base/locator.dart';

import '../../services/services.dart';
import '../ui.dart';

class SignUpScreen extends StatelessWidget {
  final VoidCallback showSignInScreen;
  SignUpScreen({super.key, required this.showSignInScreen});

  final SignUpFormController controller = SignUpFormController();

  handleSignUp() async {
    if (await controller.validate()) {
        try {
          locate<ProgressIndicatorController>().show();
          await locate<RestService>()
              .createUserAccount(email: controller.value.uName!.toLowerCase(), password: controller.value.pwd!);
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "Profile Created",
              subtitle: "The Profile has been created successfully!",
              color: Colors.green,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
          showSignInScreen();
        } on UserAlreadyExistsException catch (e) {
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: e.message,
              subtitle: e.message.length <= 20 ? "Please Try again" : '',
              color: Colors.red,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
      } on WeakPasswordException catch (e) {
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
                'Hello There!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Register below with your credentials.',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SignUpForm(controller: controller),
              ),
              const SizedBox(height: 20),
              CustomButton(
                  onPressed: () => handleSignUp(), padding: 30, height: 50, text: 'SIGNUP', isBig: true, icon: null),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'I am a member!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: showSignInScreen,
                    child: Text(
                      'Login Now',
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

class SignUpForm extends StatefulFormWidget<SignUpFormValue> {
  const SignUpForm({
    Key? key,
    required SignUpFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<SignUpForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignUpForm> with FormMixin {
  TextEditingController uNameTextEditingController = TextEditingController();
  TextEditingController pWDTextEditingController = TextEditingController();
  TextEditingController pWDConfirmTextEditingController = TextEditingController();
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
                    prefixIcon: const Icon(Icons.email_outlined),
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
                  controller: pWDConfirmTextEditingController,
                  obscureText: _isObscure,
                  autocorrect: false,
                  style: GoogleFonts.lato(color: const Color(0xFF616161)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Confirm Password",
                    hintStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    errorText: formValue.getError("confirmPwd"),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                  onChanged: (value) => widget.controller.setValue(
                    widget.controller.value..confirmPwd = value,
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

class SignUpFormValue extends FormValue {
  String? uName;
  String? pwd;
  String? confirmPwd;

  SignUpFormValue({this.uName, this.pwd, this.confirmPwd});
}

class SignUpFormController extends FormController<SignUpFormValue> {
  SignUpFormController() : super(initialValue: SignUpFormValue());
  @override
  Future<bool> validate() async {
    value.errors.clear();

    String? uName = value.uName;
    String? password = value.pwd;
    String? cPassword = value.confirmPwd;

    if (FormValidators.isEmpty(uName)) {
      value.errors.addAll({"uName": "Email is required"});
    } else {
      try {
        FormValidators.email(uName!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"uName": err.message});
      }
    }

    if (FormValidators.isEmpty(password)) {
      value.errors.addAll({"pwd": "Password is required"});
    } else {
      try {
        FormValidators.password(password!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"pwd": err.message});
      }

      if (password != cPassword) {
        value.errors.addAll({"confirmPwd": "Confirmation do not match"});
      }
    }

    if (FormValidators.isEmpty(cPassword)) {
      value.errors.addAll({"confirmPwd": "Password confirmation is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}
