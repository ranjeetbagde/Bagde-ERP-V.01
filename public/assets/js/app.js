/**
 * Bagde ERP - Main JavaScript
 */

const BASE_URL = document.querySelector('meta[name="base-url"]')?.content || '';
const ASSET_BASE = document.querySelector('meta[name="asset-base"]')?.content?.replace(/\/$/, '') || (BASE_URL + '/public/assets');
const ROUTE_ENTRY = document.querySelector('meta[name="route-entry"]')?.content || (BASE_URL + '/index.php');
const USE_PRETTY_URLS = document.querySelector('meta[name="use-pretty-urls"]')?.content === '1';

/** Build application route URL (respects pretty URLs vs index.php?url=). */
function routeUrl(path, query) {
    path = (path || '').replace(/^\//, '');
    query = query || '';
    let url;
    if (USE_PRETTY_URLS) {
        url = path ? BASE_URL + '/' + path : BASE_URL;
    } else {
        url = path ? ROUTE_ENTRY + '?url=' + encodeURIComponent(path) : ROUTE_ENTRY;
    }
    return query ? url + (url.includes('?') ? '&' : '?') + query.replace(/^\?/, '') : url;
}

document.addEventListener('DOMContentLoaded', function () {
    initSidebar();
    initTheme();
    initAlerts();
    initConfirmDelete();
    initMoneyFormat();
    initAjaxSetup();
    initTabs();
    initDataTables();
    initNotifications();
    initQuickCreate();
    initFlashToasts();
});

/** Sidebar toggle for mobile/desktop */
function initSidebar() {
    const toggle = document.querySelector('.sidebar-toggle');
    const sidebar = document.querySelector('.sidebar');
    const overlay = document.querySelector('.sidebar-overlay');

    if (toggle && sidebar) {
        toggle.addEventListener('click', function () {
            if (window.innerWidth <= 992) {
                sidebar.classList.toggle('show');
                overlay?.classList.toggle('show');
            } else {
                sidebar.classList.toggle('collapsed');
                localStorage.setItem('sidebar_collapsed', sidebar.classList.contains('collapsed'));
            }
        });

        // Restore collapsed state
        if (localStorage.getItem('sidebar_collapsed') === 'true' && window.innerWidth > 992) {
            sidebar.classList.add('collapsed');
        }
    }

    overlay?.addEventListener('click', function () {
        sidebar?.classList.remove('show');
        overlay.classList.remove('show');
    });
}

/** Dark/Light theme toggle */
function initTheme() {
    const themeBtn = document.querySelector('.theme-toggle');
    const saved = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', saved);

    themeBtn?.addEventListener('click', function () {
        const current = document.documentElement.getAttribute('data-theme');
        const next = current === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', next);
        localStorage.setItem('theme', next);
    });
}

/** Auto-dismiss alerts */
function initAlerts() {
    document.querySelectorAll('.alert-dismissible').forEach(function (alert) {
        setTimeout(function () {
            alert.style.opacity = '0';
            setTimeout(function () { alert.remove(); }, 300);
        }, 5000);
    });
}

/** Confirm before delete */
function initConfirmDelete() {
    document.querySelectorAll('[data-confirm]').forEach(function (el) {
        el.addEventListener('click', function (e) {
            if (!confirm(el.dataset.confirm || 'Are you sure?')) {
                e.preventDefault();
            }
        });
    });
}

/** Format money inputs */
function initMoneyFormat() {
    document.querySelectorAll('.money-input').forEach(function (input) {
        input.addEventListener('blur', function () {
            const val = parseFloat(input.value) || 0;
            input.value = val.toFixed(2);
        });
    });
}

/** Setup CSRF for AJAX requests */
function initAjaxSetup() {
    window.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
}

/** Generic AJAX helper */
function ajax(url, options = {}) {
    const defaults = {
        method: 'GET',
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Content-Type': 'application/json',
        },
    };
    const config = { ...defaults, ...options };

    if (config.method === 'POST' && config.body && typeof config.body === 'object') {
        config.body = JSON.stringify(config.body);
    }

    return fetch(url, config).then(r => r.json());
}

/** Customer search autocomplete */
function initCustomerSearch(inputEl, callback) {
    let timeout;
    inputEl.addEventListener('input', function () {
        clearTimeout(timeout);
        const term = inputEl.value.trim();
        if (term.length < 2) return;

        timeout = setTimeout(function () {
            ajax(routeUrl('api/customers/search', 'q=' + encodeURIComponent(term)))
                .then(data => callback(data));
        }, 300);
    });
}

