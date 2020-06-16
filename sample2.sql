DELETE FROM table1 WHERE col1 = 'aaa' AND col2 = 'bbb' AND TRUNC(created_at) = DATE_TRUNC('week', CONVERT_TIMEZONE('JST', GETDATE()));

INSERT INTO table1 WITH
table2 AS( SELECT id ,MAX(col1) AS max_col1 FROM table3 GROUP BY id) ,xxx AS(SELECT col1 ,col2 ,col3 FROM table2)
SELECT id ,DATE_TRUNC('year', col1) AS year ,DATEADD('day', -365, created_at) AS begin_date FROM xxx LEFT JOIN yyy AS y ON xxx.id = y.xxx_id;

COMMIT;
