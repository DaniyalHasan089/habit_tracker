# TrackMotive: Habit Tracker
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/DaniyalHasan089/habit_tracker)

TrackMotive is a modern, feature-rich habit tracking application built with Flutter. It's designed to help you build, maintain, and analyze positive habits through an intuitive and visually appealing user interface. The app provides tools for tracking streaks, managing relapses, visualizing progress, and earning achievements, all while storing your data locally for privacy and offline access.

## Key Features

*   **Comprehensive Habit Management**: Create and customize habits with titles, icons, categories (Health, Work, Learning, Fitness, Mindfulness, Other), and priorities (Low, Medium, High).
*   **Streak Tracking**: Automatically tracks current and best streaks for each habit. Includes functionality to manually record relapses and restart habits.
*   **Achievement System**: Unlock milestones based on your habit streaks (e.g., 1-day, 7-day, 30-day streaks).
*   **Detailed Statistics**: Visualize your journey with insightful charts and data, including overall progress, weekly activity trends, habit category breakdowns, and a leaderboard of your longest current streaks.
*   **User Profile**: Personalize your experience with a customizable display name, email, and profile picture. View your join date and overall statistics.
*   **Local Data Storage**: Habits and user data are stored locally using `shared_preferences`, ensuring privacy and offline usability.
*   **Notifications**: Receive timely reminders for habits, notifications for unlocked achievements, and prompts for inactivity, powered by `awesome_notifications`.
*   **Cross-Platform**: Built with Flutter, TrackMotive is designed to run smoothly on Android, iOS, Web, Windows, macOS, and Linux.
*   **Modern UI/UX**: Utilizes `flutter_animate` for smooth animations, `google_fonts` for elegant typography, and `fl_chart` for beautiful data visualization.

## Core Functionality

### 1. Habit Tracking
*   Add new habits with specific details like title, icon (auto-assigned by category), category, and priority.
*   View all your active habits on the home screen, each displayed in a card format.
*   Active streak duration is displayed prominently on each habit card.
*   Delete habits using a slidable action.

### 2. Streaks and Relapses
*   Streaks are calculated based on the start date and the last relapse date.
*   Record a relapse for any habit with an optional note explaining the circumstances. This resets the current streak and updates the best streak information.
*   Restart a habit, effectively resetting its start date and clearing relapse history for a fresh start.

### 3. Achievements
*   A predefined set of achievements based on streak milestones (e.g., "First Step" for 1 day, "Week Warrior" for 7 days).
*   Achievements are automatically unlocked and displayed in the Achievements screen, showing your progress towards collecting them all.

### 4. User Profile
*   Edit your display name, email, and profile picture (selected from the device gallery and stored locally).
*   Tracks your "Member since" date.
*   Provides an overview of key statistics like total completions and best overall streak.
*   Share your progress summary with others.

### 5. Statistics & Visualization
*   **Overall Progress**: A dashboard card shows average streak duration, total number of habits, and currently active streaks.
*   **Weekly Activity Chart**: A line chart visualizes the number of active habits for each day of the current week.
*   **Category Breakdown**: See how your habits are distributed across different categories and the average streak for each.
*   **Current Streaks**: Lists habits with the longest active streaks.

### 6. Notifications
*   Set reminders for your habits (though specific reminder scheduling UI details are part of `Habit` model, the `NotificationService` supports it).
*   Receive encouraging notifications when you unlock new achievements.
*   Get nudges if you're about to break a streak due to inactivity.

### 7. Data Models
The application relies on several core data models:
*   **`Habit`**: Represents a single habit with all its properties, including notes, streak data, and relapse history.
*   **`UserProfile`**: Stores user-specific information, preferences, and aggregated statistics.
*   **`Achievement`**: Defines the structure for unlockable milestones.
*   **`Challenge`**: (Model present) Defines challenges involving multiple habits over a set duration.
*   **`HabitNote`**: Allows users to add notes to habits, including specific notes for relapses.

## Technologies Used

*   **Framework**: Flutter
*   **Language**: Dart
*   **State Management**: `provider`
*   **Local Storage**: `shared_preferences`
*   **Notifications**: `awesome_notifications`
*   **Charting**: `fl_chart`
*   **UI Enhancements**:
    *   `flutter_slidable` (for swipe actions)
    *   `flutter_animate` (for UI animations)
    *   `google_fonts` (for custom typography)
    *   `cached_network_image` (though primarily local, available if needed)
*   **Utilities**:
    *   `image_picker` (for selecting profile pictures)
    *   `uuid` (for generating unique identifiers)
    *   `intl` (for date formatting)
    *   `share_plus` (for sharing functionality)
    *   `path_provider` & `path` (for file system path management)
*   **App Icons**: `flutter_launcher_icons`

## Getting Started

To get a local copy up and running, follow these simple steps:

1.  **Prerequisites**:
    *   Ensure you have the Flutter SDK installed on your system. For more information, see the [Flutter installation guide](https://flutter.dev/docs/get-started/install).
2.  **Clone the repository**:
    ```bash
    git clone https://github.com/daniyalhasan089/habit_tracker.git
    cd habit_tracker
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the application**:
    ```bash
    flutter run
    ```
    You can choose your target device (emulator, physical device, or desktop/web).

## Project Structure

The `lib` directory is organized as follows:

*   `main.dart`: The main entry point of the application. Initializes services and sets up the root widget.
*   `config/`: Contains application-wide configurations, such as:
    *   `theme.dart`: Defines the application's visual theme (currently a dark theme).
*   `models/`: Defines the data structures used throughout the application:
    *   `habit.dart`: Model for individual habits.
    *   `user_profile.dart`: Model for user-specific data.
    *   `achievement.dart`: Model for achievements.
    *   `challenge.dart`: Model for habit-based challenges.
    *   `HabitNote.dart`: Model for notes associated with habits.
*   `providers/`: Contains state management logic using the Provider package:
    *   `habit_provider.dart`: Manages the state of habits, user profiles, and related operations like loading/saving data and achievements.
*   `screens/`: Contains the UI for different parts of the application:
    *   `splash_screen.dart`: The initial screen shown when the app launches.
    *   `home_screen.dart`: The main dashboard displaying habits and overall progress.
    *   `profile_screen.dart`: Screen for viewing and editing user profile information and stats.
    *   `statistics_screen.dart`: Displays detailed statistics and charts about habit progress.
    *   `achievements_screen.dart`: Shows unlocked and available achievements.
*   `services/`: Contains services that provide specific functionalities:
    *   `notification_service.dart`: Handles scheduling and managing local notifications.
*   `assets/`: Includes static assets like images (`trackmotive.png`, `icon.png`).

## Platform Support
*   Android
