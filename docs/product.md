# Nombres à l’Oreille

## Product summary

Nombres à l’Oreille is a minimal mobile app that helps beginners recognize spoken French numbers more quickly. The app says a random number, the learner enters the digits they heard, and the app immediately checks the answer.

The experience is intentionally narrow: choose a range, start practicing, and continue for as long as desired. It works entirely offline and collects no user data.

## Problem

Beginner French learners can often read written numbers but struggle to understand the same numbers when spoken. Translating the sound into digits takes too long, especially for forms such as *soixante-dix*, *quatre-vingts*, and *quatre-vingt-dix-neuf*.

Learners need a fast, repeatable listening exercise focused only on building this recognition skill.

## Target audience

- Beginner learners of French
- People who can read basic French numbers but cannot yet recognize them quickly by ear
- Learners who want a private, distraction-free practice tool

## Product goals

- Improve recognition of spoken French whole numbers.
- Make starting a practice session nearly effortless.
- Give clear, immediate feedback after every answer.
- Allow unlimited repetition without scores, pressure, or session limits.
- Keep the app private, free, and fully usable offline.

## Non-goals

- Teaching number spelling, grammar, or pronunciation
- Supporting decimals, fractions, ordinals, or negative numbers
- Structured lessons or a fixed curriculum
- Timed exercises, finite quizzes, scores, streaks, or progress history
- Accounts, cloud synchronization, social features, leaderboards, or notifications
- Advertising, subscriptions, purchases, or other monetization
- Supporting French variants other than standard France French

## Supported platforms

- iOS
- Android

## Language and content

- All interface copy is in French.
- Spoken content uses standard France French pronunciation.
- The app supports whole numbers from `0` through `999`, inclusive.
- Speech is delivered at one natural, normal speed.
- Every spoken number and all required app behavior must be available offline.

## Core user journey

1. The user opens the app.
2. The app displays the range selector with `60` as the lower bound and `99` as the upper bound.
3. The user optionally changes either bound and taps **Commencer**.
4. The practice screen opens and automatically speaks a random number within the selected range.
5. The user types the number using the phone’s native numeric keyboard.
6. The user taps **Valider**.
7. If the answer is correct, the app immediately selects and speaks the next random number.
8. If the answer is incorrect, the app displays the correct digits and waits for the user to tap **Suivant**.
9. Practice continues indefinitely until the user leaves the practice screen.

## Functional requirements

### Range selection

- Provide two numeric fields labeled **De** and **À**.
- Use `60` and `99` as the defaults on every app launch.
- Accept only whole numbers from `0` through `999`.
- Require the lower bound to be less than or equal to the upper bound.
- Keep **Commencer** disabled while either value is missing or invalid.
- Show a short inline French error when the range is invalid.
- Do not remember a previously selected range after the app is closed.

### Number selection

- Select numbers randomly from the chosen range, including both endpoints.
- If the range contains more than one number, do not repeat the same number twice consecutively.
- If both bounds are equal, repeatedly use that single number.

### Listening and replay

- Automatically play the spoken number when each question begins.
- Provide a clearly visible **Réécouter** control.
- Allow unlimited replays before an answer is submitted.
- Keep replay at the same normal speech speed.
- Do not reveal the number in text before submission.

### Answer entry

- Use one numeric answer field and the platform’s native numeric keyboard.
- Keep a visible **Valider** button so submission does not depend on a keyboard action key.
- Accept digits only.
- Ignore leading zeros when checking an otherwise valid answer; for example, `072` is accepted as `72`.
- Keep **Valider** disabled when the answer field is empty.

### Correct answer behavior

- Treat an exact numeric match as correct.
- Immediately clear the answer field and begin the next question.
- Automatically speak the next number.
- Do not require a **Next** action.
- Do not update or display scores, streaks, or other statistics.

### Incorrect answer behavior

- Stop answer entry for the current question.
- Display a clear message such as **La bonne réponse était 72**.
- Provide a **Suivant** button.
- Begin and automatically speak a new question only after **Suivant** is tapped.

### Leaving practice

- Provide a standard back action that returns to the range selector.
- Returning to the selector resets its fields to the product defaults, `60` and `99`.
- No confirmation is needed because no progress or user data is stored.

## Screens

### 1. Range selector

Purpose: let the user define the practice range and start.

Required elements:

- App name: **Nombres à l’Oreille**
- **De** numeric field
- **À** numeric field
- Inline validation message when needed
- Primary **Commencer** button

### 2. Practice — awaiting answer

Purpose: let the user listen, replay, and submit the digits they heard.

Required elements:

- Back control
- **Réécouter** control with an audio/speaker icon
- Numeric answer field
- Primary **Valider** button

### 3. Practice — incorrect answer

Purpose: clearly correct the learner without adding pressure.

Required elements:

- Incorrect state indicator
- Correct answer in large, legible digits
- Primary **Suivant** button

This is a state of the practice screen, not a separate navigation destination.

## Design direction

- Minimal, neutral, and calm
- Generous spacing and a strong visual hierarchy
- High contrast and highly legible numbers
- One restrained accent color for primary controls and focus states
- No decorative illustrations, gamification, celebratory effects, or dense UI
- Use native platform behavior where it improves familiarity, especially for navigation and keyboard input

## Accessibility

- Add accessible labels to replay, back, and submission controls.
- Do not communicate correct or incorrect states through color alone.
- Support platform text scaling without clipping essential controls or digits.
- Maintain accessible color contrast.
- Ensure the full flow is usable with VoiceOver and TalkBack.
- Do not automatically focus the answer field until the spoken number finishes, so keyboard and screen-reader changes do not obscure the audio cue.

## Privacy and connectivity

- Make no network requests during normal use.
- Do not require an account or sign-in.
- Do not collect analytics, diagnostics, identifiers, or behavioral data.
- Do not store practice history, answers, scores, or selected ranges.
- Package or generate speech on-device in a way that guarantees offline availability.

## Release acceptance criteria

The first release is complete when:

- A user can select any valid inclusive range between `0` and `999`.
- Invalid and incomplete ranges cannot start a session.
- Every supported number can be spoken clearly in standard France French without a network connection.
- Each question starts by automatically playing its number.
- The user can replay a number any number of times before answering.
- Correct answers proceed immediately to a new spoken number.
- Incorrect answers display the correct digits and wait for **Suivant**.
- Practice can continue indefinitely without accumulating progress or user data.
- Closing and reopening the app restores the default range of `60–99`.
- The complete flow works on both iOS and Android and remains functional in airplane mode.

## Future considerations

These ideas are explicitly outside the first release but may be reconsidered later:

- Additional number ranges above `999`
- Alternative French regional variants
- Adjustable speech speed
- Targeted review of difficult numbers
- Optional progress summaries
- Interface language selection
