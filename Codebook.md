# Data Codebook - Hospital Wait Time QC System

## Overview

This codebook describes the structure and variables in our test datasets. Each **dataset** consists of **two related CSV files**: Patient Data and Visit Data.

---

## Dataset Structure

### File 1: Patient Data (Patients_*.csv)

**Purpose:** Master list of all active patients on Floor 3

**File Format:** CSV (Comma-Separated Values)

**Columns:**

| Variable | Type | Description | Valid Values | Example |
|----------|------|-------------|--------------|---------|
| `patient_id` | String | Unique patient identifier | P001-P999 | P042 |
| `room_number` | Integer | Room assignment on Floor 3 | 301-320 | 312 |
| `acuity_level` | String | Clinical acuity classification | High, Medium, Low | High |
| `assigned_nurse` | String | Primary nurse responsible for patient | N01, N03, N04, N08, N12, N15 | N12 |
| `admission_time` | DateTime | When patient was admitted to floor | YYYY-MM-DD HH:MM:SS | 2025-10-16 08:30:00 |

**Notes:**
- Each patient appears exactly once in this file
- Acuity level determines care frequency thresholds (High=2hrs, Medium=4hrs, Low=6hrs)
- Room numbers represent physical bed locations

---

### File 2: Visit Data (Visits_*.csv)

**Purpose:** Record of every care visit to each patient

**File Format:** CSV (Comma-Separated Values)

**Columns:**

| Variable | Type | Description | Valid Values | Example |
|----------|------|-------------|--------------|---------|
| `visit_id` | String | Unique visit identifier | V0001-V9999 | V0156 |
| `patient_id` | String | Patient who received visit (foreign key) | P001-P999 | P042 |
| `staff_id` | String | Staff member who conducted visit | N01-N99, D01-D99 | N12 |
| `visit_time` | DateTime | When visit occurred | YYYY-MM-DD HH:MM:SS | 2025-10-16 14:30:00 |
| `visit_duration_min` | Integer | Length of visit in minutes | 5-30 | 15 |

**Notes:**
- Each patient typically has 3-6 visits recorded
- Multiple visits can occur on the same day
- Staff_id starting with N = Nurse, D = Doctor
- Dashboard calculates "hours since last visit" using most recent `visit_time`

---

## Relationship Between Files

**One-to-Many Relationship:**
- One patient (in Patients file) → Many visits (in Visits file)
- Linked by `patient_id` field

**Example:**
```
Patient P042 appears once in Patients_Baseline.csv
Patient P042 appears 5 times in Visits_Baseline.csv (5 care visits)
```

---

## Test Dataset Descriptions

### Dataset 1: Baseline (Problem State)

**Files:**
- `Patients_Baseline.csv` (48 patients)
- `Visits_Baseline.csv` (~110 visit records)

**Scenario:** Represents typical Floor 3 operations BEFORE using the quality control tool. Demonstrates severe workload imbalance.

**Key Characteristics:**
- Nurse N12: 12 patients (Acuity Score: 29) - OVERLOADED
- Nurse N01: 4 patients (Acuity Score: 8) - UNDERUTILIZED
- Expected Compliance Rate: ~70%
- Expected Workload Variance: ~7.5

**Use Case:** Demonstrates the problem the tool is designed to solve

---

### Dataset 2: Post-Intervention (Improved State)

**Files:**
- `Patients_PostIntervention.csv` (48 patients)
- `Visits_PostIntervention.csv` (~200 visit records)

**Scenario:** Represents Floor 3 operations AFTER implementing dashboard recommendations. Same patients and staff, but rebalanced assignments and more frequent visits.

**Key Characteristics:**
- All nurses balanced: 8 patients each
- Acuity Scores: 11-20 (all within acceptable range)
- Expected Compliance Rate: ~94%
- Expected Workload Variance: ~3.0

**Use Case:** Demonstrates tool effectiveness and improvement metrics

---

### Dataset 3: Night Shift Crisis (Systematic Issue)

**Files:**
- `Patients_NightShift.csv` (28 patients)
- `Visits_NightShift.csv` (~48 visit records)

**Scenario:** Represents night shift (11pm-7am) operations with only 2 nurses on duty. Reveals systematic understaffing.

**Key Characteristics:**
- Only 2 nurses: N12 and N15 (each with 14 patients)
- Both severely overloaded (Acuity Scores ~35)
- Expected Compliance Rate: ~60%
- Many high-acuity patients at risk

