
SELECT new.table_name,
       new.aus - old.aus as difference,
	   new.aus as new_aus,
       old.aus as old_aus
	FROM gnaf_202105.qa as new
	INNER JOIN gnaf_202102.qa as old ON new.table_name = old.table_name
;