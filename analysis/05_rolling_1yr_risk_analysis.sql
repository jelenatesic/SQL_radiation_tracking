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


-- Task 4.1: Cumulate only ones within a year of the watched event
SELECT 
    p.patient_id,
    p.name,
    re.event_date,

    (
        SELECT SUM(pr2.typical_dose_mSv)
        FROM radiation_events re2
        JOIN procedures pr2
        ON re2.procedure_id = pr2.procedure_id
        WHERE re2.patient_id = re.patient_id
        AND re2.event_date BETWEEN date(re.event_date, -'1 year') AND re.event_date
    ) AS rolling_1yr_dose_mSv

FROM patients p 
JOIN radiation_events re 
    ON p.patient_id = re.patient_id
GROUP BY p.patient_id, p.name, re.event_date;
