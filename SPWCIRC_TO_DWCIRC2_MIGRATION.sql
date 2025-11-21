-- ========================================
-- SPWCIRC SOLAR_CIRC TABLE MIGRATION
-- Purpose: Bring SPWCIRC up to DWCIRC2 standard
-- Database: SPWCIRC
-- Main Table: SOLAR_CIRC
-- Target Standard: DWCIRC2 (DW_CIRC)
-- ========================================
--
-- IMPORTANT: This script adds missing fields from DWCIRC2 to SOLAR_CIRC
-- Fields that exist in SPWCIRC but not in DWCIRC2 are preserved
--
-- Missing from SPWCIRC: 24 fields
-- Extra in SPWCIRC: 27 fields (will be kept for backward compatibility)
--
-- ========================================

USE SPWCIRC;

-- Backup recommendation
-- CREATE TABLE SOLAR_CIRC_BACKUP_20251121 AS SELECT * FROM SOLAR_CIRC;

-- ========================================
-- ADD MISSING FIELDS FROM DWCIRC2
-- ========================================

-- Add AUTOMATIONDIRECT field
ALTER TABLE SOLAR_CIRC
ADD COLUMN AUTOMATIONDIRECT varchar(3) NULL DEFAULT NULL
AFTER ACTIVATION_DATE;

-- Add AUTOMATIONDIRECT_DATE field
ALTER TABLE SOLAR_CIRC
ADD COLUMN AUTOMATIONDIRECT_DATE datetime NULL DEFAULT NULL
AFTER AUTOMATIONDIRECT;

-- Add BUY_SPECIFY field
ALTER TABLE SOLAR_CIRC
ADD COLUMN BUY_SPECIFY varchar(32) NULL DEFAULT NULL;

-- Add BUY_SPECIFY_EE field
ALTER TABLE SOLAR_CIRC
ADD COLUMN BUY_SPECIFY_EE varchar(32) NULL DEFAULT NULL
AFTER BUY_SPECIFY;

-- Add COUNTRY field (note: SPWCIRC has 'Country', this is the standardized version)
ALTER TABLE SOLAR_CIRC
ADD COLUMN COUNTRY varchar(32) NULL DEFAULT NULL,
ADD INDEX idx_country (COUNTRY);

-- Add DIRECT_REQUEST field (SPWCIRC has DIRECTREQUEST, this is the standard name)
ALTER TABLE SOLAR_CIRC
ADD COLUMN DIRECT_REQUEST enum('Y','N') NULL DEFAULT 'Y';

-- Add DO_NOT_CALL field
ALTER TABLE SOLAR_CIRC
ADD COLUMN DO_NOT_CALL char(1) NULL DEFAULT NULL;

-- Add DW_FUNCTION field (SPWCIRC has JOB_FUNC, this is the standardized version)
ALTER TABLE SOLAR_CIRC
ADD COLUMN DW_FUNCTION varchar(2) NULL DEFAULT NULL
COMMENT 'Standardized job function code from DWCIRC2';

-- Add DW_INDUSTRY field
ALTER TABLE SOLAR_CIRC
ADD COLUMN DW_INDUSTRY varchar(3) NULL DEFAULT NULL
COMMENT 'Standardized industry code from DWCIRC2';

-- Add DW_INDUSTRY_OTR field
ALTER TABLE SOLAR_CIRC
ADD COLUMN DW_INDUSTRY_OTR varchar(255) NULL DEFAULT NULL
COMMENT 'Industry other/description text';

-- Add DW_PRIMARY_CAD field
ALTER TABLE SOLAR_CIRC
ADD COLUMN DW_PRIMARY_CAD varchar(2) NULL DEFAULT NULL
COMMENT 'Primary CAD software code';

-- Add DW_PURCHASING field
ALTER TABLE SOLAR_CIRC
ADD COLUMN DW_PURCHASING enum('Y','N') NULL DEFAULT NULL
COMMENT 'Purchasing authority indicator';

-- Add EMAIL_PERMISSION field
ALTER TABLE SOLAR_CIRC
ADD COLUMN EMAIL_PERMISSION char(1) NULL DEFAULT NULL;

