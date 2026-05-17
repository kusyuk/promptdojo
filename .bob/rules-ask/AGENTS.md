# AGENTS.md - Ask Mode

This file provides documentation-specific guidance for agents working in this repository.

## Critical Documentation Context (Non-Obvious Only)

### Project Purpose Clarification
- This is a **hackathon submission** for IBM Bob, not a production app
- Primary target is **Flutter Web** (not mobile app stores) - judges access via URL
- Game teaches prompt engineering through narrative, not traditional tutorials

### Architecture Documentation
- PRD in `documentation/prd.md` is the **canonical source** for all game logic
- State management formulas are defined in PRD, not in code comments
- Story dialogue and character voice must match PRD exactly (Archmage Bob tone)

### Technology Constraints
- **Cannot use Flame engine** despite being a game (uses standard Flutter widgets)
- Riverpod chosen over other state management (Provider, Bloc, GetX not used)
- watsonx.ai granite-guardian-3-8b is the only supported LLM (no GPT, Claude, etc.)
- Must use `animated_text_kit` for typewriter effect (not custom implementation)

### API Integration Context
- watsonx.ai requires Dallas region endpoint specifically
- API returns strict JSON only (no markdown, no conversational text)
- System prompt enforces "Archmage Bob" character voice in feedback
- IAM tokens expire and must be regenerated per session

### Game Logic Documentation
- Mana penalty calculation is **client-side** before API call (not server-side)
- Act 1 tutorial intentionally forces bad choice (800 mana deduction is hardcoded)
- Act 2 has exactly 3 decision nodes affecting final score
- Act 3 endings check `manaReserves <= 0` (not `< 0`) for bad ending
- Blueprint penalty is -100 mana if not chosen (applied before context cost)

### Testing Context
- Uses standard `flutter_test` from SDK (no custom test framework)
- No integration tests defined yet (only unit/widget tests planned)
- Test coverage not enforced by CI (hackathon MVP scope)