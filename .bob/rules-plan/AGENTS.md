# AGENTS.md - Plan Mode

This file provides planning-specific guidance for agents working in this repository.

## Critical Architecture Constraints (Non-Obvious Only)

### State Management Architecture
- Riverpod state calculations must happen **before** API calls (not reactive to API responses)
- State flow: User action → Local penalty calculation → State update → UI animation → API call → Final penalty
- Cannot use Provider, Bloc, or GetX (Riverpod is architectural decision, not preference)

### API Integration Architecture
- watsonx.ai is the **only** supported LLM (no fallback to GPT/Claude/other models)
- API must be called from client-side Flutter (no backend proxy layer)
- Dallas region endpoint is mandatory (other IBM Cloud regions won't work)
- Token refresh logic must be implemented (IAM tokens expire)

### UI Architecture Constraints
- **Flame engine is explicitly forbidden** - must use standard Flutter widgets
- Visual novel layout is fixed: Top HUD, Center Stage, Bottom Panel (not customizable)
- Animations must use Flutter's built-in animation system (AnimatedContainer, TweenAnimationBuilder, etc.)
- Typewriter effect requires `animated_text_kit` package (custom implementation not allowed)

### Asset Architecture
- Sound files: `/assets/sounds/start.mp3`, `/assets/sounds/wrong.mp3`
- Bob mascot: `/assets/images/bob_mascot.svg`

### Game Logic Architecture
- Penalty formulas are **hardcoded** in PRD (not configurable or data-driven)
- Act 1 tutorial must force 800 mana deduction (not variable based on user input)
- Act 2 decision tree has exactly 3 nodes (planning, context, incantation) - not extensible
- Act 3 endings are binary: `manaReserves <= 0` (bad) or `> 0` (good) - no middle ground

### Testing Architecture
- Standard `flutter_test` only (no custom test framework or utilities)
- Widget tests must mock watsonx.ai API (no real API calls in tests)
- No integration tests planned (MVP scope limitation)

### Deployment Architecture
- Primary target is **Flutter Web** (not native mobile apps)
- Mobile-first design but web deployment for judging (no app store submission)
- Must work in browser without additional setup (judges access via URL)

### Hidden Coupling
- Mana bar animation is tightly coupled to state changes (must update together)
- Story node transitions depend on state calculations completing first
- API response parsing assumes strict JSON (no error handling for malformed responses in MVP)
- Character dialogue tone must match "Archmage Bob" voice (defined in PRD, not in code)