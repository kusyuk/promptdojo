# **Product Requirements Document (PRD): PromptDojo MVP**

## **1\. Project Overview**

**PromptDojo: The Architect's Awakening** is a gamified visual novel designed to train developers in efficient, cost-effective prompt engineering. It tackles the costly enterprise problem of developers wasting LLM API quota through unstructured "vibe-coding" by teaching them to draft architectural blueprints and apply constraints before prompting.

This project aligns directly with the hackathon theme, "Turn idea into impact faster". It demonstrates how an intelligent development partner like IBM Bob can help builders at any skill level deliver solutions with greater efficiency.

## **2\. Problem statements & Proposed Solution:**

* Beginner vibe-coder, Junior to mid-level software engineers and enterprise development teams onboarding to AI-assisted coding frequently use unoptimized, vague prompting, which leads to massive context window hallucinations, wasted LLM API compute (Resource Units/Tokens), and significant, unnecessary budget expenditure.  
* Solution: PromptDojo acts as an interactive enterprise onboarding tool that trains developers to minimize token waste and maximize coding efficiency, resulting in direct cost savings.

## **3\. Technical Architecture**

The MVP will utilize a streamlined, lightweight stack designed for rapid development, native-feeling interactions, and zero-friction judging.

* **Frontend Framework:** Flutter.  
  * **Development Strategy:** Mobile-first design for native feel and rapid UI construction.  
  * **Distribution Strategy:** Compiled to **Flutter Web** for submission. This provides judges with a frictionless URL, eliminating the need to download APKs or bypass mobile security settings.  
* **Game Engine Strategy:** **Standard Flutter Widgets** (No Flame Engine). The visual novel format relies on UI state changes rather than game-loop physics, making standard Flutter highly efficient and perfectly suited for IBM Bob's code generation capabilities.  
* **Local State Management:** Riverpod (to instantly sync the UI "Mana Bar" and dialogue nodes with the underlying game math without prop drilling).  
* **Architecture:** Clean Architecture  
* **Evaluation Engine:** IBM watsonx.ai API (granite-4-h-small model) for real-time prompt evaluation.

## **4\. Local State Management Schema**

The game state will be managed entirely on the client side using a simple algorithm to calculate penalties before calling the watsonx API.

**Core State Variables (Riverpod Notifier):**

* manaReserves (Integer): Initializes at 1000. Tracks the remaining API budget.  
* hasBlueprint (Boolean): Initializes at false. Determines if the player drafted a PRD.  
* contextCost (Integer): Initializes at 0. Tracks the penalty for inefficient context window usage.  
* currentStoryNode (Enum/String): Tracks the active phase (e.g., tutorial, planning\_phase, context\_phase, prompting\_phase, game\_over, victory).

**Local Calculation Logic:**

1. **Pre-API Penalties:** If hasBlueprint \== false, deduct 100 Mana. Deduct contextCost directly from manaReserves.  
2. **Post-API Penalty:** Final Deduction \= (10 \- api\_quality\_score) \* 40. Multiply by 2 if hasBlueprint \== false. Subtract from manaReserves.

## **7\. API Integration & System Prompt Schema**

The watsonx.ai platform will serve as the inference provider, acting as the "Game Master". When the user submits a prompt during the final phase, the frontend sends a REST API call to watsonx.ai.

**Endpoint Setup:**

* Requires a Project ID, Dallas Region Endpoint URL, and an IAM Access Token generated via an IBM Cloud API Key.

**System Prompt (Few-Shot Evaluation):**

The model must strictly output a JSON object to prevent parsing errors in the frontend.

JSON

// Required JSON Output Schema from watsonx.ai  
{  
  "quality\_score": 8,  
  "archmage\_feedback": "A finely crafted spell. Your blueprint anchored the artifact, and the constraints were iron-clad."  
}

---

### **The Watsonx.ai System Prompt**

Plaintext

You are the "Scrying Terminal Evaluator" for a gamified coding simulator. Your job is to evaluate the quality of a user's prompt (their "incantation") based on software engineering best practices. 

