<?php
/**
 * Application Routes
 * Static routes MUST be registered before dynamic {id} routes.
 */

declare(strict_types=1);

// Auth Routes
$router->get('', 'AuthController@loginForm', ['guest']);
$router->get('login', 'AuthController@loginForm', ['guest']);
$router->post('login', 'AuthController@login', ['guest']);
$router->get('logout', 'AuthController@logout', ['auth']);
$router->get('forgot-password', 'AuthController@forgotForm', ['guest']);
$router->post('forgot-password', 'AuthController@forgotPassword', ['guest']);
$router->get('reset-password/{token}', 'AuthController@resetForm', ['guest']);
$router->post('reset-password', 'AuthController@resetPassword', ['guest']);

// Dashboard
$router->get('dashboard', 'DashboardController@index', ['auth']);

// Customers — static before {id}
$router->get('customers', 'CustomerController@index', ['auth']);
$router->get('customers/create', 'CustomerController@create', ['auth']);
$router->post('customers/store', 'CustomerController@store', ['auth']);
$router->get('customers/{id}/ledger', 'CustomerController@ledger', ['auth']);
$router->get('customers/{id}/statement', 'CustomerController@statement', ['auth']);
$router->get('customers/{id}/edit', 'CustomerController@edit', ['auth']);
$router->post('customers/{id}/update', 'CustomerController@update', ['auth']);
$router->post('customers/{id}/delete', 'CustomerController@delete', ['auth']);
$router->get('customers/{id}', 'CustomerController@show', ['auth']);
$router->get('api/customers/search', 'CustomerController@search', ['auth']);

// Orders — static before {id}
$router->get('orders', 'OrderController@index', ['auth']);
$router->get('orders/create', 'OrderController@create', ['auth']);
$router->post('orders/store', 'OrderController@store', ['auth']);
$router->get('orders/{id}/edit', 'OrderController@edit', ['auth']);
$router->post('orders/{id}/update', 'OrderController@update', ['auth']);
$router->post('orders/{id}/increase', 'OrderController@increase', ['auth']);
$router->post('orders/{id}/cancel', 'OrderController@cancel', ['auth']);
$router->post('orders/{id}/close', 'OrderController@close', ['auth']);
$router->post('orders/{id}/generate-invoice', 'OrderController@generateInvoice', ['auth']);
$router->get('orders/{id}', 'OrderController@show', ['auth']);
$router->get('api/orders/by-customer/{customerId}', 'OrderController@byCustomer', ['auth']);
$router->get('api/orders/{id}/trip-prefill', 'OrderController@tripPrefill', ['auth']);
$router->get('api/orders/{id}/invoice-preview', 'OrderController@invoicePreview', ['auth']);

// Trips — static before {id}
$router->get('trips', 'TripController@index', ['auth']);
$router->get('trips/create', 'TripController@create', ['auth']);
$router->post('trips/store', 'TripController@store', ['auth']);
$router->get('trips/{id}/edit', 'TripController@edit', ['auth']);
$router->post('trips/{id}/update', 'TripController@update', ['auth']);
$router->post('trips/{id}/complete', 'TripController@complete', ['auth']);
$router->post('trips/{id}/delete', 'TripController@delete', ['auth']);
$router->get('trips/{id}', 'TripController@show', ['auth']);

// Labours — static paths BEFORE {id}
$router->get('labours', 'LabourController@index', ['auth']);
$router->get('labours/create', 'LabourController@create', ['auth']);
$router->post('labours/store', 'LabourController@store', ['auth']);
$router->get('labours/advance', 'LabourController@advanceForm', ['auth']);
$router->post('labours/advance/store', 'LabourController@storeAdvance', ['auth']);
$router->get('labours/payment', 'LabourController@paymentForm', ['auth']);
$router->post('labours/payment/calculate', 'LabourController@calculatePayment', ['auth']);
$router->post('labours/payment/store', 'LabourController@storePayment', ['auth']);
$router->get('labours/payment/{id}/receipt', 'LabourController@paymentReceipt', ['auth']);
$router->post('labours/{id}/activate', 'LabourController@activate', ['auth']);
$router->post('labours/{id}/deactivate', 'LabourController@deactivate', ['auth']);
$router->get('labours/{id}/ledger', 'LabourController@ledger', ['auth']);
$router->get('labours/{id}/edit', 'LabourController@edit', ['auth']);
$router->post('labours/{id}/update', 'LabourController@update', ['auth']);
$router->get('labours/{id}', 'LabourController@show', ['auth']);

