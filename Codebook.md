# Data Codebook - Hospital Wait Time QC System

## Overview

This codebook describes the structure and variables in our test datasets.
---

## Dataset Structure

### File 1: Patient Data (`Mock Data - Patients1.csv`)

**Purpose:** Master list of all active patients on Floor 3

**File Format:** CSV (Comma-Separated Values)

**Columns:**

| Variable | Type | Description | Valid Values | Example |
|:----------|:------|:-------------|:--------------|:---------|
| `patient_id` | String | Unique patient identifier | P201-P250 | P201 | 
| `room_number` | Integer | Room assignment on Floor 3 | 100-500 Range | 301 | 
| `acuity_level` | String | Clinical acuity classification | **High, Medium, Low** | Medium |
| `assigned_nurse` | String | Primary nurse responsible for patient | Nurse Smith, Nurse Chen, etc. | Nurse Chen |
| **`hours_since_last_visit`** | Decimal | The time elapsed since a staff member last attended to the patient. **(Raw Data Field)** | $\geq 0.00$ | 20.25 |

**Notes:**
- Acuity level determines care frequency thresholds (High= over 12 hrs, Medium = between 6 to 12 hrs, Low = less than 6 hrs).


---

## Data Collection Process (Based on Patient Data)

### Patient Data Collection
**Source:** Hospital Admissions System (EHR) $\rightarrow$ Updated Patient Data
**Frequency:** Real-time on admission / Updated on visit
**Responsibility:** Admissions Clerk + Charge Nurse + Attending Nurse

**Steps:**
1. Patient admitted $\rightarrow$ Room assigned.
2. Nurse completes acuity assessment.
3. Charge nurse assigns primary nurse based on workload.
4. Current `hours_since_last_visit` is logged/calculated and exported to dashboard.

---

## Data Quality Standards

### Required Fields
All fields in the Patient Data file are **required** (no null values permitted).

### Validation Rules
- `patient_id`: Must be unique in the file.
- `room_number`: Must be a valid integer.
- `acuity_level`: Must be **High, Medium, or Low** (case-sensitive).
- `assigned_nurse`: Must match an active staff roster name.
- `hours_since_last_visit`: Must be a non-negative decimal value.

### Data Integrity
- The file contains 50 records, each with a unique patient ID.


---

## Acuity Scoring System

**Purpose:** Weight patients by care intensity for workload calculation

| Acuity Level | Points | Description | Care Threshold |
|:--------------|:--------|:-------------|:----------------|
| **High** | 3 | Critical patients, post-op, unstable | Visit over 12 hours |
| **Medium** | 2 | Standard inpatient care | Visit every 6 to 12 hours |
| **Low** | 1 | Stable, awaiting discharge | Visit between 0 to 6 hours |

**Nurse Workload Score** = Sum of all assigned patients' acuity points

**Example:**
- Nurse has 3 High (×3) + 4 Medium (×2) + 2 Low (×1) = $9 + 8 + 2 = \mathbf{19 \text{ points}}$

**Workload Thresholds:**
- **Acceptable:** 12-20 points
- **Overloaded:** $>20$ points (too many patients)
- **Underutilized:** $<10$ points (capacity available)

---

## Calculated Metrics (Derived from Raw Data)

Since **`hours_since_last_visit`** is present as a raw data column, the dashboard calculates these metrics directly:

| Metric | Calculation | Interpretation |
|:--------|:-------------|:----------------|
| **Compliance Rate** | (Patients where `hours_since_last_visit` is $\le$ Acuity Threshold / Total patients) $\times 100$ | Quality metric |
| **Workload Variance** | Standard deviation of all nurses' acuity scores | Distribution balance |
| **Alert Status** | If `hours_since_last_visit` $>$ Acuity Threshold: **WARNING** or **CRITICAL** | Urgency level |

---

## Technical Specifications

**File Encoding:** UTF-8
**Date Format:** **N/A** (No date/time fields present in the CSV)
**Decimal Separator:** Period (.)
**Delimiter:** Comma (,)
**Line Ending:** CRLF (Windows-style)
**Header Row:** Required (column names in first row)

---

## Data Privacy & HIPAA Compliance

**Test Datasets:**
- All patient IDs are synthetic (P201-P250).
- No real patient information included.
- Safe for public demonstration.

**Production Implementation:**
- Must use hospital's secure EHR system.
- PHI (Protected Health Information) encryption required.
- Access controls: Role-based permissions.
- Audit logging of all data access.
- HIPAA compliance mandatory.

---

## Questions & Support

For questions about data structure or collection methodology:
- **Technical Issues:** [Your GitHub repository issues page]
- **Clinical Questions:** [Your team email]
- **General Info:** See README.md

---

**Last Updated:** October 18, 2025
**Version:** 1.0
**Authors:** Deepro B, Chris L., Bradley M., Sreekar S.
**Institution:** Cornell University - SYSEN 5300