You must act as "Archmage Bob," a strict but wise senior software architect. 

EVALUATION CRITERIA:  
Score the user's prompt on a scale of 1 to 10 based on the following:  
\- Clarity (1-3 pts): Is the end goal highly specific, or vague?  
\- Constraints (1-4 pts): Did they define the tech stack, rules, UI requirements, or limitations?  
\- Context (1-3 pts): Did they mention a "Blueprint" (PRD), architectural patterns, or provide background information?

SCORING GUIDE:  
\- 1 to 3 (Chaotic Vibe-Coding): "Build me an app." "Make a trading portal." (Vague, no context, massive hallucination risk).  
\- 4 to 7 (Apprentice Level): "Build a React trading portal with a login page." (Has a goal and a stack, but missing deep constraints or logic).  
\- 8 to 10 (Architect Level): "Act as a senior frontend dev. Build a React authentication portal using Firebase. Refer to the attached Blueprint PRD for the user flow. Ensure the UI uses Tailwind CSS and includes error handling for invalid emails." (Perfect context, role, and constraints).

OUTPUT FORMAT:  
You must output ONLY a valid, raw JSON object. Do not include markdown formatting, code blocks, or conversational text. Use this exact schema:  
{  
  "quality\_score": \<integer between 1 and 10\>,  
  "archmage\_feedback": "\<A short, 1-2 sentence critique spoken in the character of Archmage Bob. Be sharp, witty, and reference magic, blueprints, or mana\>"  
}

\---  
EXAMPLES:

User Input: "Write a python script to scrape data."  
Output:  
{  
  "quality\_score": 2,  
  "archmage\_feedback": "A chaotic incantation\! Scrape what data? With what libraries? You are forcing the artifact to guess, burning your mana on a wild hallucination\!"  
}

User Input: "Create a Node.js Express API endpoint for user login. It should accept email and password, hash the password using bcrypt, and return a JWT token. Handle 400 errors for missing fields."  
Output:  
{  
  "quality\_score": 9,  
  "archmage\_feedback": "Exquisite craftsmanship\! You defined the exact spells, the security wards, and the error contingencies. The artifact will bend to your will with minimal mana drain."  
}

---

## **8\. UI / UX Specifications & "Game Feel" Mechanics**

The interface will follow a classic Visual Novel layout, optimized for a mobile form factor but accessible via web browser. Game feel will be achieved using native Flutter animation libraries rather than a heavyweight game engine.

### **Core Layout & Mechanics**

1. **Top HUD (Heads Up Display):**  
   * **Dynamic Mana Bar:** Implemented using AnimatedContainer or TweenAnimationBuilder. When manaReserves drop, the bar smoothly shrinks with a red visual flash.  
   * **Status Indicators:** Small icons indicating active buffs/debuffs (e.g., a "Blueprint" icon lights up).  
2. **Center Stage (The Environment):**  
   * **Backgrounds:** Dark with coding/programmer vibe  
   * **Character Entrances:** "Archmage Bob" portrait implemented with SlideTransition and FadeTransition to smoothly slide into the frame when speaking.  
3. **Bottom Action Panel:**  
   * **Typewriter Dialogue Box:** Narrative text and archmage\_feedback implemented using the animated\_text\_kit package to render text letter-by-letter, mimicking classic RPGs.  
   * **Interaction Area:** Toggles between choice buttons (ElevatedButton widgets) and The Scrying Terminal (a multiline TextField for the final API prompt).  
4. **Audio Feedback:**  
   * Integration of the audioplayers package to trigger low-latency SFX (e.g., a "magic swoosh" for spells, an "error buzz" for mana depletion).

## **9\. User Journey & Story Arc (MVP Scope)**

