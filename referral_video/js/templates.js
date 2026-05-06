const TEMPLATE_META = [
  { key:'promo',    label:'🎉 May Promotion Offer',       cat:'Promotional' },
  { key:'followup', label:'🔔 Follow-Up Reminder',         cat:'Follow-Up'   },
  { key:'welcome',  label:'👋 Welcome Message',            cat:'Onboarding'  },
  { key:'quote',    label:'📋 Quote Ready Notification',   cat:'Transactional'},
  { key:'referral', label:'🤝 Referral Invite',            cat:'Referral'    },
];

function initTemplates() {
  renderTemplatesGrid();
}

function renderTemplatesGrid() {
  const grid = document.getElementById('templates-grid');
  if (!grid) return;
  grid.innerHTML = TEMPLATE_META.map(t => `
    <div class="template-card">
      <div class="template-card-header">
        <span class="template-name">${t.label}</span>
        <span class="template-category">${t.cat}</span>
      </div>
      <div class="template-body">${TEMPLATES[t.key]}</div>
      <div class="template-actions">
        <button class="template-btn use" onclick="useTemplate('${t.key}', event)">Use</button>
      </div>
    </div>
  `).join('');
}

function useTemplate(key, event) {
  navigateTo('campaigns', event);
  // Give it a tiny bit of time to load and init
  setTimeout(() => {
    const sel = document.getElementById('template-select');
    if (sel) {
      sel.value = key;
      sel.dispatchEvent(new Event('change'));
      showToast('Template loaded in Campaign Setup!','success');
    }
  }, 100);
}

window.initTemplates = initTemplates;
