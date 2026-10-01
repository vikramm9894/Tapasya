// Tapasya Web Application State & Logic

const state = {
  dayNumber: 12,
  totalDays: 90,
  streak: 7,
  totalXp: 2450,
  isBareMin: false,
  checkedIn: false,
  
  nonNegotiables: [
    { id: '1', title: 'Deep Study: Data Structures', cue: 'Chai ke baad 1 ghanta', difficulty: 3, completed: true },
    { id: '2', title: 'Morning 45-min Gym / Running', cue: 'Uthte hi workout clothes pehno', difficulty: 3, completed: false },
    { id: '3', title: 'Read 15 Pages of Book', cue: 'Dinner ke baad bed par', difficulty: 2, completed: false }
  ],

  bonusHabits: [
    { id: '4', title: '10-min Mindfulness Meditation', cue: 'Subah uthte hi', difficulty: 1, completed: true },
    { id: '5', title: 'Zero Sugar Today', cue: 'Din bhar discipline', difficulty: 2, completed: false }
  ],

  timerDuration: 25 * 60,
  timerRemaining: 25 * 60,
  timerInterval: null,
  timerRunning: false
};

function calculateDailyScore() {
  const nnDone = state.nonNegotiables.filter(h => h.completed).length;
  const nnTotal = state.nonNegotiables.length;
  const bonusDone = state.bonusHabits.filter(h => h.completed).length;
  const bonusTotal = state.bonusHabits.length;

  const nnRatio = nnTotal === 0 ? 0 : nnDone / nnTotal;
  const bonusRatio = bonusTotal === 0 ? 0 : bonusDone / bonusTotal;

  const raw = (0.65 * nnRatio) + (0.25 * bonusRatio) + (state.checkedIn ? 0.10 : 0.0);
  return Math.min(100, Math.max(0, Math.round(raw * 100)));
}

function calculateHabitXp(difficulty, isNonNeg, isBareMin) {
  const baseMap = { 1: 10, 2: 20, 3: 30 };
  let xp = baseMap[difficulty] || 20;
  if (isNonNeg) xp *= 1.5;
  if (isBareMin) xp *= 0.5;
  return Math.round(xp);
}

function getLevelData(totalXp) {
  let level = 1;
  let left = totalXp;
  const xpToNext = (lvl) => 500 + 150 * (lvl - 1);

  while (left >= xpToNext(level)) {
    left -= xpToNext(level);
    level++;
  }

  let title = 'Frost Rookie';
  if (level >= 20) title = 'Tapasvi (तपस्वी)';
  else if (level >= 15) title = 'Blizzard Master';
  else if (level >= 10) title = 'Snow Warrior';
  else if (level >= 5) title = 'Ice Walker';

  return { level, into: left, need: xpToNext(level), title };
}

const scoreDisplay = document.getElementById('scoreDisplay');
const scoreBar = document.getElementById('scoreBar');
const nnListEl = document.getElementById('nonNegotiablesList');
const bonusListEl = document.getElementById('bonusHabitsList');
const nnProgressText = document.getElementById('nnProgressText');
const bonusProgressText = document.getElementById('bonusProgressText');
const streakCountEl = document.getElementById('streakCount');
const headerXpEl = document.getElementById('headerXp');
const bareMinToggle = document.getElementById('bareMinToggle');
const modeTitleEl = document.getElementById('modeTitle');
const modeBadgeEl = document.getElementById('modeBadge');

