/* Will search for all entity attributes which have 'nextval(<sequencename>:;regclass)'
 * as default value, get the highest value from this attribute and use attribute + 1 
 * to set new sequence value
 */

DO $$
DECLARE
	rec RECORD;
	seq_name TEXT;
	update_sequence TEXT;
BEGIN
	FOR rec IN SELECT * FROM information_schema.columns WHERE table_schema = 'public' AND column_default LIKE '%nextval(%::regclass%' ORDER BY table_name LOOP
		seq_name := substring(rec.column_default from '''(.+)''');
                update_sequence:= 'SELECT setval(''' || seq_name || ''',(SELECT MAX('|| rec.column_name ||') + 1 FROM ' || rec.table_name ||'), false)';
		raise notice 'Value: %', update_sequence;
		EXECUTE update_sequence;
	END LOOP;
END$$;
