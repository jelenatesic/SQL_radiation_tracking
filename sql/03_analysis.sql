
-- SELECT * FROM radiation_events;
-- SELECT * FROM radiation_events
-- WHERE event_date >= date('now', '-1 year');

-- Task: Track patients dose of radiation over the last year

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

--> Task 1: Patients with total dose > 20mSv in the last year
SELECT 
    p.patient_id,
    p.name, 
    dpp.total_dose_mSv AS dose_higher_than_20mSv,
    dpp.num_events AS number_of_radiation_events_in_year,
    dpp.first_event_date,
    dpp.last_event_date
FROM patients p
JOIN Dose_per_Patient_Last_Year dpp
    ON p.patient_id = dpp.patient_id
WHERE dpp.total_dose_mSv > 20 
GROUP BY p.patient_id, p.name;

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

--> Task 4: Time Based Risk Analysis - Patients with increasing dose over last year
WITH Cumulative_Dose_mSv AS (
SELECT 
    p.patient_id,
    p.name,
    re.event_date,
    
    SUM(pr.typical_dose_mSv) OVER(
        PARTITION BY re.patient_id
        ORDER BY re.event_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_dose_mSv
FROM patients p 
JOIN radiation_events re 
ON p.patient_id = re.patient_id
JOIN procedures pr 
ON re.procedure_id = pr.procedure_id
ORDER BY re.patient_id, re.event_date
)
SELECT *
FROM Cumulative_Dose_mSv 
WHERE cumulative_dose_mSv > 20
ORDER BY patient_id, event_date;

    