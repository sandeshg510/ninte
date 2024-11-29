# Ninte App - File Structure Documentation

## Core Architecture
The app follows a feature-first architecture with clear separation of concerns:

## Overview
This document provides a detailed explanation of every file in the Ninte app's lib directory.

## Directory Structure

### /lib/core
Core functionality and application-wide services.

- `app.dart` - Root application widget
  - Handles theme management
  - Manages authentication state
  - Controls initial routing
  - Configures system UI appearance

- `/providers`
  - `auth_provider.dart` - Authentication state management using Riverpod
  - `shared_preferences_provider.dart` - Local storage provider

- `/services`
  - `auth_service.dart` - Firebase authentication implementation
    - Login/Signup functionality
    - Google Sign-in
    - Email verification
    - Password reset

### /lib/features
Feature-specific modules and functionality.

- `/support`
  - `/pages`
    - `personal_support_page.dart` - Support message submission UI
  - `/services`
    - `support_service.dart` - Backend integration for support messages
  - `/providers`
    - `support_provider.dart` - State management for support features

- `/productivity`
  - `/models`
    - `feature.dart` - Data models for productivity features

- `/habit_tracking`
  - `/models`
    - `habit.dart` - Habit data model with frequency, category, and streak tracking
  - `/pages`
    - `archived_habits_page.dart` - View for archived habits
    - `habit_detail_page.dart` - Detailed view of individual habits
    - `habit_insights_page.dart` - Analytics and insights for habits
  - `/providers`
    - `habit_provider.dart` - State management for habits
    - `habit_state.dart` - Habit state definitions
  - `/services`
    - `habit_firestore_service.dart` - Firebase integration for habits
  - `/widgets`
    - `habit_achievement_card.dart` - Achievement display
    - `habit_archive_animation.dart` - Animation for archiving
    - `habit_category_list.dart` - Category filtering
    - `habit_completion_animation.dart` - Completion celebrations
    - `habit_completion_celebration.dart` - Extended completion effects
    - `habit_completion_confetti.dart` - Confetti animation
    - `habit_detail_card.dart` - Habit details display
    - `habit_insights_card.dart` - Insights visualization
    - `habit_milestone_card.dart` - Milestone achievements
    - `habit_progress_summary.dart` - Progress overview
    - `habit_stats_card.dart` - Statistics display
    - `habit_streak_calendar.dart` - Streak visualization
    - `habit_streak_milestone.dart` - Streak achievements

- `/pomodoro`
  - `/models`
    - `pomodoro_timer.dart` - Timer configuration and state
  - `/services`
    - `notification_service.dart` - Timer notifications
  - `/utils`
    - `notification_helper.dart` - Notification utilities

### /lib/presentation
UI components and visual elements.

- `/pages`
  - `/auth`
    - `auth_page.dart` - Authentication flow container
    - `login_page.dart` - Login screen
    - `signup_page.dart` - Registration screen
  
  - `/home`
    - `home_page.dart` - Main app container with navigation
    - `/tabs`
      - `dashboard_tab.dart` - Main dashboard UI
      - `habits_tab.dart` - Habits management
      - `dailies_tab.dart` - Daily tasks
      - `stats_tab.dart` - Statistics and analytics
    - `/modals`
      - `create_habit_modal.dart` - Habit creation UI
      - `create_daily_modal.dart` - Daily task creation
      - `profile_modal.dart` - User profile editing

  - `/settings`
    - `settings_page.dart` - App settings
    - `theme_settings_page.dart` - Theme customization

- `/theme`
  - `app_theme.dart` - Theme definitions and configurations
  - `app_theme_data.dart` - Theme data structure
  - `app_colors.dart` - Color system implementation
  - `theme_cubit.dart` - Theme state management

- `/widgets`
  - `gradient_container.dart` - Reusable gradient container
  - `shimmer_loading.dart` - Loading animations
  - Other reusable UI components

### /lib/utils
Utility functions and helpers.

- `animations.dart` - Shared animation configurations
- `constants.dart` - App-wide constants
- `extensions.dart` - Dart extensions

## Key Components

### Authentication Flow
The authentication system is implemented across:
- `auth_service.dart` - Core authentication logic
- `auth_provider.dart` - State management
- `auth_page.dart`, `login_page.dart`, `signup_page.dart` - UI components

### Navigation System
Navigation is handled through:
- `home_page.dart` - Tab-based navigation
- Bottom navigation bar for main sections
- Drawer for additional options

### Theme System
The theming system consists of:
- `app_theme.dart` - Theme definitions
- `app_theme_data.dart` - Theme structure
- `app_colors.dart` - Color management
- `theme_cubit.dart` - Theme state
See THEME_SYSTEM.md for detailed documentation. 

## Key Features

### Habit Tracking System
- Comprehensive habit management
- Multiple frequency options (daily, weekly, monthly)
- Category organization
- Streak tracking and milestones
- Detailed insights and statistics
- Archive functionality
- Celebration animations

### Pomodoro Timer
- Configurable work/break durations
- Sound and vibration notifications
- Auto-start options
- Session tracking
- Break management (short/long breaks)
- Maximum session limits

## State Management
- Riverpod for state management
- Firebase integration for data persistence
- Local storage for preferences

## UI/UX Features
- Smooth animations
- Interactive celebrations
- Progress visualizations
- Detailed statistics
- Category filtering
- Archive management