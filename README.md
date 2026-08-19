# Employee Security Management System (ESMS)

A SQL Server (T-SQL) database system for managing employee records with a focus on security — including role-based access control, security clearance levels, and access card tracking.

## Features

- Normalized relational schema with foreign key constraints across Departments, Employees, Security Roles, and Access Cards
- Role-based access control with 5-tier security clearance levels (Guest to Top Secret)
- Employee-role assignment tracking with expiry dates
- Views, stored procedures, and triggers for common security operations
- Sample data for testing and demonstration

## Tech Stack

- SQL Server (T-SQL)

## Files

- `schema_sqlserver.sql` — Database schema (tables, constraints, relationships)
- `data_sqlserver.sql` — Sample data inserts
- `queries_sqlserver.sql` — Queries, views, stored procedures, and triggers

## How to Use

Run the files in order in SQL Server Management Studio (SSMS) or Azure Data Studio:
```sql
1. schema_sqlserver.sql   -- creates tables and relationships
2. data_sqlserver.sql     -- inserts sample data
3. queries_sqlserver.sql  -- run individual queries as needed
```

## What This Project Demonstrates

Database design principles for security-sensitive systems: normalized schema design, referential integrity, role-based access control modeling, and clearance-level access management — concepts directly applicable to enterprise identity and access management (IAM) systems.

## Contact

Open to freelance work in SQL, database design, and security tooling. Reach out via Fiverr or GitHub.
