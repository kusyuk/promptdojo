# PromptDojo Implementation Todo List

This checklist tracks all implementation tasks for the PromptDojo project. Mark items as complete as you progress.

## Phase 0: Project Setup & Foundation ✅ COMPLETE

### Environment Setup
- [x] Create IBM Cloud account
- [x] Set up watsonx.ai project
- [x] Generate API key for Dallas region
- [x] Test API connectivity
- [x] Document credentials securely (use environment variables)

### Dependencies
- [x] Add `flutter_riverpod: ^2.5.1` to pubspec.yaml
- [x] Add `animated_text_kit: ^4.2.2` to pubspec.yaml
- [x] Add `audioplayers: ^6.0.0` to pubspec.yaml
- [x] Add `http: ^1.2.0` to pubspec.yaml
- [x] Add `flutter_svg: ^2.0.10` to pubspec.yaml
- [x] Add `flutter_dotenv: ^5.1.0` to pubspec.yaml
- [x] Run `flutter pub get`
- [x] Verify all packages install successfully

### Asset Organization
- [x] Create `/assets/sounds/` directory
- [x] Create `/assets/images/` directory
- [x] Copy `bob_mascot.svg` to `/assets/images/`
- [x] Copy `start.mp3` to `/assets/sounds/`
- [x] Copy `wrong.mp3` to `/assets/sounds/`
- [x] Add `bgm.mp3` to `/assets/sounds/`
- [x] Update `pubspec.yaml` with asset declarations

### Project Structure
- [x] Create `lib/core/constants/` directory
- [x] Create `lib/core/theme/` directory
- [x] Create `lib/core/services/` directory
- [x] Create `lib/data/models/` directory
- [x] Create `lib/data/services/` directory
- [x] Create `lib/data/repositories/` directory
- [x] Create `lib/domain/entities/` directory
- [x] Create `lib/presentation/providers/` directory
- [x] Create `lib/presentation/screens/` directory
- [x] Create `lib/presentation/widgets/` directory
- [x] Create `lib/config/` directory

---

## Phase 1: Core State Management ✅ COMPLETE

### Game State Model
- [x] Create `lib/domain/entities/game_state.dart`
- [x] Define `GameState` class with properties:
  - [x] `int manaReserves` (default: 1000)
  - [x] `bool hasBlueprint` (default: false)
  - [x] `int contextCost` (default: 0)
  - [x] `StoryNode currentStoryNode`
  - [x] `List<String> choices` (for decision tracking)
  - [x] `String currentDialogue`
  - [x] `bool showPromptInput`
- [x] Implement `copyWith()` method

### Story Node Enum
- [x] Create `lib/domain/entities/story_node.dart`
- [x] Define `StoryNode` enum with values:
  - [x] `title`
  - [x] `tutorial`
  - [x] `tutorialReaction`
  - [x] `planning`
  - [x] `planningReaction`
  - [x] `context`
  - [x] `contextReaction`
  - [x] `incantation`
  - [x] `incantationReaction`
  - [x] `badEnding`
  - [x] `goodEnding`

### Game State Provider
- [x] Create `lib/presentation/providers/game_state_provider.dart`
- [x] Create `GameStateNotifier` extending `StateNotifier<GameState>`
- [x] Implement `applyBlueprintPenalty()` method (-100 if hasBlueprint == false)
- [x] Implement `applyContextCost(int cost)` method
- [x] Implement `applyQualityPenalty(int score)` method:
  - [x] Formula: `(10 - score) * 40 * (hasBlueprint ? 1 : 2)`
- [x] Implement `setBlueprint(bool value)` method
- [x] Implement `setContextCost(int cost)` method
- [x] Implement `advanceToNode(StoryNode node)` method
- [x] Implement `resetGame()` method
- [x] Implement `resetMana()` method (for post-tutorial reset)
- [x] Create `StateNotifierProvider` for GameStateNotifier

### Game Controller
- [x] Create `lib/presentation/providers/game_controller.dart`
- [x] Implement story flow management
- [x] Implement phase transitions (planning, context, incantation)
- [x] Implement choice selection handlers
- [x] Implement reaction detection logic

---

## Phase 2: watsonx.ai API Integration ✅ COMPLETE

### API Configuration
- [x] Create `lib/config/watsonx_config.dart`
- [x] Define `WatsonxConfig` class with:
  - [x] `projectId` property
  - [x] `endpointUrl` property (Dallas region)
  - [x] `apiKey` property
- [x] Create `.env` file for credentials (add to .gitignore)
- [x] Add `flutter_dotenv` package
- [x] Load configuration from environment variables

