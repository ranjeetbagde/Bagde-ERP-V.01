<?php
/**
 * Bagde ERP - Front Controller
 * Building Material & Transport Management System
 */

declare(strict_types=1);

define('ROOT_PATH', __DIR__);
define('APP_PATH', ROOT_PATH . '/app');
define('CONFIG_PATH', ROOT_PATH . '/config');
define('STORAGE_PATH', ROOT_PATH . '/storage');
define('PUBLIC_PATH', ROOT_PATH . '/public');
define('UPLOAD_PATH', PUBLIC_PATH . '/uploads');

spl_autoload_register(function (string $class): void {
    $paths = [
        APP_PATH . '/Core/' . $class . '.php',
        APP_PATH . '/Controllers/' . $class . '.php',
        APP_PATH . '/Models/' . $class . '.php',
        APP_PATH . '/Helpers/' . $class . '.php',
    ];
    foreach ($paths as $path) {
        if (file_exists($path)) {
            require_once $path;
            return;
        }
    }
});

if (!file_exists(CONFIG_PATH . '/installed.lock')) {
    $scriptDir = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '/index.php'));
    if ($scriptDir === '/' || $scriptDir === '.' || $scriptDir === '') {
        $scriptDir = '';
    }
    header('Location: ' . $scriptDir . '/install/install.php');
    exit;
}

require_once CONFIG_PATH . '/config.php';
require_once APP_PATH . '/Helpers/functions.php';

if (!defined('INVOICE_LIVE_TRACE')) {
    define('INVOICE_LIVE_TRACE', true);
}

set_exception_handler(static function (Throwable $e): void {
    error_log('[BagdeERP] ' . $e->getMessage() . ' in ' . $e->getFile() . ':' . $e->getLine());
    if (!headers_sent()) {
        http_response_code(500);
    }
    if (class_exists('View')) {
        View::render('errors/500', [
            'pageTitle' => 'Server Error',
            'message'   => 'An unexpected error occurred. Please try again.',
        ], 'main');
    } else {
        echo 'An unexpected error occurred. Please try again.';
    }
    exit;
});

Session::start();

RequestTrace::enableIfRequested();
if (defined('INVOICE_LIVE_TRACE') && INVOICE_LIVE_TRACE) {
    $_GET['debug_trace'] = '1';
    RequestTrace::enableIfRequested();
}
RequestTrace::logRequestContext();

$router = new Router();
require_once CONFIG_PATH . '/routes.php';
$router->dispatch();

RequestTrace::flush(http_response_code() ?: 200);
