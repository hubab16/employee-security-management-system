-- ============================================================
-- EMPLOYEE SECURITY MANAGEMENT SYSTEM
-- SQL Server (T-SQL) Queries, Views, Procedures & Triggers
-- No GO statements
-- ============================================================

-- ===========================================================
-- SECTION A: BASIC QUERIES
-- ===========================================================

-- Q1. All active employees with department name
SELECT e.emp_code,
       e.first_name + ' ' + e.last_name AS employee_name,
       d.dept_name,
       e.designation,
       e.status
FROM   Employees   e
JOIN   Departments d ON e.dept_id = d.dept_id
WHERE  e.status = 'Active'
ORDER  BY d.dept_name, e.last_name;

-- Q2. Security roles with readable clearance labels
SELECT role_name,
       CASE clearance_level
           WHEN 1 THEN '1 - Guest'
           WHEN 2 THEN '2 - Standard'
           WHEN 3 THEN '3 - Elevated'
           WHEN 4 THEN '4 - Confidential'
           WHEN 5 THEN '5 - Top Secret'
       END AS clearance_label,
       role_description
FROM   Security_Roles
WHERE  is_active = 1
ORDER  BY clearance_level;

-- Q3. Access cards and their assigned employees
SELECT ac.card_number,
       ac.card_type,
       ac.status,
       ISNULL(e.first_name + ' ' + e.last_name, 'Unassigned') AS holder,
       ac.issued_date,
       ac.expiry_date
FROM   Access_Cards ac
LEFT JOIN Employees e ON ac.emp_id = e.emp_id
ORDER  BY ac.status, ac.card_number;

-- Q4. Open and under-investigation incidents sorted by severity
SELECT incident_id,
       title,
       severity,
       incident_type,
       reported_date,
       status
FROM   Security_Incidents
WHERE  status IN ('Open', 'Under Investigation')
ORDER  BY CASE severity
              WHEN 'Critical' THEN 1
              WHEN 'High'     THEN 2
              WHEN 'Medium'   THEN 3
              ELSE 4
          END;

-- Q5. Active employees who have never attended any training
SELECT e.emp_code,
       e.first_name + ' ' + e.last_name AS employee_name,
       e.designation
FROM   Employees e
WHERE  e.status = 'Active'
  AND  e.emp_id NOT IN (SELECT DISTINCT emp_id FROM Training_Records);

-- ===========================================================
-- SECTION B: INTERMEDIATE QUERIES
-- ===========================================================

-- Q6. Monthly access summary — granted vs denied per employee
SELECT e.first_name + ' ' + e.last_name                          AS employee_name,
       SUM(CASE WHEN al.result = 'Granted' THEN 1 ELSE 0 END)   AS granted,
       SUM(CASE WHEN al.result = 'Denied'  THEN 1 ELSE 0 END)   AS denied,
       COUNT(*)                                                   AS total_attempts
FROM   Access_Logs al
JOIN   Employees   e ON al.emp_id = e.emp_id
WHERE  al.access_time >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
GROUP  BY e.emp_id, e.first_name, e.last_name
ORDER  BY denied DESC;

-- Q7. Employees with expired mandatory training certificates
SELECT e.emp_code,
       e.first_name + ' ' + e.last_name AS employee_name,
       st.training_name,
       tr.completion_date,
       tr.expiry_date,
       DATEDIFF(DAY, tr.expiry_date, CAST(GETDATE() AS DATE)) AS days_overdue
FROM   Training_Records   tr
JOIN   Employees          e  ON tr.emp_id      = e.emp_id
JOIN   Security_Trainings st ON tr.training_id = st.training_id
WHERE  st.is_mandatory = 1
  AND  tr.expiry_date  < CAST(GETDATE() AS DATE)
  AND  e.status        = 'Active'
ORDER  BY tr.expiry_date;

-- Q8. Top 5 zones with the most access denials
SELECT TOP 5
       sz.zone_name,
       sz.building,
       COUNT(*) AS denied_attempts
FROM   Access_Logs    al
JOIN   Security_Zones sz ON al.zone_id = sz.zone_id
WHERE  al.result = 'Denied'
GROUP  BY sz.zone_id, sz.zone_name, sz.building
ORDER  BY denied_attempts DESC;

