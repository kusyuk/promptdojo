# PromptDojo Development Plan

## Overview
This document outlines the development strategy for PromptDojo, a gamified visual novel teaching prompt engineering. The plan is divided into phases with clear milestones and dependencies.

## Development Phases

### Phase 0: Project Setup & Foundation (Day 1)
**Goal:** Establish project infrastructure and dependencies

#### Tasks:
1. **Environment Setup**
   - Set up IBM watsonx.ai account and credentials
   - Configure Dallas region endpoint
   - Generate and test IAM API key
   - Document API credentials securely

2. **Dependencies Installation**
   - Add Riverpod for state management (`flutter_riverpod: ^2.5.1`)
   - Add `animated_text_kit` for typewriter effects
   - Add `audioplayers` for sound effects
   - Add `http` or `dio` for API calls
   - Update `pubspec.yaml` with all dependencies

3. **Asset Organization**
   - Create `/assets/sounds/` directory
   - Create `/assets/images/` directory
   - Move Bob mascot SVG to `/assets/images/bob_mascot.svg`
   - Move sound files to `/assets/sounds/`
   - Update `pubspec.yaml` asset declarations

4. **Project Structure**
   - Create folder structure:
     ```
     lib/
     ├── main.dart
     ├── core/
     │   ├── constants/
     │   ├── theme/
     │   └── utils/
     ├── data/
     │   ├── models/
     │   └── services/
     ├── domain/
     │   └── entities/
     ├── presentation/
     │   ├── providers/
     │   ├── screens/
     │   └── widgets/
     └── config/
     ```

**Milestone:** Project builds successfully with all dependencies

---

### Phase 1: Core State Management (Day 1-2)
**Goal:** Implement game state logic and penalty calculations

#### Tasks:
1. **Game State Model**
   - Create `GameState` class with:
     - `manaReserves` (int, default: 1000)
     - `hasBlueprint` (bool, default: false)
     - `contextCost` (int, default: 0)
     - `currentStoryNode` (enum)
   - Implement `copyWith` method for immutability

2. **Story Node Enum**
   - Define all story nodes:
     - `tutorial`, `planning`, `context`, `incantation`
     - `badEnding`, `goodEnding`

3. **Game State Provider (Riverpod)**
   - Create `StateNotifierProvider<GameStateNotifier, GameState>`
   - Implement penalty calculation methods:
     - `applyBlueprintPenalty()` → -100 if hasBlueprint == false
     - `applyContextCost(int cost)` → subtract contextCost
     - `applyQualityPenalty(int score)` → `(10 - score) * 40 * multiplier`
   - Implement state transition methods:
     - `setBlueprint(bool value)`
     - `setContextCost(int cost)`
     - `advanceToNode(StoryNode node)`

4. **Unit Tests for State Logic**
   - Test penalty calculations match PRD formulas
   - Test state transitions
   - Test edge cases (mana <= 0)

**Milestone:** State management working with correct penalty calculations

---

### Phase 2: watsonx.ai API Integration (Day 2-3)
**Goal:** Connect to IBM watsonx.ai and handle API responses

#### Tasks:
1. **API Configuration**
   - Create `WatsonxConfig` class:
     - Project ID
     - Dallas endpoint URL
     - API key storage (secure)
   - Create environment variables or config file

2. **IAM Token Service**
   - Implement token generation from API key
   - Add token caching with expiration check
   - Implement automatic token refresh

3. **Watsonx API Service**
   - Create `WatsonxService` class
   - Implement `evaluatePrompt(String userPrompt)` method
   - Build request with system prompt from PRD
   - Parse JSON response: `{"quality_score": int, "archmage_feedback": string}`
   - Handle API errors gracefully

4. **System Prompt Template**
   - Extract exact system prompt from PRD
   - Create template with Archmage Bob character
   - Ensure strict JSON output enforcement

5. **API Response Model**
   - Create `PromptEvaluation` model:
     - `qualityScore` (int, 1-10)
     - `archmageFeedback` (String)
   - Add JSON serialization

