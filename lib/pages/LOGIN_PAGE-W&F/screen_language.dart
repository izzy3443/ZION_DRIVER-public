import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zion_driver_553/UI/AppBar(ZION).dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_login.dart';
import 'package:zion_driver_553/theme.dart';

class LanguageSelectionPage extends ConsumerWidget {
  final bool isToLogin;
  LanguageSelectionPage({super.key, required this.isToLogin});
  final selectedLangProvider = StateProvider<int>((ref) => -1);
  final isLoadingProvider = StateProvider<bool>((ref) => false);

  final List<Map<String, dynamic>> languageOptions = [
    {
      'title': 'English',
      'subtitle': 'Change app language to English',
      'locale': const Locale('en'),
    },
    {
      'title': 'తెలుగు',
      'subtitle': 'యాప్‌ను తెలుగులో చూడండి',
      'locale': const Locale('te'),
    },
    {
      'title': 'हिंदी',
      'subtitle': 'ऐप को हिंदी में इस्तेमाल करें',
      'locale': const Locale('hi'),
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedLangProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Select your language',
                  style: Themes.headline.copyWith(height: 0.0.h),
                ),
              ),

              SizedBox(height: 30.h),

              // Language Options
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: languageOptions.length,
                itemBuilder: (context, index) {
                  final lang = languageOptions[index];
                  return languageOptionItem(
                    title: lang['title'],
                    subtitle: lang['subtitle'],
                    isSelected: selectedIndex == index,
                    onTap: () {
                      ref.read(selectedLangProvider.notifier).state = index;
                    },
                  );
                },
              ),

              // Continue Button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 24.h),
                child: customButton(
                  text: 'continue'.tr(),
                  isLoading: isLoading,
                  onPressed: selectedIndex != -1
                      ? () async {
                          ref.read(isLoadingProvider.notifier).state = true;
                          final selected = languageOptions[selectedIndex];
                          final newLocale = selected['locale'] as Locale;
                          await context.setLocale(newLocale);

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              'languageCode', newLocale.languageCode);
                          ref.read(isLoadingProvider.notifier).state = false;

                          if (isToLogin) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget languageOptionItem({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color:
                isSelected ? Themes.fire_red.withOpacity(0.1) : Themes.white0,
            border: Border.all(
              color: isSelected ? Themes.fire_red : Colors.grey.shade300,
              width: 1.5.w,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: isSelected ? Themes.fire_red : Colors.grey,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Themes.headline2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Themes.fire_red : Colors.black,
                        )),
                    SizedBox(height: 4.h),
                    Text(subtitle, style: Themes.SmallContainerText),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Themes.fire_red)
              else
                const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
