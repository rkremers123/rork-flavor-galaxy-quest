# 🎯 Rork Sprint Brief: PHASE 2-5 (Remaining Work — Color/Food Group UI Integration)

## ✅ Foundation Complete
Rork has successfully implemented:
- ✅ FoodItem model with `color: String` + `foodGroup: String`
- ✅ All 62+ foods populated with color + foodGroup values
- ✅ Goal food selection UI (Step 3) displays colors + food groups
- ✅ Goal food data stored in user profile

**Foundation is solid. Now let's build the UI layers on top.**

---

## What We're Building NOW (5-6 Hour Sprint)

Using the complete color + foodGroup data, add UI/features across 4 remaining areas:

1. **Food Logging Screen** — Show color + groups during SOS phase tracking
2. **Analytics Tab** — Visualize dietary diversity patterns
3. **Suggest Tab** — Intelligent bridge food recommendations
4. **Bug Fix** — Settings back button navigation

---

## PHASE 2: Food Logging Screen (2 hours)
**File:** RORK-FOOD-LOGGING-COLOR-FOODGROUP-DISPLAY.md

### What to Build
- [ ] Pre-logging screen shows food summary: color emoji + foodGroup tag
- [ ] Display full sensory profile (👅 Soft | 🍍 Sweet | 🌡️ Cold | 👃 Mild)
- [ ] Visualize phase progress (LOOK → TOUCH → SMELL → LICK → TASTE)
- [ ] Show "Why This Food" (goal food or bridge from safe food)
- [ ] Display similar foods (same color/group) as reference
- [ ] Streak progress + milestones
- [ ] Create food profile modal (tap food name)
- [ ] Add celebration messages on phase progression
- [ ] Color-code goal foods vs. safe foods in all views

### Example Display
```
Logging: 🍌 Banana
━━━━━━━━━━━━━━━━━━━
🟡 Yellow | Fruit
Soft | Sweet | Cold | Mild

Phase Progress:
✓ LOOK (Feb 21) → ✓ TOUCH (Feb 25) → ◯ SMELL → ◯ LICK → ◯ TASTE

[Log SMELL] [Log LICK] [Log TASTE]
```

### Success Criteria
- ✅ Color + foodGroup visible on all logging screens
- ✅ Sensory profile easy to understand (emoji-based)
- ✅ Phase visualizer clear and motivating
- ✅ No performance impact

---

## PHASE 3: Analytics Tab (2.5 hours)
**File:** RORK-ANALYTICS-COLOR-FOODGROUP-INTEGRATION.md

### What to Build
- [ ] Add "Food Group Distribution" card
  - Bar chart showing count + % per group
  - Week/Month toggle
  - Alert if missing entire food group
- [ ] Add "Color Variety" card with gamification
  - Show all 9 colors tracked
  - Display "8/9 colors unlocked"
  - "Rainbow Week" achievement
- [ ] Update calendar view to show colors + food groups per day
- [ ] Create monthly trend graph (food group progression)
- [ ] Implement regression detection alerts
- [ ] Build "Strength" insights section
- [ ] Add color preference analysis

### Example Display
```
Food Groups This Week
━━━━━━━━━━━━━━━━━━━━━
Fruit      ████████░░  8 foods (32%)
Protein    ██████░░░░  6 foods (24%)
Grain      ████████░░  8 foods (32%)
Dairy      ██░░░░░░░░  2 foods (8%)
Vegetable  ██░░░░░░░░  2 foods (8%)

Color Variety: 8/9 colors unlocked 🌈
```

### Success Criteria
- ✅ Food group distribution visible at a glance
- ✅ Color variety gamified and motivating
- ✅ Regression alerts work correctly
- ✅ No performance lag with large datasets

---

## PHASE 4: Suggest Tab (2 hours)
**File:** RORK-SUGGEST-COLOR-FOODGROUP-BRIDGE-FOODS.md

### What to Build
- [ ] Build bridge food matching algorithm
  - Query safe foods
  - Calculate sensory distance
  - Rank by risk level (Low/Medium/High)
- [ ] Display "Try Next" section (top 3-5 recommendations)
- [ ] Show why each food is recommended (sensory match explanation)
- [ ] Add "By Color" progression section
- [ ] Add "By Food Group" diversity tracker
- [ ] Implement confidence level indicators
- [ ] Ensure recommendations update daily

### Example Display
```
Try Next
━━━━━━━━━━━━━━━━━━━━

#1  🍓 Strawberry (Fruit)
    Why: Same soft + sweet as Applesauce
    Risk: LOW
    [Log Food]

#2  🥤 Milk (Dairy)
    Why: Similar temp + mild aroma to Yogurt
    Risk: MEDIUM
    [Log Food]
```

### Success Criteria
- ✅ Recommendations are personalized, not generic
- ✅ Algorithm prioritizes sensory similarity
- ✅ Risk levels appropriate and helpful
- ✅ Works for 1-50+ safe foods

---

## PHASE 5: Bug Fix + Testing (1 hour)
**File:** RORK-COMPLETE-SPRINT-BRIEF.md

### What to Fix
- [ ] **Settings Back Button:** In Command Center, tapping "< Nova's Journey" on Settings tab now works
- [ ] Test back navigation from all tabs (Analytics → Settings, Suggest → Settings)
- [ ] Verify no crashes on tab transitions
- [ ] Test on both iOS + Android

### Success Criteria
- ✅ Back button works from all tabs
- ✅ No navigation crashes
- ✅ Navigates to correct explorer detail screen

---

## Implementation Sequence

1. **Food Logging Screen** (PHASE 2) — Build display layer
2. **Analytics Tab** (PHASE 3) — Build insights layer
3. **Suggest Tab** (PHASE 4) — Build recommendation engine
4. **Bug Fix** (PHASE 5) — Polish navigation

---

## File Reference (Everything You Need)

**Foundation (Already Complete):**
- RORK-FOOD-DATABASE-COLOR-FOODGROUP-UPDATE.md ✓
- RORK-COLOR-FOODGROUP-IMPLEMENTATION-BRIEF.md ✓
- RORK-ONBOARDING-GOAL-FOOD-COLOR-FOODGROUP.md ✓

**New Work (This Sprint):**
- RORK-FOOD-LOGGING-COLOR-FOODGROUP-DISPLAY.md (PHASE 2)
- RORK-ANALYTICS-COLOR-FOODGROUP-INTEGRATION.md (PHASE 3)
- RORK-SUGGEST-COLOR-FOODGROUP-BRIDGE-FOODS.md (PHASE 4)

---

## Timeline
**Total: 5-6 hours** (all tasks, one sprint)
- Food Logging: 2 hours
- Analytics: 2.5 hours
- Suggest: 2 hours
- Bug Fix + Testing: 1 hour

**DO NOT SPLIT THIS WORK. Complete all in one sprint.**

---

## Success Criteria (All Must Pass)

✅ **Food Logging**
- Color + foodGroup visible on all screens
- Sensory profile emoji-based and clear
- Phase progress visualizer intuitive
- No performance impact

✅ **Analytics**
- Food group distribution visible at glance
- Color variety gamified
- Regression alerts work
- Insights personalized

✅ **Suggest**
- Recommendations personalized
- Algorithm uses sensory matching
- Risk levels appropriate
- Works with various dietary profiles

✅ **Bug Fix**
- Back button works from all tabs
- No crashes
- iOS + Android tested

---

## Questions?

1. Timeline ok? (5-6 hours)
2. Any blockers from foundation work?
3. Want to start with Food Logging?
4. Need clarification on any phase?

---

**Ready to start PHASE 2?** 🚀
