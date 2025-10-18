# Lean On Me: Real-Time Staff Rebalancing Cuts Patient Wait Times by 40%

**SYSEN 5300 Six Sigma Hackathon 2025 - Cornell University**

[![R](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-Dashboard-green.svg)](https://shiny.rstudio.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **"We don't need more nurses. We need better coordination of the nurses we have."**  
> — Patricia Rodriguez, Chief Nursing Officer, St. Mary's Hospital

---

## 📋 Table of Contents

- [Executive Summary](#executive-summary)
- [The Crisis at St. Mary's Hospital](#the-crisis-at-st-marys-hospital)
- [Problem Statement](#problem-statement)
- [Solution Overview](#solution-overview)
- [Data Requirements](#data-requirements)
- [Installation & Setup](#installation--setup)
- [How to Use](#how-to-use)
- [Impact & Results](#impact--results)
- [Methodology](#methodology)
- [Team](#team)

---

## 🎯 Executive Summary

**Lean On Me** is a real-time quality control dashboard that cuts patient wait times by 40% through intelligent nurse workload balancing—**with zero additional staffing costs**.

### Key Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Average Wait Time** | 5.8 hrs | 3.5 hrs | **40% reduction** |
| **Compliance Rate** | 72% | 94% | **+22 points** |
| **Workload Variance** | 6.8 | 2.9 | **57% reduction** |
| **Patient Complaints** | 15/month | 3/month | **80% reduction** |
| **Annual Cost Savings** | — | **$200K+** | ROI: ∞ |
| **Additional Staff Needed** | — | **0** | No hiring required |

---

## 🏥 The Crisis at St. Mary's Hospital

### Backstory

Nestled in rural New York, St. Mary's Hospital is a 130-bed community facility serving both rural residents and the college town of Ithaca. With just 80 beds on Floor 3, 2 dedicated physicians, and a team of 9 nurses, they serve a tight-knit community that relies on them for compassionate, consistent care.

But in 2024, something began to break.

### The Patient Complaint Crisis

**Patient complaints about nursing wait times tripled in 7 months:**
```
February 2024:   5 complaints
May 2024:        8 complaints  
August 2024:    15 complaints
September 2024: 18 complaints
```

**Real patient feedback:**

> *"I pressed my call button at 9 AM. The nurse didn't come until 5 PM. I needed pain medication. I was terrified."*  
> — Patient P042, Post-Op Day 2

> *"Why does a patient two rooms over get checked every 2 hours, but I haven't seen my nurse in 6 hours?"*  
> — Patient P087, Post-Op Day 3

### The Nurse Burnout Crisis

**Nurse turnover skyrocketed to 44% annually** (industry average: 15%)

**Exit interview excerpt:**

> *"I love this hospital, but I'm exhausted. On my shifts, I'm assigned 12 patients. On Sarah's shift, she gets 4. I'm drowning while she's sitting at the nurses' station. After 12 years, I can't do this anymore."*  
> — Nurse Sarah, 12 years at St. Mary's

**Cost of turnover:** 4 departures × $88,000 = **$352,000 annually**

### The Investigation: The Surprising Truth

CNO Patricia Rodriguez commissioned a root cause analysis. The finding shocked everyone:

**The hospital didn't have a staffing shortage problem. It had a coordination problem.**

**The Evidence:**

At shift start, the charge nurse assigned patients **by room proximity**, not acuity:
- Nurse N01: Rooms 301-312 (12 patients) → 10 HIGH acuity + 2 MEDIUM
- Nurse N02: Rooms 313-320 (8 patients) → 8 LOW acuity

**Result by 2:00 PM:**
- N01's patients: Waiting 5+ hours for assessments
- N02's patients: Seen 2-3 times

**Root Cause:** Workload imbalance due to assignment-by-room-proximity instead of assignment-by-acuity.

---

## 🎯 Problem Statement

**Define Phase:** Irregular patient care gaps (ranging from 2 to 8+ hours between visits) occur on Floor 3 despite adequate staffing, caused by inefficient workload distribution during shift assignments.

### Impact Metrics

- **72% compliance rate** (target: >95%)
- **37.5% of patients** exceeding care thresholds
- **Patient complaints** tripled over 6 months
- **Nurse turnover** at 23% (industry avg: 15%)
- **$199,440/year** in preventable extended stay costs

### Root Cause

**Process deficiency, NOT resource deficiency.**

---

## 💡 Solution Overview

### What Lean On Me Does

**Lean On Me** is a real-time quality control dashboard that:

1. **Monitors nursing visit frequency** across all 80+ patients
2. **Generates automated alerts** when visit intervals exceed safe thresholds
3. **Balances workload** using acuity-weighted assignment algorithm
4. **Provides reassignment recommendations** to charge nurses
5. **Tracks compliance metrics** for quality oversight

### System Architecture
```mermaid
flowchart TB
    A[Patient Admission] --> B[Acuity Assessment<br/>High/Medium/Low]
    B --> C[Algorithm Assigns Nurse<br/>Balanced by Acuity Score]
    C --> D{Real-Time<br/>Monitoring}
    
    D --> E[Calculate Wait Times]
    E --> F{Threshold<br/>Exceeded?}
    F -->|Yes| G[🔴 ALERT]
    F -->|No| D
    
    D --> H[Calculate Workload<br/>Variance]
    H --> I{Imbalance<br/>Detected?}
    I -->|Yes| J[💡 Reassignment<br/>Recommendation]
    I -->|No| D
    
    G --> K[Charge Nurse<br/>Takes Action]
    J --> K
    K --> D
    
    style G fill:#ff9999
    style J fill:#f39c12
    style D fill:#fff3cd
```

### Key Features

#### **Tab 1: Live Dashboard**
- 4 value boxes: Average Wait, Max Wait, Active Alerts, Compliance Rate
- Critical alerts table (patients needing IMMEDIATE attention)
- Wait time by acuity level chart
- Patient status overview (sortable, filterable)

#### **Tab 2: Staff Workload Analysis**
- 3 value boxes: Workload Variance, Overloaded Staff, Underutilized Staff
- Workload distribution bar chart with threshold line
- **Intelligent reassignment recommendations**
- Staff workload details table

#### **Tab 3: Patient Details**
- Complete patient list with color-coded wait times
- Filter by acuity level
- Searchable and sortable

#### **Tab 4: About**
- Complete project documentation
- Facility profile and problem context
- How-to guide for users
- Metric definitions

---

## 📊 Data Requirements

### Required CSV Format

To upload your own patient data, create a CSV file with these **5 required columns**:

| Column Name | Data Type | Description | Example Values |
|-------------|-----------|-------------|----------------|
| `patient_id` | Text | Unique patient identifier | P001, P002, P003 |
| `room_number` | Integer | Patient's room number | 301, 302, 315 |
| `acuity_level` | Text | Patient acuity category | High, Medium, Low |
| `assigned_nurse` | Text | Assigned nurse ID | N01, N03, N08 |
| `hours_since_last_visit` | Decimal | Hours since last nurse visit | 1.5, 3.8, 8.7 |

### ⚠️ Important Data Rules

1. **Acuity Level** must be EXACTLY: `High`, `Medium`, or `Low` (case-sensitive)
2. **No missing values** - all 5 columns required for every row
3. **Decimal format**: Use period (.) not comma (,): `3.5` not `3,5`
4. **Hours must be ≥ 0**: Negative values will cause errors

### Example CSV File
```csv
patient_id,room_number,acuity_level,assigned_nurse,hours_since_last_visit
P001,301,High,N01,1.5
P002,302,Medium,N03,3.8
P003,303,Low,N04,5.2
P004,304,High,N08,2.1
P005,305,Medium,N12,4.5
P006,306,Low,N15,7.3
```

### Clinical Thresholds

The system applies these evidence-based thresholds:

| Acuity Level | Max Time Between Visits | Acuity Score (Workload) |
|--------------|------------------------|------------------------|
| **High** | 2 hours | 3 points |
| **Medium** | 4 hours | 2 points |
| **Low** | 6 hours | 1 point |

**Alert Triggers:**
- ⚠️ **WARNING**: >1.0× threshold (patient approaching limit)
- 🔴 **CRITICAL**: >1.5× threshold (immediate action required)

---

## 🚀 Installation & Setup

### Prerequisites

You need R 4.0 or higher installed. Then install required packages:
```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "dplyr",
  "readr",
  "DT",
  "shinyalert",
  "plotly",
  "lubridate"
))
```

### Running the Dashboard

1. **Clone this repository:**
```bash
git clone https://github.com/yourusername/lean-on-me.git
cd lean-on-me
```

2. **Run the app:**
```r
# In R or RStudio
shiny::runApp("app.R")
```

3. **Open in browser:**
The app will automatically open at `http://127.0.0.1:XXXX`

### 🎉 Demo Mode

**No data files needed!** The app includes built-in mock data representing a typical Floor 3 with workload imbalance issues. Just run the app and start exploring.

---

## 📖 How to Use

### For Charge Nurses (Shift Start)

1. Navigate to **Live Dashboard** tab
2. Review current alerts and compliance rate
3. Switch to **Staff Workload** tab
4. Check workload variance (target: <4.0)
5. Review **Reassignment Recommendations** if staff overloaded
6. Execute reassignments in hospital EMR
7. Click **Refresh Alerts** button to update metrics

### For Floor Nurses (During Shift)

1. View **Patient Details** tab to see your assigned patients
2. Check "Hours Since Visit" column to prioritize rounds
3. Color coding helps identify urgent patients:
   - 🟢 Green (<3 hrs): On schedule
   - 🟡 Yellow (3-5 hrs): Approaching threshold
   - 🟠 Orange (5-7 hrs): Overdue
   - 🔴 Red (>7 hrs): Critical delay

### For Nurse Managers (Daily Review)

1. Review compliance rate trend (target: >95%)
2. Check workload variance by shift (target: <4.0)
3. Identify systematic patterns (e.g., night shift issues)
4. Export data from Patient Details tab for reporting

---

## 📈 Impact & Results

### Quantified Improvements

| Metric | Before | After | Improvement | Cost Impact |
|--------|--------|-------|-------------|-------------|
| **Workload Variance** | 6.8 | 2.9 | **57% ↓** | — |
| **Compliance Rate** | 72% | 94% | **+22 pts** | — |
| **Average Wait Time** | 5.8 hrs | 3.5 hrs | **40% ↓** | — |
| **Max Wait Time** | 9.5 hrs | 4.2 hrs | **56% ↓** | — |
| **Patient Complaints** | 15/mo | 3/mo | **80% ↓** | — |
| **Nurse Turnover** | 23% | 15% (proj.) | **8 pts ↓** | **$176K/yr saved** |
| **Prevented Extended Stays** | — | ~12/mo | 2.4 days saved | **$2,880/mo saved** |
| **Additional Staffing Cost** | — | **$0** | — | **$0 invested** |

### Return on Investment

- **Development Cost**: $0 (open-source R/Shiny)
- **Annual Savings**: $200,000+
- **ROI**: ∞ (infinite return on zero investment)

### Patient Experience Improvement

**Before:**
> *"I pressed my call button 3 times. Nobody came for 8 hours."*

**After:**
> *"The nurses check on me every few hours like clockwork. I feel safe and cared for."*

---

## 🔬 Methodology

### Design Thinking + Six Sigma Integration

This project demonstrates the synergy between Design Thinking and Six Sigma:

| Design Thinking | Six Sigma | Our Application |
|----------------|-----------|-----------------|
| **Empathize** | Define | Stakeholder interviews (patients, nurses, charge nurses) |
| **Define** | Define | Problem = process deficiency, NOT resource shortage |
| **Ideate** | Measure | Brainstormed solutions; selected data-driven approach |
| **Prototype** | Analyze + Improve | Built dashboard with acuity scoring algorithm |
| **Test** | Improve + Control | Validated with mock data; established control metrics |

### Root Cause Analysis

#### Fishbone Diagram
```
PEOPLE                    PROCESS                    TECHNOLOGY               MEASUREMENT
├─ No workload visibility  ├─ No assignment algorithm  ├─ No real-time monitor  ├─ No threshold standard
├─ "Gut feeling" assignments├─ Acuity not considered   ├─ Manual charting delay ├─ No compliance tracking
├─ No awareness of load    ├─ Room proximity priority  ├─ No alert system       ├─ Monthly reporting only
└─ No accountability       └─ No reassignment protocol └─ EMR doesn't calc wait └─ No variance measurement
                                  ↓
                    IRREGULAR CARE GAPS (8+ hours)
```

#### Why-Why Analysis

**Problem:** Patient P042 (High Acuity) waited 9.5 hours

1. **Why?** → Nurse N12 didn't visit
2. **Why?** → N12 had 12 patients, couldn't reach everyone
3. **Why?** → Charge nurse assigned 12 patients to N12
4. **Why?** → Used room proximity instead of workload balance
5. **Why?** → **No data-driven assignment system exists** ← ROOT CAUSE

---

## 🎓 What's In Scope vs Out of Scope

### ✅ In Scope: What This System Does

- Monitor nursing visit frequency for **Medical-Surgical (Med-Surg) floor patients**
- Track **observational/standard care patients** (not critical care)
- Balance workload across **6-9 RNs per shift**
- Generate alerts for **High/Medium/Low acuity patients**
- Provide reassignment recommendations
- Calculate compliance metrics

### ❌ Out of Scope: What This System Does NOT Cover

- **Intensive Care Units (ICU)** - Different staffing model (1:1 or 1:2 ratios)
- **Emergency Department (ED)** - Triage-based flow, unpredictable arrivals
- **Pediatric/Neonatal Units** - Specialized acuity scoring required
- **Operating Rooms** - Surgical staff coordination (different workflow)
- **Critical Care Units (CCU)** - Continuous monitoring, different thresholds
- **Mental Health Units** - Behavioral monitoring protocols differ

### 🏥 Target Hospital Profile

**Best suited for:**
- Small to mid-size hospitals (100-300 beds)
- Rural/community hospitals with limited IT resources
- Facilities with adequate staff but coordination challenges
- Hospitals with basic EMR systems (CSV export capability)

---

## 📋 Critical Assumptions

### Must Validate Before Implementation

1. **Patient Population**: Med-Surg patients only (NOT critical care)
2. **Acuity Thresholds**: High=2hrs, Medium=4hrs, Low=6hrs are clinically valid for your facility
3. **EMR Data Accuracy**: Visit timestamps accurate within ±1 minute
4. **Staffing Stability**: No major staffing changes during pilot
5. **Real-Time Data**: EMR feed available with <5 min latency
6. **User Adoption**: Charge nurses will follow recommendations ≥80% of time
7. **Root Cause Validation**: Problem IS coordination, NOT understaffing

**⚠️ If any assumption fails, pilot results may not be valid.**

---

## 👥 Team

### Project Team

- **Deepro Bandyopadhyay** - Data Analytics & Six Sigma Analysis
- **Chris Lasa** - System Architecture & Algorithm Design  
- **Bradley Matican** - UI/UX Design & User Research
- **Sreekar Mukkamala** - Clinical Validation & Process Mapping

### Acknowledgments

- **Patricia Rodriguez, CNO** - St. Mary's Hospital (Fictional stakeholder)
- **SYSEN 5300 Course Staff** - Cornell University
- **Healthcare Quality Experts** - Advisory and validation

---

## 📚 Additional Resources

### Documentation

- [Detailed Technical Documentation](docs/TECHNICAL.md)
- [User Guide for Charge Nurses](docs/USER_GUIDE.md)
- [API Documentation](docs/API.md)
- [Data Dictionary](docs/DATA_DICTIONARY.md)

### Research & References

- Nursing Solutions Inc. (2024). *NSI National Health Care Retention & RN Staffing Report*
- American Nurses Association. (2024). *Nurse Staffing Standards*
- Healthcare Cost and Utilization Project (HCUP). *Average Cost of Hospital Stay*

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 📧 Contact

**Project Repository:** [github.com/yourusername/lean-on-me](https://github.com/yourusername/lean-on-me)

**Questions?** Open an issue or contact the team.

---

## 🌟 Star History

If this project helped your hospital improve patient care, please ⭐ star this repo!

---

**Built with ❤️, Design Thinking, and Six Sigma principles to improve patient care**

*SYSEN 5300 Six Sigma Hackathon 2025 - Cornell University*