6. **Integration Tests**
   - Mock API responses for testing
   - Test JSON parsing
   - Test error handling

**Milestone:** Successfully call watsonx.ai API and receive valid responses

---

### Phase 3: UI Foundation & Layout (Day 3-4)
**Goal:** Build visual novel layout structure

#### Tasks:
1. **Theme Setup**
   - Create dark programmer theme
   - Define color palette (dark blues, purples, cyber aesthetic)
   - Set up custom fonts if needed

2. **Main Screen Structure**
   - Create `GameScreen` widget
   - Implement three-section layout:
     - Top: HUD (mana bar, status indicators)
     - Center: Stage (backgrounds, characters)
     - Bottom: Action panel (dialogue, choices)

3. **HUD Components**
   - Create `ManaBar` widget with `TweenAnimationBuilder`
   - Implement smooth depletion animation
   - Add red flash effect on penalty
   - Create status indicator widgets

4. **Stage Components**
   - Create `GameStage` widget for backgrounds
   - Implement `CharacterPortrait` widget
   - Add `SlideTransition` + `FadeTransition` for entrances
   - Create placeholder backgrounds

5. **Action Panel Components**
   - Create `DialogueBox` widget
   - Implement typewriter effect using `animated_text_kit`
   - Create `ChoiceButton` widget
   - Create `PromptInput` widget (multiline TextField)

6. **Widget Tests**
   - Test widget rendering
   - Test animation triggers
   - Test user interactions

**Milestone:** Complete UI layout with all major components

---

### Phase 4: Story Flow Implementation (Day 4-5)
**Goal:** Implement all three acts with dialogue and choices

#### Tasks:
1. **Story Data Structure**
   - Create `StoryNode` model:
     - `id`, `dialogue`, `choices`, `nextNode`
   - Create story data repository with all PRD dialogue

2. **Act 1: Tutorial**
   - Implement forced bad prompt scenario
   - Show 800 mana deduction
   - Introduce Archmage Bob with entrance animation
   - Display tutorial dialogue

3. **Act 2: Decision Nodes**
   - **Node 2.1 (Planning):**
     - Present blueprint choice
     - Update `hasBlueprint` state
     - Apply -100 mana penalty if declined
   - **Node 2.2 (Context):**
     - Present context window choices
     - Calculate and apply `contextCost`
     - Animate mana bar depletion
   - **Node 2.3 (Incantation):**
     - Show prompt input field
     - Send to watsonx.ai API
     - Display loading state
     - Show Archmage feedback
     - Calculate final penalty

4. **Act 3: Endings**
   - Check `manaReserves <= 0` condition
   - **Bad Ending:**
     - Show terminal crash animation
     - Display stats screen with wasted mana
     - Show real-world cost equivalent
   - **Good Ending:**
     - Show success animation
     - Display victory stats
     - Show mana saved

5. **Story Navigation**
   - Implement node transition logic
   - Add "Continue" button functionality
   - Handle choice selection

**Milestone:** Complete playthrough from start to both endings

---

### Phase 5: Audio & Polish (Day 5-6)
**Goal:** Add sound effects and visual polish

#### Tasks:
1. **Audio Integration**
   - Initialize `audioplayers` package
   - Load sound files:
     - `start.mp3` for game start
     - `wrong.mp3` for penalties
   - Implement sound playback on events:
     - Mana depletion
     - Choice selection
     - Ending triggers

2. **Visual Polish**
   - Add particle effects for mana depletion (optional)
   - Improve button hover states
   - Add smooth transitions between nodes
   - Polish typography and spacing

3. **Responsive Design**
   - Test on different screen sizes
   - Ensure mobile-first design works
   - Optimize for web browser display

4. **Loading States**
   - Add loading indicator during API calls
   - Show "Archmage is thinking..." message
   - Prevent multiple submissions

**Milestone:** Polished, production-ready game experience

---