-- Q9. Employee role assignments with validity status
SELECT e.first_name + ' ' + e.last_name AS employee_name,
       d.dept_name,
       sr.role_name,
       sr.clearance_level,
       er.assigned_date,
       er.expiry_date,
       CASE
           WHEN er.expiry_date IS NULL
             OR er.expiry_date >= CAST(GETDATE() AS DATE) THEN 'Valid'
           ELSE 'Expired'
       END AS role_status
FROM   Employee_Roles er
JOIN   Employees      e  ON er.emp_id  = e.emp_id
JOIN   Departments    d  ON e.dept_id  = d.dept_id
JOIN   Security_Roles sr ON er.role_id = sr.role_id
WHERE  e.status = 'Active'
ORDER  BY sr.clearance_level DESC, e.last_name;

-- Q10. Incident count by type and severity (cross-tab)
SELECT incident_type,
       SUM(CASE WHEN severity = 'Low'      THEN 1 ELSE 0 END) AS low_count,
       SUM(CASE WHEN severity = 'Medium'   THEN 1 ELSE 0 END) AS medium_count,
       SUM(CASE WHEN severity = 'High'     THEN 1 ELSE 0 END) AS high_count,
       SUM(CASE WHEN severity = 'Critical' THEN 1 ELSE 0 END) AS critical_count,
       COUNT(*)                                                AS total
FROM   Security_Incidents
GROUP  BY incident_type
ORDER  BY total DESC;

-- ===========================================================
-- SECTION C: ADVANCED QUERIES
-- ===========================================================

-- Q11. Access granted where clearance was below zone minimum
SELECT e.first_name + ' ' + e.last_name AS employee_name,
       sr.role_name,
       sr.clearance_level               AS emp_clearance,
       sz.zone_name,
       sz.min_clearance                 AS zone_min_clearance,
       al.access_time,
       al.result
FROM   Access_Logs    al
JOIN   Employees      e  ON al.emp_id  = e.emp_id
JOIN   Employee_Roles er ON e.emp_id   = er.emp_id AND er.is_active = 1
JOIN   Security_Roles sr ON er.role_id = sr.role_id
JOIN   Security_Zones sz ON al.zone_id = sz.zone_id
WHERE  sz.min_clearance > sr.clearance_level
  AND  al.result = 'Granted'
ORDER  BY al.access_time DESC;

-- Q12. Employee risk score (incidents x3, denials x1, expired training x2)
SELECT e.emp_code,
       e.first_name + ' ' + e.last_name AS employee_name,
       d.dept_name,
       ISNULL(inc.incident_count, 0)    AS incidents_involved,
       ISNULL(den.denial_count,   0)    AS access_denials,
       ISNULL(exp.expired_count,  0)    AS expired_trainings,
       (ISNULL(inc.incident_count, 0) * 3
      + ISNULL(den.denial_count,   0) * 1
      + ISNULL(exp.expired_count,  0) * 2) AS risk_score
FROM   Employees   e
JOIN   Departments d ON e.dept_id = d.dept_id
LEFT JOIN (
    SELECT emp_involved, COUNT(*) AS incident_count
    FROM   Security_Incidents
    WHERE  emp_involved IS NOT NULL
    GROUP  BY emp_involved
) inc ON e.emp_id = inc.emp_involved
LEFT JOIN (
    SELECT emp_id, COUNT(*) AS denial_count
    FROM   Access_Logs
    WHERE  result = 'Denied'
    GROUP  BY emp_id
) den ON e.emp_id = den.emp_id
LEFT JOIN (
    SELECT tr.emp_id, COUNT(*) AS expired_count
    FROM   Training_Records   tr
    JOIN   Security_Trainings st ON tr.training_id = st.training_id
    WHERE  st.is_mandatory = 1
      AND  tr.expiry_date  < CAST(GETDATE() AS DATE)
    GROUP  BY tr.emp_id
) exp ON e.emp_id = exp.emp_id
WHERE  e.status = 'Active'
ORDER  BY risk_score DESC;

