# Circulation Database Audit - Quick Start Guide

## Overview

This audit system provides comprehensive analysis and tracking for standardizing 11 circulation databases to match the DWCIRC2 gold standard.

## Files Created

### Analysis Reports
```
/tmp/audit_report.txt              - Complete analysis output
/tmp/field_comparison.csv          - Field-by-field comparison
/tmp/table_matrix.csv              - Table existence matrix
```

### Migration Scripts
```
/var/www/circ_system_standerization/SPWCIRC_TO_DWCIRC2_MIGRATION.sql  - SPWCIRC upgrade script
/var/www/circ_system_standerization/AUDIT_SUMMARY_REPORT.md           - This comprehensive report
```

### Audit Database
```
/tmp/create_audit_database.sql     - Audit database schema
/tmp/populate_audit_database.py    - Database population script
```

## Quick Commands

### 1. View the Main Analysis Report

```bash
cat /tmp/audit_report.txt
```

This shows:
- Table comparison matrix across all 11 databases
- Main circulation table column counts
- Detailed field comparisons for each database
- SPWCIRC detailed analysis (top priority)

### 2. View Field Comparison Data

```bash
# View as CSV
cat /tmp/field_comparison.csv

# Or open in MySQL
mysql -h localhost -u agent_circ -pdevelopment_password -e "
  SELECT * FROM (
    SELECT * FROM information_schema.TABLES LIMIT 0
  ) t;
"

# Import into a temp table for analysis
mysql -h localhost -u agent_circ -pdevelopment_password -e "
  CREATE DATABASE IF NOT EXISTS TEMP_ANALYSIS;
  USE TEMP_ANALYSIS;
  CREATE TABLE field_comparison (
    Database VARCHAR(50),
    Field VARCHAR(100),
    In_DWCIRC2 VARCHAR(3),
    In_Database VARCHAR(3),
    Status VARCHAR(20),
    Type_DWCIRC2 VARCHAR(100),
    Type_Database VARCHAR(100)
  );
  LOAD DATA LOCAL INFILE '/tmp/field_comparison.csv'
  INTO TABLE field_comparison
  FIELDS TERMINATED BY ','
  ENCLOSED BY '\"'
  LINES TERMINATED BY '\n'
  IGNORE 1 ROWS;
"
```

### 3. Create and Populate the Audit Database

```bash
# Create the audit database structure
mysql -h localhost -u agent_circ -pdevelopment_password < /tmp/create_audit_database.sql

# Populate with analysis data
python3 /tmp/populate_audit_database.py
```

### 4. Query the Audit Database

```sql
-- Connect to audit database
USE CIRC_AUDIT;

-- View overall standardization progress
SELECT * FROM v_field_standardization_summary
ORDER BY match_percentage DESC;

-- View table distribution matrix
SELECT * FROM v_table_matrix;

-- View SPWCIRC migration roadmap
SELECT * FROM v_spwcirc_standardization_roadmap
WHERE exists_in_database = FALSE
ORDER BY standardization_priority;

-- Get list of all databases and their status
SELECT
    database_name,
    main_table_name,
    publication_code,
    total_tables,
    is_gold_standard,
    last_audited
FROM databases
ORDER BY database_name;

-- View missing fields for a specific database
SELECT
    fc.field_name,
    mf.dwcirc2_type,
    mf.dwcirc2_nullable,
    mf.standardization_priority
FROM field_comparison fc
JOIN main_circulation_fields mf ON fc.field_id = mf.field_id
JOIN databases d ON fc.database_id = d.database_id
WHERE d.database_name = 'SPWCIRC'
  AND fc.status = 'missing'
ORDER BY mf.standardization_priority;
```

### 5. Execute SPWCIRC Migration (PRIORITY)

```bash
# STEP 1: Create backup (CRITICAL!)
mysql -h localhost -u agent_circ -pdevelopment_password SPWCIRC -e "
  CREATE TABLE SOLAR_CIRC_BACKUP_20251121 AS SELECT * FROM SOLAR_CIRC;
"

# STEP 2: Verify backup
mysql -h localhost -u agent_circ -pdevelopment_password SPWCIRC -e "
  SELECT COUNT(*) as backup_count FROM SOLAR_CIRC_BACKUP_20251121;
  SELECT COUNT(*) as original_count FROM SOLAR_CIRC;
"

# STEP 3: Review migration script
cat /var/www/circ_system_standerization/SPWCIRC_TO_DWCIRC2_MIGRATION.sql

# STEP 4: Execute migration
mysql -h localhost -u agent_circ -pdevelopment_password SPWCIRC < /var/www/circ_system_standerization/SPWCIRC_TO_DWCIRC2_MIGRATION.sql

# STEP 5: Verify results
mysql -h localhost -u agent_circ -pdevelopment_password SPWCIRC -e "
  SELECT COUNT(*) as column_count
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'SPWCIRC' AND TABLE_NAME = 'SOLAR_CIRC';
"
# Should show 76 columns (52 original + 24 added)
```

