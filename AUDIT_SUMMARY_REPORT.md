# Circulation Database Standardization Audit Report

**Date:** November 21, 2025
**Auditor:** Database Schema Analysis System
**Gold Standard:** DWCIRC2 (DW_CIRC table)

## Executive Summary

This audit analyzed 11 circulation databases with the goal of standardizing them to match the DWCIRC2 database schema, which serves as the gold standard (newest database). The analysis focused on comparing main circulation tables across all databases.

### Databases Audited

| Database | Main Table | Columns | Match % | Status |
|----------|------------|---------|---------|--------|
| DWCIRC2 | DW_CIRC | 49 | 100% | **GOLD STANDARD** |
| CSDCIRC | CSD_CIRC | 58 | 77.6% | Good |
| CRBCIRC | CRB_CIRC | 56 | 73.5% | Good |
| CSECIRC | CSE_CIRC | 40 | 67.3% | Moderate |
| PMQCIRC | PMQ_CIRC | 97 | 65.3% | Moderate (many extra fields) |
| CECIRC | CE_CIRC | 39 | 63.3% | Moderate |
| PECIRC | PE_CIRC | 38 | 63.3% | Moderate |
| FLUIDCIRC | FLUID_CIRC | 35 | 51.0% | Needs Work |
| MEDICALCIRC | MEDICAL_CIRC | 33 | 51.0% | Needs Work |
| SPWCIRC | SOLAR_CIRC | 52 | 51.0% | **PRIORITY** (oldest) |
| RDCIRC | RD_CIRC | 41 | 44.9% | Needs Significant Work |

## Key Findings

### 1. SPWCIRC (Oldest Database - Top Priority)

**Main Table:** SOLAR_CIRC (note: uses SOLAR_CIRC instead of SPW_CIRC)

**Current Status:**
- Total Columns: 52
- Columns matching DWCIRC2: 25 (51.0%)
- Missing from SPWCIRC: 24 critical fields
- Extra in SPWCIRC: 27 publication-specific fields

**Missing Critical Fields:**
1. `AUTOMATIONDIRECT` / `AUTOMATIONDIRECT_DATE` - Automation Direct integration
2. `BUY_SPECIFY` / `BUY_SPECIFY_EE` - Purchasing behavior tracking
3. `COUNTRY` - Standardized country field (has 'Country' instead)
4. `DIRECT_REQUEST` - Direct request tracking (has 'DIRECTREQUEST' instead)
5. `DO_NOT_CALL` / `EMAIL_PERMISSION` - Privacy/permission fields
6. `DW_FUNCTION` / `DW_INDUSTRY` / `DW_INDUSTRY_OTR` - Standardized taxonomy
7. `DW_PRIMARY_CAD` / `DW_PURCHASING` - Industry-specific qualifiers
8. `FAX` / `PHONEEXT` - Contact information fields
9. `IMPORTSOURCE` - Data lineage tracking
10. `JOB_TITLE` / `JOB_TITLE_OTHER` - Standardized job title codes
11. `TC` - Territory/class code
12. `TYPE` - Record type classifier
13. `VD_TEXT` - Verification data text
14. `compid` / `idchkdig` / `pubcode` - Record identification fields

**Publication-Specific Fields to Preserve:**
- Solar industry product specification fields (Q4_* series: 13 fields)
- `PRODUCTS_SPECIFIED`, `TYPEBIZ`, `TYPEBIZ_OTR`
- Legacy fields: `GFID`, `OLDSOURCE`, `SOUNDMK`, `FULLNAME`

### 2. Table Distribution Analysis

Total unique tables across all databases: 84

**Common Tables (in most databases):**
- `BPASOURCE` - Present in 10/11 databases
- `CLASS` - Present in 9/11 databases
- `CLOSE_REPORT_ARCHIVE` - Present in all 11 databases
- `STATUS` - Present in 8/11 databases
- `REGION_CODES` - Present in 8/11 databases
- `USPSdate` - Present in 10/11 databases
- `dmacodes` - Present in 9/11 databases
- `skipDupes` - Present in 10/11 databases

