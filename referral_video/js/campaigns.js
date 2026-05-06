/* ═══════════════════════════════════════════
   WhatsApp Broadcast Campaign – campaigns.js
═══════════════════════════════════════════ */

const STATUS_LABELS = { sent:'Sent', delivered:'Delivered', read:'Read', replied:'Replied' };
const STATUS_TICK = {
  sent:      '<svg viewBox="0 0 16 11" fill="none" width="14" height="11"><path d="M1 5.5L5 9.5L11 1.5" stroke="#aaa" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>',
  delivered: '<svg viewBox="0 0 16 11" fill="none" width="14" height="11"><path d="M1 5.5L5 9.5L11 1.5" stroke="#53bdeb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M5 5.5L9 9.5L15 1.5" stroke="#53bdeb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>',
  read:      '<svg viewBox="0 0 16 11" fill="none" width="14" height="11"><path d="M1 5.5L5 9.5L11 1.5" stroke="#53bdeb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M5 5.5L9 9.5L15 1.5" stroke="#53bdeb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>',
  replied:   '💬',
};

let sentCount = 0, deliveredCount = 0, repliesCount = 0;
let simulationTimer = null;

async function initCampaigns() {
  renderClientList();
  renderTableSkeleton(); // Initial skeleton
  bindCampaignEvents();
  initTableFilters();
  prefillCampaignDateTime();
  await fetchLatestCampaignStats(); // Load real DB data
}

async function fetchLatestCampaignStats() {
  try {
    const response = await fetch('api/get_latest_campaign.php');
    const data = await response.json();

    // 1. Update Global Stats (Always available)
    const svTotal = document.getElementById('sv-total');
    if (svTotal) svTotal.textContent = data.global_total_clients || 0;

    // 2. Update Activity Feed (Always available)
    const activityList = document.getElementById('activity-list');
    if (activityList && data.activities) {
      if (data.activities.length === 0) {
        activityList.innerHTML = '<div style="padding:20px;text-align:center;color:var(--text-muted)">No activity yet.</div>';
      } else {
        activityList.innerHTML = data.activities.map(act => {
          const icon = act.type === 'Campaign Started' ? '🚀' : (act.type === 'Form Input' ? '✍' : '👁');
          const parsedData = JSON.parse(act.data || '{}');
          const text = act.type === 'Form Input' 
            ? `Editing field <strong>${act.field || 'unknown'}</strong> for ${parsedData.name || 'Untitled'}`
            : `${act.type}: <strong>${parsedData.name || ''}</strong>`;
            
          return `
            <div class="activity-item">
              <span class="activity-icon">${icon}</span>
              <span class="activity-text">${text}</span>
              <span class="activity-time">${act.time}</span>
            </div>
          `;
        }).join('');
      }
    }

    // 3. Stop here if no campaign data
    if (data.no_campaign) return;

    // 4. Update Campaign Stats
    const svSent = document.getElementById('sv-sent');
    const svDelivered = document.getElementById('sv-delivered');
    const svReplies = document.getElementById('sv-replies');
    const drate = document.getElementById('delivery-rate');
    const rrate = document.getElementById('reply-rate');

    if (svSent) svSent.textContent = data.total_sent || 0;
    if (svDelivered) svDelivered.textContent = data.delivered || 0;
    if (svReplies) svReplies.textContent = data.replies || 0;
    
    if (data.total_sent > 0) {
      if (drate) drate.textContent = Math.round((data.delivered / data.total_sent) * 100) + '% rate';
      if (rrate) rrate.textContent = Math.round((data.replies / data.total_sent) * 100) + '% response';
    }

    // 5. Update Table
    const tbody = document.getElementById('delivery-tbody');
    if (tbody && data.deliveries) {
      tbody.innerHTML = data.deliveries.map(d => `
        <tr data-id="${d.client_id}" data-status="${d.status.toLowerCase()}">
          <td><div class="client-cell">
            <div class="client-initials">${d.initials}</div>
            <div><div class="client-name">${d.name}</div></div>
          </div></td>
          <td>${d.phone}</td>
          <td><span class="status-badge badge-${d.status.toLowerCase()}">
            ${STATUS_TICK[d.status.toLowerCase()] || ''} ${d.status}
          </span></td>
          <td class="time-cell">${d.sent_time || '—'}</td>
          <td class="time-cell">—</td>
        </tr>
      `).join('');
    }

  } catch (err) {
    console.error('Error fetching latest campaign:', err);
  }
}