### IAM Token Service
- [x] Create `lib/data/services/iam_token_service.dart`
- [x] Implement `generateToken(String apiKey)` method
- [x] Add token caching with expiration timestamp
- [x] Implement `isTokenExpired()` check
- [x] Implement automatic token refresh
- [x] Handle token generation errors

### Watsonx API Service
- [x] Create `lib/data/services/watsonx_service.dart`
- [x] Create `WatsonxService` class
- [x] Implement `evaluatePrompt(String userPrompt)` method
- [x] Build API request with:
  - [x] System prompt from PRD
  - [x] User prompt
  - [x] Model: granite-guardian-3-8b
  - [x] Temperature and other parameters
- [x] Parse JSON response
- [x] Handle API errors (timeout, network, invalid response)
- [x] Add retry logic (3 attempts)

### System Prompt Template
- [x] Create `lib/core/constants/prompts.dart`
- [x] Extract exact system prompt from PRD
- [x] Create `SYSTEM_PROMPT` constant
- [x] Ensure strict JSON output enforcement in prompt

### API Response Model
- [x] Create `lib/data/models/prompt_evaluation.dart`
- [x] Define `PromptEvaluation` class with:
  - [x] `int qualityScore` (1-10)
  - [x] `String archmageFeedback`
- [x] Implement `fromJson()` factory constructor
- [x] Add validation for qualityScore range

---

## Phase 3: UI Foundation & Layout ✅ COMPLETE

### Theme Setup
- [x] Create `lib/core/theme/app_theme.dart`
- [x] Define dark color scheme:
  - [x] Primary color (cyber blue)
  - [x] Secondary color (purple)
  - [x] Background colors (dark grays)
  - [x] Text colors
- [x] Define text styles
- [x] Create `ThemeData` for dark theme
- [x] Apply theme in `main.dart`

### Multi-Screen Architecture (UX Redesign)
- [x] Create `lib/presentation/screens/title_screen.dart`
- [x] Create `lib/presentation/screens/new_story_screen.dart`
- [x] Create `lib/presentation/screens/prompt_input_screen.dart`
- [x] Create `lib/presentation/screens/evaluation_screen.dart`
- [x] Create `lib/presentation/screens/result_screen.dart`
- [x] Create `lib/presentation/screens/ending_screen.dart`

### Core UI Components
- [x] Create `lib/presentation/widgets/characters/bob_mascot.dart`
  - [x] SVG rendering with floating animation
  - [x] Positioned in top 65% of screen
- [x] Create `lib/presentation/widgets/dialogue/dialogue_overlay.dart`
  - [x] Semi-transparent dialogue box (92% opacity)
  - [x] Typewriter effect using `animated_text_kit`
  - [x] Overlays bottom portion of screen
- [x] Create `lib/presentation/widgets/layouts/story_layout.dart`
  - [x] Combines Bob + Dialogue + Action buttons
  - [x] Handles mana bar display
- [x] Create `lib/presentation/widgets/hud/mana_bar.dart`
  - [x] Animated mana depletion
  - [x] Color transitions (green → yellow → red)
- [x] Create `lib/presentation/widgets/action_panel/choice_button.dart`
  - [x] Hover effects
  - [x] Disabled state handling
- [x] Create `lib/presentation/widgets/action_panel/prompt_input.dart`
  - [x] Multiline text input
  - [x] Character counter
  - [x] Submit button

---

## Phase 4: Story Flow Implementation ✅ COMPLETE

### Story Data Structure
- [x] Create `lib/data/repositories/story_repository.dart`
- [x] Implement all dialogue from PRD
- [x] Create methods for each story phase:
  - [x] `getTutorialDialogue()`
  - [x] `getTutorialReactionDialogue()`
  - [x] `getPlanningDialogue()`
  - [x] `getPlanningReactionDialogue()`
  - [x] `getContextDialogue()`
  - [x] `getContextReactionDialogue()`
  - [x] `getIncantationDialogue()`
  - [x] `getBadEndingDialogue()`
  - [x] `getGoodEndingDialogue()`

### Act 1: Tutorial
- [x] Implement tutorial flow in `new_story_screen.dart`
- [x] Force bad prompt scenario (skip API call)
- [x] Apply 800 mana deduction
- [x] Show Archmage Bob introduction
- [x] Navigate to result screen
- [x] Reset mana to 1000 after tutorial

### Act 2: Decision Nodes

#### Node 2.1 - Planning Phase
- [x] Implement planning phase in `game_controller.dart`
- [x] Create Choice A (Vibe-Coder):
  - [x] Set `hasBlueprint = false`
  - [x] Apply -100 mana penalty
  - [x] Show Bob's reaction dialogue
- [x] Create Choice B (Architect):
  - [x] Set `hasBlueprint = true`
  - [x] Show Bob's approval dialogue
