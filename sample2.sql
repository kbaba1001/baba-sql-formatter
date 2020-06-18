DELETE FROM table1 WHERE col1 = 'aaa' AND col2 = 'bbb' AND TRUNC(created_at) = DATE_TRUNC('week', CONVERT_TIMEZONE('JST', GETDATE()));

INSERT INTO table1 WITH
table2 AS( SELECT id ,MAX(col1) AS max_col1 FROM table3 GROUP BY id) ,xxx AS(SELECT col1 ,col2 ,col3, LAG(col1, 1) OVER(PARTITION BY col1 ORDER BY update_timestamp) AS col4 FROM table2)
SELECT id ,DATE_TRUNC('year', col1) AS year ,DATEADD('day', -365, created_at) AS begin_date FROM xxx LEFT JOIN yyy AS y ON xxx.id = y.xxx_id INNER JOIN aaa AS a ON aaa.id = y.aaa_id AND b.id = a.id AND b.id = a.id RIGHT OUTER JOIN bbb ON bbb.id = a.bbb_id LEFT OUTER JOIN ccc ON ccc.id = bbb.c_id CROSS JOIN zzz;

COMMIT;
