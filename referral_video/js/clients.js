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
  const countEl = document.getElementById('client-count-subtitle');
  if (!tbody) return;
  
  if (countEl) countEl.textContent = `${CLIENTS.length} contacts in your list`;
  
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
  
  const tagsHtml = (c.tags || []).map(t => `<span class="client-tag-mini">${t}</span>`).join('');
  
  return `
    <tr data-client-id="${c.id}">
      <td><div class="client-cell">
        <div class="client-initials">${c.initials}</div>
        <div>
          <div class="client-name">${c.name}</div>
          <div class="client-tags-list">${tagsHtml}</div>
        </div>
      </div></td>
      <td>${c.phone}</td>
      <td class="time-cell">${date}</td>
      <td style="font-weight:600;color:var(--green-dark)">${campaigns}</td>
      <td><span class="status-badge badge-delivered">${c.status || 'Active'}</span></td>
      <td><button class="action-btn" onclick="removeClientRow(${c.id}, '${c.name.split(' ')[0]}')">Remove</button></td>
    </tr>
  `;
}

let clientToDelete = null;

function removeClientRow(id, firstName) {
  clientToDelete = { id, firstName };
  const modal = document.getElementById('confirm-delete-modal');
  const textEl = document.getElementById('confirm-delete-text');
  if (modal && textEl) {
    textEl.innerHTML = `Are you sure you want to remove <strong>${firstName}</strong>? This action cannot be undone.`;
    modal.classList.add('open');
  }
}

function closeConfirmDeleteModal() {
  const modal = document.getElementById('confirm-delete-modal');
  if (modal) modal.classList.remove('open');
  clientToDelete = null;
}

async function executeClientDeletion() {
  if (!clientToDelete) return;
  const { id, firstName } = clientToDelete;
  
  const confirmBtn = document.getElementById('confirm-delete-btn');
  if (confirmBtn) confirmBtn.textContent = 'Deleting...';

  try {
    const response = await fetch('api/delete_client.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: id })
    });

    const result = await response.json();

    if (result.success) {
      closeConfirmDeleteModal();
      const row = document.querySelector(`tr[data-client-id="${id}"]`);
      if (row) {
        row.style.transition = 'opacity .3s, transform .3s';
        row.style.opacity = '0';
        row.style.transform = 'translateX(20px)';
        setTimeout(() => {
          row.remove();
          CLIENTS = CLIENTS.filter(c => c.id != id);
          const countEl = document.getElementById('client-count-subtitle');
          if (countEl) countEl.textContent = `${CLIENTS.length} contacts in your list`;
        }, 300);
      }
      showToast(`Contact ${firstName} removed permanently`, 'success');
      logActivity({ type: 'Client Removed', page: 'clients', data: { name: firstName, id: id } });
    } else {
      closeConfirmDeleteModal();
      showToast('Error: ' + result.message, 'error');
    }
  } catch (err) {
    console.error('Error deleting client:', err);
    closeConfirmDeleteModal();
    showToast('Failed to delete client. Check connection.', 'error');
  } finally {
    if (confirmBtn) confirmBtn.textContent = 'Delete';
  }
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
      logActivity({ type: 'Client Added', page: 'clients', data: { name: name, phone: phone, tags: tags } });
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
window.closeConfirmDeleteModal = closeConfirmDeleteModal;
window.executeClientDeletion = executeClientDeletion;