**Use Case:** Demonstrates tool's ability to identify policy-level problems requiring management intervention

---

## Data Collection Process (If Implementing in Real Hospital)

### Patient Data Collection
**Source:** Hospital Admissions System (EHR)  
**Frequency:** Real-time on admission  
**Responsibility:** Admissions Clerk + Charge Nurse  

**Steps:**
1. Patient admitted from ER/ICU → Room assigned
2. Nurse completes acuity assessment within 30 minutes
3. Charge nurse assigns primary nurse based on workload
4. Data entered into EHR, exported to dashboard

### Visit Data Collection
**Source:** Electronic Medical Record (EMR) visit documentation  
**Frequency:** Real-time after each visit  
**Responsibility:** Attending Nurse/Doctor  

**Steps:**
1. Staff member visits patient
2. Completes care tasks (vitals, meds, assessment)
3. Documents visit in EMR with timestamp and duration
4. EMR automatically exports to dashboard

---

## Data Quality Standards

### Required Fields
All fields in both files are **required** (no null values permitted)

### Validation Rules
- `patient_id`: Must be unique in Patients file
- `visit_id`: Must be unique in Visits file
- `room_number`: Must be 301-320
- `acuity_level`: Must be High, Medium, or Low (case-sensitive)
- `assigned_nurse`: Must match active staff roster
- `visit_time`: Must be after `admission_time` for that patient
- `visit_duration_min`: Must be 5-30 minutes

### Data Integrity
- Every `patient_id` in Visits file must exist in Patients file
- Minimum 2 visits per patient (discharge requires ≥2 visits)
- Visit timestamps must be chronological

---

## Acuity Scoring System

**Purpose:** Weight patients by care intensity for workload calculation

| Acuity Level | Points | Description | Care Threshold |
|--------------|--------|-------------|----------------|
| **High** | 3 | Critical patients, post-op, unstable | Visit every 2 hours |
| **Medium** | 2 | Standard inpatient care | Visit every 4 hours |
| **Low** | 1 | Stable, awaiting discharge | Visit every 6 hours |

**Nurse Workload Score** = Sum of all assigned patients' acuity points

**Example:**
- Nurse has 3 High (×3) + 4 Medium (×2) + 2 Low (×1) = 9 + 8 + 2 = **19 points**

**Workload Thresholds:**
- **Acceptable:** 12-20 points
- **Overloaded:** >20 points (too many patients)
- **Underutilized:** <10 points (capacity available)

---

## Calculated Metrics (Not in Raw Data)

The dashboard calculates these metrics from the raw data:

| Metric | Calculation | Interpretation |
|--------|-------------|----------------|
| **Hours Since Last Visit** | Current Time - Most Recent `visit_time` | Patient wait time |
| **Compliance Rate** | (Patients within threshold / Total patients) × 100 | Quality metric |
| **Workload Variance** | Standard deviation of all nurses' acuity scores | Distribution balance |
| **Alert Status** | If hours > threshold: WARNING or CRITICAL | Urgency level |

---

## File Naming Convention
```
[FileType]_[Scenario].csv

Examples:
- Patients_Baseline.csv
- Visits_PostIntervention.csv
- Patients_NightShift.csv
```

---

## Data Privacy & HIPAA Compliance

**Test Datasets:**
- All patient IDs are synthetic (P001-P999)
- No real patient information included
- Safe for public demonstration

**Production Implementation:**
- Must use hospital's secure EHR system
- PHI (Protected Health Information) encryption required
- Access controls: Role-based permissions
- Audit logging of all data access
- HIPAA compliance mandatory

---

## Technical Specifications

**File Encoding:** UTF-8  
**Date Format:** YYYY-MM-DD HH:MM:SS (24-hour time)  
**Decimal Separator:** Period (.)  
**Delimiter:** Comma (,)  
**Line Ending:** LF (Unix-style) or CRLF (Windows-style)  
**Header Row:** Required (column names in first row)

---

## Questions & Support

For questions about data structure or collection methodology:
- **Technical Issues:** [Your GitHub repository issues page]
- **Clinical Questions:** [Your team email]
- **General Info:** See README.md

---

**Last Updated:** October 18, 2025  
**Version:** 1.0  
**Authors:** [Your team names]  
**Institution:** Cornell University - SYSEN 5300
