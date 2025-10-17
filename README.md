# leanonme
SYSEN 5300 Hackathon Team: Lean on Me Fall 2025
# Lean On Me: Inpatient Wait Time Quality Control System

## Overview
Hospitals require seamless coordination between nurses and doctors to ensure timely and effective patient care. However, patients in our hospital system have reported wide and irregular gaps between staff visits during inpatient stays—impacting both perceived and actual treatment quality. This project was developed during the SYSEN 5300 Hackathon to address that challenge.

## Objective
To build a lightweight, data-driven tool that tracks inpatient wait times, identifies excessive delays in staff visits, and provides actionable alerts to improve care quality and responsiveness.

## Features
- Synthetic data generation for patient and staff activity
- Real-time tracking of wait times between visits
- Alert system for excessive delays
- Visualizations including heatmaps and time-series charts
- Quality control logic using Six Sigma principles

## Inputs
- `patient_id`, `room_number`, `check_in_time`, `discharge_time`
- `staff_id`, `visit_time`, `patient_id`, `role`
- Optional: `floor_id`, `acuity_level`, `staff_schedule`

## Outputs
- Average and maximum wait times per patient
- Alerts for patients exceeding wait thresholds
- Visual dashboards for hospital staff
- Control charts and statistical summaries

## Installation
```r
# Install devtools if needed
install.packages("devtools")

# Install the package from GitHub
devtools::install_github("BradleyMatican25/leanonme")
