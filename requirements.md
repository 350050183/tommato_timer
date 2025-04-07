A "3D Tomato Timer" app using the Flutter framework

## Tomato Time App Design (Flutter)

**App Name:** 3D Tomato Timer

**Core Concept:** A simple and effective Tomato Technique timer app using 3D technology to help users manage their time and improve focus.

**Target Platforms:** iOS and Android (Flutter's primary advantage)

**Key Features:**

1.  **Tomato Timer:**
    *   A 3d cube session selector implement with threejs framework.
    *   The 3d cube each side means: A side means 5 minutes session,B side meas 10 minutes session, C side means 15 minutes session, D side means 20 minutes session, E side means 25 minutes session, F side means 30 minutes session.
    *   Customizable session duration (e.g., E side - 25 minutes default).
    *   After customizable session duration need sync 3d cube side automate.
    *   Clear visual display of the remaining time.
    *   Start, pause, and reset functionality.

2.  **Customization:**
    *   Sound/vibration notifications for the end of sessions.
    *   Option to customize notification sounds.
    *   (Optional) Themes/color schemes.

3.  **History/Statistics (Basic):**
    *   A simple log of completed Tomato sessions.

4.  **Settings:**
    *   Configure default durations.
    *   Manage notifications (enable/disable, choose sounds).
    *   (Optional) Theme selection.
    *   (Optional) Option to keep screen on during sessions.】
    *   Support multiple languages, like Chinese and English, default by system settings.

**UI/UX Design:**

**Overall Aesthetic:** Using Material Design system,glassmorhism effect,Clean, minimalist, and easy to understand. Focus on clarity and distraction-free experience.

**Key Screens:**

1.  **Timer Screen (Primary Screen):**
    *   **Large Central Timer Display:** Dominant display showing the 3d cube for session select.
    *   **Control Buttons:**
        *   A prominent "Start" button (changes to "Pause" when running).
        *   A "Reset" button to stop the current session and reset the timer to the default session.
    *   **Progress Indicator:** A linear progress bar display visually representing the elapsed time within the current session.
    *   **Bottom Navigation (Optional for future expansion):** Could include icons for "Timer," "History," and "Settings." However, for simplicity, the initial version could keep everything on one screen.

2.  **Settings Screen:**
    *   Clear sections for:
        *   **Durations:** select default session.
        *   **Notifications:** Switches or checkboxes for "Enable Notifications," "Vibrate on Finish." A button to select notification sound for work and break completion.
        *   **Appearance (Optional):** Theme selection dropdown or color palette options.
        *   **Other (Optional):** "Keep Screen On" toggle.

3.  **History Screen (Basic List):**
    *   A simple list view showing completed Tomato sessions.
    *   Each item in the list could display:
        *   Date and time of completion.
        *   (Optional) Duration of the session.

**Visual Elements:**

*   **Color Palette:** Use a calming and focused color scheme. Consider using:
    *   A primary color for the active state (e.g., a shade of red or orange, referencing a tomato).
    *   A secondary color for breaks (e.g., a calming blue or green).
    *   Neutral background and text colors for readability.
*   **Typography:** Choose a clean and legible font for all text elements, especially the timer display.
*   **Icons:** Use intuitive icons for controls and navigation (if implemented).

**User Experience (UX) Principles:**

*   **Simplicity:** The app should be easy to use and understand at a glance. Avoid overwhelming the user with too many features initially.
*   **Clarity:** Clearly communicate the current state of the timer and the remaining time.
*   **Customization:** Provide enough customization options to suit individual preferences without being overly complex.
*   **Feedback:** Provide clear visual and auditory feedback when sessions start, pause, end, and when breaks begin and end.
*   **Distraction-Free:** The design should minimize visual clutter and potential distractions.

**Flutter Implementation Considerations:**

*   **3D display and interaction:**: Using threejs techonoly implement 3D cube interact with flutter.the 3d model locate at `assets/cube/tomato-timer.obj` and `assets/cube/tomato-timer.mtl`, don't create another `assets/model` directory. threejs need communicate with flutter when 3d rotated by user, for example: use rotate to side A means selected 5 minuts session, then session need change to 5 minutes and after play START button count down from 5 minuts.
*   下面是各个面的角度关系：E面（x:0,y:0,z:0）;
*   `flutter_web_plugins` 是 Flutter Web 平台特定的包，不应该手动添加到 `pubspec.yaml` dependencies 中
*   在 Web 平台上，runJavaScript, setJavaScriptMode, addJavaScriptChannel 没有实现，不用使用
*   **State Management:** Choose a suitable state management solution (e.g., `setState` for simple cases, Provider, BLoC/Cubit for more complex logic). For this relatively simple app, `setState` might suffice initially.
*   **Timer Logic:** Use Flutter's `dart:async` library, specifically the `Timer` class, to implement the countdown mechanism.
*   **Notifications:** Utilize platform-specific plugins like `flutter_local_notifications` to display notifications when sessions and breaks end. You'll need to handle platform-specific configurations and permissions.
*   **Sound/Vibration:** Use plugins like `audioplayers` or `vibration` to play sounds and trigger vibrations for notifications.
*   **User Preferences:** Store user settings (durations, notification preferences) using packages like `shared_preferences`.
*   **UI Building:** Leverage Flutter's widgets (e.g., `Scaffold`, `AppBar`, `Text`, `ElevatedButton`, `ThreejsCubeSelector`, `ListView`, `TextField`) to build the user interface.
*   **Responsiveness:** Design the UI to adapt well to different screen sizes and orientations using Flutter's layout widgets (e.g., `Expanded`, `Flexible`, `MediaQuery`).

**Example Widget Structure (Conceptual - Timer Screen):**

*   `Scaffold`
    *   `AppBar` (with the app title)
    *   `Body`
        *   `Column` (to arrange elements vertically)
            *   `Text` (Session Type Indicator)
            *   `Stack` (to overlay the timer text on a progress indicator)
                *   `A 3D Cube session selector`
                *   `Center`
                    *   `Text` (Timer Display)
            *   `Padding`
                *   `Row` (to arrange control buttons horizontally)
                    *   `ProgressBar` (indicator time remains)
                    *   `ElevatedButton` (Start/Pause)
                    *   `SizedBox`
                    *   `ElevatedButton` (Reset)
                    *   `(Optional) ElevatedButton` (Skip Break)


**Future Enhancements (Beyond the Core):**

*   **More Detailed Statistics:** Track focus time, break time, completion rates over different periods.
*   **Task Management Integration:** Allow users to associate Tomato sessions with specific tasks.
*   **Customizable Themes:** Offer a wider range of visual themes.
*   **Background Execution:** Ensure the timer continues to run and notifications are delivered even when the app is in the background (requires careful platform-specific implementation).
*   **Cloud Sync:** Allow users to sync their history and settings across multiple devices.
*   **Focus Mode Integrations:** Explore integrations with other focus-enhancing features or apps.
