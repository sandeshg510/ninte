ok# Known Issues and Bugs

## High Priority

### 1. Theme Persistence
**Issue:** Theme resets to default after app restart
- Theme selection not being properly saved
- SharedPreferences implementation might be incorrect
- Theme state management needs review

### 2. Authentication State
**Issue:** App shows login screen when offline
- Not properly handling offline authentication state
- Need to implement local auth state persistence
- Should maintain login state even without internet

### 3. App Initialization
**Issue:** App sometimes stuck at shimmer loading screen
- Inconsistent initialization behavior
- Need to implement proper timeout and fallback
- Better error handling required for initialization

## UI/UX Issues

### 1. Personal Support Page
**Issues:**
- Missing text in action button
- Status bar overlap with header content
- Need proper safe area implementation
- Improve visual hierarchy

### 2. Theme System
**Issues:**
- Theme transitions could be smoother
- Need better visual feedback for theme selection
- Theme preview needs improvement

## Proposed Solutions

### Theme Persistence
1. Implement proper theme state persistence using: 