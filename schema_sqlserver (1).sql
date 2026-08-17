-- ============================================================
-- EMPLOYEE SECURITY MANAGEMENT SYSTEM (ESMS)
-- SQL Server (T-SQL) Schema  —  No GO statements
-- ============================================================

-- TABLE 1: DEPARTMENTS
CREATE TABLE Departments (
    dept_id       INT           PRIMARY KEY IDENTITY(1,1),
    dept_name     NVARCHAR(100) NOT NULL UNIQUE,
    dept_location NVARCHAR(150),
    manager_id    INT,
    created_at    DATETIME2     DEFAULT GETDATE()
);

-- TABLE 2: EMPLOYEES
CREATE TABLE Employees (
    emp_id           INT           PRIMARY KEY IDENTITY(1,1),
    emp_code         NVARCHAR(20)  NOT NULL UNIQUE,
    first_name       NVARCHAR(50)  NOT NULL,
    last_name        NVARCHAR(50)  NOT NULL,
    email            NVARCHAR(100) NOT NULL UNIQUE,
    phone            NVARCHAR(20),
    dept_id          INT           NOT NULL,
    designation      NVARCHAR(100),
    employment_type  NVARCHAR(20)  NOT NULL DEFAULT 'Full-Time'
                     CHECK (employment_type IN ('Full-Time','Part-Time','Contract','Intern')),
    hire_date        DATE          NOT NULL,
    termination_date DATE,
    status           NVARCHAR(20)  NOT NULL DEFAULT 'Active'
                     CHECK (status IN ('Active','Inactive','Suspended','Terminated')),
    created_at       DATETIME2     DEFAULT GETDATE(),
    CONSTRAINT FK_Emp_Dept FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

-- Add manager FK to Departments now that Employees exists
ALTER TABLE Departments
    ADD CONSTRAINT FK_Dept_Manager
    FOREIGN KEY (manager_id) REFERENCES Employees(emp_id);

-- TABLE 3: SECURITY ROLES
CREATE TABLE Security_Roles (
    role_id          INT           PRIMARY KEY IDENTITY(1,1),
    role_name        NVARCHAR(100) NOT NULL UNIQUE,
    role_description NVARCHAR(MAX),
    clearance_level  TINYINT       NOT NULL
                     CHECK (clearance_level BETWEEN 1 AND 5),
    is_active        BIT           NOT NULL DEFAULT 1,
    created_at       DATETIME2     DEFAULT GETDATE()
);

-- TABLE 4: EMPLOYEE SECURITY ROLES
CREATE TABLE Employee_Roles (
    assignment_id INT  PRIMARY KEY IDENTITY(1,1),
    emp_id        INT  NOT NULL,
    role_id       INT  NOT NULL,
    assigned_by   INT  NOT NULL,
    assigned_date DATE NOT NULL,
    expiry_date   DATE,
    is_active     BIT  NOT NULL DEFAULT 1,
    CONSTRAINT FK_ER_Emp      FOREIGN KEY (emp_id)      REFERENCES Employees(emp_id),
    CONSTRAINT FK_ER_Role     FOREIGN KEY (role_id)     REFERENCES Security_Roles(role_id),
    CONSTRAINT FK_ER_AssignBy FOREIGN KEY (assigned_by) REFERENCES Employees(emp_id),
    CONSTRAINT UQ_EmpRole     UNIQUE (emp_id, role_id)
);

-- TABLE 5: SECURITY ZONES
CREATE TABLE Security_Zones (
    zone_id          INT           PRIMARY KEY IDENTITY(1,1),
    zone_name        NVARCHAR(100) NOT NULL UNIQUE,
    zone_description NVARCHAR(255),
    building         NVARCHAR(100),
    floor_number     INT,
    min_clearance    TINYINT       NOT NULL
                     CHECK (min_clearance BETWEEN 1 AND 5),
    is_active        BIT           NOT NULL DEFAULT 1
);

-- TABLE 6: ACCESS CONTROL POLICIES
CREATE TABLE Access_Policies (
    policy_id    INT           PRIMARY KEY IDENTITY(1,1),
    policy_name  NVARCHAR(150) NOT NULL UNIQUE,
    zone_id      INT           NOT NULL,
    role_id      INT           NOT NULL,
    access_type  NVARCHAR(10)  NOT NULL DEFAULT 'Allow'
                 CHECK (access_type IN ('Allow','Deny')),
    time_start   TIME,
    time_end     TIME,
    days_allowed NVARCHAR(50),
    valid_from   DATE          NOT NULL,
    valid_until  DATE,
    created_by   INT           NOT NULL,
    created_at   DATETIME2     DEFAULT GETDATE(),
    CONSTRAINT FK_AP_Zone      FOREIGN KEY (zone_id)    REFERENCES Security_Zones(zone_id),
    CONSTRAINT FK_AP_Role      FOREIGN KEY (role_id)    REFERENCES Security_Roles(role_id),
    CONSTRAINT FK_AP_CreatedBy FOREIGN KEY (created_by) REFERENCES Employees(emp_id)
);

-- TABLE 7: ACCESS CARDS
CREATE TABLE Access_Cards (
    card_id      INT          PRIMARY KEY IDENTITY(1,1),
    card_number  NVARCHAR(50) NOT NULL UNIQUE,
    emp_id       INT,
    issued_date  DATE         NOT NULL,
    expiry_date  DATE         NOT NULL,
    card_type    NVARCHAR(20) NOT NULL DEFAULT 'Standard'
                 CHECK (card_type IN ('Standard','Temporary','Visitor','Master')),
    status       NVARCHAR(20) NOT NULL DEFAULT 'Active'
                 CHECK (status IN ('Active','Inactive','Lost','Expired','Revoked')),
    issued_by    INT          NOT NULL,
    CONSTRAINT FK_AC_Emp      FOREIGN KEY (emp_id)    REFERENCES Employees(emp_id),
    CONSTRAINT FK_AC_IssuedBy FOREIGN KEY (issued_by) REFERENCES Employees(emp_id)
);

-- TABLE 8: ACCESS LOGS
CREATE TABLE Access_Logs (
    log_id        BIGINT       PRIMARY KEY IDENTITY(1,1),
    emp_id        INT,
    card_id       INT,
    zone_id       INT          NOT NULL,
    access_time   DATETIME2    NOT NULL DEFAULT GETDATE(),
    access_type   NVARCHAR(10) NOT NULL CHECK (access_type IN ('Entry','Exit')),
    result        NVARCHAR(10) NOT NULL CHECK (result      IN ('Granted','Denied','Timeout')),
    denial_reason NVARCHAR(200),
    terminal_id   NVARCHAR(50),
    CONSTRAINT FK_AL_Emp  FOREIGN KEY (emp_id)  REFERENCES Employees(emp_id),
    CONSTRAINT FK_AL_Card FOREIGN KEY (card_id) REFERENCES Access_Cards(card_id),
    CONSTRAINT FK_AL_Zone FOREIGN KEY (zone_id) REFERENCES Security_Zones(zone_id)
);

CREATE INDEX IX_AL_AccessTime ON Access_Logs (access_time);
CREATE INDEX IX_AL_EmpTime    ON Access_Logs (emp_id, access_time);

-- TABLE 9: SECURITY INCIDENTS
CREATE TABLE Security_Incidents (
    incident_id     INT           PRIMARY KEY IDENTITY(1,1),
    title           NVARCHAR(200) NOT NULL,
    description     NVARCHAR(MAX),
    severity        NVARCHAR(10)  NOT NULL
                    CHECK (severity IN ('Low','Medium','High','Critical')),
    incident_type   NVARCHAR(50)  NOT NULL
                    CHECK (incident_type IN (
                        'Unauthorized Access','Tailgating','Stolen Card',
                        'Suspicious Activity','Data Breach','Violence',
                        'Equipment Theft','Policy Violation','Other')),
    zone_id         INT,
    reported_by     INT           NOT NULL,
    emp_involved    INT,
    incident_date   DATETIME2     NOT NULL,
    reported_date   DATETIME2     DEFAULT GETDATE(),
    status          NVARCHAR(25)  NOT NULL DEFAULT 'Open'
                    CHECK (status IN ('Open','Under Investigation','Resolved','Closed')),
    resolution_note NVARCHAR(MAX),
    resolved_by     INT,
    resolved_date   DATETIME2,
    CONSTRAINT FK_SI_Zone      FOREIGN KEY (zone_id)      REFERENCES Security_Zones(zone_id),
    CONSTRAINT FK_SI_ReportBy  FOREIGN KEY (reported_by)  REFERENCES Employees(emp_id),
    CONSTRAINT FK_SI_Involved  FOREIGN KEY (emp_involved) REFERENCES Employees(emp_id),
    CONSTRAINT FK_SI_ResolveBy FOREIGN KEY (resolved_by)  REFERENCES Employees(emp_id)
);

-- TABLE 10: SECURITY TRAININGS
CREATE TABLE Security_Trainings (
    training_id    INT            PRIMARY KEY IDENTITY(1,1),
    training_name  NVARCHAR(200)  NOT NULL,
    description    NVARCHAR(MAX),
    trainer        NVARCHAR(100),
    duration_hours DECIMAL(4,1),
    is_mandatory   BIT            NOT NULL DEFAULT 0,
    valid_months   INT            DEFAULT 12,
    created_at     DATETIME2      DEFAULT GETDATE()
);

-- TABLE 11: TRAINING RECORDS
CREATE TABLE Training_Records (
    record_id       INT           PRIMARY KEY IDENTITY(1,1),
    emp_id          INT           NOT NULL,
    training_id     INT           NOT NULL,
    completion_date DATE          NOT NULL,
    score           DECIMAL(5,2),
    passed          BIT           NOT NULL,
    certificate_no  NVARCHAR(100),
    expiry_date     DATE,
    notes           NVARCHAR(MAX),
    CONSTRAINT FK_TR_Emp      FOREIGN KEY (emp_id)      REFERENCES Employees(emp_id),
    CONSTRAINT FK_TR_Training FOREIGN KEY (training_id) REFERENCES Security_Trainings(training_id)
);

-- TABLE 12: AUDIT TRAIL
CREATE TABLE Audit_Trail (
    audit_id   BIGINT        PRIMARY KEY IDENTITY(1,1),
    table_name NVARCHAR(100) NOT NULL,
    record_id  INT           NOT NULL,
    action     NVARCHAR(10)  NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
    changed_by INT           NOT NULL,
    changed_at DATETIME2     DEFAULT GETDATE(),
    old_values NVARCHAR(MAX),
    new_values NVARCHAR(MAX),
    ip_address NVARCHAR(45),
    CONSTRAINT FK_AT_ChangedBy FOREIGN KEY (changed_by) REFERENCES Employees(emp_id)
);

CREATE INDEX IX_AT_Table ON Audit_Trail (table_name, record_id);
CREATE INDEX IX_AT_Time  ON Audit_Trail (changed_at);