function bindCampaignEvents() {
  // --- Activity Tracking for Abandoned Forms ---
  const logInput = (e) => {
    logActivity({
      type: 'Form Input',
      page: 'campaigns',
      field: e.target.id,
      data: { value: e.target.value, name: document.getElementById('campaign-name').value }
    });
  };

  const cn = document.getElementById('campaign-name');
  if (cn) cn.addEventListener('blur', logInput);
  
  // Template select
  const ts = document.getElementById('template-select');
  if (ts) {
    ts.addEventListener('change', function(e) {
      const txt = TEMPLATES[this.value] || 'Select a template above to preview the message here.';
      document.getElementById('preview-text').textContent = txt;
      logInput(e);
    });
  }

  // All-clients toggle
  const act = document.getElementById('all-clients-toggle');
  if (act) {
    act.addEventListener('change', function(e) {
      const ms = document.getElementById('client-multiselect');
      if (this.checked) {
        ms.style.opacity = '.4';
        ms.style.pointerEvents = 'none';
        CLIENTS.forEach(c => selectedClients.add(c.id));
      } else {
        ms.style.opacity = '1';
        ms.style.pointerEvents = 'auto';
        selectedClients.clear();
      }
      renderCampaignTags();
      logInput(e);
    });
  }

  // Schedule radio
  document.querySelectorAll('input[name="schedule"]').forEach(r => {
    r.addEventListener('change', function(e) {
      const row = document.getElementById('datetime-row');
      this.value === 'later' ? row.classList.remove('hidden') : row.classList.add('hidden');
      logInput(e);
    });
  });

  // Repeat toggle
  const rt = document.getElementById('repeat-toggle');
  if (rt) {
    rt.addEventListener('change', function(e) {
      const opts = document.getElementById('repeat-options');
      this.checked ? opts.classList.remove('hidden') : opts.classList.add('hidden');
      logInput(e);
    });
  }

  // Client search
  const cs = document.getElementById('client-search');
  if (cs) {
    cs.addEventListener('input', function() {
      const q = this.value.toLowerCase();
      document.querySelectorAll('.client-item').forEach(item => {
        const name = item.dataset.name.toLowerCase();
        item.style.display = name.includes(q) ? '' : 'none';
      });
    });
  }

  // CTA
  const scb = document.getElementById('start-campaign-btn');
  if (scb) scb.addEventListener('click', startCampaign);
  
  const sdb = document.getElementById('save-draft-btn');
  if (sdb) sdb.addEventListener('click', saveCampaignDraft);
}

function renderClientList() {
  const list = document.getElementById('client-list');
  if (!list) return;
  list.innerHTML = CLIENTS.map(c => `
    <div class="client-item" data-id="${c.id}" data-name="${c.name}">
      <input type="checkbox" id="client-${c.id}" value="${c.id}" ${selectedClients.has(c.id) ? 'checked' : ''}/>
      <div class="client-avatar">${c.initials}</div>
      <div>
        <div style="font-weight:600;font-size:.875rem">${c.name}</div>
        <div class="client-phone">${c.phone}</div>
      </div>
    </div>
  `).join('');

  document.querySelectorAll('.client-item').forEach(item => {
    item.addEventListener('click', function(e) {
      if (e.target.tagName === 'INPUT') return;
      const cb = this.querySelector('input[type=checkbox]');
      cb.checked = !cb.checked;
      toggleCampaignClient(parseInt(this.dataset.id), cb.checked);
    });
    item.querySelector('input').addEventListener('change', function() {
      toggleCampaignClient(parseInt(item.dataset.id), this.checked);
    });
  });
  renderCampaignTags();
}

function toggleCampaignClient(id, checked) {
  checked ? selectedClients.add(id) : selectedClients.delete(id);
  renderCampaignTags();
}

function renderCampaignTags() {
  const container = document.getElementById('client-tags');
  if (!container) return;
  container.innerHTML = [...selectedClients].map(id => {
    const c = CLIENTS.find(x => x.id === id);
    if (!c) return '';
    return `<div class="tag">${c.initials} ${c.name.split(' ')[0]} <button onclick="removeCampaignTag(${id})" title="Remove">×</button></div>`;
  }).join('');
}

function removeCampaignTag(id) {
  selectedClients.delete(id);
  const cb = document.querySelector(`#client-${id}`);
  if (cb) cb.checked = false;
  renderCampaignTags();
}