**Publication-Specific Tables:**
- Each database has its own main circulation table (XX_CIRC)
- Each database has export/update tables (XX_CIRCULATION_EXPORTS, XX_CIRCULATION_UPDATES)
- Some have publication-specific lookup tables

### 3. Field Standardization Issues

**Naming Inconsistencies:**
- COUNTRY vs Country
- DIRECT_REQUEST vs DIRECTREQUEST
- PROMOCODE vs Promocode
- skipDupes vs skipdupes

**Type Mismatches:**
Analysis shows some databases use different data types for the same logical field.

## Standardization Roadmap

### Phase 1: SPWCIRC Migration (Immediate Priority)

**Objective:** Bring the oldest database (SPWCIRC) up to DWCIRC2 standard

**Actions:**
1. Add 24 missing fields to SOLAR_CIRC table
2. Migrate data from legacy field names to standardized names
3. Preserve publication-specific Q4_* fields and solar industry data
4. Update application code to use standardized field names

**Migration Script:** `/var/www/circ_system_standerization/SPWCIRC_TO_DWCIRC2_MIGRATION.sql`

**Estimated Impact:**
- Rows affected: All records in SOLAR_CIRC
- Downtime required: Minimal (ALTER TABLE operations)
- Data migration: Required for Country→COUNTRY, DIRECTREQUEST→DIRECT_REQUEST

### Phase 2: RDCIRC, FLUIDCIRC, MEDICALCIRC (High Priority)

These databases have match percentages below 52% and need significant work:

**RDCIRC (44.9% match):**
- Missing: 27 fields
- Extra: 19 fields
- Notable missing: CITY, CLASS, basic contact fields

**FLUIDCIRC (51.0% match):**
- Missing: 24 fields
- Extra: 10 fields (some appear to be renamed versions)

**MEDICALCIRC (51.0% match):**
- Missing: 24 fields
- Extra: 8 fields

### Phase 3: Moderate Priority Databases

**CECIRC, PECIRC, CSECIRC, PMQCIRC:**
- Match percentages: 63-67%
- Primarily missing DW_* standardized taxonomy fields
- PMQCIRC has 65 extra fields (most comprehensive database, may inform future standard)

### Phase 4: Good Standing Databases

**CRBCIRC, CSDCIRC:**
- Match percentages: 73-77%
- Minimal changes needed
- Focus on DW_* taxonomy fields

## Deliverables Created

### 1. Analysis Reports
- `/tmp/audit_report.txt` - Complete console output with detailed comparisons
- `/tmp/field_comparison.csv` - Field-by-field comparison across all databases
- `/tmp/table_matrix.csv` - Table existence matrix

### 2. Audit Database
- `/tmp/create_audit_database.sql` - Complete audit database schema
- Database: `CIRC_AUDIT`
- Purpose: Centralized tracking of standardization progress

**Key Tables:**
- `databases` - Track all databases being standardized
- `main_circulation_fields` - Master field definitions from DWCIRC2
- `field_comparison` - Which fields exist in which databases
- `standardization_tasks` - Track migration tasks
- `table_comparison_matrix` - Table existence across databases

**Useful Views:**
- `v_field_standardization_summary` - Overall progress by database
- `v_table_matrix` - Table distribution visualization
- `v_spwcirc_standardization_roadmap` - SPWCIRC migration plan
- `v_pending_standardization_tasks` - Work queue

### 3. Population Script
- `/tmp/populate_audit_database.py` - Python script to populate CIRC_AUDIT

### 4. Migration Scripts
- `/var/www/circ_system_standerization/SPWCIRC_TO_DWCIRC2_MIGRATION.sql` - SPWCIRC migration

## Recommendations

### Immediate Actions (Week 1)

1. **Review and validate** the SPWCIRC migration script
2. **Create backup** of SOLAR_CIRC table
3. **Test migration** on development/staging environment
4. **Execute migration** on production during maintenance window
5. **Update application code** to use standardized field names