### Phase 6: Testing & Bug Fixes (Day 6-7)
**Goal:** Comprehensive testing and quality assurance

#### Tasks:
1. **Unit Tests**
   - Test all state calculations
   - Test penalty formulas
   - Test API service methods
   - Achieve >80% code coverage

2. **Widget Tests**
   - Test all UI components
   - Test user interactions
   - Test state updates trigger UI changes

3. **Integration Testing**
   - Test complete user flows
   - Test both ending scenarios
   - Test API integration with mocked responses

4. **Manual Testing**
   - Playthrough testing (multiple runs)
   - Test edge cases:
     - Mana exactly at 0
     - Maximum quality score (10)
     - Minimum quality score (1)
   - Test error scenarios:
     - API timeout
     - Invalid API response
     - Network errors

5. **Bug Fixes**
   - Fix any discovered issues
   - Optimize performance
   - Ensure smooth animations

**Milestone:** Stable, bug-free application

---

### Phase 7: Web Deployment (Day 7)
**Goal:** Deploy to Flutter Web for hackathon submission

#### Tasks:
1. **Web Build Optimization**
   - Run `flutter build web --release`
   - Optimize asset loading
   - Test web build locally
   - Verify all features work in browser

2. **Deployment**
   - Choose hosting platform (Firebase Hosting, Netlify, Vercel)
   - Configure deployment
   - Deploy web build
   - Test deployed version

3. **Documentation**
   - Create README with:
     - Project description
     - Setup instructions
     - Play instructions
     - Technology stack
   - Document API setup process
   - Add screenshots/demo video

4. **Final Testing**
   - Test on multiple browsers (Chrome, Firefox, Safari)
   - Test on mobile browsers
   - Verify judges can access without issues

**Milestone:** Live, accessible web application

---

## Risk Mitigation

### Technical Risks:
1. **watsonx.ai API Issues**
   - **Risk:** API downtime or rate limits
   - **Mitigation:** Implement retry logic, cache responses for testing, have fallback mock responses

2. **Flutter Web Performance**
   - **Risk:** Slow loading or laggy animations
   - **Mitigation:** Optimize assets, use web-specific optimizations, test early

3. **State Management Complexity**
   - **Risk:** State bugs causing incorrect calculations
   - **Mitigation:** Comprehensive unit tests, clear state flow documentation

### Timeline Risks:
1. **Scope Creep**
   - **Risk:** Adding features beyond MVP
   - **Mitigation:** Stick to PRD requirements, defer nice-to-haves

2. **API Integration Delays**
   - **Risk:** watsonx.ai setup takes longer than expected
   - **Mitigation:** Start API setup early (Phase 0), have mock responses ready

## Success Criteria

### Must-Have (MVP):
- ✅ Complete story flow (Acts 1-3)
- ✅ Working watsonx.ai integration
- ✅ Correct penalty calculations
- ✅ Both endings functional
- ✅ Deployed to web
- ✅ Mobile-responsive design

### Nice-to-Have (Post-MVP):
- 🎯 Advanced animations
- 🎯 Multiple background variations
- 🎯 Sound effect variations
- 🎯 Analytics tracking
- 🎯 Leaderboard system

## Timeline Summary

| Phase | Duration | Key Deliverable |
|-------|----------|----------------|
| Phase 0 | 1 day | Project setup complete |
| Phase 1 | 1-2 days | State management working |
| Phase 2 | 1-2 days | API integration complete |
| Phase 3 | 1-2 days | UI layout complete |
| Phase 4 | 1-2 days | Story flow complete |
| Phase 5 | 1 day | Audio & polish done |
| Phase 6 | 1 day | Testing complete |
| Phase 7 | 1 day | Deployed to web |
| **Total** | **7-10 days** | **Live hackathon submission** |

## Next Steps

1. Review and approve this development plan
2. Set up watsonx.ai account (see `watsonx-setup.md`)
3. Begin Phase 0: Project Setup
4. Track progress using `todo.md`