function renderTableSkeleton() {
  const tbody = document.getElementById('delivery-tbody');
  if (!tbody) return;
  tbody.innerHTML = CLIENTS.map(c => `
    <tr data-id="${c.id}" data-status="">
      <td><div class="client-cell">
        <div class="client-initials">${c.initials}</div>
        <div><div class="client-name">${c.name}</div></div>
      </div></td>
      <td>${c.phone}</td>
      <td><span class="status-badge" id="badge-${c.id}">—</span></td>
      <td class="time-cell" id="sent-time-${c.id}">—</td>
      <td class="time-cell" id="next-time-${c.id}">—</td>
    </tr>
  `).join('');
}

async function saveCampaignDraft() {
  const name = document.getElementById('campaign-name').value.trim() || 'Untitled Draft';
  await performSaveCampaign('Draft');
  showToast(`💾 Draft "${name}" saved to database!`, 'info');
}

async function startCampaign() {
  const name = document.getElementById('campaign-name').value.trim();
  const template = document.getElementById('template-select').value;
  const allToggle = document.getElementById('all-clients-toggle').checked;
  const audience = allToggle ? CLIENTS.map(c => c.id) : [...selectedClients];

  if (!name) { showToast('Please enter a campaign name.', 'error'); return; }
  if (!template) { showToast('Please select a message template.', 'error'); return; }
  if (!audience.length) { showToast('Please select at least one client.', 'error'); return; }
  if (campaignRunning) { showToast('A campaign is already running!', 'error'); return; }

  // 1. Save to Database first
  const dbResult = await performSaveCampaign('Running');
  if (!dbResult || !dbResult.id) return; // Stop if DB failed

  campaignRunning = true;
  sentCount = 0; deliveredCount = 0; repliesCount = 0;
  
  const statusChip = document.querySelector('.status-chip');
  if (statusChip) {
    statusChip.className = 'status-chip running';
    statusChip.textContent = 'Running';
  }

  const startBtn = document.getElementById('start-campaign-btn');
  if (startBtn) {
    startBtn.disabled = true;
    startBtn.style.opacity = '.6';
  }

  showToast(`🚀 Campaign "${name}" launched and saved!`, 'success');
  addCampaignActivity('🚀', `Campaign <strong>${name}</strong> launched for ${audience.length} clients`);
  
  logActivity({ type: 'Campaign Started', page: 'campaigns', data: { name, audience: audience.length } });
  
  simulateCampaignSending(audience);
}

async function performSaveCampaign(status) {
  const name = document.getElementById('campaign-name').value.trim();
  const template_key = document.getElementById('template-select').value;
  const allToggle = document.getElementById('all-clients-toggle').checked;
  const audience = allToggle ? CLIENTS.map(c => parseInt(c.id)) : [...selectedClients];
  const button_link = document.getElementById('btn-link').value;
  const schedule_type = document.querySelector('input[name="schedule"]:checked')?.value || 'now';
  
  // New fields to match the requested format
  const is_repeat = document.getElementById('repeat-toggle').checked;
  const repeat_interval = document.querySelector('input[name="repeat"]:checked')?.value || '24h';
  const stop_on_reply = true; // Hardcoded true for now based on your image request

  try {
    const response = await fetch('api/save_campaign.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name,
        template_key,
        button_link,
        target_audience: allToggle ? 'All' : 'Selected',
        schedule_type,
        status,
        client_ids: audience,
        is_repeat,
        repeat_interval,
        stop_on_reply
      })
    });
    return await response.json();
  } catch (err) {
    console.error('Error saving campaign:', err);
    showToast('Failed to save campaign to database', 'error');
    return { error: true };
  }
}

function simulateCampaignSending(audience) {
  let idx = 0;
  function sendNext() {
    if (idx >= audience.length) {
      campaignRunning = false;
      const startBtn = document.getElementById('start-campaign-btn');
      if (startBtn) {
        startBtn.disabled = false;
        startBtn.style.opacity = '1';
      }
      showToast('✅ All messages sent!', 'success');
      addCampaignActivity('✅', `Campaign completed. ${sentCount} messages sent.`);
      return;
    }
    const cid = audience[idx++];
    const client = CLIENTS.find(c => c.id === cid);
    if (!client) { sendNext(); return; }

    const now = new Date();
    const sentTime = now.toLocaleTimeString([], { hour:'2-digit', minute:'2-digit' });
    updateCampaignClientStatus(client, 'sent', sentTime);
    sentCount++;
    updateCampaignStats();
    addCampaignActivity('✔', `Message sent to <strong>${client.name}</strong>`);

    setTimeout(() => {
      updateCampaignClientStatus(client, 'delivered', sentTime);
      deliveredCount++;
      updateCampaignStats();
      addCampaignActivity('✔✔', `Delivered to <strong>${client.name}</strong>`);

      if (Math.random() > 0.4) {
        setTimeout(() => {
          const willReply = Math.random() > 0.55;
          const finalStatus = willReply ? 'replied' : 'read';
          updateCampaignClientStatus(client, finalStatus, sentTime);
          if (willReply) {
            repliesCount++;
            updateCampaignStats();
            addCampaignActivity('💬', `Reply received from <strong>${client.name}</strong>`);
          } else {
            addCampaignActivity('👁️', `Message read by <strong>${client.name}</strong>`);
          }
        }, 800 + Math.random() * 1200);
      }
    }, 600 + Math.random() * 800);

    simulationTimer = setTimeout(sendNext, 700 + Math.random() * 600);
  }
  sendNext();
}