function updateUI() {
  const score = calculateDailyScore();
  scoreDisplay.textContent = score;
  
  const offset = 264 - (score / 100) * 264;
  scoreBar.style.strokeDashoffset = offset;
  scoreBar.style.stroke = score >= 70 ? 'var(--cyan-primary)' : 'var(--gold-accent)';

  streakCountEl.textContent = state.streak;
  headerXpEl.textContent = state.totalXp.toLocaleString();

  const nnDone = state.nonNegotiables.filter(h => h.completed).length;
  nnProgressText.textContent = `${nnDone}/${state.nonNegotiables.length}`;
  renderHabitsList(nnListEl, state.nonNegotiables, true);

  const bonusDone = state.bonusHabits.filter(h => h.completed).length;
  bonusProgressText.textContent = `${bonusDone}/${state.bonusHabits.length}`;
  renderHabitsList(bonusListEl, state.bonusHabits, false);

  const reviewTitle = document.getElementById('reviewTitle');
  const reviewSub = document.getElementById('reviewSub');
  const openReviewBtn = document.getElementById('openReviewBtn');
  if (state.checkedIn) {
    reviewTitle.textContent = 'Day Locked & Finalized ✓';
    reviewSub.textContent = 'Check-in bonus +10% recorded in today\'s score.';
    openReviewBtn.textContent = 'View Log';
  } else {
    reviewTitle.textContent = 'Evening Reflection & Lock-in';
    reviewSub.textContent = 'Log sleep, mood, and win to get +10% daily score bonus.';
    openReviewBtn.textContent = 'Review';
  }

  const lvlInfo = getLevelData(state.totalXp);
  document.getElementById('profileLvlNum').textContent = lvlInfo.level;
  document.getElementById('profileLvlTitle').textContent = lvlInfo.title;
  document.getElementById('profileCurrentXp').textContent = state.totalXp.toLocaleString();
  document.getElementById('profileNeedXp').textContent = `${lvlInfo.need - lvlInfo.into} XP to Level ${lvlInfo.level + 1}`;
  document.getElementById('profileXpFill').style.width = `${(lvlInfo.into / lvlInfo.need) * 100}%`;
}

function renderHabitsList(container, habits, isNonNeg) {
  container.innerHTML = '';
  habits.forEach(habit => {
    const card = document.createElement('div');
    card.className = `habit-card ${habit.completed ? 'done' : ''}`;
    card.innerHTML = `
      <div class="habit-details">
        <div class="habit-name">${habit.title}</div>
        <div class="habit-cue">📌 ${habit.cue}</div>
      </div>
      <div class="habit-checkbox"></div>
    `;

    card.addEventListener('click', () => {
      habit.completed = !habit.completed;
      if (habit.completed) {
        const earned = calculateHabitXp(habit.difficulty, isNonNeg, state.isBareMin);
        state.totalXp += earned;
        showToast(`+${earned} XP earned! ⚡`);
      }
      updateUI();
    });

    container.appendChild(card);
  });
}

function showToast(message) {
  const container = document.getElementById('toastContainer');
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.innerHTML = `<span>🔥</span> ${message}`;
  container.appendChild(toast);
  setTimeout(() => toast.remove(), 1400);
}

function buildJourneyMatrix() {
  const matrix = document.getElementById('journeyMatrixGrid');
  matrix.innerHTML = '';
  for (let i = 1; i <= 90; i++) {
    const cell = document.createElement('div');
    cell.className = 'matrix-cell';
    cell.textContent = i;
    cell.style.cursor = 'pointer';
    if (i < state.dayNumber) {
      cell.classList.add('done');
    } else if (i === state.dayNumber) {
      cell.classList.add('today');
    }

    cell.addEventListener('click', () => {
      const isPast = i < state.dayNumber;
      const isCurrent = i === state.dayNumber;
      const score = isCurrent ? calculateDailyScore() : (isPast ? 85 : 0);
      const status = isCurrent ? 'Today (In Progress)' : (isPast ? 'Completed • 100% Non-Negotiables' : 'Upcoming Day');

      document.getElementById('detailDayTitle').textContent = `Day ${i} of 90`;
      document.getElementById('detailDayStatus').textContent = status;
      document.getElementById('detailDayScore').textContent = `${score}/100`;

      document.getElementById('dayDetailModal').classList.add('show');
    });

    matrix.appendChild(cell);
  }
}

document.getElementById('closeDayDetailBtn').addEventListener('click', () => {
  document.getElementById('dayDetailModal').classList.remove('show');
});

const timerDigits = document.getElementById('timerDigits');
const timerDialBar = document.getElementById('timerDialBar');
const toggleTimerBtn = document.getElementById('toggleTimerBtn');
const resetTimerBtn = document.getElementById('resetTimerBtn');
const timerStateLabel = document.getElementById('timerStateLabel');