- [x] Animate mana bar on penalty
- [x] Clear choices list for reaction detection

#### Node 2.2 - Context Phase
- [x] Implement context phase in `game_controller.dart`
- [x] Create Choice A (Data Dumper):
  - [x] Set `contextCost = 150`
  - [x] Show Bob's warning dialogue
- [x] Create Choice B (Precision Caster):
  - [x] Set `contextCost = 10`
  - [x] Show Bob's approval dialogue
- [x] Create Choice C (Amnesiac):
  - [x] Set `contextCost = 50`
  - [x] Show Bob's concern dialogue
- [x] Apply context cost to mana
- [x] Animate mana bar depletion
- [x] Clear choices list for reaction detection

#### Node 2.3 - Incantation Phase
- [x] Implement incantation phase flow
- [x] Navigate to `prompt_input_screen.dart`
- [x] Implement "Cast Spell" button
- [x] Navigate to `evaluation_screen.dart` with loading state
- [x] Call `watsonxService.evaluatePrompt()`
- [x] Navigate to `result_screen.dart` with feedback
- [x] Calculate final quality penalty
- [x] Apply penalty to mana
- [x] Animate mana bar
- [x] Navigate to appropriate ending

### Act 3: Endings

#### Bad Ending
- [x] Implement in `ending_screen.dart`
- [x] Check condition: `manaReserves <= 0`
- [x] Display failure message
- [x] Show stats:
  - [x] Total mana wasted
  - [x] Lesson learned message
- [x] Add "Try Again" button

#### Good Ending
- [x] Implement in `ending_screen.dart`
- [x] Check condition: `manaReserves > 0`
- [x] Display success message
- [x] Show victory stats:
  - [x] Mana remaining
  - [x] Mana saved
  - [x] "Architect" title earned
- [x] Add "Play Again" button

### Story Navigation
- [x] Implement navigation in all screens
- [x] Handle "Continue" button functionality
- [x] Handle choice selection callbacks
- [x] Update UI based on current node
- [x] Ensure state updates before node transitions
- [x] Fix tutorial looping bug
- [x] Fix planning phase stuck bug
- [x] Fix incantation phase navigation

---

## Phase 5: Audio & Polish ✅ COMPLETE

### Audio Integration
- [x] Create `lib/core/services/audio_service.dart`
- [x] Implement singleton AudioService
- [x] Initialize `audioplayers` in main.dart
- [x] Implement background music (BGM):
  - [x] Load `bgm.mp3`
  - [x] Auto-start on app launch
  - [x] Loop continuously
  - [x] Set volume to 30%
- [x] Implement sound effects methods:
  - [x] `playSfx()` for one-shot sounds
  - [x] Support for `start.mp3` and `wrong.mp3`
- [x] Implement audio controls:
  - [x] `toggleMute()` for mute/unmute
  - [x] `setBgmVolume()` for volume control
  - [x] `pauseBgm()` / `resumeBgm()` for pause/resume

### Visual Polish
- [x] Implement button hover states
- [x] Add smooth screen transitions
- [x] Polish typography (font sizes, weights, spacing)
- [x] Add proper padding/margins
- [x] Implement mana bar color transitions
- [x] Add Bob mascot floating animation
- [x] Add dialogue typewriter effect

### Responsive Design
- [x] Mobile-first design approach
- [x] Test on various screen sizes
- [x] Ensure text readability
- [x] Proper layout for different orientations

### Loading States
- [x] Implement loading indicator in `evaluation_screen.dart`
- [x] Show "Archmage is evaluating..." message
- [x] Disable input during API calls
- [x] Handle API timeouts

---

## Phase 6: Testing & Bug Fixes 🔄 IN PROGRESS

### Critical Bug Fixes (Completed)
- [x] Fix tutorial looping bug (skip API for tutorial)
- [x] Fix Bob positioning (top 65% of screen)
- [x] Fix planning phase stuck (clear choices list)
- [x] Fix incantation phase navigation (add showPromptInput check)
- [x] Fix mana penalty carryover (reset mana after tutorial)

### Manual Testing (Pending)
- [ ] Complete playthrough (vibe-coder path)
- [ ] Complete playthrough (architect path)
- [ ] Test with various prompt qualities
- [ ] Test API error scenarios:
  - [ ] Network timeout
  - [ ] Invalid JSON response
  - [ ] API rate limit
- [ ] Test audio playback on web
- [ ] Test animations smoothness
- [ ] Test on different browsers:
  - [ ] Chrome
  - [ ] Firefox
  - [ ] Safari
  - [ ] Edge

### Performance Testing
- [ ] Check for memory leaks
- [ ] Verify smooth 60fps animations
- [ ] Test asset loading times
- [ ] Optimize if needed

---

