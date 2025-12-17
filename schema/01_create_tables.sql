DROP TABLE IF EXISTS radiation_events;
DROP TABLE IF EXISTS procedures;
DROP TABLE IF EXISTS patients;

CREATE TABLE patients (
    patient_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    date_of_birth DATE,
    sex TEXT
);

CREATE TABLE procedures (
    procedure_id INTEGER PRIMARY KEY,
    procedure_name TEXT NOT NULL,
    modality TEXT,            -- CT, X-ray, PET, etc.
    typical_dose_mSv REAL     -- typical dose for reference
);

CREATE TABLE radiation_events (
    event_id INTEGER PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    procedure_id INTEGER NOT NULL,
    event_date DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (procedure_id) REFERENCES procedures(procedure_id)
);