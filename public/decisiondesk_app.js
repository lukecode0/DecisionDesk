const state = {
  currentQuestionId: 'intro',
  answers: {},
  history: [],
  latestSubmissionId: null,
  currentView: 'welcomeView',
  questions: {},
  labels: {},
  submissions: [],
  seededCount: 0,
  outcomeCount: 0,
  questionBranches: 0
};

const routeGraph = {
  intro: () => 'entityType',
  entityType: answers => {
    if (answers.entityType === 'small_business') return 'yearsActive';
    if (answers.entityType === 'nonprofit') return 'npYearsActive';
    return 'householdIncome';
  },
  yearsActive: () => 'annualRevenue',
  annualRevenue: () => 'urgentNeed',
  urgentNeed: () => 'county',
  county: () => null,
  npYearsActive: () => 'servesYouth',
  servesYouth: () => 'county',
  householdIncome: () => 'veteran',
  veteran: () => 'county'
};

const answerOrder = [
  'applicantName', 'applicantEmail', 'entityType', 'yearsActive', 'annualRevenue', 'urgentNeed',
  'county', 'npYearsActive', 'servesYouth', 'householdIncome', 'veteran'
];

async function fetchJSON(url, options = {}) {
  const response = await fetch(url, {
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error || 'Request failed');
  }
  return data;
}

async function bootstrap() {
  const data = await fetchJSON('/api/bootstrap');
  state.questions = data.questions;
  state.labels = data.labels;
  state.submissions = data.submissions;
  state.seededCount = data.seeded_count;
  state.outcomeCount = data.outcome_count;
  state.questionBranches = data.question_branches;
  renderSummary();
  renderOutcomeFilter();
  renderTable();
  bindEvents();
}

function bindEvents() {
  document.getElementById('showWizardButton')?.addEventListener('click', startWizard);
  document.getElementById('showDashboardButton')?.addEventListener('click', () => showView('dashboardView'));
  document.getElementById('saveAnotherButton')?.addEventListener('click', startWizard);
  document.getElementById('viewSubmissionButton')?.addEventListener('click', async () => {
    await refreshSubmissions();
    showView('dashboardView');
  });
  document.getElementById('backToDashboardButton')?.addEventListener('click', () => showView('dashboardView'));
  document.getElementById('resetDemoButton')?.addEventListener('click', resetDemoData);
  document.getElementById('prevButton')?.addEventListener('click', goBack);
  document.getElementById('wizardForm')?.addEventListener('submit', handleNext);
  document.getElementById('searchInput')?.addEventListener('input', renderTable);
  document.getElementById('outcomeFilter')?.addEventListener('change', renderTable);
  document.getElementById('statusFilter')?.addEventListener('change', renderTable);
}

function renderSummary() {
  document.getElementById('seededCount').textContent = String(state.seededCount);
  document.getElementById('outcomeCount').textContent = String(state.outcomeCount);
  document.getElementById('branchCount').textContent = String(state.questionBranches);
}

async function refreshSubmissions() {
  const data = await fetchJSON('/api/submissions');
  state.submissions = data.submissions;
  renderOutcomeFilter();
  renderTable();
}

async function resetDemoData() {
  await fetchJSON('/api/reset', { method: 'POST' });
  await refreshSubmissions();
  showFlash('Sample data reset. Initial submissions restored.');
  showView('welcomeView');
}

function startWizard() {
  state.currentQuestionId = 'intro';
  state.answers = {};
  state.history = [];
  renderQuestion();
  showView('wizardView');
}

function showView(viewId) {
  document.querySelectorAll('.app-main > section').forEach(section => {
    section.classList.toggle('hidden', section.id !== viewId);
    section.classList.toggle('active-view', section.id === viewId);
  });
  state.currentView = viewId;
}

function showFlash(message) {
  const flash = document.getElementById('flash');
  flash.textContent = message;
  flash.classList.remove('hidden');
  clearTimeout(showFlash.timeoutId);
  showFlash.timeoutId = setTimeout(() => flash.classList.add('hidden'), 2800);
}

