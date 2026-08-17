-- ============================================================
-- EMPLOYEE SECURITY MANAGEMENT SYSTEM
-- SQL Server Sample Data  —  No GO statements
-- ============================================================

-- DEPARTMENTS
SET IDENTITY_INSERT Departments ON;
INSERT INTO Departments (dept_id, dept_name, dept_location) VALUES
(1, 'Information Technology', 'Block A, Floor 3'),
(2, 'Human Resources',        'Block B, Floor 1'),
(3, 'Finance',                'Block B, Floor 2'),
(4, 'Operations',             'Block C, Ground Floor'),
(5, 'Security & Compliance',  'Block A, Floor 1'),
(6, 'Research & Development', 'Block D, Floor 4'),
(7, 'Executive',              'Block A, Floor 5');
SET IDENTITY_INSERT Departments OFF;

-- SECURITY ROLES
SET IDENTITY_INSERT Security_Roles ON;
INSERT INTO Security_Roles (role_id, role_name, role_description, clearance_level) VALUES
(1, 'Guest',            'Temporary visitor — public areas only',           1),
(2, 'Standard User',    'Regular employee access to general areas',        2),
(3, 'IT Staff',         'Access to server rooms and IT infrastructure',    3),
(4, 'Finance Staff',    'Access to finance vaults and sensitive records',  3),
(5, 'HR Staff',         'Access to HR records and sensitive employee data',3),
(6, 'Security Officer', 'Access to all non-classified zones',              4),
(7, 'Senior Manager',   'Elevated access including management floors',     4),
(8, 'Executive',        'Unrestricted access to all zones',                5),
(9, 'System Admin',     'Full system and physical access for maintenance', 5);
SET IDENTITY_INSERT Security_Roles OFF;

-- EMPLOYEES
SET IDENTITY_INSERT Employees ON;
INSERT INTO Employees (emp_id, emp_code, first_name, last_name, email, phone, dept_id, designation, hire_date) VALUES
(1,  'EMP001', 'Ahmed',  'Khan',     'ahmed.khan@esms.com',   '0321-1111111', 1, 'IT Manager',         '2018-03-15'),
(2,  'EMP002', 'Sara',   'Ali',      'sara.ali@esms.com',      '0321-2222222', 2, 'HR Director',        '2017-06-01'),
(3,  'EMP003', 'Omar',   'Malik',    'omar.malik@esms.com',    '0321-3333333', 3, 'CFO',                '2016-01-10'),
(4,  'EMP004', 'Fatima', 'Raza',     'fatima.raza@esms.com',   '0321-4444444', 5, 'Security Admin',     '2019-08-20'),
(5,  'EMP005', 'Hassan', 'Sheikh',   'hassan.sheikh@esms.com', '0321-5555555', 1, 'Network Engineer',   '2020-02-01'),
(6,  'EMP006', 'Ayesha', 'Siddiqui', 'ayesha.s@esms.com',      '0321-6666666', 6, 'R&D Lead',           '2019-11-15'),
(7,  'EMP007', 'Bilal',  'Ahmed',    'bilal.ahmed@esms.com',   '0321-7777777', 4, 'Operations Manager', '2021-05-10'),
(8,  'EMP008', 'Zara',   'Hussain',  'zara.hussain@esms.com',  '0321-8888888', 7, 'CEO',                '2015-01-01'),
(9,  'EMP009', 'Imran',  'Qureshi',  'imran.q@esms.com',       '0321-9999999', 5, 'Security Officer',   '2022-01-15'),
(10, 'EMP010', 'Nadia',  'Baig',     'nadia.baig@esms.com',    '0321-1011100', 3, 'Financial Analyst',  '2021-09-01'),
(11, 'EMP011', 'Tariq',  'Farooq',   'tariq.farooq@esms.com',  '0321-1111200', 1, 'Software Developer', '2023-03-01'),
(12, 'EMP012', 'Maria',  'Iqbal',    'maria.iqbal@esms.com',   '0321-1112300', 2, 'HR Officer',         '2022-07-15');
SET IDENTITY_INSERT Employees OFF;

