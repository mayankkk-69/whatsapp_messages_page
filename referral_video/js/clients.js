function initClients() {
  renderClientsTable();
  bindClientsSearch();

  // Close modal on overlay click
  const modal = document.getElementById('add-client-modal');
  if (modal) {
    modal.addEventListener('click', function(e) {
      if (e.target === this) closeAddClientModal();
    });
  }

  // Close modal on Escape key
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeAddClientModal();
  });
}

function renderClientsTable() {
  const tbody = document.getElementById('clients-tbody');
  if (!tbody) return;
  
  if (CLIENTS.length === 0) {
    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:40px;color:var(--text-muted)">No clients found in the database.</td></tr>';
    return;
  }

  tbody.innerHTML = CLIENTS.map(c => buildClientRow(c)).join('');
}

function buildClientRow(c) {
  // Use DB provided dates/counts or defaults
  const date = c.added_date || 'N/A';
  const campaigns = c.campaign_count || 0;
  
  return `
    <tr data-client-id="${c.id}">
      <td><div class="client-cell">
        <div class="client-initials">${c.initials}</div>
        <div><div class="client-name">${c.name}</div></div>
      </div></td>
      <td>${c.phone}</td>
      <td class="time-cell">${date}</td>
      <td style="font-weight:600;color:var(--green-dark)">${campaigns}</td>
      <td><span class="status-badge badge-delivered">${c.status || 'Active'}</span></td>
      <td><button class="action-btn" onclick="removeClientRow(${c.id}, '${c.name.split(' ')[0]}')">Remove</button></td>
    </tr>
  `;
}

function removeClientRow(id, firstName) {
  const row = document.querySelector(`tr[data-client-id="${id}"]`);
  if (row) {
    row.style.transition = 'opacity .3s, transform .3s';
    row.style.opacity = '0';
    row.style.transform = 'translateX(20px)';
    setTimeout(() => row.remove(), 300);
  }
  showToast(`Contact ${firstName} removed`, 'info');
  // Note: Actual DB removal would happen here via API
}

function bindClientsSearch() {
  const searchInput = document.getElementById('clients-page-search');
  if (searchInput) {
    searchInput.addEventListener('input', function() {
      const q = this.value.toLowerCase();
      document.querySelectorAll('#clients-tbody tr').forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
      });
    });
  }
}

// ── MODAL FUNCTIONS ───────────────────────

function openAddClientModal() {
  const modal = document.getElementById('add-client-modal');
  if (!modal) return;
  // Reset form
  document.getElementById('new-client-name').value = '';
  document.getElementById('new-client-phone').value = '';
  document.getElementById('new-client-email').value = '';
  document.getElementById('new-client-notes').value = '';
  document.querySelectorAll('.tag-option').forEach(t => t.classList.remove('active'));
  document.querySelector('.tag-option[data-tag="Lead"]')?.classList.add('active');

  modal.classList.add('open');
  setTimeout(() => document.getElementById('new-client-name').focus(), 100);
}

function closeAddClientModal() {
  const modal = document.getElementById('add-client-modal');
  if (modal) modal.classList.remove('open');
}

function toggleTag(btn) {
  btn.classList.toggle('active');
}

async function saveNewClient() {
  const name  = document.getElementById('new-client-name').value.trim();
  const phone = document.getElementById('new-client-phone').value.trim();
  const email = document.getElementById('new-client-email').value.trim();
  const notes = document.getElementById('new-client-notes').value.trim();
  const tags  = [...document.querySelectorAll('.tag-option.active')].map(t => t.dataset.tag);

  // Validation
  if (!name) {
    document.getElementById('new-client-name').focus();
    document.getElementById('new-client-name').style.borderColor = 'var(--red)';
    showToast('Please enter the client\'s full name.', 'error');
    return;
  }
  if (!phone || phone.length < 10) {
    document.getElementById('new-client-phone').focus();
    document.getElementById('new-client-phone').style.borderColor = 'var(--red)';
    showToast('Please enter a valid phone number.', 'error');
    return;
  }

  const saveBtn = document.getElementById('save-client-btn');
  saveBtn.disabled = true;
  saveBtn.textContent = 'Saving...';

  try {
    const response = await fetch('api/save_client.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, phone: `+91 ${phone}`, email, notes, tags })
    });

    const result = await response.json();

    if (result.id) {
      showToast(`✅ ${name} added successfully!`, 'success');
      // Refresh local data
      await fetchInitialData();
      // Re-render table if on clients page
      if (currentPage === 'clients') renderClientsTable();
      closeAddClientModal();
    } else {
      showToast('Error: ' + result.message, 'error');
    }
  } catch (err) {
    console.error('Error saving client:', err);
    showToast('Connection error. Please try again.', 'error');
  } finally {
    saveBtn.disabled = false;
    saveBtn.textContent = 'Save Client';
  }
}

window.initClients    = initClients;
window.openAddClientModal  = openAddClientModal;
window.closeAddClientModal = closeAddClientModal;
window.toggleTag      = toggleTag;
window.saveNewClient  = saveNewClient;
window.removeClientRow = removeClientRow;
