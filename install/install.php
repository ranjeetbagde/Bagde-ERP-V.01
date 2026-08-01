<?php
/**
 * Bagde ERP Installer
 */

declare(strict_types=1);

session_start();

define('INSTALL_PATH', __DIR__);
define('ROOT_PATH', dirname(__DIR__));
define('APP_PATH', ROOT_PATH . '/app');

// Check if already installed
if (file_exists(ROOT_PATH . '/config/installed.lock')) {
    header('Location: ../index.php');
    exit;
}

$step = (int) ($_GET['step'] ?? 1);
$error = '';
$success = '';

// Handle form submissions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    match ($step) {
        2 => handleRequirements(),
        3 => handleDatabaseConfig(),
        4 => handleCompanyInfo(),
        5 => handleAdminUser(),
        default => null,
    };
}

function executeSqlFile(PDO $pdo, string $filePath): void
{
    $sql = file_get_contents($filePath);
    // Remove comments
    $sql = preg_replace('/--.*$/m', '', $sql);
    $sql = preg_replace('/\/\*.*?\*\//s', '', $sql);

    $statements = array_filter(array_map('trim', explode(';', $sql)));
    foreach ($statements as $statement) {
        if (!empty($statement)) {
            $pdo->exec($statement);
        }
    }
}

function handleRequirements(): void
{
    header('Location: install.php?step=3');
    exit;
}