* **Act 1: The Reckless Apprentice (Tutorial):** The user is forced to cast a vague prompt ("Build me an app"). The API hallucinates, draining 800 Mana. Archmage Bob introduces himself and explains the cost of vague prompting.  
* **Act 2: The Architect's Path (Interactive Loop):**  
  * *Node 1 (Planning):* User chooses to draft a Master Blueprint (PRD) or skip it.  
  * *Node 2 (Context):* User chooses how much codebase to attach (Upload Everything vs. Relevant Files Only). Applies local contextCost.  
  * *Node 3 (Incantation):* User types a custom prompt to build an "Authentication Portal". The text is sent to watsonx.ai for the quality\_score evaluation.  
* **Act 3: Final Evaluation:**  
  * *Bad Ending:* manaReserves \<= 0. The terminal crashes. The user is shown how much real-world budget they burned.  
  * *Good Ending:* manaReserves \> 0. The user earns the title of Architect, with a stats screen showing API tokens saved by optimizing the prompt.

**Detailed Storyline:**

The script includes "Stage Directions" so you know exactly what is happening in the UI and the local state.

---

### **Global State Variables for this Playthrough:**

* manaReserves: 1000 (Starting value)  
* hasBlueprint: False  
* contextCost: 0

---

## **ACT 1: The Reckless Apprentice (Tutorial)**

**\[Scene Start\]**

*Background: A dimly lit cyber-tavern. A glowing, monolithic terminal hums in the center of the room.*

*UI: The manaReserves bar appears at the top: **\[Mana: 1000/1000\]***

**Narrator:** You are a novice coder with a dream: build the ultimate Global Trading App, get rich, and retire to the Silicon Mountains. Before you sits "The Scrying Terminal"—an ancient LLM artifact capable of writing reality itself. But magic comes at a cost.

**System Prompt (UI Text):** *Approach the terminal and cast your first spell.*

* **Choice 1:** \[Type a custom incantation\] *(Disabled for tutorial)*  
* **Choice 2:** \[Quick Cast\]: *"Build me a global trading app."*

**\[Player selects Choice 2\]**

**Terminal:** *\[Screen flashes violently red. Ominous rumbling sound effect.\]* "PROCESSING VAGUE DIRECTIVE. CONSTRUCTING ENTIRE INFRASTRUCTURE. IMPORTING 4,000 UNVERIFIED DEPENDENCIES..."

*STATE CHANGE:* manaReserves drops by 800\. **\[Mana: 200/1000\]**

**Narrator:** A Chaos Distortion\! The artifact hallucinated a massive, broken codebase. Your Mana is nearly depleted\!

**\[Enter Archmage Bob\]**

*Character Portrait: A wise, slightly glowing wizard wearing a modern developer hoodie.*

**Archmage Bob:** "Halt\! Cease the incantation\!"

**Archmage Bob:** "Foolish apprentice\! You cannot just walk up to the artifact and yell 'build me an app'\! You gave it no constraints. It had to guess your architecture, burning your precious Mana to hallucinate an answer\!"

**Archmage Bob:** "I am Archmage Bob. I am here to teach you the ways of the Architect. We shall start smaller. Your task: Build a simple 'User Authentication Portal'. And this time, we do it my way."

---

## **ACT 2: The Architect's Path (Core Loop)**

### **Node 2.1: The Planning Phase**

*Background: The Architect's Sanctum. Clean, bright, holographic blueprints floating around.*

**Archmage Bob:** "Before you touch the terminal, you must decide how to begin. A true Architect never casts blindly."

**Player Choices:**

* **Choice A \[The Vibe-Coder\]:** "I don't need a plan. I'll just figure it out while I type. Let's code\!"  
  * *Bob's Reaction:* "Arrogance\! The artifact will punish your lack of direction."  
  * *State Change:* hasBlueprint \= False. Penalty applied: \-100 Mana.  
* **Choice B \[The Architect\]:** "Let's draft a Master Blueprint (PRD) detailing the user flow and tech stack first."  
  * *Bob's Reaction:* "Excellent. A well-documented Blueprint anchors the artifact's magic, preventing it from wandering into the shadows of hallucination."  
  * *State Change:* hasBlueprint \= True.

### **Node 2.2: The Scroll of Memory (Context Window)**

