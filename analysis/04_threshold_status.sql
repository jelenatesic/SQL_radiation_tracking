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

--> Task 2: Adding status if the patient is above 20mSv threshold
SELECT
    p.patient_id,
    p.name, 
    dpp.total_dose_mSv,
    dpp.num_events,
    CASE 
        WHEN dpp.total_dose_mSv > 20 THEN 'EXCEEDED'
        ELSE 'Safe'
    END AS dose_status
FROM patients p
JOIN Dose_per_Patient_Last_Year dpp
    ON p.patient_id = dpp.patient_id   
GROUP BY p.patient_id, p.name;     