-- Q13. Access pattern heatmap — hour of day x day of week
SELECT DATENAME(WEEKDAY, access_time)                            AS day_of_week,
       DATEPART(HOUR,    access_time)                            AS hour_of_day,
       COUNT(*)                                                  AS access_count,
       SUM(CASE WHEN result = 'Granted' THEN 1 ELSE 0 END)      AS granted,
       SUM(CASE WHEN result = 'Denied'  THEN 1 ELSE 0 END)      AS denied
FROM   Access_Logs
WHERE  access_time >= DATEADD(DAY, -30, GETDATE())
GROUP  BY DATENAME(WEEKDAY, access_time),
          DATEPART(WEEKDAY, access_time),
          DATEPART(HOUR,    access_time)
ORDER  BY DATEPART(WEEKDAY, access_time),
          DATEPART(HOUR,    access_time);

-- Q14. Training compliance matrix — per department per mandatory training
SELECT d.dept_name,
       st.training_name,
       COUNT(DISTINCT e.emp_id) AS total_employees,
       COUNT(DISTINCT CASE
             WHEN tr.passed = 1
              AND (tr.expiry_date IS NULL
                   OR tr.expiry_date >= CAST(GETDATE() AS DATE))
             THEN tr.emp_id END)                             AS compliant,
       COUNT(DISTINCT e.emp_id)
         - COUNT(DISTINCT CASE
                 WHEN tr.passed = 1
                  AND (tr.expiry_date IS NULL
                       OR tr.expiry_date >= CAST(GETDATE() AS DATE))
                 THEN tr.emp_id END)                         AS non_compliant,
       CAST(
           100.0
           * COUNT(DISTINCT CASE
                   WHEN tr.passed = 1
                    AND (tr.expiry_date IS NULL
                         OR tr.expiry_date >= CAST(GETDATE() AS DATE))
                   THEN tr.emp_id END)
           / COUNT(DISTINCT e.emp_id)
       AS DECIMAL(5,1))                                      AS compliance_pct
FROM   Departments        d
JOIN   Employees          e  ON d.dept_id      = e.dept_id AND e.status = 'Active'
INNER JOIN Security_Trainings st               ON st.is_mandatory = 1
LEFT JOIN  Training_Records   tr ON e.emp_id   = tr.emp_id
                                AND st.training_id = tr.training_id
GROUP  BY d.dept_name, st.training_id, st.training_name
ORDER  BY d.dept_name, st.training_name;

-- ===========================================================
-- SECTION D: VIEWS
-- ===========================================================

CREATE VIEW v_Employee_Security_Profile AS
SELECT e.emp_id,
       e.emp_code,
       e.first_name + ' ' + e.last_name AS employee_name,
       e.email,
       d.dept_name,
       e.designation,
       e.status,
       sr.role_name,
       sr.clearance_level,
       ac.card_number,
       ac.card_type,
       ac.status      AS card_status,
       ac.expiry_date AS card_expiry
FROM   Employees       e
JOIN   Departments     d  ON e.dept_id   = d.dept_id
LEFT JOIN Employee_Roles er ON e.emp_id  = er.emp_id  AND er.is_active = 1
LEFT JOIN Security_Roles sr ON er.role_id = sr.role_id
LEFT JOIN Access_Cards   ac ON e.emp_id  = ac.emp_id  AND ac.status    = 'Active';

CREATE VIEW v_Active_Incidents AS
SELECT si.incident_id,
       si.title,
       si.severity,
       si.incident_type,
       sz.zone_name,
       rep.first_name + ' ' + rep.last_name                 AS reported_by,
       ISNULL(inv.first_name + ' ' + inv.last_name, 'None') AS employee_involved,
       si.incident_date,
       si.status,
       DATEDIFF(DAY, CAST(si.incident_date AS DATE), CAST(GETDATE() AS DATE)) AS days_open
FROM   Security_Incidents si
LEFT JOIN Security_Zones sz ON si.zone_id      = sz.zone_id
JOIN   Employees rep         ON si.reported_by = rep.emp_id
LEFT JOIN Employees inv      ON si.emp_involved= inv.emp_id
WHERE  si.status IN ('Open', 'Under Investigation');

CREATE VIEW v_Todays_Access AS
SELECT al.log_id,
       al.access_time,
       ISNULL(e.first_name + ' ' + e.last_name, 'Unknown') AS employee_name,
       ac.card_number,
       sz.zone_name,
       al.access_type,
       al.result,
       al.denial_reason,
       al.terminal_id
