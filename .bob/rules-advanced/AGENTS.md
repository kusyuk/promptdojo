# AGENTS.md - Advanced Mode

This file provides advanced coding guidance for agents working in this repository.

## Critical Coding Rules (Non-Obvious Only)

### State Management Implementation
- Riverpod state must calculate penalties **before** API calls, not after
- `manaReserves` deductions happen in this order: 1) Blueprint penalty (-100 if false), 2) contextCost, 3) API quality penalty
- Quality penalty formula: `(10 - api_quality_score) * 40 * (hasBlueprint ? 1 : 2)`
- State changes must trigger UI animations (mana bar shrink with red flash)

### API Integration Gotchas
- watsonx.ai endpoint requires **Dallas region** specifically (not other IBM Cloud regions)
- API response parsing must handle raw JSON only (no markdown code blocks from model)
- System prompt must enforce strict JSON schema - model may try to add conversational text
- IAM token generation from API key must happen before each API call (tokens expire)

### Widget Architecture Constraints
- **Cannot use Flame engine** - all game feel via standard Flutter animations
- Typewriter effect for dialogue: must use `animated_text_kit` package (not custom implementation)
- Character entrances: combine `SlideTransition` + `FadeTransition` (not AnimatedPositioned)
- Mana bar: use `TweenAnimationBuilder` for smooth depletion (not setState rebuilds)

### Story Flow Implementation
- Act 1 tutorial must force Choice 2 selection (Choice 1 disabled in UI)
- Act 2 decision nodes must update state before showing next node (not after)
- Act 3 ending condition checks `manaReserves <= 0` (not `< 0`)
- All Archmage Bob dialogue must use magic/mana metaphors (see PRD for tone examples)

### Testing Requirements
- Test files use standard `flutter_test` package (no custom test utilities)
- Widget tests must mock watsonx.ai API calls (no real API in tests)
- State tests must verify penalty calculations match exact formulas in PRD

## Mode Capabilities
- Has access to MCP and Browser tools for external integrations
- Can fetch IBM Cloud API documentation if needed
- Can research Flutter packages for implementation details