/** Calculate trip profit */
function calculateTripProfit() {
    const amount = parseFloat(document.getElementById('amount')?.value) || 0;
    const diesel = parseFloat(document.getElementById('diesel_amount')?.value) || 0;
    const royalty = parseFloat(document.getElementById('royalty')?.value) || 0;
    const loading = parseFloat(document.getElementById('loading_charge')?.value) || 0;
    const unloading = parseFloat(document.getElementById('unloading_charge')?.value) || 0;
    const other = parseFloat(document.getElementById('other_expense')?.value) || 0;
    const labour = parseFloat(document.getElementById('labour_cost')?.value) || 0;
    const driver = parseFloat(document.getElementById('driver_payment')?.value) || 0;

    const totalExpense = diesel + royalty + loading + unloading + other + labour + driver;
    const profit = amount - totalExpense;

    const expenseEl = document.getElementById('total_expense');
    const profitEl = document.getElementById('net_profit');
    if (expenseEl) expenseEl.value = totalExpense.toFixed(2);
    if (profitEl) profitEl.value = profit.toFixed(2);
}

/** Split labour cost equally among selected labours */
function splitLabourCost() {
    const totalCost = parseFloat(document.getElementById('labour_cost')?.value) || 0;
    const checkboxes = document.querySelectorAll('.labour-check:checked');
    const count = checkboxes.length;
    if (count === 0) return;

    const perLabour = (totalCost / count).toFixed(2);
    checkboxes.forEach(function (cb) {
        const amountInput = document.querySelector('[data-labour-amount="' + cb.value + '"]');
        if (amountInput) amountInput.value = perLabour;
    });
}

/** Print element */
function printElement(elementId) {
    const content = document.getElementById(elementId);
    if (!content) return;
    const win = window.open('', '_blank');
    win.document.write('<html><head><title>Print</title>');
    win.document.write('<link href="' + ASSET_BASE + '/css/style.css" rel="stylesheet">');
    win.document.write('<style>body{padding:20px} @media print{body{padding:0}}</style>');
    win.document.write('</head><body>' + content.innerHTML + '</body></html>');
    win.document.close();
    win.onload = function () { win.print(); };
}

/** Format number as Indian currency */
function formatINR(amount) {
    return '₹' + parseFloat(amount || 0).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

/** Global search handler */
function handleGlobalSearch(e) {
    if (e.key === 'Enter') {
        const q = e.target.value.trim();
        if (q) window.location.href = routeUrl('search', 'q=' + encodeURIComponent(q));
    }
}

/** Load order details when order selected in trip form */
function loadOrderDetails(orderId) {
    if (!orderId) return;
    if (typeof loadOrderTripPrefill === 'function') {
        loadOrderTripPrefill(orderId);
        return;
    }
    ajax(routeUrl('api/orders/' + orderId + '/trip-prefill'))
        .then(function (data) {
            if (!data.dispatchable || !data.prefill) return;
            const pf = data.prefill;
            const set = (id, val) => { const el = document.getElementById(id); if (el) el.value = val; };
            set('customer_id', pf.customer_id);
            set('material_id', pf.material_id);
            set('rate', pf.rate);
            set('unit', pf.unit);
            set('quantity', pf.quantity);
            set('source', pf.source);
            set('destination', pf.destination);
            set('labour_cost', pf.labour_charge);
            calculateTripAmount();
        });
}

/** Calculate trip amount from rate * quantity */
function calculateTripAmount() {
    const qty = parseFloat(document.getElementById('quantity')?.value) || 1;
    const rate = parseFloat(document.getElementById('rate')?.value) || 0;
    const amountEl = document.getElementById('amount');
    if (amountEl) {
        amountEl.value = (qty * rate).toFixed(2);
        calculateTripProfit();
    }
}

/** Order form - calculate totals */
function calculateOrderTotal() {
    const qty = parseFloat(document.getElementById('quantity')?.value) || 0;
    const rate = parseFloat(document.getElementById('rate')?.value) || 0;
    const discount = parseFloat(document.getElementById('discount_amount')?.value) || 0;
    const advance = parseFloat(document.getElementById('advance_amount')?.value) || 0;

    const total = qty * rate;
    const net = total - discount;

    document.getElementById('total_amount').value = total.toFixed(2);
    document.getElementById('net_amount').value = net.toFixed(2);
    document.getElementById('balance_amount').value = (net - advance).toFixed(2);
}

/** Tab panels */
function initTabs() {
    document.querySelectorAll('[data-ui-tabs]').forEach(function (root) {
        const nav = root.querySelector('.ui-tabs__nav');
        if (!nav) return;
        nav.querySelectorAll('[data-tab]').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                const id = btn.getAttribute('data-tab');
                nav.querySelectorAll('li').forEach(li => li.classList.remove('active'));
                btn.closest('li')?.classList.add('active');
                root.querySelectorAll('.ui-tabs__panel').forEach(p => p.classList.remove('active'));
                root.querySelector('#' + id)?.classList.add('active');
            });
        });
    });
}

