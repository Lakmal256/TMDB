import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../locator.dart';
import '../../services/services.dart';
import '../ui.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileFormController controller = ProfileFormController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Row(
            children: [
              Transform.scale(
                scale: 0.7,
                child: BackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(
                'Profile',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ProfileForm(controller: controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileForm extends StatefulFormWidget<ProfileFormValue> {
  const ProfileForm({
    Key? key,
    required ProfileFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> with FormMixin {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  User? user;
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userNameTextEditingController.text = user?.displayName ?? '';
      emailTextEditingController.text = user!.email!;
    }
  }

  handleUserNameUpdate() async {
    if (userNameTextEditingController.text.isNotEmpty && user!.displayName != userNameTextEditingController.text) {
      try {
        locate<ProgressIndicatorController>().show();

        await locate<RestService>().updateUserName(userName: widget.controller.value.userName!);

        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Update User Name",
            subtitle: "The User Name has been updated successfully.",
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

  handlePasswordResetLinkSend() async {
    try {
      locate<ProgressIndicatorController>().show();

      await locate<RestService>().sendPasswordResetEmail(email: emailTextEditingController.text);

      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Password Reset Link Sent",
          subtitle: "Password Reset Link Send Successfully",
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
                  controller: userNameTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: GoogleFonts.lato(color: const Color(0xFF616161)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Add User Name",
                    hintStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    prefixIcon: const Icon(Icons.person_2_outlined),
                  ),
                  onChanged: (value) => widget.controller.setValue(
                    widget.controller.value..userName = value,
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
                  controller: emailTextEditingController,
                  maxLines: 1,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  style: GoogleFonts.lato(color: const Color(0xFF616161)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  onChanged: (value) => widget.controller.setValue(
                    widget.controller.value..email = value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
                onPressed: () => handleUserNameUpdate(),
                padding: 30,
                height: 50,
                text: 'UPDATE',
                isBig: true,
                icon: null),
            const SizedBox(height: 20),
            CustomButton(
                onPressed: () => handlePasswordResetLinkSend(),
                padding: 30,
                height: 50,
                text: 'RESET PASSWORD',
                isBig: true,
                icon: null),
          ],
        );
      },
    );
  }
}

class ProfileFormValue extends FormValue {
  String? userName;
  String? email;

  ProfileFormValue({this.userName, this.email});
}

class ProfileFormController extends FormController<ProfileFormValue> {
  ProfileFormController() : super(initialValue: ProfileFormValue(email: "", userName: ""));
}