FROM   Access_Logs    al
JOIN   Security_Zones sz ON al.zone_id = sz.zone_id
LEFT JOIN Employees    e  ON al.emp_id  = e.emp_id
LEFT JOIN Access_Cards ac ON al.card_id = ac.card_id
WHERE  CAST(al.access_time AS DATE) = CAST(GETDATE() AS DATE);

-- ===========================================================
-- SECTION E: STORED PROCEDURES
-- ===========================================================

CREATE PROCEDURE sp_IssueAccessCard
    @emp_id        INT,
    @card_type     NVARCHAR(20),
    @validity_days INT,
    @issued_by     INT,
    @card_number   NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @next_id INT;
    SELECT @next_id = ISNULL(MAX(card_id), 0) + 1 FROM Access_Cards;
    SET @card_number = 'CRD-' + CAST(YEAR(GETDATE()) AS NVARCHAR(4))
                     + '-' + RIGHT('0000' + CAST(@next_id AS NVARCHAR(4)), 4);
    INSERT INTO Access_Cards (card_number, emp_id, issued_date, expiry_date, card_type, issued_by)
    VALUES (@card_number,
            @emp_id,
            CAST(GETDATE() AS DATE),
            DATEADD(DAY, @validity_days, CAST(GETDATE() AS DATE)),
            @card_type,
            @issued_by);
    SELECT 'Card ' + @card_number + ' issued successfully.' AS message;
END;

CREATE PROCEDURE sp_RevokeCard
    @card_id  INT,
    @reason   NVARCHAR(200),
    @admin_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @old_status NVARCHAR(20);
    SELECT @old_status = status FROM Access_Cards WHERE card_id = @card_id;

    UPDATE Access_Cards
    SET    status = 'Revoked'
    WHERE  card_id = @card_id;

    INSERT INTO Audit_Trail (table_name, record_id, action, changed_by, old_values, new_values)
    VALUES ('Access_Cards',
            @card_id,
            'UPDATE',
            @admin_id,
            '{"status":"' + @old_status + '"}',
            '{"status":"Revoked","reason":"' + @reason + '"}');

    SELECT 'Card revoked and audit logged.' AS message;
END;

CREATE PROCEDURE sp_EmployeeSecurityReport
    @emp_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Basic profile
    SELECT emp_code,
           first_name + ' ' + last_name AS full_name,
           email,
           designation,
           status
    FROM   Employees
    WHERE  emp_id = @emp_id;

    -- Assigned roles
    SELECT sr.role_name, sr.clearance_level, er.assigned_date, er.expiry_date
    FROM   Employee_Roles er
    JOIN   Security_Roles sr ON er.role_id = sr.role_id
    WHERE  er.emp_id   = @emp_id
      AND  er.is_active = 1;

    -- Training summary
    SELECT st.training_name,
           tr.completion_date,
           tr.score,
           tr.passed,
           tr.expiry_date,
           CASE
               WHEN tr.expiry_date < CAST(GETDATE() AS DATE) THEN 'EXPIRED'
               ELSE 'Valid'
           END AS cert_status
    FROM   Training_Records   tr
    JOIN   Security_Trainings st ON tr.training_id = st.training_id
    WHERE  tr.emp_id = @emp_id
    ORDER  BY tr.completion_date DESC;

    -- Last 10 access events
    SELECT TOP 10
           sz.zone_name,
           al.access_time,
           al.access_type,
           al.result,
           al.denial_reason
    FROM   Access_Logs    al
    JOIN   Security_Zones sz ON al.zone_id = sz.zone_id
    WHERE  al.emp_id = @emp_id
    ORDER  BY al.access_time DESC;

    -- Incidents involving this employee
    SELECT title, severity, incident_type, incident_date, status
    FROM   Security_Incidents
    WHERE  emp_involved = @emp_id
    ORDER  BY incident_date DESC;
END;

-- ===========================================================
-- SECTION F: TRIGGERS
-- ===========================================================

