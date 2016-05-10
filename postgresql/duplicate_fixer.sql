/**
 * Replace <id_column> as your entity's primary key property name. (eg. car_id)
 * Replace <entity_name> as your entity name. (eg. car)
 * 
 */

DO $$
DECLARE
        total_rows INTEGER;
        _offset INTEGER := 0;
        _limit INTEGER := 1000;
BEGIN
        
        SELECT COUNT(*) INTO total_rows FROM <entity_name>;
        WHILE _offset <= total_rows LOOP
                RAISE NOTICE 'Checking % records from record #%',_limit,_offset;
                DELETE FROM 
                        <entity_name> 
                WHERE 
                        <id_column> IN (
                                SELECT id FROM (
                                        SELECT 
                                                <id_column> As id,
                                                (SELECT COUNT(*) FROM <entity_name> e2 WHERE e2.<id_column> = e1.<id_column>) As duplicate_count --You should replace "WHERE" statement according to your application
                                        FROM <entity_name> e1 
                                        ORDER BY <id_column>
                                        OFFSET @_offset LIMIT @_limit
                                ) AS duplicate_detector
                                WHERE duplicate_count > 1
                        );
                _offset := _offset + _limit;
        END LOOP;
END$$;
