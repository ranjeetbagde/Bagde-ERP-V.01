# Bagde ERP

**Building Material & Transport Management System**

Production-ready ERP software for Building Material Suppliers, Sand Transport Business, Tractor Owners, and Construction Material Dealers.

## Requirements

- PHP 8.2+
- MySQL 5.7+ / MariaDB 10.3+
- Apache with mod_rewrite (cPanel compatible)
- Extensions: PDO, pdo_mysql, mbstring, json, gd

## Installation (cPanel)

1. Upload the `BagdeERP` folder to your hosting (e.g., `public_html/bagdeerp/`)
2. Create a MySQL database and user in cPanel
3. Ensure these folders are writable: `config/`, `storage/`, `public/uploads/`
4. Visit `https://yourdomain.com/bagdeerp/install/install.php`
5. Follow the 5-step installer:
   - Requirements check
   - Database configuration
   - Company information
   - Admin account creation
6. Login and start using the system

## Default Login (after install)

Use the admin credentials you set during installation.

## Project Structure

```
BagdeERP/
├── app/
│   ├── Controllers/    # Request handlers
│   ├── Models/         # Data layer
│   ├── Views/          # Templates
│   ├── Core/           # Framework (Router, Database, Auth)
│   └── Helpers/        # Utilities
├── config/             # Configuration & routes
├── database/           # SQL schema & seed
├── install/            # Web installer
├── public/assets/      # CSS, JS, images
├── public/uploads/     # User uploads
├── storage/            # Logs, cache, backups
└── index.php           # Front controller
```

## Modules

| Module | Description |
|--------|-------------|
| Dashboard | Today's stats, profit chart, quick actions |
| Customers | Master, ledger, payments, statement |
| Orders | Auto numbering, advance, trip tracking |
| Trips | Core module - profit calculation, ledger updates |
| Labours | Trip earnings, advance, weekly payment |
| Drivers | Master, advance, payment, ledger |
| Diesel | Purchase & consumption tracking |
| Stock | Materials, purchase, ledger |
| Expenses | Category-wise expense tracking |
| Challans | Delivery challan PDF/print |
| Invoices | Tax/Non-GST/Proforma invoices |
| Payments | Cash/UPI/Bank/Cheque |
| Accounting | Cash book, bank book, day book |
| Reports | Daily/weekly/monthly reports |
| Settings | Company info, users, permissions |
| Backup | Database backup & restore |

## Business Workflow

```
Customer → Order → Advance Payment → Trip Entry → Labour/Driver/Diesel
→ Expenses → Delivery Challan → Invoice → Customer Payment → Reports
```

## Auto Numbering

- Orders: `ORD-000001`
- Trips: `TRP-000001`
- Invoices: `INV-000001`
- Challans: `DC-000001`
- Labour Payments: `LPR-000001`

## Security

- Prepared statements (PDO)
- CSRF protection
- XSS sanitization
- Password hashing (bcrypt)
- Role-based permissions
- Soft delete
- Activity audit log

## Optional: Composer Dependencies

For PDF export (DomPDF) and Excel export (PhpSpreadsheet):

```bash
composer install
```

These are optional — the system works with HTML print views by default.

## Support

Bagde Building Material Supplier — A unit of Bagde Enterprise