// Drivers — static paths BEFORE {id}
$router->get('drivers', 'DriverController@index', ['auth']);
$router->get('drivers/create', 'DriverController@create', ['auth']);
$router->post('drivers/store', 'DriverController@store', ['auth']);
$router->get('drivers/advance', 'DriverController@advanceForm', ['auth']);
$router->post('drivers/advance/store', 'DriverController@storeAdvance', ['auth']);
$router->get('drivers/payment', 'DriverController@paymentForm', ['auth']);
$router->post('drivers/payment/store', 'DriverController@storePayment', ['auth']);
$router->get('drivers/payment/{id}/receipt', 'DriverController@paymentReceipt', ['auth']);
$router->get('drivers/{id}/ledger', 'DriverController@ledger', ['auth']);
$router->get('drivers/{id}/edit', 'DriverController@edit', ['auth']);
$router->post('drivers/{id}/update', 'DriverController@update', ['auth']);
$router->get('drivers/{id}', 'DriverController@show', ['auth']);

// Vehicles — static paths BEFORE {id}
$router->get('vehicles', 'VehicleController@index', ['auth']);
$router->get('vehicles/create', 'VehicleController@create', ['auth']);
$router->post('vehicles/store', 'VehicleController@store', ['auth']);
$router->get('vehicles/{id}/maintenance', 'VehicleController@maintenanceForm', ['auth']);
$router->post('vehicles/{id}/maintenance/store', 'VehicleController@storeMaintenance', ['auth']);
$router->get('vehicles/{id}/edit', 'VehicleController@edit', ['auth']);
$router->post('vehicles/{id}/update', 'VehicleController@update', ['auth']);
$router->get('vehicles/{id}', 'VehicleController@show', ['auth']);

// Diesel
$router->get('diesel', 'DieselController@index', ['auth']);
$router->get('diesel/create', 'DieselController@create', ['auth']);
$router->post('diesel/store', 'DieselController@store', ['auth']);
$router->get('diesel/report', 'DieselController@report', ['auth']);

// Stock / Materials — static before {id}
$router->get('materials', 'MaterialController@index', ['auth']);
$router->get('materials/create', 'MaterialController@create', ['auth']);
$router->post('materials/store', 'MaterialController@store', ['auth']);
$router->get('materials/stock', 'MaterialController@stock', ['auth']);
$router->get('materials/purchase', 'MaterialController@purchaseForm', ['auth']);
$router->get('stock', 'MaterialController@stock', ['auth']);
$router->get('stock/purchase', 'MaterialController@purchaseForm', ['auth']);
$router->post('stock/purchase/store', 'MaterialController@storePurchase', ['auth']);
$router->get('stock/{id}/ledger', 'MaterialController@stockLedger', ['auth']);
$router->get('materials/{id}/edit', 'MaterialController@edit', ['auth']);
$router->post('materials/{id}/update', 'MaterialController@update', ['auth']);

// Expenses
$router->get('expenses', 'ExpenseController@index', ['auth']);
$router->get('expenses/create', 'ExpenseController@create', ['auth']);
$router->post('expenses/store', 'ExpenseController@store', ['auth']);
$router->post('expenses/{id}/delete', 'ExpenseController@delete', ['auth']);

// Delivery Challans
$router->get('challans', 'ChallanController@index', ['auth']);
$router->get('challans/create', 'ChallanController@create', ['auth']);
$router->get('challans/preview/{tripId}', 'ChallanController@preview', ['auth']);
$router->post('challans/generate/{tripId}', 'ChallanController@generate', ['auth']);
$router->post('challans/store', 'ChallanController@store', ['auth']);
$router->get('challans/{id}/pdf', 'ChallanController@pdf', ['auth']);
$router->get('challans/{id}/print', 'ChallanController@printView', ['auth']);
$router->get('challans/{id}', 'ChallanController@show', ['auth']);

// Invoices — static before {id}
$router->get('invoices', 'InvoiceController@index', ['auth']);
$router->get('invoices/create', 'InvoiceController@create', ['auth']);
$router->get('invoices/legacy/create', 'InvoiceController@legacyCreate', ['auth']);
$router->post('invoices/legacy/store', 'InvoiceController@legacyStore', ['auth']);
$router->post('invoices/store', 'InvoiceController@store', ['auth']);
$router->get('invoices/{id}/edit', 'InvoiceController@edit', ['auth']);
$router->post('invoices/{id}/update', 'InvoiceController@update', ['auth']);
$router->post('invoices/{id}/payment', 'InvoiceController@storePayment', ['auth']);
$router->get('invoices/{id}/pdf', 'InvoiceController@pdf', ['auth']);
$router->get('invoices/{id}/print', 'InvoiceController@printView', ['auth']);
$router->get('invoices/{id}', 'InvoiceController@show', ['auth']);
$router->get('api/invoices/trips/{customerId}', 'InvoiceController@tripsByCustomer', ['auth']);

