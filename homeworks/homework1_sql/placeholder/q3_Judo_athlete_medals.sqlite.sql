WITH judo_athletes AS (
    SELECT DISTINCT code, name
    FROM athletes
    WHERE disciplines LIKE '%Judo%'
),
all_medals AS (
    SELECT winner_code, COUNT(*) as medal_count
    FROM medals
    GROUP BY winner_code
    UNION ALL
    SELECT a.code, COUNT(*) as medal_count
    FROM athletes a
    JOIN teams t ON t.athletes_code LIKE '%' || a.code || '%'
    JOIN medals m ON m.winner_code = t.code
    GROUP BY a.code
)

SELECT ja.name AS ATHLETE_NAME, COALESCE(SUM(am.medal_count), 0) AS MEDAL_NUMBER
FROM judo_athletes ja
LEFT JOIN all_medals am ON ja.code = am.winner_code
GROUP BY ja.code, ja.name
ORDER BY MEDAL_NUMBER DESC, ATHLETE_NAME ASC;