# Keep FFmpegKit JNI bindings — R8 otherwise strips them in release and the app crashes on launch.
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-dontwarn com.antonkarpenko.ffmpegkit.**