## Phase 7: Web Deployment 📋 PENDING

### Web Build Optimization
- [ ] Run `flutter build web --release`
- [ ] Check build output size
- [ ] Optimize images (compress if needed)
- [ ] Test web build locally:
  - [ ] `flutter run -d chrome --release`
- [ ] Verify all features work in web build
- [ ] Test asset loading
- [ ] Test API calls from web

### Deployment
- [ ] Choose hosting platform:
  - [ ] Option A: Firebase Hosting
  - [ ] Option B: Netlify
  - [ ] Option C: Vercel
  - [ ] Option D: GitHub Pages
- [ ] Create deployment account
- [ ] Configure deployment settings
- [ ] Deploy web build
- [ ] Verify deployment successful
- [ ] Test deployed URL

### Documentation
- [ ] Update README.md with:
  - [ ] Project description
  - [ ] Live demo link
  - [ ] Screenshots
  - [ ] Technology stack
  - [ ] Setup instructions
  - [ ] How to play
- [ ] Create SETUP.md for developers
- [ ] Document watsonx.ai setup process
- [ ] Add demo video or GIF (optional)
- [ ] Create hackathon submission document

### Final Testing
- [ ] Test on Chrome browser
- [ ] Test on Firefox browser
- [ ] Test on Safari browser
- [ ] Test on Edge browser
- [ ] Test on mobile Chrome
- [ ] Test on mobile Safari
- [ ] Verify judges can access without login
- [ ] Test complete playthrough on deployed version
- [ ] Verify all assets load correctly
- [ ] Check console for errors

---

## Post-Deployment (Optional Enhancements)

### Additional Audio
- [ ] Add sound effects for button clicks
- [ ] Add sound effect for mana depletion
- [ ] Add sound effect for choice selection
- [ ] Add sound effect for ending triggers
- [ ] Add volume control UI

### Visual Enhancements
- [ ] Add particle effects for mana depletion
- [ ] Add glow effect to Bob mascot
- [ ] Add confetti animation for good ending
- [ ] Add terminal crash animation for bad ending
- [ ] Add more background variations

### Analytics (Optional)
- [ ] Add Google Analytics
- [ ] Track user choices
- [ ] Track completion rates
- [ ] Track average mana remaining

---

## Progress Tracking

**Current Phase:** Phase 6 - Testing & Bug Fixes (In Progress)

**Completion Status:**
- Phase 0: ✅ 100% (All tasks complete)
- Phase 1: ✅ 100% (All tasks complete)
- Phase 2: ✅ 100% (All tasks complete)
- Phase 3: ✅ 100% (All tasks complete)
- Phase 4: ✅ 100% (All tasks complete)
- Phase 5: ✅ 100% (All tasks complete)
- Phase 6: 🔄 30% (Critical bugs fixed, manual testing pending)
- Phase 7: 📋 0% (Not started)

**Overall Progress:** ~85% complete

**Next Steps:**
1. Complete manual testing of all game paths
2. Test on multiple browsers
3. Build for web deployment
4. Deploy to hosting platform
5. Final testing and submission

---

## Implementation Notes

### Architecture Decisions
- **Multi-Screen UX:** Each screen has a single purpose (Title, Story, PromptInput, Evaluation, Result, Ending)
- **Bob Positioning:** Large SVG (65% screen height) positioned in top portion with dialogue overlaying bottom
- **State Management:** Riverpod with GameStateNotifier and GameController
- **Navigation:** Direct Navigator.push/pop between screens
- **Audio:** Singleton AudioService with auto-start BGM

### Key Files
- **State:** `lib/presentation/providers/game_state_provider.dart`, `lib/presentation/providers/game_controller.dart`
- **Screens:** `lib/presentation/screens/*.dart` (6 screens total)
- **Widgets:** `lib/presentation/widgets/` (Bob, Dialogue, Layout, HUD, ActionPanel)
- **Services:** `lib/data/services/watsonx_service.dart`, `lib/core/services/audio_service.dart`
- **Story Data:** `lib/data/repositories/story_repository.dart`

### Known Issues (Fixed)
- ✅ Tutorial looping - Fixed by skipping API call for tutorial
- ✅ Bob positioning - Fixed by positioning in top 65% with dialogue overlay
- ✅ Planning phase stuck - Fixed by clearing choices list
- ✅ Incantation navigation - Fixed by adding showPromptInput check
- ✅ Mana carryover - Fixed by resetting mana after tutorial

---

## Celebration Milestones! 🎉

- ✅ Project setup complete
- ✅ Core state management working
- ✅ watsonx.ai API integration successful
- ✅ UI foundation complete
- ✅ Story flow fully implemented
- ✅ Background music playing!
- 🎯 Ready for final testing and deployment!