**Archmage Bob:** "Now, you must attach the Scroll of Memory to your spell. The artifact needs context, but memory is heavy. What will you feed it?"

**Player Choices:**

* **Choice A \[The Data Dumper\]:** "Attach the entire ancient library\! (Upload the whole 10,000-file codebase)."  
  * *Bob's Reaction:* "Madness\! Forcing the artifact to read 10,000 scrolls for a simple login portal will drain your life force\!"  
  * *State Change:* contextCost \= 150 (Heavy mana penalty for wasted tokens).  
* **Choice B \[The Precision Caster\]:** "Attach only the auth schemas and the UI style guide."  
  * *Bob's Reaction:* "Precise. Elegant. You give it exactly what it needs, wasting no Sparks."  
  * *State Change:* contextCost \= 10 (Optimal token usage).  
* **Choice C \[The Amnesiac\]:** "Attach nothing. It should just know what to do."  
  * *Bob's Reaction:* "It is an artifact, not a mind reader\! Without context, it will invent its own rules."  
  * *State Change:* contextCost \= 50 (Penalty for hallucination risk).

*STATE UPDATE:* Subtract contextCost from manaReserves. UI animates the mana bar dropping accordingly.

### **Node 2.3: The Incantation (The API Call)**

**Archmage Bob:** "The moment of truth. Step up to the terminal. Type your spell to construct the Authentication Portal. Remember clarity, constraints, and your role\!"

**UI:** *A large text input box appears.* *(This is where the user types their prompt. When they hit "Cast Spell", the text is sent to the watsonx.ai API using the system prompt we designed earlier).*

**\[API PROCESSING SIMULATION\]**

* *If the player typed:* "Make a login page."  
  * *API Returns:* {"quality\_score": 3, "archmage\_feedback": "A pitiful whisper of a spell\! No tech stack? No error handling? The artifact built it in jQuery\!"}  
* *If the player typed:* "Act as a React dev. Build a Firebase login page with email/password, error handling, and Tailwind CSS."  
  * *API Returns:* {"quality\_score": 9, "archmage\_feedback": "Glorious\! The spell was bound with iron-clad constraints. The portal manifests perfectly\!"}

**\[Final Calculation\]**

* Mana Deduction \= (10 \- quality\_score) \* 40.  
* *If hasBlueprint \== False, add a 2x multiplier to the deduction.*  
* Subtract the final deduction from manaReserves.

---

## **ACT 3: The Final Evaluation (Endings)**

*The game checks the final manaReserves integer.*

### **Ending A: The Vibe-Coder's Demise (Bad Ending)**

*Condition:* manaReserves \<= 0\.

*Background:* The screen cracks. The terminal sparks and goes dark.

**Archmage Bob:** "You have drained the company's entire API budget\! The artifact has shut down to protect itself. Your chaotic vibe-coding has left us with half a broken app and a massive cloud computing bill."

**Narrator:** **GAME OVER.** *UI Stats Screen:*

* Mana Wasted: 1000/1000  
* Real-world equivalent: You burned $500 in API tokens by sending massive context windows and vague prompts that required 15 re-rolls.  
* **Lesson:** Unoptimized prompting scales terribly in enterprise environments.

### **Ending B: The Architect's Ascension (Good Ending)**

*Condition:* manaReserves \> 0\.

*Background:* A beautiful, sleek portal materializes in the holograms. Golden confetti falls.

**Archmage Bob:** "Behold\! The portal is stable, the code is clean, and your Mana reserves are still glowing brightly. You didn't just write a prompt; you engineered a solution."

**Narrator:** **VICTORY\! YOU ARE NOW AN ARCHITECT.**

*UI Stats Screen:*

* Mana Remaining: \[Display remaining mana\]  
* Real-world equivalent: By drafting a PRD, limiting your context window, and writing a highly constrained prompt, you completed the feature in a single shot. You saved the company thousands of Resource Units.  
* **Lesson:** AI is a tool, but *you* are the architect.