-- Add FAX field
ALTER TABLE SOLAR_CIRC
ADD COLUMN FAX varchar(24) NULL DEFAULT NULL;

-- Add IMPORTSOURCE field
ALTER TABLE SOLAR_CIRC
ADD COLUMN IMPORTSOURCE varchar(255) NULL DEFAULT NULL;

-- Add JOB_TITLE field (standardized job title code)
ALTER TABLE SOLAR_CIRC
ADD COLUMN JOB_TITLE varchar(2) NULL DEFAULT NULL
COMMENT 'Standardized job title code from DWCIRC2';

-- Add JOB_TITLE_OTHER field
ALTER TABLE SOLAR_CIRC
ADD COLUMN JOB_TITLE_OTHER varchar(255) NULL DEFAULT NULL;

-- Add PHONEEXT field
ALTER TABLE SOLAR_CIRC
ADD COLUMN PHONEEXT varchar(24) NULL DEFAULT NULL;

-- Add TC field
ALTER TABLE SOLAR_CIRC
ADD COLUMN TC varchar(2) NULL DEFAULT NULL;

-- Add TYPE field
ALTER TABLE SOLAR_CIRC
ADD COLUMN TYPE char(1) NULL DEFAULT NULL;

-- Add VD_TEXT field
ALTER TABLE SOLAR_CIRC
ADD COLUMN VD_TEXT varchar(255) NULL DEFAULT NULL;

-- Add compid field
ALTER TABLE SOLAR_CIRC
ADD COLUMN compid bigint(20) NULL DEFAULT NULL;

-- Add idchkdig field
ALTER TABLE SOLAR_CIRC
ADD COLUMN idchkdig int(11) NULL DEFAULT NULL;

-- Add pubcode field
ALTER TABLE SOLAR_CIRC
ADD COLUMN pubcode varchar(8) NULL DEFAULT NULL;

-- ========================================
-- DATA MIGRATION RECOMMENDATIONS
-- ========================================

-- Migrate existing 'Country' to standardized 'COUNTRY' field
-- UPDATE SOLAR_CIRC SET COUNTRY = Country WHERE Country IS NOT NULL;

-- Migrate DIRECTREQUEST to DIRECT_REQUEST for consistency
-- UPDATE SOLAR_CIRC SET DIRECT_REQUEST = DIRECTREQUEST WHERE DIRECTREQUEST IS NOT NULL;

-- Migrate JOB_FUNC to DW_FUNCTION (may require mapping table)
-- UPDATE SOLAR_CIRC SET DW_FUNCTION = JOB_FUNC WHERE JOB_FUNC IS NOT NULL;

-- Set pubcode to 'SPW' for all existing records
-- UPDATE SOLAR_CIRC SET pubcode = 'SPW' WHERE pubcode IS NULL;

-- ========================================
-- VERIFICATION QUERIES
-- ========================================

-- Check column count
-- SELECT COUNT(*) as column_count FROM information_schema.COLUMNS
-- WHERE TABLE_SCHEMA = 'SPWCIRC' AND TABLE_NAME = 'SOLAR_CIRC';

-- Compare with DWCIRC2
-- Expected: SOLAR_CIRC should now have 76 columns (49 from DWCIRC2 + 27 extra)

-- List all columns
-- SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_DEFAULT
-- FROM information_schema.COLUMNS
-- WHERE TABLE_SCHEMA = 'SPWCIRC' AND TABLE_NAME = 'SOLAR_CIRC'
-- ORDER BY ORDINAL_POSITION;

-- ========================================
-- NOTES
-- ========================================
--
-- Fields kept from SPWCIRC but not in DWCIRC2:
-- - AUDITTIME, Country, DIRECTREQUEST, DUPECHECK, FULLNAME
-- - GFID, ID, JOB_FUNC, JOB_FUNC_OTR, MK, OLDSOURCE
-- - PRODUCTS_SPECIFIED, Q4_* fields (13 fields)
-- - SOUNDMK, TYPEBIZ, TYPEBIZ_OTR
--
-- These fields are preserved for backward compatibility
-- and may contain publication-specific data
--
-- ========================================

SELECT 'SPWCIRC migration script completed. Please verify column structure.' as Status;
