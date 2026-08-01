<?php
/**
 * Route permission map — controller@action => permission key
 */

declare(strict_types=1);

return [
    // Dashboard
    'DashboardController@index'  => 'dashboard.view',
    'DashboardController@stats'    => 'dashboard.view',
    'DashboardController@chartData' => 'dashboard.view',

    // Customers
    'CustomerController@index'     => 'customers.view',
    'CustomerController@create'    => 'customers.create',
    'CustomerController@store'     => 'customers.create',
    'CustomerController@show'      => 'customers.view',
    'CustomerController@edit'      => 'customers.edit',
    'CustomerController@update'    => 'customers.edit',
    'CustomerController@delete'    => 'customers.delete',
    'CustomerController@ledger'    => 'customers.view',
    'CustomerController@statement' => 'customers.view',
    'CustomerController@search'    => 'customers.view',

    // Orders
    'OrderController@index'    => 'orders.view',
    'OrderController@create'   => 'orders.create',
    'OrderController@store'    => 'orders.create',
    'OrderController@show'     => 'orders.view',
    'OrderController@edit'     => 'orders.edit',
    'OrderController@update'   => 'orders.edit',
    'OrderController@increase' => 'orders.edit',
    'OrderController@cancel'   => 'orders.edit',
    'OrderController@close'    => 'orders.edit',
    'OrderController@generateInvoice' => 'invoices.create',
    'OrderController@byCustomer' => 'orders.view',
    'OrderController@tripPrefill' => 'orders.view',
    'OrderController@invoicePreview' => 'invoices.create',

    // Trips
    'TripController@index'  => 'trips.view',
    'TripController@create' => 'trips.create',
    'TripController@store'  => 'trips.create',
    'TripController@show'   => 'trips.view',
    'TripController@edit'   => 'trips.edit',
    'TripController@update' => 'trips.edit',
    'TripController@complete' => 'trips.create',
    'TripController@delete' => 'trips.delete',

    // Labours
    'LabourController@index'          => 'labours.view',
    'LabourController@create'         => 'labours.create',
    'LabourController@store'          => 'labours.create',
    'LabourController@show'           => 'labours.view',
    'LabourController@edit'           => 'labours.edit',
    'LabourController@update'         => 'labours.edit',
    'LabourController@activate'       => 'labours.edit',
    'LabourController@deactivate'     => 'labours.edit',
    'LabourController@ledger'         => 'labours.view',
    'LabourController@advanceForm'    => 'labours.advance',
    'LabourController@storeAdvance'   => 'labours.advance',
    'LabourController@paymentForm'    => 'labours.payment',
    'LabourController@calculatePayment' => 'labours.payment',
    'LabourController@storePayment'   => 'labours.payment',
    'LabourController@paymentReceipt' => 'labours.view',
    'LabourController@apiList'        => 'labours.view',

    // Drivers
    'DriverController@index'        => 'drivers.view',
    'DriverController@create'     => 'drivers.create',
    'DriverController@store'      => 'drivers.create',
    'DriverController@show'       => 'drivers.view',
    'DriverController@edit'       => 'drivers.edit',
    'DriverController@update'     => 'drivers.edit',
    'DriverController@ledger'     => 'drivers.view',
    'DriverController@advanceForm'  => 'drivers.payment',
    'DriverController@storeAdvance' => 'drivers.payment',
    'DriverController@paymentForm' => 'drivers.payment',
    'DriverController@storePayment' => 'drivers.payment',
    'DriverController@paymentReceipt' => 'drivers.view',
    'DriverController@apiList'        => 'drivers.view',

    // Vehicles
    'VehicleController@index'            => 'vehicles.view',
    'VehicleController@create'           => 'vehicles.create',
    'VehicleController@store'            => 'vehicles.create',
    'VehicleController@show'             => 'vehicles.view',
    'VehicleController@edit'             => 'vehicles.edit',
    'VehicleController@update'           => 'vehicles.edit',
    'VehicleController@maintenanceForm'  => 'vehicles.maintenance',
    'VehicleController@storeMaintenance' => 'vehicles.maintenance',
    'VehicleController@apiList'          => 'vehicles.view',

    // Payments
    'PaymentController@index'  => 'payments.view',
    'PaymentController@create' => 'payments.create',
    'PaymentController@store'  => 'payments.create',
    'PaymentController@show'   => 'payments.view',

    // Invoices
    'InvoiceController@index'  => 'invoices.view',
    'InvoiceController@create' => 'invoices.create',
    'InvoiceController@legacyCreate' => 'invoices.create',
    'InvoiceController@legacyStore' => 'invoices.create',
    'InvoiceController@store'  => 'invoices.create',
    'InvoiceController@show'   => 'invoices.view',
    'InvoiceController@edit'   => 'invoices.edit',
    'InvoiceController@update' => 'invoices.edit',
    'InvoiceController@storePayment' => 'payments.create',
    'InvoiceController@pdf'    => 'invoices.view',
    'InvoiceController@printView' => 'invoices.view',
    'InvoiceController@tripsByCustomer' => 'invoices.view',

    // Challans
    'ChallanController@index'  => 'challans.view',
    'ChallanController@create' => 'challans.create',
    'ChallanController@preview' => 'challans.create',
    'ChallanController@generate' => 'challans.create',
    'ChallanController@store'  => 'challans.create',
    'ChallanController@show'   => 'challans.view',
    'ChallanController@pdf'    => 'challans.view',
    'ChallanController@printView' => 'challans.view',

    // Materials & Stock
    'MaterialController@index'         => 'stock.view',
    'MaterialController@create'        => 'stock.create',
    'MaterialController@store'         => 'stock.create',
    'MaterialController@edit'          => 'stock.edit',
    'MaterialController@update'        => 'stock.edit',
    'MaterialController@stock'         => 'stock.create',
    'MaterialController@purchaseForm'  => 'stock.create',
    'MaterialController@storePurchase' => 'stock.create',
    'MaterialController@stockLedger'   => 'stock.view',
    'MaterialController@apiList'     => 'stock.view',

    // Diesel
    'DieselController@index'  => 'diesel.view',
    'DieselController@create' => 'diesel.create',
    'DieselController@store'  => 'diesel.create',
    'DieselController@report' => 'diesel.view',

    // Expenses
    'ExpenseController@index'  => 'expenses.view',
    'ExpenseController@create' => 'expenses.create',
    'ExpenseController@store'  => 'expenses.create',
    'ExpenseController@delete' => 'expenses.delete',

    // Accounting
    'AccountingController@cashBook' => 'accounting.view',
    'AccountingController@bankBook' => 'accounting.view',
    'AccountingController@dayBook'  => 'accounting.view',
    'AccountingController@income'   => 'accounting.view',

    // Reports
    'ReportController@index'       => 'reports.view',
    'ReportController@daily'       => 'reports.view',
    'ReportController@weekly'      => 'reports.view',
    'ReportController@monthly'     => 'reports.view',
    'ReportController@yearly'      => 'reports.view',
    'ReportController@orders'      => 'reports.view',
    'ReportController@customer'    => 'reports.view',
    'ReportController@trip'        => 'reports.view',
    'ReportController@labour'      => 'reports.view',
    'ReportController@driver'      => 'reports.view',
    'ReportController@vehicle'     => 'reports.view',
    'ReportController@expense'     => 'reports.view',
    'ReportController@diesel'      => 'reports.view',
    'ReportController@profit'      => 'reports.view',
    'ReportController@outstanding' => 'reports.view',
    'ReportController@export'      => 'reports.export',

    // Documents & Search
    'DocumentController@index'      => 'documents.view',
    'DocumentController@uploadForm' => 'documents.upload',
    'DocumentController@upload'     => 'documents.upload',
    'DocumentController@show'       => 'documents.view',
    'DocumentController@download'   => 'documents.download',
    'DocumentController@delete'     => 'documents.delete',
    'SearchController@index'    => 'search.view',
    'SearchController@api'      => 'search.view',

    // Settings & Backup (admin only — checked in controller too)
    'SettingsController@index'       => 'settings.view',
    'SettingsController@about'       => 'settings.view',
    'SettingsController@update'      => 'settings.edit',
    'SettingsController@users'       => 'settings.users',
    'SettingsController@storeUser'   => 'settings.users',
    'SettingsController@updateUser'  => 'settings.users',
    'SettingsController@activityLog' => 'settings.view',
    'BackupController@index'    => 'backup.view',
    'BackupController@create'   => 'backup.create',
    'BackupController@download' => 'backup.view',
    'BackupController@restore'  => 'backup.restore',
];