function computeFlow(answers) {
  const path = ['intro', 'entityType'];
  const branchStart = routeGraph.entityType(answers);
  if (!branchStart) return path;
  let current = branchStart;
  while (current) {
    path.push(current);
    current = routeGraph[current] ? routeGraph[current](answers) : null;
  }
  return path;
}

function getProgressFlow() {
  if (state.currentQuestionId === 'intro' || state.currentQuestionId === 'entityType') {
    return ['intro', 'entityType', 'householdIncome', 'veteran', 'county'];
  }
  return computeFlow(state.answers);
}

function totalStepsFor(answers) {
  return getProgressFlow().length;
}

function currentStepIndex() {
  const flow = getProgressFlow();
  return Math.max(flow.indexOf(state.currentQuestionId), 0) + 1;
}

function renderQuestion() {
  const question = state.questions[state.currentQuestionId];
  if (!question) return;

  document.getElementById('wizardTitle').textContent = question.title;
  document.getElementById('questionContainer').innerHTML = buildQuestionMarkup(question);

  const total = totalStepsFor(state.answers);
  const step = currentStepIndex();
  const percentage = Math.max(12, Math.round((step / total) * 100));
  document.getElementById('progressBar').style.width = `${percentage}%`;
  document.getElementById('progressText').textContent = `Step ${step} of ${total} so far`;
  document.getElementById('prevButton').style.visibility = state.history.length ? 'visible' : 'hidden';

  if (question.fields.some(field => field.type === 'radio')) {
    bindOptionSelection();
  }
}

function buildQuestionMarkup(question) {
  return question.fields.map(field => {
    if (field.type === 'text' || field.type === 'email') {
      const value = escapeHTML(state.answers[field.id] || '');
      return `
        <div class="question-block">
          <div class="question-title">${escapeHTML(field.label)}</div>
          <div class="question-help">${escapeHTML(question.help)}</div>
          <input class="input" type="${field.type}" name="${field.id}" placeholder="${escapeHTML(field.placeholder || '')}" value="${value}" required />
        </div>
      `;
    }

    const options = (field.options || []).map(option => {
      const checked = state.answers[field.id] === option.value ? 'checked' : '';
      const selected = checked ? 'selected' : '';
      return `
        <label class="option-card ${selected}">
          <input type="radio" name="${field.id}" value="${escapeHTML(option.value)}" ${checked} required />
          <span>${escapeHTML(option.label)}</span>
        </label>
      `;
    }).join('');

    return `
      <div class="question-block">
        <div class="question-title">${escapeHTML(field.label)}</div>
        <div class="question-help">${escapeHTML(question.help)}</div>
        <div class="option-group">${options}</div>
      </div>
    `;
  }).join('');
}

function bindOptionSelection() {
  document.querySelectorAll('.option-card input').forEach(input => {
    input.addEventListener('change', () => {
      document.querySelectorAll('.option-card').forEach(card => card.classList.remove('selected'));
      if (input.checked) input.closest('.option-card').classList.add('selected');
    });
  });
}

function collectAnswers(form) {
  const data = new FormData(form);
  for (const [key, value] of data.entries()) {
    state.answers[key] = value.trim();
  }
}