/** Sortable / searchable data tables */
function initDataTables() {
    document.querySelectorAll('[data-table-search]').forEach(function (input) {
        const tableId = input.getAttribute('data-table-search');
        const table = document.getElementById(tableId);
        if (!table) return;
        input.addEventListener('input', function () {
            const q = input.value.toLowerCase();
            table.querySelectorAll('tbody tr').forEach(function (row) {
                row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
            });
        });
    });

    document.querySelectorAll('.data-table thead th[data-sort]').forEach(function (th) {
        th.addEventListener('click', function () {
            const table = th.closest('table');
            const tbody = table.querySelector('tbody');
            const idx = Array.from(th.parentNode.children).indexOf(th);
            const asc = !th.classList.contains('sort-asc');
            table.querySelectorAll('thead th').forEach(h => h.classList.remove('sort-asc', 'sort-desc'));
            th.classList.add(asc ? 'sort-asc' : 'sort-desc');
            const rows = Array.from(tbody.querySelectorAll('tr'));
            rows.sort(function (a, b) {
                const av = (a.children[idx]?.textContent || '').trim();
                const bv = (b.children[idx]?.textContent || '').trim();
                const an = parseFloat(av.replace(/[^\d.-]/g, ''));
                const bn = parseFloat(bv.replace(/[^\d.-]/g, ''));
                if (!isNaN(an) && !isNaN(bn)) return asc ? an - bn : bn - an;
                return asc ? av.localeCompare(bv) : bv.localeCompare(av);
            });
            rows.forEach(r => tbody.appendChild(r));
        });
    });
}

/** Notification dropdown */
function initNotifications() {
    const toggle = document.getElementById('notifToggle');
    const dropdown = document.getElementById('notifDropdown');
    if (!toggle || !dropdown) return;
    toggle.addEventListener('click', function (e) {
        e.stopPropagation();
        closeQuickCreate();
        dropdown.classList.toggle('show');
        toggle.setAttribute('aria-expanded', dropdown.classList.contains('show'));
    });
    document.addEventListener('click', function () {
        dropdown.classList.remove('show');
        toggle.setAttribute('aria-expanded', 'false');
    });
}

/** Quick create dropdown */
function initQuickCreate() {
    const btn = document.getElementById('quickCreateBtn');
    const menu = document.getElementById('quickCreateMenu');
    if (!btn || !menu) return;
    btn.addEventListener('click', function (e) {
        e.stopPropagation();
        document.getElementById('notifDropdown')?.classList.remove('show');
        menu.classList.toggle('show');
    });
    document.addEventListener('click', closeQuickCreate);
}

function closeQuickCreate() {
    document.getElementById('quickCreateMenu')?.classList.remove('show');
}

/** Toast notifications */
function showToast(message, type) {
    type = type || 'success';
    const container = document.getElementById('toastContainer');
    if (!container) return;
    const icons = { success: 'fa-check-circle text-success', error: 'fa-times-circle text-danger', warning: 'fa-exclamation-circle text-warning' };
    const el = document.createElement('div');
    el.className = 'ui-toast ' + type;
    el.innerHTML = '<i class="fas ' + (icons[type] || icons.success) + ' mt-1"></i><div>' + message + '</div>';
    container.appendChild(el);
    setTimeout(function () {
        el.style.opacity = '0';
        el.style.transform = 'translateX(100%)';
        setTimeout(function () { el.remove(); }, 300);
    }, 4500);
}

/** Convert flash alerts to toasts */
function initFlashToasts() {
    document.querySelectorAll('.alert-dismissible').forEach(function (alert) {
        const type = alert.classList.contains('alert-danger') ? 'error' : (alert.classList.contains('alert-warning') ? 'warning' : 'success');
        showToast(alert.textContent.trim(), type);
    });
}