-- Update department managers
UPDATE Departments SET manager_id = 1 WHERE dept_id = 1;
UPDATE Departments SET manager_id = 2 WHERE dept_id = 2;
UPDATE Departments SET manager_id = 3 WHERE dept_id = 3;
UPDATE Departments SET manager_id = 7 WHERE dept_id = 4;
UPDATE Departments SET manager_id = 4 WHERE dept_id = 5;
UPDATE Departments SET manager_id = 6 WHERE dept_id = 6;
UPDATE Departments SET manager_id = 8 WHERE dept_id = 7;

-- EMPLOYEE ROLES
INSERT INTO Employee_Roles (emp_id, role_id, assigned_by, assigned_date) VALUES
(1,  3, 4, '2018-03-15'),
(2,  5, 4, '2017-06-01'),
(3,  7, 4, '2016-01-10'),
(4,  6, 4, '2019-08-20'),
(5,  3, 4, '2020-02-01'),
(6,  2, 4, '2019-11-15'),
(7,  7, 4, '2021-05-10'),
(8,  8, 4, '2015-01-01'),
(9,  6, 4, '2022-01-15'),
(10, 4, 4, '2021-09-01'),
(11, 2, 4, '2023-03-01'),
(12, 5, 4, '2022-07-15');

-- SECURITY ZONES
SET IDENTITY_INSERT Security_Zones ON;
INSERT INTO Security_Zones (zone_id, zone_name, zone_description, building, floor_number, min_clearance) VALUES
(1,  'Main Lobby',       'Public entrance and reception',          'Block A',  0,  1),
(2,  'General Office',   'Open office area for all staff',         'Block B',  1,  2),
(3,  'IT Server Room',   'Primary data center',                    'Block A',  3,  3),
(4,  'Finance Vault',    'Secure document and cash storage',       'Block B',  2,  3),
(5,  'HR Records Room',  'Confidential personnel files',           'Block B',  1,  3),
(6,  'Security Control', 'CCTV and access control operations',     'Block A',  1,  4),
(7,  'R&D Lab',          'Research and development facility',      'Block D',  4,  3),
(8,  'Executive Suite',  'CEO and board meeting rooms',            'Block A',  5,  4),
(9,  'Parking Garage',   'Employee vehicle access',                'Ground',  -1,  2),
(10, 'Data Center B2',   'Backup data center — high security',    'Block A', -1,  5);
SET IDENTITY_INSERT Security_Zones OFF;

