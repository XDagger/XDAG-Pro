
## how to use
The project is built using Flutter, so you just need to refer to the Flutter official website to set up your development environment.

The project supports Android, iOS, Web, Mac, Windows, and Linux platforms, so you can run it on any of these platforms. However, due to security concerns on the web platform, it is not recommended to run it on the web.

Before running the project, please run `flutter pub get` to get the dependencies, then run `flutter gen-l10n` to generate the localization files, and finally run `flutter run ${your platform}` to start the project.

* Follow the steps on the website to install [flutter](https://docs.flutter.dev/get-started/install)
* Execute this command to check `flutter doctor`
* Execute this command to install dependencies `flutter pub get`
* Execute this command to generate the localization files `flutter gen-l10n`
* Execute this command to run the project `flutter run`
* Recommended use [Android Studio](https://developer.android.com/studio) to run the project, or use [VSCode](https://code.visualstudio.com/) with [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) plugin


## Window Note
* No support for ARM and x86 Windows devices, only for x64 devices.
## add language
* app_[locale].arb，example: app_zh.arb
* flutter gen-l10n
* change `lib/model/config_modal.dart` langs
* [localization](https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry)

## Android
* if you see the error like this:
```
 Namespace not specified. Please specify a namespace in the module's build.gradle file like so:
```
* add namespace to `build.gradle` for the third-party plugin
```
android {
    compileSdkVersion 33
    namespace "xxxx"
}
```


## End
If you would like to make a donation to support this project, below is the donation address:  
**4AzP6NX68y854ztnSMuBYLj8KHHAtX5HK**