function updateTimerDisplay() {
  const m = Math.floor(state.timerRemaining / 60).toString().padStart(2, '0');
  const s = (state.timerRemaining % 60).toString().padStart(2, '0');
  timerDigits.textContent = `${m}:${s}`;

  const progress = state.timerRemaining / state.timerDuration;
  timerDialBar.style.strokeDashoffset = 553 * (1 - progress);
}

toggleTimerBtn.addEventListener('click', () => {
  if (state.timerRunning) {
    clearInterval(state.timerInterval);
    state.timerRunning = false;
    toggleTimerBtn.textContent = 'Resume Focus';
    timerStateLabel.textContent = 'PAUSED';
  } else {
    state.timerRunning = true;
    toggleTimerBtn.textContent = 'Pause';
    timerStateLabel.textContent = 'FOCUSING';
    state.timerInterval = setInterval(() => {
      if (state.timerRemaining > 0) {
        state.timerRemaining--;
        updateTimerDisplay();
      } else {
        clearInterval(state.timerInterval);
        state.timerRunning = false;
        toggleTimerBtn.textContent = 'Start Focus';
        timerStateLabel.textContent = 'COMPLETED';
        state.timerRemaining = state.timerDuration;
        showToast('25m Focus Logged! +30 XP 🎯');
        state.totalXp += 30;
        updateUI();
      }
    }, 1000);
  }
});

resetTimerBtn.addEventListener('click', () => {
  clearInterval(state.timerInterval);
  state.timerRunning = false;
  state.timerRemaining = state.timerDuration;
  toggleTimerBtn.textContent = 'Start Focus';
  timerStateLabel.textContent = 'READY';
  updateTimerDisplay();
});

bareMinToggle.addEventListener('change', (e) => {
  state.isBareMin = e.target.checked;
  if (state.isBareMin) {
    modeTitleEl.textContent = 'Bare Minimum Mode';
    modeBadgeEl.textContent = 'Active (50% XP)';
    modeBadgeEl.style.background = 'rgba(255, 145, 0, 0.2)';
    showToast('Bare Min Mode Activated: Streak Protected 🛡️');
  } else {
    modeTitleEl.textContent = 'Daily Mission';
    modeBadgeEl.textContent = '50% XP';
    modeBadgeEl.style.background = 'rgba(255, 145, 0, 0.15)';
  }
  updateUI();
});

document.querySelectorAll('.nav-item').forEach(button => {
  button.addEventListener('click', () => {
    document.querySelectorAll('.nav-item').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));

    button.classList.add('active');
    const tabId = button.getAttribute('data-tab');
    document.getElementById(tabId).classList.add('active');
  });
});

const reviewModal = document.getElementById('reviewModal');
const openReviewBtn = document.getElementById('openReviewBtn');
const closeReviewBtn = document.getElementById('closeReviewBtn');
const saveReviewBtn = document.getElementById('saveReviewBtn');

openReviewBtn.addEventListener('click', () => reviewModal.classList.add('show'));
closeReviewBtn.addEventListener('click', () => reviewModal.classList.remove('show'));

document.getElementById('moodSlider').addEventListener('input', (e) => document.getElementById('moodVal').textContent = e.target.value);
document.getElementById('energySlider').addEventListener('input', (e) => document.getElementById('energyVal').textContent = e.target.value);
document.getElementById('focusSlider').addEventListener('input', (e) => document.getElementById('focusVal').textContent = e.target.value);
document.getElementById('sleepSlider').addEventListener('input', (e) => document.getElementById('sleepVal').textContent = `${e.target.value}h`);

saveReviewBtn.addEventListener('click', () => {
  state.checkedIn = true;
  state.totalXp += 20;
  reviewModal.classList.remove('show');
  showToast('Day Locked! +10% Score Bonus & +20 XP 🌙');
  updateUI();
});