function updateCampaignClientStatus(client, status, sentTime) {
  const badge = document.getElementById(`badge-${client.id}`);
  const sentCell = document.getElementById(`sent-time-${client.id}`);
  const nextCell = document.getElementById(`next-time-${client.id}`);
  const row = document.querySelector(`tr[data-id="${client.id}"]`);

  if (badge) {
    badge.className = `status-badge badge-${status}`;
    badge.innerHTML = `${STATUS_TICK[status] || ''} ${STATUS_LABELS[status]}`;
  }
  if (sentCell) sentCell.textContent = sentTime;
  if (nextCell) {
    const repeat = document.getElementById('repeat-toggle').checked;
    nextCell.textContent = repeat ? getNextCampaignSendTime() : '—';
  }
  if (row) row.dataset.status = status;
}

function getNextCampaignSendTime() {
  const d = new Date();
  const repeatVal = document.querySelector('input[name="repeat"]:checked')?.value || '24h';
  if (repeatVal === '24h') d.setDate(d.getDate() + 1);
  else if (repeatVal === '48h') d.setDate(d.getDate() + 2);
  else {
    const val = parseInt(document.getElementById('interval-val')?.value) || 3;
    const unit = document.getElementById('interval-unit')?.value || 'days';
    if (unit === 'hours') d.setHours(d.getHours() + val);
    else if (unit === 'days') d.setDate(d.getDate() + val);
    else d.setDate(d.getDate() + val * 7);
  }
  return d.toLocaleDateString([], { month:'short', day:'numeric' }) + ' ' + d.toLocaleTimeString([], { hour:'2-digit', minute:'2-digit' });
}

function updateCampaignStats() {
  const svSent = document.getElementById('sv-sent');
  const svDelivered = document.getElementById('sv-delivered');
  const svReplies = document.getElementById('sv-replies');
  
  if (svSent) svSent.textContent = sentCount;
  if (svDelivered) svDelivered.textContent = deliveredCount;
  if (svReplies) svReplies.textContent = repliesCount;
  
  if (sentCount > 0) {
    const dr = document.getElementById('delivery-rate');
    const rr = document.getElementById('reply-rate');
    if (dr) dr.textContent = Math.round((deliveredCount / sentCount) * 100) + '% rate';
    if (rr) rr.textContent = Math.round((repliesCount / sentCount) * 100) + '% response';
  }
}

function addCampaignActivity(icon, text) {
  const list = document.getElementById('activity-list');
  if (!list) return;
  const now = new Date().toLocaleTimeString([], { hour:'2-digit', minute:'2-digit', second:'2-digit' });
  const item = document.createElement('div');
  item.className = 'activity-item';
  item.innerHTML = `
    <span class="activity-icon">${icon}</span>
    <span class="activity-text">${text}</span>
    <span class="activity-time">${now}</span>
  `;
  list.insertBefore(item, list.firstChild);
  while (list.children.length > 20) list.removeChild(list.lastChild);
}

function initTableFilters() {
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      this.classList.add('active');
      const f = this.dataset.filter;
      document.querySelectorAll('#delivery-tbody tr').forEach(row => {
        row.style.display = (f === 'all' || row.dataset.status === f) ? '' : 'none';
      });
    });
  });
}

function prefillCampaignDateTime() {
  const now = new Date();
  const dateStr = now.toISOString().split('T')[0];
  const hh = String(now.getHours()).padStart(2,'0');
  const mm = String(now.getMinutes()).padStart(2,'0');
  const dateEl = document.getElementById('schedule-date');
  const timeEl = document.getElementById('schedule-time');
  if (dateEl) dateEl.value = dateStr;
  if (timeEl) timeEl.value = `${hh}:${mm}`;
}

// Global hook for the router
window.initCampaigns = initCampaigns;
