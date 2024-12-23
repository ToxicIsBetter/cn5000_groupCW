-- ===========================
--         QUERY: 1
-- ===========================
SELECT 
    FC.CLASS_TYPE AS CLASS_LIST,
    S.FIRST_NAME || ' ' || S.LAST_NAME AS INSTRUCTOR_NAME,
    LISTAGG(TO_CHAR(FC.SCHEDULE, 'DD-MON-YYYY HH24:MI'), ', ') 
        WITHIN GROUP (ORDER BY FC.SCHEDULE) AS SCHEDULE
FROM FITNESS_CLASSES FC
JOIN STAFF S ON FC.INSTRUCTOR_ID = S.STAFF_ID
GROUP BY FC.CLASS_TYPE, S.FIRST_NAME, S.LAST_NAME
ORDER BY CLASS_LIST;

-- ===========================
--         QUERY: 2
-- ===========================

SELECT CL.CLIENT_ID, CL.FIRST_NAME || ' ' || CL.LAST_NAME AS CLIENT_NAME, CB.STATUS
FROM FITNESS_CLASSES FC
INNER JOIN CLASS_BOOKINGS CB ON FC.CLASS_ID = CB.CLASS_ID
INNER JOIN CLIENTS CL ON CB.CLIENT_ID = CL.CLIENT_ID
WHERE FC.CLASS_TYPE = 'Yoga';

-- ===========================
--         QUERY: 3
-- ===========================

SELECT 
    SUM(CASE WHEN SERVICE_NAME = 'Membership' THEN AMOUNT ELSE 0 END) AS MEMBERSHIP_REVENUE,
    SUM(CASE WHEN SERVICE_NAME = 'Class Booking' THEN AMOUNT ELSE 0 END) AS CLASS_REVENUE,
    SUM(CASE WHEN SERVICE_NAME = 'Personal Training' THEN AMOUNT ELSE 0 END) AS PERSONAL_TRAINING_SESSION_REVENUE,
    SUM(CASE WHEN SERVICE_NAME IN ('Membership', 'Class Booking', 'Personal Training') THEN AMOUNT ELSE 0 END) AS TOTAL_REVENUE
FROM BILLING;

-- ===========================
--         QUERY: 4
-- ===========================
SELECT PTS.TRAINER_ID, ST.FIRST_NAME || ' ' || ST.LAST_NAME AS TRAINER_NAME, COUNT(PTS.TRAINING_ID) AS SESSIONS_TAKEN
FROM PERSONAL_TRAINING_SESSIONS PTS
JOIN STAFF ST
ON PTS.TRAINER_ID = ST.STAFF_ID
GROUP BY PTS.TRAINER_ID, ST.FIRST_NAME, ST.LAST_NAME
ORDER BY SESSIONS_TAKEN DESC, TRAINER_NAME
FETCH FIRST 5 ROWS ONLY;

-- ===========================
--         QUERY: 5
-- ===========================

SELECT 
    CL.CLIENT_ID,
    CL.FIRST_NAME || ' ' || CL.LAST_NAME AS CLIENT_NAME,
    COUNT(GA.ATTENDANCE_ID) AS CHECKIN_COUNT
FROM GYM_ATTENDANCE GA
JOIN MEMBERSHIP MEM ON GA.CLIENT_ID = MEM.CLIENT_ID
JOIN CLIENTS CL ON GA.CLIENT_ID = CL.CLIENT_ID
WHERE MEM.END_DATE < SYSDATE -- Membership has expired
  AND GA.CHECK_IN > SYSDATE - 30 -- Checked in within the last 30 days
GROUP BY CL.FIRST_NAME, CL.LAST_NAME, CL.CLIENT_ID
ORDER BY CHECKIN_COUNT DESC;

-- ===========================
--         QUERY: 6
-- ===========================

SELECT CL.FIRST_NAME || ' ' || CL.LAST_NAME AS CLIENT_NAME, COUNT(PTS.EXERCISE_TYPE) AS EXERCISES
FROM PERSONAL_TRAINING_SESSIONS PTS
JOIN CLIENTS CL ON PTS.CLIENT_ID = CL.CLIENT_ID
WHERE CL.CLIENT_CATEGORY = 'Member'
GROUP BY CL.FIRST_NAME, CL.LAST_NAME
-- using 'HAVING' function instead of 'WHERE' as group by does not support 'WHERE'
HAVING COUNT(PTS.EXERCISE_TYPE) >= 3
ORDER BY EXERCISES DESC, CLIENT_NAME;

-- ===========================
--         QUERY: 7
-- ===========================

SELECT DISCOUNT_CODE, USAGE_COUNT, REVENUE_LOSS
FROM DISCOUNTS
ORDER BY REVENUE_LOSS DESC;

-- ===========================
--         QUERY: 8
-- ===========================

SELECT 
    -- Concatenate the first and last names to create the full name
    CL.FIRST_NAME || ' ' || CL.LAST_NAME AS CLIENT_NAME,
    
    -- Use GYM_VISITS directly since it's guaranteed to be non-NULL
    CUR.GYM_VISITS AS GYM_VISITS,
    
    -- Progress percentage capped at 100%
    TRUNC(LEAST(100 * (CUR.GYM_VISITS / 21), 100)) || '%' AS PROGRESS,
    
    -- Last month's gym visits
    LAST.GYM_VISITS AS LAST_MONTH_GYM_VISITS,
    
    -- Progress percentage for the last month, capped at 100%
    TRUNC(LEAST(100 * (LAST.GYM_VISITS / 21), 100)) || '%' AS LAST_MONTH_PROGRESS,
    
    -- If no visit dates, use 'No Visits' explicitly
    CASE WHEN CUR.VISIT_DATES IS NULL THEN 'No Visits' ELSE CUR.VISIT_DATES END AS VISIT_DATES
FROM CLIENTS CL
-- Join for gym visits in the last 30 days
LEFT JOIN (
    SELECT 
        GA.CLIENT_ID, 
        COUNT(*) AS GYM_VISITS, 
        LISTAGG(TO_CHAR(GA.CHECK_IN, 'DD-MM-YYYY'), ', ') WITHIN GROUP (ORDER BY GA.CHECK_IN) AS VISIT_DATES
    FROM GYM_ATTENDANCE GA
    WHERE GA.CHECK_IN >= SYSDATE - 30
    GROUP BY GA.CLIENT_ID
) CUR ON CL.CLIENT_ID = CUR.CLIENT_ID
-- Join for gym visits 31–60 days ago
LEFT JOIN (
    SELECT 
        GA.CLIENT_ID, 
        COUNT(*) AS GYM_VISITS
    FROM GYM_ATTENDANCE GA
    WHERE GA.CHECK_IN BETWEEN SYSDATE - 60 AND SYSDATE - 31
    GROUP BY GA.CLIENT_ID
) LAST ON CL.CLIENT_ID = LAST.CLIENT_ID
ORDER BY CLIENT_NAME;