async function handleNext(event) {
  event.preventDefault();
  const form = event.currentTarget;
  if (!form.reportValidity()) return;

  collectAnswers(form);
  const nextId = routeGraph[state.currentQuestionId] ? routeGraph[state.currentQuestionId](state.answers) : null;

  if (!nextId) {
    const payload = { ...state.answers };
    const data = await fetchJSON('/api/submissions', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
    state.latestSubmissionId = data.submission.id;
    state.submissions.unshift(data.submission);
    renderOutcomeFilter();
    renderTable();
    renderResult(data.submission);
    showView('resultView');
    return;
  }

  state.history.push(state.currentQuestionId);
  state.currentQuestionId = nextId;
  renderQuestion();
}

function goBack() {
  if (!state.history.length) return;
  state.currentQuestionId = state.history.pop();
  renderQuestion();
}

function renderResult(submission) {
  document.getElementById('resultOutcome').textContent = submission.outcome;
  document.getElementById('resultReason').textContent = submission.reason;
  document.getElementById('resultPath').innerHTML = submission.decisionPath.map(item => `<li>${escapeHTML(item)}</li>`).join('');
}

function renderOutcomeFilter() {
  const filter = document.getElementById('outcomeFilter');
  const selected = filter.value;
  const outcomes = [...new Set(state.submissions.map(item => item.outcome))].sort();
  filter.innerHTML = '<option value="">All outcomes</option>' + outcomes.map(outcome => `
    <option value="${escapeHTML(outcome)}">${escapeHTML(outcome)}</option>
  `).join('');
  filter.value = outcomes.includes(selected) ? selected : '';
}

function filteredSubmissions() {
  const q = document.getElementById('searchInput').value.trim().toLowerCase();
  const outcome = document.getElementById('outcomeFilter').value;
  const status = document.getElementById('statusFilter').value;

  return state.submissions.filter(item => {
    const matchesQuery = !q || [item.applicantName, item.applicantEmail].join(' ').toLowerCase().includes(q);
    const matchesOutcome = !outcome || item.outcome === outcome;
    const matchesStatus = !status || item.status === status;
    return matchesQuery && matchesOutcome && matchesStatus;
  });
}

function renderTable() {
  const body = document.getElementById('submissionTableBody');
  const rows = filteredSubmissions();
  if (!rows.length) {
    body.innerHTML = '<tr><td colspan="6" class="empty-state">No submissions match the current filters.</td></tr>';
    return;
  }

  body.innerHTML = rows.map(item => `
    <tr>
      <td>
        <strong>${escapeHTML(item.applicantName)}</strong><br />
        <span class="muted">${escapeHTML(item.applicantEmail)}</span>
      </td>
      <td>${escapeHTML(labelFor('entityType', item.entityType))}</td>
      <td>${escapeHTML(item.outcome)}</td>
      <td><span class="badge ${item.status.toLowerCase()}">${escapeHTML(item.status)}</span></td>
      <td>${escapeHTML(item.createdAt)}</td>
      <td><button class="button button-small button-ghost" data-submission-id="${item.id}" type="button">Open</button></td>
    </tr>
  `).join('');

  body.querySelectorAll('button[data-submission-id]').forEach(button => {
    button.addEventListener('click', () => openSubmission(Number(button.dataset.submissionId)));
  });
}

async function openSubmission(id) {
  const data = await fetchJSON(`/api/submissions/${id}`);
  const submission = data.submission;
  document.getElementById('detailName').textContent = submission.applicantName;
  document.getElementById('detailMeta').textContent = `${labelFor('entityType', submission.entityType)} • ${submission.applicantEmail} • ${submission.createdAt}`;
  document.getElementById('detailOutcome').textContent = submission.outcome;
  document.getElementById('detailReason').textContent = submission.reason;
  document.getElementById('detailPath').innerHTML = submission.decisionPath.map(item => `<li>${escapeHTML(item)}</li>`).join('');

  const answerRows = answerOrder
    .filter(key => submission[key])
    .map(key => `
      <div class="answer-row">
        <div class="answer-label">${escapeHTML(humanizeKey(key))}</div>
        <div class="answer-value">${escapeHTML(labelFor(key, submission[key]))}</div>
      </div>
    `).join('');
  document.getElementById('detailAnswers').innerHTML = answerRows;
  showView('detailView');
}

function labelFor(key, value) {
  const map = state.labels[key];
  return map && map[value] ? map[value] : value;
}

function humanizeKey(key) {
  return key
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, letter => letter.toUpperCase());
}

function escapeHTML(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

bootstrap().catch(error => {
  console.error(error);
  const flash = document.getElementById('flash');
  flash.textContent = 'The application could not load. Check the server and try again.';
  flash.classList.remove('hidden');
});