const recapModal = document.getElementById('recapModal');
document.getElementById('viewRecapBtn').addEventListener('click', () => recapModal.classList.add('show'));
document.getElementById('closeRecapBtn').addEventListener('click', () => recapModal.classList.remove('show'));

// Create Habit Modal Handlers
const addHabitModal = document.getElementById('addHabitModal');
document.getElementById('openAddHabitBtn').addEventListener('click', () => addHabitModal.classList.add('show'));
document.getElementById('closeAddHabitBtn').addEventListener('click', () => addHabitModal.classList.remove('show'));

document.getElementById('saveNewHabitBtn').addEventListener('click', () => {
  const name = document.getElementById('newHabitName').value.trim();
  if (!name) {
    alert('Please enter a habit name');
    return;
  }
  const category = document.getElementById('newHabitCategory').value;
  const cue = document.getElementById('newHabitCue').value.trim() || 'Daily habit';
  const difficulty = parseInt(document.getElementById('newHabitDifficulty').value, 10);

  state.bonusHabits.push({
    id: 'h_' + Date.now(),
    title: name,
    cue: cue,
    difficulty: difficulty,
    completed: false
  });

  addHabitModal.classList.remove('show');
  document.getElementById('newHabitName').value = '';
  document.getElementById('newHabitCue').value = '';
  showToast(`New habit "${name}" created! 🔥`);
  updateUI();
});

// Onboarding Modal Handlers
const onboardingModal = document.getElementById('onboardingModal');
document.getElementById('openOnboardingBtn').addEventListener('click', () => {
  goToObStep(1);
  onboardingModal.classList.add('show');
});
document.getElementById('closeOnboardingBtn').addEventListener('click', () => onboardingModal.classList.remove('show'));

window.goToObStep = function(step) {
  document.getElementById('obStep1').style.display = 'none';
  document.getElementById('obStep2').style.display = 'none';
  document.getElementById('obStep3').style.display = 'none';
  document.getElementById('obStep4').style.display = 'none';

  document.getElementById('obStep' + step).style.display = 'block';
  const headings = {
    1: 'Step 1: ॐ Tapasya Philosophy',
    2: 'Step 2: "Why" Anchor & Letter',
    3: 'Step 3: Core 3-5 Habits',
    4: 'Step 4: Journey Commitment'
  };
  document.getElementById('obStepHeading').textContent = headings[step];
};

document.getElementById('finishOnboardingBtn').addEventListener('click', () => {
  onboardingModal.classList.remove('show');
  showToast('90-Day Tapasya Activated! Welcome, Vikram! 🔥');
});

// --- EXAM MODE LOGIC ---
const examState = {
  daysLeft: 14,
  topics: [
    { id: 'et1', title: 'Binary Trees, BFS & DFS Traversals', done: true },
    { id: 'et2', title: 'Dynamic Programming (Knapsack & LCS)', done: true },
    { id: 'et3', title: 'Graph Shortest Path & Dijkstra', done: false },
    { id: 'et4', title: 'B-Trees & Database B+ Indexing', done: false },
    { id: 'et5', title: 'Operating Systems: Semaphores & Deadlock', done: false }
  ]
};