### Short-term Actions (Month 1)

1. **Create audit database** using provided SQL script
2. **Populate audit database** with current schema information
3. **Develop migration scripts** for RDCIRC, FLUIDCIRC, MEDICALCIRC
4. **Establish standardization committee** to review publication-specific needs

### Medium-term Actions (Quarter 1)

1. **Migrate remaining databases** to DWCIRC2 standard
2. **Standardize table naming** across all databases
3. **Create data dictionary** documenting all fields
4. **Implement validation rules** to prevent schema drift

### Long-term Actions (Year 1)

1. **Consider database consolidation** - Single database with publication_code instead of 11 separate databases
2. **Implement schema version control** and migration framework
3. **Automate schema validation** in CI/CD pipeline
4. **Create standardized API layer** to abstract schema differences during transition

## Data Quality Considerations

### Fields Requiring Data Migration

When adding missing fields, some existing data should be migrated:

**SPWCIRC Examples:**
```sql
-- Migrate Country to COUNTRY
UPDATE SOLAR_CIRC SET COUNTRY = Country WHERE Country IS NOT NULL;

-- Migrate DIRECTREQUEST to DIRECT_REQUEST
UPDATE SOLAR_CIRC SET DIRECT_REQUEST = DIRECTREQUEST WHERE DIRECTREQUEST IS NOT NULL;

-- Set publication code for all records
UPDATE SOLAR_CIRC SET pubcode = 'SPW' WHERE pubcode IS NULL;
```

### Lookup Table Standardization

Several databases use different lookup tables for the same concepts:
- Job functions: `JOB_FUNCTION` vs `JOB_FUNCTION_CODES` vs `FUNCTIONS`
- Industries: `INDUSTRIES` vs `DW_INDUSTRIES`
- Type of business: `TYPE_OF_BUSINESS` vs `PRIMARY_BUSINESS`

**Recommendation:** Create master lookup tables and standardize codes across all databases.

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Data loss during migration | Low | High | Mandatory backups before any ALTER TABLE |
| Application breakage | Medium | High | Maintain legacy field names alongside new ones |
| Duplicate field confusion | High | Medium | Clear migration plan and data validation |
| Performance impact | Low | Medium | Execute during maintenance windows |
| Business logic changes | Medium | High | Thorough testing of all affected applications |

## Success Metrics

1. **Schema Compliance:** All databases achieve >95% match with DWCIRC2
2. **Field Standardization:** All DW_* taxonomy fields present in all databases
3. **Naming Consistency:** No duplicate field names (e.g., COUNTRY vs Country)
4. **Documentation:** Complete data dictionary with field definitions
5. **Application Updates:** All applications use standardized field names

## Next Steps

1. **Schedule review meeting** to discuss findings and approve migration plan
2. **Identify stakeholders** for each publication/database
3. **Establish testing procedures** for migration validation
4. **Create rollback procedures** for each migration
5. **Set up monitoring** to track standardization progress

## Appendix A: DWCIRC2 Field List (Gold Standard)

The 49 fields in DW_CIRC that serve as the standardization target are documented in the detailed analysis files.

## Appendix B: Files Generated

All analysis files are located in `/tmp/`:
- `audit_report.txt` - Main console report
- `field_comparison.csv` - Detailed field comparison
- `table_matrix.csv` - Table distribution matrix
- `*_schema.tsv` - Individual database schemas (11 files)

Migration and audit files in `/var/www/circ_system_standerization/`:
- `SPWCIRC_TO_DWCIRC2_MIGRATION.sql` - SPWCIRC migration script
- `AUDIT_SUMMARY_REPORT.md` - This document

Audit database files in `/tmp/`:
- `create_audit_database.sql` - Audit database schema
- `populate_audit_database.py` - Population script

---

**Report Generated:** 2025-11-21
**Tools Used:** MySQL information_schema queries, Python analysis scripts
**Databases Analyzed:** 11 circulation databases (1,472 total columns examined)