function handleDatabaseConfig(): void
{
    global $error;

    $host = trim($_POST['db_host'] ?? 'localhost');
    $name = trim($_POST['db_name'] ?? '');
    $user = trim($_POST['db_user'] ?? '');
    $pass = $_POST['db_pass'] ?? '';

    if (empty($name) || empty($user)) {
        $error = 'Database name and username are required.';
        return;
    }

    try {
        $dsn = "mysql:host=$host;charset=utf8mb4";
        $pdo = new PDO($dsn, $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

        // Create database if not exists
        $pdo->exec("CREATE DATABASE IF NOT EXISTS `$name` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
        $pdo->exec("USE `$name`");

        // Run schema and seed (statement by statement for cPanel compatibility)
        executeSqlFile($pdo, ROOT_PATH . '/database/schema.sql');
        executeSqlFile($pdo, ROOT_PATH . '/database/seed.sql');

        // Save config
        $appUrl = rtrim($_POST['app_url'] ?? '', '/');
        $configContent = generateConfig($host, $name, $user, $pass, $appUrl);
        file_put_contents(ROOT_PATH . '/config/config.php', $configContent);

        $_SESSION['install_db'] = true;
        header('Location: install.php?step=4');
        exit;
    } catch (PDOException $e) {
        $error = 'Database connection failed: ' . $e->getMessage();
    }
}

function handleCompanyInfo(): void
{
    global $error;

    if (!isset($_SESSION['install_db'])) {
        header('Location: install.php?step=3');
        exit;
    }

    require_once ROOT_PATH . '/config/config.php';

    try {
        $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

        $settings = [
            'company_name'    => trim($_POST['company_name'] ?? 'Bagde Building Material Supplier'),
            'company_address' => trim($_POST['company_address'] ?? ''),
            'company_phone'   => trim($_POST['company_phone'] ?? ''),
            'company_email'   => trim($_POST['company_email'] ?? ''),
            'company_gst'     => trim($_POST['company_gst'] ?? ''),
            'financial_year'  => trim($_POST['financial_year'] ?? currentFY()),
        ];

        foreach ($settings as $key => $value) {
            $stmt = $pdo->prepare('UPDATE settings SET setting_value = ?, updated_at = NOW() WHERE setting_key = ?');
            $stmt->execute([$value, $key]);
        }

        // Handle logo upload
        if (!empty($_FILES['company_logo']['tmp_name'])) {
            $uploadDir = ROOT_PATH . '/public/uploads/company/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }
            $ext = strtolower(pathinfo($_FILES['company_logo']['name'], PATHINFO_EXTENSION));
            if (in_array($ext, ['jpg', 'jpeg', 'png', 'gif'])) {
                $filename = 'logo.' . $ext;
                move_uploaded_file($_FILES['company_logo']['tmp_name'], $uploadDir . $filename);
                $stmt = $pdo->prepare('UPDATE settings SET setting_value = ? WHERE setting_key = ?');
                $stmt->execute(['company/' . $filename, 'company_logo']);
            }
        }

        header('Location: install.php?step=5');
        exit;
    } catch (Exception $e) {
        $error = 'Failed to save company info: ' . $e->getMessage();
    }
}

function handleAdminUser(): void
{
    global $error;

    $name = trim($_POST['admin_name'] ?? '');
    $email = trim($_POST['admin_email'] ?? '');
    $password = $_POST['admin_password'] ?? '';
    $confirm = $_POST['admin_confirm'] ?? '';

    if (empty($name) || empty($email) || empty($password)) {
        $error = 'All fields are required.';
        return;
    }

    if ($password !== $confirm) {
        $error = 'Passwords do not match.';
        return;
    }

    if (strlen($password) < 6) {
        $error = 'Password must be at least 6 characters.';
        return;
    }

    require_once ROOT_PATH . '/config/config.php';

    try {
        $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

        $hash = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare('UPDATE users SET name = ?, email = ?, password = ? WHERE role = ?');
        $stmt->execute([$name, $email, $hash, 'admin']);

        // Create directories
        $dirs = [
            ROOT_PATH . '/storage/logs',
            ROOT_PATH . '/storage/cache',
            ROOT_PATH . '/storage/backups',
            ROOT_PATH . '/public/uploads/company',
            ROOT_PATH . '/public/uploads/customers',
            ROOT_PATH . '/public/uploads/drivers',
            ROOT_PATH . '/public/uploads/labours',
            ROOT_PATH . '/public/uploads/trips',
            ROOT_PATH . '/public/uploads/documents',
        ];
        foreach ($dirs as $dir) {
            if (!is_dir($dir)) {
                mkdir($dir, 0755, true);
            }
        }

        // Create lock file
        file_put_contents(ROOT_PATH . '/config/installed.lock', date('Y-m-d H:i:s'));

        header('Location: install.php?step=6');
        exit;
    } catch (Exception $e) {
        $error = 'Failed to create admin: ' . $e->getMessage();
    }
}

function detectInstallAppUrl(): string
{
    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
    $scheme = $https ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    $appRoot = str_replace('\\', '/', dirname(dirname($_SERVER['SCRIPT_NAME'] ?? '/install/install.php')));
    if ($appRoot === '/' || $appRoot === '.' || $appRoot === '') {
        $appRoot = '';
    }
    return rtrim($scheme . '://' . $host . $appRoot, '/');
}

function generateConfig(string $host, string $name, string $user, string $pass, string $url): string
{
    return "<?php
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
define('APP_URL', '$url');
define('APP_BASE_PATH', '');
define('APP_TIMEZONE', 'Asia/Kolkata');

date_default_timezone_set(APP_TIMEZONE);

define('ASSET_WEB_ROOT', 'public/assets');
define('UPLOAD_WEB_ROOT', 'public/uploads');
define('USE_PRETTY_URLS', false);

define('DB_HOST', '$host');
define('DB_NAME', '$name');
define('DB_USER', '$user');
define('DB_PASS', '$pass');
define('DB_CHARSET', 'utf8mb4');

define('CSRF_TOKEN_NAME', '_csrf_token');
define('SESSION_LIFETIME', 7200);
define('REMEMBER_COOKIE_NAME', 'bagde_remember');
define('REMEMBER_COOKIE_DAYS', 30);

define('MAX_UPLOAD_SIZE', 5 * 1024 * 1024);
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx']);
define('ITEMS_PER_PAGE', 25);
define('FY_START_MONTH', 4);
";
}

function currentFY(): string
{
    $month = (int) date('n');
    $year = (int) date('Y');
    return $month < 4 ? ($year - 1) . '-' . $year : $year . '-' . ($year + 1);
}

function checkRequirements(): array
{
    return [
        ['name' => 'PHP Version >= 8.2', 'pass' => version_compare(PHP_VERSION, '8.2.0', '>=')],
        ['name' => 'PDO Extension', 'pass' => extension_loaded('pdo')],
        ['name' => 'PDO MySQL Extension', 'pass' => extension_loaded('pdo_mysql')],
        ['name' => 'MBString Extension', 'pass' => extension_loaded('mbstring')],
        ['name' => 'JSON Extension', 'pass' => extension_loaded('json')],
        ['name' => 'GD Extension', 'pass' => extension_loaded('gd')],
        ['name' => 'config/ Writable', 'pass' => is_writable(ROOT_PATH . '/config') || @mkdir(ROOT_PATH . '/config', 0755, true)],
        ['name' => 'storage/ Writable', 'pass' => is_writable(ROOT_PATH . '/storage') || @mkdir(ROOT_PATH . '/storage', 0755, true)],
        ['name' => 'public/uploads/ Writable', 'pass' => is_writable(ROOT_PATH . '/public/uploads') || @mkdir(ROOT_PATH . '/public/uploads', 0755, true)],
    ];
}

$requirements = checkRequirements();
$allPassed = !in_array(false, array_column($requirements, 'pass'), true);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Install Bagde ERP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        :root { --primary: #1e3a5f; --accent: #f97316; --bg: #f0f4f8; }
        body { background: var(--bg); font-family: 'Segoe UI', system-ui, sans-serif; }
        .install-container { max-width: 700px; margin: 40px auto; }
        .install-header { text-align: center; margin-bottom: 30px; }
        .install-header h1 { color: var(--primary); font-weight: 700; }
        .install-header p { color: #64748b; }
        .step-indicator { display: flex; justify-content: center; gap: 8px; margin-bottom: 30px; }
        .step-dot { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-weight: 600; font-size: 14px; background: #e2e8f0; color: #94a3b8; }
        .step-dot.active { background: var(--primary); color: #fff; }
        .step-dot.done { background: #22c55e; color: #fff; }
        .install-card { background: #fff; border-radius: 16px; box-shadow: 0 4px 24px rgba(0,0,0,0.08); padding: 32px; }
        .btn-primary { background: var(--primary); border-color: var(--primary); }
        .btn-primary:hover { background: #163050; border-color: #163050; }
        .btn-accent { background: var(--accent); border-color: var(--accent); color: #fff; }
        .btn-accent:hover { background: #ea580c; border-color: #ea580c; color: #fff; }
        .req-item { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f1f5f9; }
        .req-pass { color: #22c55e; } .req-fail { color: #ef4444; }
    </style>
</head>
<body>
<div class="install-container">
    <div class="install-header">
        <h1><i class="fas fa-building"></i> Bagde ERP</h1>
        <p>Building Material & Transport Management System</p>
    </div>

    <div class="step-indicator">
        <?php for ($i = 1; $i <= 6; $i++): ?>
            <div class="step-dot <?= $i < $step ? 'done' : ($i === $step ? 'active' : '') ?>">
                <?= $i < $step ? '<i class="fas fa-check"></i>' : $i ?>
            </div>
        <?php endfor; ?>
    </div>

    <div class="install-card">
        <?php if ($error): ?>
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <?= htmlspecialchars($error) ?></div>
        <?php endif; ?>

        <?php if ($step === 1): ?>
            <h4 class="mb-4">Welcome to Bagde ERP Installation</h4>
            <p>This installer will guide you through setting up your ERP system. Make sure you have:</p>
            <ul>
                <li>MySQL/MariaDB database credentials</li>
                <li>Writable permissions on config/, storage/, and public/uploads/ folders</li>
                <li>PHP 8.2 or higher</li>
            </ul>
            <div class="text-end mt-4">
                <a href="install.php?step=2" class="btn btn-primary">Start Installation <i class="fas fa-arrow-right"></i></a>
            </div>

        <?php elseif ($step === 2): ?>
            <h4 class="mb-4">System Requirements</h4>
            <?php foreach ($requirements as $req): ?>
                <div class="req-item">
                    <span><?= $req['name'] ?></span>
                    <span class="<?= $req['pass'] ? 'req-pass' : 'req-fail' ?>">
                        <i class="fas fa-<?= $req['pass'] ? 'check-circle' : 'times-circle' ?>"></i>
                    </span>
                </div>
            <?php endforeach; ?>
            <div class="text-end mt-4">
                <?php if ($allPassed): ?>
                    <form method="POST"><button type="submit" class="btn btn-primary">Continue <i class="fas fa-arrow-right"></i></button></form>
                <?php else: ?>
                    <button class="btn btn-secondary" disabled>Fix Requirements First</button>
                <?php endif; ?>
            </div>

        <?php elseif ($step === 3): ?>
            <h4 class="mb-4">Database Configuration</h4>
            <form method="POST">
                <div class="mb-3">
                    <label class="form-label">Application URL</label>
                    <input type="url" name="app_url" class="form-control" value="<?= htmlspecialchars(detectInstallAppUrl()) ?>" required>
                    <small class="text-muted">Must include subfolder if installed in one (e.g. https://bagdeenterprises.in/erp)</small>
                </div>
                <div class="mb-3">
                    <label class="form-label">Database Host</label>
                    <input type="text" name="db_host" class="form-control" value="localhost" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Database Name</label>
                    <input type="text" name="db_name" class="form-control" value="bagde_erp" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Database Username</label>
                    <input type="text" name="db_user" class="form-control" value="root" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Database Password</label>
                    <input type="password" name="db_pass" class="form-control">
                </div>
                <div class="text-end"><button type="submit" class="btn btn-primary">Install Database <i class="fas fa-database"></i></button></div>
            </form>

        <?php elseif ($step === 4): ?>
            <h4 class="mb-4">Company Information</h4>
            <form method="POST" enctype="multipart/form-data">
                <div class="mb-3">
                    <label class="form-label">Company Name</label>
                    <input type="text" name="company_name" class="form-control" value="Bagde Building Material Supplier" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Address</label>
                    <textarea name="company_address" class="form-control" rows="2"></textarea>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Phone</label>
                        <input type="text" name="company_phone" class="form-control">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" name="company_email" class="form-control">
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">GST Number</label>
                        <input type="text" name="company_gst" class="form-control">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Financial Year</label>
                        <input type="text" name="financial_year" class="form-control" value="<?= currentFY() ?>">
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label">Company Logo</label>
                    <input type="file" name="company_logo" class="form-control" accept="image/*">
                </div>
                <div class="text-end"><button type="submit" class="btn btn-primary">Continue <i class="fas fa-arrow-right"></i></button></div>
            </form>

        <?php elseif ($step === 5): ?>
            <h4 class="mb-4">Create Admin Account</h4>
            <form method="POST">
                <div class="mb-3">
                    <label class="form-label">Admin Name</label>
                    <input type="text" name="admin_name" class="form-control" value="Administrator" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Admin Email</label>
                    <input type="email" name="admin_email" class="form-control" value="admin@bagdeerp.com" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Password</label>
                    <input type="password" name="admin_password" class="form-control" required minlength="6">
                </div>
                <div class="mb-3">
                    <label class="form-label">Confirm Password</label>
                    <input type="password" name="admin_confirm" class="form-control" required>
                </div>
                <div class="text-end"><button type="submit" class="btn btn-accent">Complete Installation <i class="fas fa-check"></i></button></div>
            </form>

        <?php elseif ($step === 6): ?>
            <div class="text-center py-4">
                <div style="font-size: 64px; color: #22c55e; margin-bottom: 20px;"><i class="fas fa-check-circle"></i></div>
                <h3 class="mb-3">Installation Complete!</h3>
                <p class="text-muted mb-4">Bagde ERP has been successfully installed. You can now login and start managing your business.</p>
                <a href="../index.php" class="btn btn-primary btn-lg"><i class="fas fa-sign-in-alt"></i> Go to Login</a>
            </div>
        <?php endif; ?>
    </div>
</div>
</body>
</html>
