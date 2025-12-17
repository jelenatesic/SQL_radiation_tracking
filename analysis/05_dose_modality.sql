----> Creating view to aggregate dose per patient over last year
DROP VIEW IF EXISTS Dose_per_Patient_Last_Year;
CREATE VIEW Dose_per_Patient_Last_Year AS 
    SELECT
        re.patient_id, 
        p.name,
        re.procedure_id,
        SUM(pr.typical_dose_mSv) AS total_dose_mSv,
        MIN(re.event_date) AS first_event_date,
        MAX(re.event_date) AS last_event_date,
        COUNT(re.event_id) AS num_events
    FROM radiation_events re
    LEFT JOIN procedures pr
        ON re.procedure_id = pr.procedure_id
    LEFT JOIN patients p
        ON re.patient_id = p.patient_id
    WHERE re.event_date >= date(date('now'), '-1 year')
    GROUP BY re.patient_id, p.name;

--> Task 3.1: Dose by Modality overall 
SELECT
    re.patient_id,
    re.procedure_id,
    pr.modality,
    SUM(pr.procedure_id) AS total_procedures
FROM radiation_events re
RIGHT OUTER JOIN procedures pr 
ON re.procedure_id = pr.procedure_id
GROUP BY re.patient_id, pr.modality;

--> Task 3.2: Dose by Modality in the last year, as regulatory reporting
SELECT 
    dpp.patient_id,
    dpp.procedure_id,
    pr.modality,
    SUM(dpp.procedure_id) AS total_procedures_last_year
FROM Dose_per_Patient_Last_Year dpp
JOIN procedures pr
ON dpp.procedure_id = pr.procedure_id
GROUP BY dpp.patient_id, pr.modality;