function updateExamModeUI() {
  const total = examState.topics.length;
  const done = examState.topics.filter(t => t.done).length;
  const remaining = total - done;
  const velocity = examState.daysLeft > 0 ? (remaining / examState.daysLeft).toFixed(1) : 0;
  const pct = total > 0 ? Math.round((done / total) * 100) : 100;

  // Update pills on Today & Me tabs
  const todayVelEl = document.getElementById('todayExamVel');
  if (todayVelEl) todayVelEl.textContent = velocity;
  const meVelEl = document.getElementById('meExamVel');
  if (meVelEl) meVelEl.textContent = velocity;

  // Modal elements
  const progressCountEl = document.getElementById('examProgressCount');
  if (progressCountEl) progressCountEl.textContent = `${done} of ${total} topics completed (${pct}%)`;
  const progressBarEl = document.getElementById('examProgressBar');
  if (progressBarEl) progressBarEl.style.width = `${pct}%`;
  const rateEl = document.getElementById('examVelocityRate');
  if (rateEl) rateEl.textContent = velocity;

  const badgeEl = document.getElementById('examStatusBadge');
  if (badgeEl) {
    if (velocity <= 1.0) {
      badgeEl.textContent = 'On Track';
      badgeEl.style.color = 'var(--cyan-primary)';
      badgeEl.style.background = 'rgba(0,229,255,0.15)';
    } else if (velocity <= 2.5) {
      badgeEl.textContent = 'Steady Focus';
      badgeEl.style.color = '#FFB300';
      badgeEl.style.background = 'rgba(255,179,0,0.15)';
    } else {
      badgeEl.textContent = 'Accelerate!';
      badgeEl.style.color = 'var(--orange-flame)';
      badgeEl.style.background = 'rgba(255,61,0,0.15)';
    }
  }

  // Render topic list
  const listEl = document.getElementById('examTopicsList');
  if (listEl) {
    listEl.innerHTML = '';
    examState.topics.forEach(t => {
      const row = document.createElement('div');
      row.style.cssText = 'background: var(--bg-card); border: 1px solid var(--border-color); padding: 10px 12px; border-radius: 10px; display: flex; align-items: center; justify-content: space-between; font-size: 13px;';
      row.innerHTML = `
        <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; flex: 1;">
          <input type="checkbox" ${t.done ? 'checked' : ''} style="width: 16px; height: 16px; accent-color: var(--cyan-primary);">
          <span style="${t.done ? 'text-decoration: line-through; color: var(--text-muted);' : 'color: var(--text-primary); font-weight: 500;'}">${t.title}</span>
        </label>
      `;
      row.querySelector('input').addEventListener('change', (e) => {
        t.done = e.target.checked;
        updateExamModeUI();
      });
      listEl.appendChild(row);
    });
  }
}

// Add Topic
const newTopicInput = document.getElementById('newTopicInput');
const addNewTopicBtn = document.getElementById('addNewTopicBtn');
if (addNewTopicBtn && newTopicInput) {
  addNewTopicBtn.addEventListener('click', () => {
    const val = newTopicInput.value.trim();
    if (val) {
      examState.topics.push({ id: 'et_' + Date.now(), title: val, done: false });
      newTopicInput.value = '';
      updateExamModeUI();
      showToast(`Added topic: "${val}"`);
    }
  });
}

// --- BOSS BATTLE LOGIC ---
const bossState = {
  maxHp: 15,
  hp: 6,
  defeated: false
};

function updateBossUI() {
  const hpBadge = document.getElementById('bossHpBadge');
  const hpBar = document.getElementById('bossHpBar');
  const bossEmoji = document.getElementById('bossEmoji');
  const bossNameTitle = document.getElementById('bossNameTitle');
  const attackBtn = document.getElementById('attackBossBtn');

  const todayHp = document.getElementById('todayBossHpText');
  const meHp = document.getElementById('meBossHpText');

  if (todayHp) todayHp.textContent = bossState.defeated ? 'Defeated' : bossState.hp;
  if (meHp) meHp.textContent = bossState.defeated ? 'Defeated' : bossState.hp;

  if (bossState.defeated) {
    if (hpBadge) { hpBadge.textContent = 'VICTORY'; hpBadge.style.color = '#00E676'; }
    if (hpBar) { hpBar.style.width = '0%'; hpBar.style.background = '#00E676'; }
    if (bossEmoji) bossEmoji.textContent = '🏆';
    if (bossNameTitle) bossNameTitle.textContent = 'Titan Vanquished!';
    if (attackBtn) { attackBtn.disabled = true; attackBtn.textContent = 'Titan Vanquished! (+150 XP Awarded)'; }
  } else {
    if (hpBadge) hpBadge.textContent = `${bossState.hp} / ${bossState.maxHp} HP`;
    if (hpBar) hpBar.style.width = `${Math.round((bossState.hp / bossState.maxHp) * 100)}%`;
  }
}

