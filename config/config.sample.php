<?php
/**
 * Bagde ERP Configuration
 * Copy to config.php during installation
 */

declare(strict_types=1);

define('APP_NAME', 'Bagde ERP');
define('APP_TAGLINE', 'Building Material & Transport Management System');
define('APP_VERSION', '1.0');
define('APP_RELEASE', 'Stable');
define('APP_BUILD', '20260729');
define('APP_RELEASE_DATE', '2026-07-29');
define('DEVELOPER_COMPANY', 'Bagde Enterprises');
define('DEVELOPER_NAME', 'Ranjeet Bagde');
define('DEVELOPER_WEBSITE', 'https://bagdeenterprises.in');
define('DEVELOPER_EMAIL', 'support@bagdeenterprises.in');
define('DEVELOPER_COPYRIGHT', 'Copyright © 2026 Bagde Enterprises');
define('APP_LICENSE', 'Proprietary — Licensed to Bagde Enterprises');
define('PDF_AUTHOR', 'Bagde Enterprises');
define('PDF_CREATOR', 'Bagde ERP');
define('PDF_PRODUCER', 'Bagde ERP PDF Engine');
define('APP_URL', 'http://localhost/BagdeERP');
// Production examples:
//   Subfolder:  https://bagdeenterprises.in/erp
//   Domain root: https://bagdeenterprises.in
// APP_URL must match the exact public URL path (no trailing slash).
// Optional override; leave empty to auto-detect subfolder from the request.
define('APP_BASE_PATH', '');
define('APP_TIMEZONE', 'Asia/Kolkata');

// Static file paths (web-accessible, relative to docroot)
// cPanel: files live at public/assets — do NOT use bare /assets unless rewrite is verified
define('ASSET_WEB_ROOT', 'public/assets');
define('UPLOAD_WEB_ROOT', 'public/uploads');

// Clean URLs (/dashboard). Set true only after confirming mod_rewrite works.
// Keep false on cPanel when routes use index.php?url=
define('USE_PRETTY_URLS', true);

date_default_timezone_set(APP_TIMEZONE);

// Database
define('DB_HOST', 'localhost');
define('DB_NAME', 'bagde_erp');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// Security
define('CSRF_TOKEN_NAME', '_csrf_token');
define('SESSION_LIFETIME', 7200);
define('REMEMBER_COOKIE_NAME', 'bagde_remember');
define('REMEMBER_COOKIE_DAYS', 30);

// Upload limits
define('MAX_UPLOAD_SIZE', 5 * 1024 * 1024); // 5MB
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx']);

// Pagination
define('ITEMS_PER_PAGE', 25);

// Invoice preview debugging (REQUEST_URI, $_GET, exceptions on page)
define('DEBUG', false);

// Financial year start month (April = 4)
define('FY_START_MONTH', 4);
