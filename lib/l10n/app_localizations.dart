import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily-Ease'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Trusted Local Services at Your Doorstep'**
  String get tagline;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Daily-Ease'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find and book reliable household & neighborhood services'**
  String get welcomeSubtitle;

  /// No description provided for @roleConsumer.
  ///
  /// In en, this message translates to:
  /// **'Customer / Consumer'**
  String get roleConsumer;

  /// No description provided for @roleConsumerDesc.
  ///
  /// In en, this message translates to:
  /// **'Book trusted local workers for home & daily chores'**
  String get roleConsumerDesc;

  /// No description provided for @roleProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get roleProvider;

  /// No description provided for @roleProviderDesc.
  ///
  /// In en, this message translates to:
  /// **'Offer services, receive direct calls & manage bookings'**
  String get roleProviderDesc;

  /// No description provided for @categoryMaid.
  ///
  /// In en, this message translates to:
  /// **'Maid / Helper'**
  String get categoryMaid;

  /// No description provided for @categoryMilkman.
  ///
  /// In en, this message translates to:
  /// **'Milk Delivery'**
  String get categoryMilkman;

  /// No description provided for @categoryWatchman.
  ///
  /// In en, this message translates to:
  /// **'Watchman / Security'**
  String get categoryWatchman;

  /// No description provided for @categoryPlumber.
  ///
  /// In en, this message translates to:
  /// **'Plumber'**
  String get categoryPlumber;

  /// No description provided for @categoryElectrician.
  ///
  /// In en, this message translates to:
  /// **'Electrician'**
  String get categoryElectrician;

  /// No description provided for @categoryCarpenter.
  ///
  /// In en, this message translates to:
  /// **'Carpenter'**
  String get categoryCarpenter;

  /// No description provided for @categoryCook.
  ///
  /// In en, this message translates to:
  /// **'Cook / Chef'**
  String get categoryCook;

  /// No description provided for @categoryCleaner.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning'**
  String get categoryCleaner;

  /// No description provided for @categoryLaundry.
  ///
  /// In en, this message translates to:
  /// **'Laundry & Ironing'**
  String get categoryLaundry;

  /// No description provided for @needHelpToday.
  ///
  /// In en, this message translates to:
  /// **'Need Help Today'**
  String get needHelpToday;

  /// No description provided for @needHelpTodayDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick 1-tap urgent service request for today'**
  String get needHelpTodayDesc;

  /// No description provided for @societyDirectory.
  ///
  /// In en, this message translates to:
  /// **'Apartment & Society Directory'**
  String get societyDirectory;

  /// No description provided for @societyDirectoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover verified workers serving your society'**
  String get societyDirectoryDesc;

  /// No description provided for @postCustomRequest.
  ///
  /// In en, this message translates to:
  /// **'Post Custom Request'**
  String get postCustomRequest;

  /// No description provided for @postCustomRequestDesc.
  ///
  /// In en, this message translates to:
  /// **'Describe your specific need and get provider responses'**
  String get postCustomRequestDesc;

  /// No description provided for @householdDashboard.
  ///
  /// In en, this message translates to:
  /// **'Household Services'**
  String get householdDashboard;

  /// No description provided for @householdDashboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your daily milk, morning maid & recurring visits'**
  String get householdDashboardDesc;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by service, society, or name (e.g. maid, bai)...'**
  String get searchPlaceholder;

  /// No description provided for @filterButton.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterButton;

  /// No description provided for @compareProviders.
  ///
  /// In en, this message translates to:
  /// **'Compare Providers'**
  String get compareProviders;

  /// No description provided for @rebookButton.
  ///
  /// In en, this message translates to:
  /// **'1-Tap Rebook'**
  String get rebookButton;

  /// No description provided for @recentlyContacted.
  ///
  /// In en, this message translates to:
  /// **'Recently Contacted'**
  String get recentlyContacted;

  /// No description provided for @callProvider.
  ///
  /// In en, this message translates to:
  /// **'Call Directly'**
  String get callProvider;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bookService;

  /// No description provided for @verifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedBadge;

  /// No description provided for @unverifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Self-Listed'**
  String get unverifiedBadge;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'{count} years exp.'**
  String experienceYears(int count);

  /// No description provided for @pricingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Prices are estimated and agreed directly between parties.'**
  String get pricingDisclaimer;

  /// No description provided for @directSettlement.
  ///
  /// In en, this message translates to:
  /// **'Direct Cash / UPI Settlement'**
  String get directSettlement;

  /// No description provided for @bookingStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get bookingStatusRequested;

  /// No description provided for @bookingStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get bookingStatusAccepted;

  /// No description provided for @bookingStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get bookingStatusDeclined;

  /// No description provided for @bookingStatusRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get bookingStatusRescheduled;

  /// No description provided for @bookingStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingStatusCompleted;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingStatusCancelled;

  /// No description provided for @recurringDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Recurring'**
  String get recurringDaily;

  /// No description provided for @recurringWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Recurring'**
  String get recurringWeekly;

  /// No description provided for @recurringMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Arrangement'**
  String get recurringMonthly;

  /// No description provided for @temporaryOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-Time / Temporary'**
  String get temporaryOneTime;

  /// No description provided for @pauseService.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseService;

  /// No description provided for @resumeService.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeService;

  /// No description provided for @skipDay.
  ///
  /// In en, this message translates to:
  /// **'Skip Day'**
  String get skipDay;

  /// No description provided for @offlineNotice.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Showing cached information.'**
  String get offlineNotice;

  /// No description provided for @offlineSyncPending.
  ///
  /// In en, this message translates to:
  /// **'Offline pending sync'**
  String get offlineSyncPending;

  /// No description provided for @addressHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressHome;

  /// No description provided for @addressOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get addressOffice;

  /// No description provided for @addressHostel.
  ///
  /// In en, this message translates to:
  /// **'Hostel / PG'**
  String get addressHostel;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addAddress;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @reportAbuse.
  ///
  /// In en, this message translates to:
  /// **'Report / Block'**
  String get reportAbuse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
