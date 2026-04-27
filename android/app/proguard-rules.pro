# ── Flutter / General ────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Google ML Kit Text Recognition ──────────────────────────────────────────
# Keep all script-specific recognizer option classes that R8 otherwise strips.
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# ── Google ML Kit Commons ────────────────────────────────────────────────────
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ── Image picker ─────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.imagepicker.** { *; }

# ── Play Core (deferred components / split install) ──────────────────────────
# Flutter references these classes at compile time; they are not available
# when building outside the Play Store pipeline, so we warn-and-ignore them.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