## Key Findings Summary

### Database Rankings (by standardization %)

1. **DWCIRC2** - 100% (Gold Standard)
2. **CSDCIRC** - 77.6% (Good)
3. **CRBCIRC** - 73.5% (Good)
4. **CSECIRC** - 67.3% (Moderate)
5. **PMQCIRC** - 65.3% (Moderate, has many extra fields)
6. **CECIRC** - 63.3% (Moderate)
7. **PECIRC** - 63.3% (Moderate)
8. **FLUIDCIRC** - 51.0% (Needs Work)
9. **MEDICALCIRC** - 51.0% (Needs Work)
10. **SPWCIRC** - 51.0% (**TOP PRIORITY** - Oldest database)
11. **RDCIRC** - 44.9% (Needs Significant Work)

### SPWCIRC Critical Stats

- **Current columns:** 52
- **Missing fields:** 24 (from DWCIRC2 standard)
- **Extra fields:** 27 (publication-specific, will be preserved)
- **After migration:** 76 columns total
- **Main table:** SOLAR_CIRC (not SPW_CIRC)

### Most Important Missing Fields (across all databases)

1. `DW_FUNCTION` - Standardized job function (missing in 9 databases)
2. `DW_INDUSTRY` - Standardized industry code (missing in 9 databases)
3. `DW_INDUSTRY_OTR` - Industry other text (missing in 9 databases)
4. `DW_PRIMARY_CAD` - Primary CAD software (missing in 9 databases)
5. `DW_PURCHASING` - Purchasing authority (missing in 9 databases)
6. `AUTOMATIONDIRECT` - AD integration flag (missing in 10 databases)
7. `EMAIL_PERMISSION` - Email permission flag (missing in 7 databases)

## Common Issues

### Issue 1: Duplicate Field Names with Different Cases
**Problem:** COUNTRY vs Country, PROMOCODE vs Promocode
**Solution:** Migration scripts add standardized uppercase versions, preserve originals temporarily

### Issue 2: Similar Fields with Different Names
**Problem:** DIRECT_REQUEST vs DIRECTREQUEST
**Solution:** Add new standardized field, migrate data from old field

### Issue 3: Publication-Specific Fields
**Problem:** SPWCIRC has Q4_* fields for solar industry
**Solution:** Preserve these fields, they don't conflict with standard

## Next Actions

### Immediate (This Week)
1. Review `/tmp/audit_report.txt` for detailed findings
2. Review `SPWCIRC_TO_DWCIRC2_MIGRATION.sql` for accuracy
3. Test SPWCIRC migration on development environment
4. Schedule production migration window

### Short Term (This Month)
1. Create audit database: `mysql < /tmp/create_audit_database.sql`
2. Populate audit database: `python3 /tmp/populate_audit_database.py`
3. Generate migration scripts for RDCIRC, FLUIDCIRC, MEDICALCIRC
4. Document publication-specific field requirements

### Medium Term (This Quarter)
1. Migrate remaining databases to standard
2. Create master data dictionary
3. Standardize lookup tables across databases
4. Update application code for standardized fields

## Support Files

### View Table Matrix
```bash
# As CSV
cat /tmp/table_matrix.csv | column -t -s,

# Or import to spreadsheet software
libreoffice /tmp/table_matrix.csv
```

### Re-run Analysis
If you make changes and want to re-analyze:

```bash
# Re-extract schemas
for db in CECIRC CRBCIRC CSDCIRC CSECIRC DWCIRC2 FLUIDCIRC MEDICALCIRC PECIRC PMQCIRC RDCIRC SPWCIRC; do
  mysql -h localhost -u agent_circ -pdevelopment_password -e "
    SELECT
        '$db' as database_name,
        TABLE_NAME as table_name,
        COLUMN_NAME as column_name,
        COLUMN_TYPE as column_type,
        IS_NULLABLE as is_nullable,
        COLUMN_KEY as column_key,
        COLUMN_DEFAULT as column_default,
        EXTRA as extra
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = '$db'
    ORDER BY TABLE_NAME, ORDINAL_POSITION;
  " > /tmp/${db,,}_schema.tsv
done

# Re-run analysis
python3 /tmp/analyze_schemas.py > /tmp/audit_report.txt 2>&1
```

## Questions?

For detailed information, see:
- `/var/www/circ_system_standerization/AUDIT_SUMMARY_REPORT.md` - Comprehensive findings
- `/tmp/audit_report.txt` - Detailed console output
- `/tmp/field_comparison.csv` - All field comparisons
- `/tmp/table_matrix.csv` - Table distribution

---

**Created:** 2025-11-21
**Last Updated:** 2025-11-21
