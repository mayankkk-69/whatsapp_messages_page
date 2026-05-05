/* ═══════════════════════════════════════════
   WhatsApp Broadcast Campaign – app.js (Core)
═══════════════════════════════════════════ */

let CLIENTS = [];
let TEMPLATES = {};

// Global State
let currentPage = '';
let selectedClients = new Set();
let campaignRunning = false;

// ── INIT ──────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
  await fetchInitialData();
  
  // Check URL hash or default
  const page = window.location.hash.replace('#', '') || 'campaigns';
  navigateTo(page);
});

async function fetchInitialData() {
  try {
    const [clientsRes, templatesRes] = await Promise.all([
      fetch('api/get_clients.php'),
      fetch('api/get_templates.php')
    ]);
    
    CLIENTS = await clientsRes.json();
    
    const templatesList = await templatesRes.json();
    TEMPLATES = {};
    templatesList.forEach(t => {
      TEMPLATES[t.key] = t.body;
    });
    
    console.log('Data fetched from DB:', { clients: CLIENTS.length, templates: Object.keys(TEMPLATES).length });
  } catch (err) {
    console.error('Error fetching initial data:', err);
    showToast('Failed to connect to database', 'error');
  }
}

// ── NAVIGATION (SPA ROUTER) ───────────────
async function navigateTo(page, event) {
  if (event) event.preventDefault();
  if (currentPage === page) return;

  const container = document.getElementById('section-container');
  
  try {
    // 1. Fetch the HTML
    const response = await fetch(`sections/${page}.html`);
    if (!response.ok) throw new Error('Page not found');
    const content = await response.text();
    
    // 2. Inject
    container.innerHTML = content;
    currentPage = page;
    window.location.hash = page;

    // 3. Update UI
    updateSidebarUI(page);
    updateBreadcrumb(page);

    // 4. Initialize section-specific JS
    initSection(page);

    // 5. Log Activity
    logActivity({ type: 'Page View', page: page });

  } catch (err) {
    console.error('Routing error:', err);
    showToast('Failed to load page', 'error');
  }
}

function updateSidebarUI(page) {
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  const activeNav = document.getElementById(`nav-${page}`);
  if (activeNav) activeNav.classList.add('active');
}

function updateBreadcrumb(page) {
  const nameEl = document.getElementById('current-page-name');
  const names = {
    dashboard: 'Dashboard', clients: 'Clients',
    templates: 'Templates', campaigns: 'Broadcast Campaign',
    analytics: 'Analytics', settings: 'Settings'
  };
  if (nameEl) nameEl.textContent = names[page] || page;
}

function initSection(page) {
  // Call the init function from the modular files
  // These will be defined in dashboard.js, clients.js, etc.
  const fnName = `init${page.charAt(0).toUpperCase() + page.slice(1)}`;
  if (typeof window[fnName] === 'function') {
    window[fnName]();
  }
}

// ── HELPERS ──────────────────────────────
function showToast(msg, type = 'info') {
  const c = document.getElementById('toast-container');
  const t = document.createElement('div');
  t.className = `toast ${type}`;
  t.innerHTML = `<span>${msg}</span>`;
  c.appendChild(t);
  setTimeout(() => { 
    t.style.opacity = '0'; 
    t.style.transform = 'translateX(20px)'; 
    t.style.transition = '.3s'; 
    setTimeout(() => t.remove(), 300); 
  }, 3000);
}

async function logActivity(details) {
  try {
    fetch('api/log_activity.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(details)
    });
  } catch (err) { /* silent fail for logging */ }
}
