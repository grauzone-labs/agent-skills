# Add a Run Skill button to the session toolbar

This PR introduces a new button in the session toolbar that lets the user run a skill from the current session. I added the RunSkillButton component from packages/ui to the SessionToolbar in apps/example/src/routes/session.tsx. When the user clicks it, the toolbar opens the skill picker and the chosen skill is sent to the daemon as an expanded prompt. I also added a SkillResultCard to the SessionTimeline so the result shows up inline.

I tested it manually and it works. Please review.