-- ACCESS POLICIES
INSERT INTO Access_Policies (policy_name, zone_id, role_id, access_type, time_start, time_end, days_allowed, valid_from, created_by) VALUES
('Standard-GeneralOffice', 2, 2, 'Allow', '07:00', '20:00', 'Mon,Tue,Wed,Thu,Fri',         '2024-01-01', 4),
('IT-ServerRoom',           3, 3, 'Allow', '08:00', '22:00', 'Mon,Tue,Wed,Thu,Fri,Sat',    '2024-01-01', 4),
('Finance-Vault',           4, 4, 'Allow', '09:00', '18:00', 'Mon,Tue,Wed,Thu,Fri',         '2024-01-01', 4),
('HR-RecordsRoom',          5, 5, 'Allow', '09:00', '18:00', 'Mon,Tue,Wed,Thu,Fri',         '2024-01-01', 4),
('Security-ControlRoom',    6, 6, 'Allow', '00:00', '23:59', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', '2024-01-01', 4),
('Manager-Executive',       8, 7, 'Allow', '08:00', '21:00', 'Mon,Tue,Wed,Thu,Fri',         '2024-01-01', 4),
('Executive-All',           8, 8, 'Allow', '00:00', '23:59', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', '2024-01-01', 4),
('Parking-Standard',        9, 2, 'Allow', '06:00', '22:00', 'Mon,Tue,Wed,Thu,Fri,Sat',    '2024-01-01', 4),
('DataCenterB2-Admin',     10, 9, 'Allow', '00:00', '23:59', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', '2024-01-01', 4);

-- ACCESS CARDS
SET IDENTITY_INSERT Access_Cards ON;
INSERT INTO Access_Cards (card_id, card_number, emp_id, issued_date, expiry_date, card_type, issued_by) VALUES
(1,  'CRD-2024-001', 1,    '2024-01-01', '2026-01-01', 'Standard', 4),
(2,  'CRD-2024-002', 2,    '2024-01-01', '2026-01-01', 'Standard', 4),
(3,  'CRD-2024-003', 3,    '2024-01-01', '2026-01-01', 'Standard', 4),
(4,  'CRD-2024-004', 4,    '2024-01-01', '2026-01-01', 'Master',   4),
(5,  'CRD-2024-005', 5,    '2024-01-01', '2026-01-01', 'Standard', 4),
(6,  'CRD-2024-006', 6,    '2024-01-01', '2026-01-01', 'Standard', 4),
(7,  'CRD-2024-007', 7,    '2024-01-01', '2026-01-01', 'Standard', 4),
(8,  'CRD-2024-008', 8,    '2024-01-01', '2026-01-01', 'Master',   4),
(9,  'CRD-2024-009', 9,    '2024-01-01', '2026-01-01', 'Standard', 4),
(10, 'CRD-2024-010', 10,   '2024-01-01', '2026-01-01', 'Standard', 4),
(11, 'CRD-2024-011', 11,   '2024-01-01', '2026-01-01', 'Standard', 4),
(12, 'CRD-2024-012', 12,   '2024-01-01', '2026-01-01', 'Standard', 4),
(13, 'CRD-TEMP-001', NULL, '2025-06-01', '2025-06-07', 'Visitor',  4);
SET IDENTITY_INSERT Access_Cards OFF;

-- ACCESS LOGS
INSERT INTO Access_Logs (emp_id, card_id, zone_id, access_time, access_type, result, terminal_id) VALUES
(1,  1,  1, '2025-06-01 08:05:00', 'Entry', 'Granted', 'TRM-A01'),
(1,  1,  3, '2025-06-01 08:15:00', 'Entry', 'Granted', 'TRM-A05'),
(1,  1,  3, '2025-06-01 12:30:00', 'Exit',  'Granted', 'TRM-A05'),
(2,  2,  2, '2025-06-01 09:00:00', 'Entry', 'Granted', 'TRM-B01'),
(5,  5,  3, '2025-06-01 08:20:00', 'Entry', 'Granted', 'TRM-A05'),
(11, 11, 3, '2025-06-01 10:00:00', 'Entry', 'Denied',  'TRM-A05'),
(11, 11, 2, '2025-06-01 10:02:00', 'Entry', 'Granted', 'TRM-B01'),
(8,  8,  8, '2025-06-02 09:30:00', 'Entry', 'Granted', 'TRM-A09'),
(4,  4,  6, '2025-06-02 07:00:00', 'Entry', 'Granted', 'TRM-A02'),
(9,  9,  6, '2025-06-02 07:05:00', 'Entry', 'Granted', 'TRM-A02'),
(10, 10, 4, '2025-06-03 20:00:00', 'Entry', 'Denied',  'TRM-B03'),
(3,  3,  8, '2025-06-03 10:00:00', 'Entry', 'Granted', 'TRM-A09'),
(6,  6,  7, '2025-06-03 11:00:00', 'Entry', 'Granted', 'TRM-D01'),
(12, 12, 5, '2025-06-04 09:15:00', 'Entry', 'Granted', 'TRM-B02');

UPDATE Access_Logs SET denial_reason = 'Insufficient clearance level'   WHERE log_id = 6;
UPDATE Access_Logs SET denial_reason = 'Access outside permitted hours'  WHERE log_id = 11;

-- SECURITY INCIDENTS
SET IDENTITY_INSERT Security_Incidents ON;
INSERT INTO Security_Incidents (incident_id, title, description, severity, incident_type, zone_id, reported_by, emp_involved, incident_date, status) VALUES
(1, 'Tailgating at Server Room',
    'Unknown individual followed EMP011 through a secured door.',
    'High', 'Tailgating', 3, 9, 11, '2025-05-20 10:15:00', 'Resolved'),
(2, 'Lost Access Card — EMP010',
    'Nadia Baig reported her card lost; card was revoked immediately.',
    'Medium', 'Stolen Card', NULL, 10, 10, '2025-05-25 14:00:00', 'Closed'),
(3, 'Suspicious Activity in Parking',
    'Unknown vehicle observed loitering near executive parking area.',
    'Medium', 'Suspicious Activity', 9, 9, NULL, '2025-06-01 22:30:00', 'Under Investigation'),
(4, 'Policy Violation — Data Sharing',
    'EMP006 shared R&D documents via personal email account.',
    'High', 'Policy Violation', 7, 2, 6, '2025-06-02 16:00:00', 'Open');
SET IDENTITY_INSERT Security_Incidents OFF;

UPDATE Security_Incidents
SET    resolved_by = 4, resolved_date = '2025-05-21 09:00:00',
       resolution_note = 'Guest escorted out; EMP011 given tailgating awareness training. CCTV footage reviewed.'
WHERE  incident_id = 1;

UPDATE Security_Incidents
SET    resolved_by = 4, resolved_date = '2025-05-25 15:30:00',
       resolution_note = 'Card CRD-2024-010 revoked. New card issued. No unauthorized access detected.'
WHERE  incident_id = 2;

-- SECURITY TRAININGS
SET IDENTITY_INSERT Security_Trainings ON;
INSERT INTO Security_Trainings (training_id, training_name, description, trainer, duration_hours, is_mandatory, valid_months) VALUES
(1, 'Security Awareness Basics',       'Foundational security policies and procedures for all staff.',  'Fatima Raza',   2.0, 1, 12),
(2, 'Physical Access Control',         'Proper card use, tailgating prevention, zone awareness.',       'Imran Qureshi', 3.0, 1, 24),
(3, 'Data Protection & Privacy',       'GDPR, data classification, and handling sensitive information.','Sara Ali',      4.0, 1, 12),
(4, 'Incident Reporting Procedures',   'How to identify and report security incidents promptly.',       'Fatima Raza',   2.0, 1, 12),
(5, 'Executive Security Protocol',     'Advanced security training for senior staff.',                  'Ahmed Khan',    6.0, 0, 24),
(6, 'Fire Safety & Emergency Drills',  'Emergency evacuation procedures and fire safety.',              'External',      3.0, 1, 12);
SET IDENTITY_INSERT Security_Trainings OFF;

-- TRAINING RECORDS
INSERT INTO Training_Records (emp_id, training_id, completion_date, score, passed, certificate_no, expiry_date) VALUES
(1,  1, '2024-02-01', 95.0, 1, 'CERT-001-001',  '2025-02-01'),
(1,  2, '2024-02-05', 90.0, 1, 'CERT-001-002',  '2026-02-05'),
(2,  1, '2024-02-01', 88.0, 1, 'CERT-002-001',  '2025-02-01'),
(2,  3, '2024-03-10', 92.0, 1, 'CERT-002-003',  '2025-03-10'),
(4,  1, '2024-01-15', 99.0, 1, 'CERT-004-001',  '2025-01-15'),
(4,  2, '2024-01-15', 98.0, 1, 'CERT-004-002',  '2026-01-15'),
(4,  4, '2024-01-15', 97.0, 1, 'CERT-004-004',  '2025-01-15'),
(5,  1, '2024-02-10', 85.0, 1, 'CERT-005-001',  '2025-02-10'),
(5,  2, '2024-02-12', 80.0, 1, 'CERT-005-002',  '2026-02-12'),
(8,  5, '2024-03-01', 94.0, 1, 'CERT-008-005',  '2026-03-01'),
(11, 1, '2023-03-15', 72.0, 1, 'CERT-011-001',  '2024-03-15'),  -- Expired
(11, 4, '2023-04-01', 68.0, 1, 'CERT-011-004',  '2024-04-01'),  -- Expired
(12, 1, '2022-08-01', 88.0, 1, 'CERT-012-001',  '2023-08-01'),  -- Expired
(6,  3, '2024-04-01', 55.0, 0, 'CERT-006-003F', '2025-04-01');  -- Failed