// Customer Payments
$router->get('payments', 'PaymentController@index', ['auth']);
$router->get('payments/create', 'PaymentController@create', ['auth']);
$router->post('payments/store', 'PaymentController@store', ['auth']);
$router->get('payments/{id}', 'PaymentController@show', ['auth']);

// Accounting
$router->get('accounting/cash-book', 'AccountingController@cashBook', ['auth']);
$router->get('accounting/bank-book', 'AccountingController@bankBook', ['auth']);
$router->get('accounting/day-book', 'AccountingController@dayBook', ['auth']);
$router->get('accounting/income', 'AccountingController@income', ['auth']);
$router->get('accounting/reconciliation', 'AccountingController@reconciliation', ['auth']);
$router->get('reports/reconciliation', 'AccountingController@reconciliation', ['auth']);

// Reports
$router->get('reports', 'ReportController@index', ['auth']);
$router->get('reports/daily', 'ReportController@daily', ['auth']);
$router->get('reports/weekly', 'ReportController@weekly', ['auth']);
$router->get('reports/monthly', 'ReportController@monthly', ['auth']);
$router->get('reports/yearly', 'ReportController@yearly', ['auth']);
$router->get('reports/orders', 'ReportController@orders', ['auth']);
$router->get('reports/customer', 'ReportController@customer', ['auth']);
$router->get('reports/trip', 'ReportController@trip', ['auth']);
$router->get('reports/labour', 'ReportController@labour', ['auth']);
$router->get('reports/driver', 'ReportController@driver', ['auth']);
$router->get('reports/vehicle', 'ReportController@vehicle', ['auth']);
$router->get('reports/expense', 'ReportController@expense', ['auth']);
$router->get('reports/diesel', 'ReportController@diesel', ['auth']);
$router->get('reports/profit', 'ReportController@profit', ['auth']);
$router->get('reports/outstanding', 'ReportController@outstanding', ['auth']);
$router->get('reports/export/{type}', 'ReportController@export', ['auth']);

// Documents — literal routes before {id} patterns
$router->get('documents', 'DocumentController@index', ['auth']);
$router->get('documents/upload', 'DocumentController@uploadForm', ['auth']);
$router->post('documents/upload', 'DocumentController@upload', ['auth']);
$router->get('documents/{id}/download', 'DocumentController@download', ['auth']);
$router->post('documents/{id}/delete', 'DocumentController@delete', ['auth']);
$router->get('documents/{id}', 'DocumentController@show', ['auth']);

// Search
$router->get('search', 'SearchController@index', ['auth']);
$router->get('api/search', 'SearchController@api', ['auth']);

// Settings
$router->get('settings', 'SettingsController@index', ['auth']);
$router->get('settings/about', 'SettingsController@about', ['auth']);
$router->post('settings/update', 'SettingsController@update', ['auth']);
$router->get('settings/users', 'SettingsController@users', ['auth']);
$router->post('settings/users/store', 'SettingsController@storeUser', ['auth']);
$router->post('settings/users/{id}/update', 'SettingsController@updateUser', ['auth']);

// Backup
$router->get('backup', 'BackupController@index', ['auth']);
$router->post('backup/create', 'BackupController@create', ['auth']);
$router->get('backup/download/{file}', 'BackupController@download', ['auth']);
$router->post('backup/restore', 'BackupController@restore', ['auth']);

// Activity Log
$router->get('activity-log', 'SettingsController@activityLog', ['auth']);
$router->get('settings/activity-log', 'SettingsController@activityLog', ['auth']);

// API endpoints
$router->get('api/dashboard/stats', 'DashboardController@stats', ['auth']);
$router->get('api/dashboard/chart', 'DashboardController@chartData', ['auth']);
$router->get('api/materials/list', 'MaterialController@apiList', ['auth']);
$router->get('api/labours/list', 'LabourController@apiList', ['auth']);
$router->get('api/drivers/list', 'DriverController@apiList', ['auth']);
$router->get('api/vehicles/list', 'VehicleController@apiList', ['auth']);
