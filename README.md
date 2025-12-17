# Radiation Dose Tracking System (SQL)

This project implements a simplified radiation dose tracking system for medical imaging using SQL and SQLite. 

The goal is to:
- Track radiation exposure per patient
- Agregate dose over clinically meaningful time windows (1 year) 
- Detect when regulatory safety thresholds are exceeded.

The project is inspired by real-world radiology and nuclear medicine dose monitoring systems. 

## Clinical Motivation
Medical imaging procedures such as X-ray, CT and PET expose patients to ionizing radiation, which can be dangerous if the defined threshold of cumulative radiation exposure over one year is exceeded (20 mSv). 

This system answers questions like:
- How much radiation has a patient recieved in the last year?
- How many imaging events contributed to that dose?
- On which imaging event did a patient cross a risk threshold?

---
## Database Shema
The database is normalized into three main tables:

### Patients
- Demographics and patient identifiers

### Procedures
- Imaging procedure metadata
- Typical radiation dose per procedure

### Radiation Events
- Individual imaging events
- Links patients to procedures and dates