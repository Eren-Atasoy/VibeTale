# VibeTale - Mobile Frontend Project Guidelines (Flutter)

## 📌 Project Overview
VibeTale is an AI-powered immersive e-book reading application. It analyzes text in real-time using an AI "VibeEngine" to generate dynamic background music, sound effects, and visual ambiance that match the story's emotions. 

## 🛠️ Tech Stack & Architecture
* **Framework:** Flutter (Dart)
* **Target Platforms:** iOS & Android (Mobile-first)
* **Architecture:** Feature-first modular architecture.
* **UI/UX Paradigm:** Cinematic Dark Mode, Glassmorphism, Neon Accents.

## 🎨 Design System & UI Guidelines
When generating UI code, strictly adhere to the following design system based on the reference mockups:

### 1. Colors
* **Backgrounds:** Deep space blues, dark indigos, and rich blacks (`#0B0C10`, `#1F2833`). NEVER use pure white backgrounds.
* **Primary Accents:** Electric Purple (`#9B59B6` or similar glowing purple) and Neon Cyan. Use these for primary buttons, active states, and glowing effects.
* **Text:** High-contrast white (`#FFFFFF`) for primary text, light gray (`#B0BEC5`) for subtitles and secondary text.

### 2. Typography
* Use modern, clean sans-serif fonts (e.g., `Inter`, `SF Pro`, or Google Fonts `Poppins`/`Roboto`).
* Ensure high legibility, especially in the "Immersive Read" screen.

### 3. Core UI Components (CRITICAL)
* **Glassmorphism:** Use `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` combined with a semi-transparent container (e.g., `Colors.white.withOpacity(0.1)`) for cards, bottom sheets, and overlay panels.
* **Borders & Corners:** Use rounded corners heavily. `BorderRadius.circular(16)` to `24` is standard for cards and dialogs.
* **Glow Effects:** Use `BoxShadow` with high blur radius and primary accent colors to create neon glowing effects around buttons or book covers.

## 📱 Screens & Features to Implement

When asked to build a specific screen, refer to its corresponding design and logic:

1. **Login & Sign Up (`vibetale_login`, `vibetale_signup`):**
   * Dark abstract/nebula background.
   * Glassmorphic central form card.
   * Glowing primary buttons. Social login outline buttons.

2. **Library (`vibetale_library`):**
   * "Continue Reading" hero section with progress bar.
   * Horizontal scrolling lists for categories.
   * Modern, floating or glassmorphic Bottom Navigation Bar.

3. **Book Details (`vibetale_book_details`):**
   * Large book cover fading into the dark background via `ShaderMask` or `LinearGradient`.
   * Pill-shaped "Vibe Tags" (e.g., Mysterious, Action) with neon borders.
   * "Start Immersive Reading" button.

4. **File Upload (`vibetale_dosya_yukleme`):**
   * Dashed border drop zone for EPUB/PDF.
   * Minimalist dark gray aesthetic with purple accents.

5. **VibeEngine Analysis (`vibetale_vibeengine_analsisy`):**
   * Loading/Processing screen. Needs smooth, pulsing animations (consider using `flutter_animate` package).
   * Dynamic loading text (e.g., "Extracting emotions...").

6. **Immersive Read (`vibetale_immersive_read`) & Ambiance Control (`vibetale_ambiance_control`):**
   * **Read View:** Full-screen text over a very dark, heavily blurred background image.
   * **Ambiance Control:** A Glassmorphic Bottom Sheet (`showModalBottomSheet` with transparent background) containing horizontal sliders for Music, SFX, and Visual Opacity.

7. **Reading Stats (`vibetale_reading_istatistigi`) & Profile (`vibetale_profil_settings`):**
   * Radar charts or bar charts for "Vibe Profile" (Emotions experienced).
   * Glassmorphic stat cards for "Total Time" and "Books Read".

## 🤖 AI Assistant Rules (How you must write code)
1. **No Placeholders:** Write complete, production-ready Flutter code. Do not leave `// add logic here` comments unless explicitly asked to scaffold.
2. **Component Extraction:** Break down complex screens into smaller, reusable widget files (e.g., `GlassCard`, `NeonButton`, `VibeSlider`).
3. **Responsiveness:** Use `MediaQuery` or `LayoutBuilder` to ensure UI looks good on different mobile screen sizes. Avoid hardcoded fixed heights/widths where possible.
4. **Imports:** Always include necessary material or package imports at the top.
5. **State Management:** *[User will define state management here - e.g., Riverpod/BLoC]* - Follow standard practices for the chosen state management tool. Ensure UI is reactive.