CREATE TRIGGER trg_Employee_Status_Change
ON Employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(status)
    BEGIN
        INSERT INTO Audit_Trail
               (table_name, record_id, action, changed_by, old_values, new_values)
        SELECT 'Employees',
               i.emp_id,
               'UPDATE',
               i.emp_id,
               '{"status":"' + d.status + '"}',
               '{"status":"' + i.status + '"}'
        FROM   inserted i
        JOIN   deleted  d ON i.emp_id = d.emp_id
        WHERE  i.status <> d.status;
    END
END;

CREATE TRIGGER trg_Block_Role_To_Terminated
ON Employee_Roles
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM   inserted i
        JOIN   Employees e ON i.emp_id = e.emp_id
        WHERE  e.status IN ('Terminated', 'Inactive')
    )
    BEGIN
        RAISERROR('Cannot assign a role to a terminated or inactive employee.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    INSERT INTO Employee_Roles (emp_id, role_id, assigned_by, assigned_date, expiry_date, is_active)
    SELECT emp_id, role_id, assigned_by, assigned_date, expiry_date, is_active
    FROM   inserted;
END;

CREATE TRIGGER trg_Card_Revoke_Audit
ON Access_Cards
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(status)
    BEGIN
        INSERT INTO Audit_Trail
               (table_name, record_id, action, changed_by, old_values, new_values)
        SELECT 'Access_Cards',
               i.card_id,
               'UPDATE',
               i.issued_by,
               '{"status":"' + d.status + '"}',
               '{"status":"' + i.status + '"}'
        FROM   inserted i
        JOIN   deleted  d ON i.card_id = d.card_id
        WHERE  i.status <> d.status;
    END
END;

-- ===========================================================
-- SECTION G: REPORTING QUERIES
-- ===========================================================

-- G1. Department clearance distribution
SELECT d.dept_name,
       SUM(CASE WHEN sr.clearance_level = 1 THEN 1 ELSE 0 END)  AS guest,
       SUM(CASE WHEN sr.clearance_level = 2 THEN 1 ELSE 0 END)  AS standard,
       SUM(CASE WHEN sr.clearance_level = 3 THEN 1 ELSE 0 END)  AS elevated,
       SUM(CASE WHEN sr.clearance_level = 4 THEN 1 ELSE 0 END)  AS confidential,
       SUM(CASE WHEN sr.clearance_level = 5 THEN 1 ELSE 0 END)  AS top_secret,
       CAST(AVG(CAST(sr.clearance_level AS DECIMAL(3,1))) AS DECIMAL(3,1)) AS avg_clearance
FROM   Employees      e
JOIN   Departments    d  ON e.dept_id    = d.dept_id
LEFT JOIN Employee_Roles er ON e.emp_id  = er.emp_id  AND er.is_active = 1
LEFT JOIN Security_Roles sr ON er.role_id = sr.role_id
WHERE  e.status = 'Active'
GROUP  BY d.dept_name
ORDER  BY avg_clearance DESC;

-- G2. Access cards expiring in the next 30 days
SELECT ac.card_number,
       ac.card_type,
       ISNULL(e.first_name + ' ' + e.last_name, 'Unassigned') AS holder,
       ac.expiry_date,
       DATEDIFF(DAY, CAST(GETDATE() AS DATE), ac.expiry_date) AS days_remaining
FROM   Access_Cards ac
LEFT JOIN Employees e ON ac.emp_id = e.emp_id
WHERE  ac.status = 'Active'
  AND  ac.expiry_date BETWEEN CAST(GETDATE() AS DATE)
                          AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
ORDER  BY ac.expiry_date;

-- G3. Zone access statistics with denial rate
SELECT sz.zone_name,
       sz.building,
       sz.floor_number,
       COUNT(*)                                                AS total_accesses,
       SUM(CASE WHEN al.result = 'Granted' THEN 1 ELSE 0 END) AS granted,
       SUM(CASE WHEN al.result = 'Denied'  THEN 1 ELSE 0 END) AS denied,
       CAST(
           100.0 * SUM(CASE WHEN al.result = 'Denied' THEN 1 ELSE 0 END) / COUNT(*)
       AS DECIMAL(5,1))                                        AS denial_rate_pct
FROM   Access_Logs    al
JOIN   Security_Zones sz ON al.zone_id = sz.zone_id
GROUP  BY sz.zone_id, sz.zone_name, sz.building, sz.floor_number
ORDER  BY total_accesses DESC;
