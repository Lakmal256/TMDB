import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_movie_data_base/locator.dart';
import 'package:the_movie_data_base/services/rest.dart';

import '../ui.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordFormController controller = ForgotPasswordFormController();

  handlePasswordResetLinkSend() async {
    if (await controller.validate()) {
      try {
        locate<ProgressIndicatorController>().show();

        await locate<RestService>().sendPasswordResetEmail(email: controller.value.uName!);

        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Password Reset Link Sent",
            subtitle: "Please Check Your Emails",
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
                'RESET PASSWORD!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ForgotPasswordForm(controller: controller),
              ),
              const SizedBox(height: 20),
              CustomButton(
                  onPressed: () => handlePasswordResetLinkSend(), padding: 30, height: 50, text: 'RESET PASSWORD', isBig: true, icon: null),
            ],
          ),
        ),
      ],
    );
  }
}

class ForgotPasswordForm extends StatefulFormWidget<ForgotPasswordFormValue> {
  const ForgotPasswordForm({
    Key? key,
    required ForgotPasswordFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> with FormMixin {
  TextEditingController uNameTextEditingController = TextEditingController();

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
                    hintStyle: GoogleFonts.lato(color: const Color(0xFF616161)),
                    errorText: formValue.getError("uName"),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  onChanged: (value) => widget.controller.setValue(
                    widget.controller.value..uName = value,
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

class ForgotPasswordFormValue extends FormValue {
  String? uName;

  ForgotPasswordFormValue({this.uName});
}

class ForgotPasswordFormController extends FormController<ForgotPasswordFormValue> {
  ForgotPasswordFormController() : super(initialValue: ForgotPasswordFormValue(uName: ""));

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

    setValue(value);
    return value.errors.isEmpty;
  }
}