const attackBossBtn = document.getElementById('attackBossBtn');
if (attackBossBtn) {
  attackBossBtn.addEventListener('click', () => {
    if (bossState.hp > 1) {
      bossState.hp -= 1;
      showToast('⚔️ Struck Titan for 1 HP damage!');
    } else {
      bossState.hp = 0;
      bossState.defeated = true;
      state.totalXp += 150;
      showToast('🏆 TITAN DEFEATED! +150 XP Awarded!');
      updateUI();
    }
    updateBossUI();
  });
}

// --- EXPORT BACKUP FUNCTION ---
function exportOfflineBackup() {
  const backupData = {
    app: 'Tapasya',
    version: '1.0.0',
    exported_at: new Date().toISOString(),
    user: 'Vikram Nishad',
    state: {
      day: state.dayNumber,
      totalDays: state.totalDays,
      streak: state.streak,
      totalXp: state.totalXp,
      habits: [...state.nonNegotiables, ...state.bonusHabits],
      examState: examState,
      bossState: bossState
    }
  };

  const blob = new Blob([JSON.stringify(backupData, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `tapasya_backup_${new Date().toISOString().substring(0, 10)}.json`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  showToast('💾 Offline JSON backup downloaded!');
}

// Event Listeners for Export
const exportBackupBtn = document.getElementById('exportBackupBtn');
if (exportBackupBtn) exportBackupBtn.addEventListener('click', exportOfflineBackup);
const exportBackupDirectBtn = document.getElementById('exportBackupDirectBtn');
if (exportBackupDirectBtn) exportBackupDirectBtn.addEventListener('click', exportOfflineBackup);

// --- MODAL CONTROLLERS ---
const examModal = document.getElementById('examModal');
const closeExamBtn = document.getElementById('closeExamBtn');
if (closeExamBtn && examModal) closeExamBtn.addEventListener('click', () => examModal.classList.remove('show'));

const openExamTodayBtn = document.getElementById('openExamTodayBtn');
if (openExamTodayBtn && examModal) openExamTodayBtn.addEventListener('click', () => { updateExamModeUI(); examModal.classList.add('show'); });
const openExamMeBtn = document.getElementById('openExamMeBtn');
if (openExamMeBtn && examModal) openExamMeBtn.addEventListener('click', () => { updateExamModeUI(); examModal.classList.add('show'); });

const challengesModal = document.getElementById('challengesModal');
const closeChallengesBtn = document.getElementById('closeChallengesBtn');
if (closeChallengesBtn && challengesModal) closeChallengesBtn.addEventListener('click', () => challengesModal.classList.remove('show'));

const openChallengesTodayBtn = document.getElementById('openChallengesTodayBtn');
if (openChallengesTodayBtn && challengesModal) openChallengesTodayBtn.addEventListener('click', () => { updateBossUI(); challengesModal.classList.add('show'); });
const openChallengesMeBtn = document.getElementById('openChallengesMeBtn');
if (openChallengesMeBtn && challengesModal) openChallengesMeBtn.addEventListener('click', () => { updateBossUI(); challengesModal.classList.add('show'); });

const settingsModal = document.getElementById('settingsModal');
const closeSettingsBtn = document.getElementById('closeSettingsBtn');
if (closeSettingsBtn && settingsModal) closeSettingsBtn.addEventListener('click', () => settingsModal.classList.remove('show'));
const openSettingsModalBtn = document.getElementById('openSettingsModalBtn');
if (openSettingsModalBtn && settingsModal) openSettingsModalBtn.addEventListener('click', () => settingsModal.classList.add('show'));

const biometricToggle = document.getElementById('biometricToggle');
if (biometricToggle) {
  biometricToggle.addEventListener('change', (e) => {
    showToast(e.target.checked ? '🔒 Biometric App Lock Enabled' : '🔓 Biometric App Lock Disabled');
  });
}

document.getElementById('currentDateDisplay').textContent = new Date().toLocaleDateString('en-US', {
  weekday: 'short',
  month: 'short',
  day: 'numeric'
});
buildJourneyMatrix();
updateUI();
updateTimerDisplay();
updateExamModeUI();
updateBossUI();

