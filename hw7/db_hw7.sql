USE music1_db;

-- Question 1
DELIMITER //

DROP FUNCTION IF EXISTS num_songs_with_genre;
CREATE FUNCTION num_songs_with_genre(genre_p VARCHAR(50)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE num_songs INT;
    
    SELECT COUNT(*) INTO num_songs
    FROM songs s
    JOIN genres g ON s.genre_id = g.gid
    WHERE g.genre_name = genre_p;
    
    RETURN num_songs;
END //

DELIMITER ;
SELECT num_songs_with_genre('Rock');

-- Question2 
DELIMITER //
DROP PROCEDURE IF EXISTS get_artists_with_label;
CREATE PROCEDURE get_artists_with_label(label_p VARCHAR(50))
READS SQL DATA

Begin
	select artist_name, label_name from artists a 
    join record_label r on r.rid = a.record_label_id
    where label_name = label_p;
	
End //

DELIMITER ;
CALL get_artists_with_label('Def Jam Recordings');


-- Question3
DELIMITER //
DROP PROCEDURE IF EXISTS song_has_genre;
CREATE PROCEDURE song_has_genre(genre_p VARCHAR(50))
READS SQL DATA

Begin
	select sid, song_name,  album_name from songs s
    join albums a on s.album_id = a.alid
    join genres g on g.gid = s.genre_id
    where g.genre_name = genre_p;
	
End //

DELIMITER ;
CALL song_has_genre('Pop');


-- Question 4
DELIMITER //
DROP FUNCTION IF EXISTS album_length;
CREATE FUNCTION album_length(length_p INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE num_albums INT;

    SELECT COUNT(*) INTO num_albums
    FROM (SELECT album_id
          FROM songs
          GROUP BY album_id
          HAVING COUNT(*) = length_p) AS album_lengths;

    RETURN num_albums;
END //

DELIMITER ;
SELECT album_length(1);



-- Question 5
DELIMITER //
DROP PROCEDURE IF EXISTS get_song_details;

CREATE PROCEDURE get_song_details(song_name_p VARCHAR(50))
READS SQL DATA
BEGIN
    SELECT s.song_name, s.sid AS song_id, rl.label_name AS recording_label, 
           a.album_name, g.genre_name, m.mood_name
    FROM songs s
    JOIN albums a ON s.album_id = a.alid
    JOIN artists art ON a.artist = art.artist_name
    JOIN record_label rl ON art.record_label_id = rl.rid
    JOIN genres g ON s.genre_id = g.gid
    JOIN moods m ON s.mood_id = m.mid
    WHERE s.song_name = song_name_p;
END //

DELIMITER ;
CALL get_song_details('xxx');



-- Question 6
DELIMITER //
DROP FUNCTION IF EXISTS more_followers;
CREATE FUNCTION more_followers(artist1_name VARCHAR(50), artist2_name VARCHAR(50)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE followers_artist1 INT;
    DECLARE followers_artist2 INT;

    -- Get the number of followers for the first artist
    SELECT COUNT(*) INTO followers_artist1
    FROM user_follows_artist ufa1 
    JOIN artists a1 ON ufa1.aid = a1.aid
    WHERE a1.artist_name = artist1_name;

    -- Get the number of followers for the second artist
    SELECT COUNT(*) INTO followers_artist2
    FROM user_follows_artist ufa2
    JOIN artists a2 ON ufa2.aid = a2.aid
    WHERE a2.artist_name = artist2_name;

    -- Return 1, 0, or -1 based on the comparison
    IF followers_artist1 > followers_artist2 THEN 
        RETURN 1;
    ELSEIF followers_artist1 = followers_artist2 THEN 
        RETURN 0;
    ELSE 
        RETURN -1;
    END IF;
END //

DELIMITER ;


-- Question 6
DELIMITER //
DROP PROCEDURE IF EXISTS create_song;

CREATE PROCEDURE create_song(
    IN title_p VARCHAR(50), 
    IN artist_p VARCHAR(50), 
    IN record_label_p VARCHAR(50), 
    IN mood_p VARCHAR(50), 
    IN genre_p VARCHAR(50), 
    IN album_title VARCHAR(50)
)
BEGIN
    DECLARE genre_id INT;
    DECLARE mood_id INT;
    DECLARE record_label_id INT;
    DECLARE artist_id INT;
    DECLARE album_id INT;

    -- Check and get the genre_id
    SELECT gid INTO genre_id FROM genres WHERE genre_name = genre_p;
    IF genre_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Genre does not exist';
    END IF;

    -- Check and get the mood_id
    SELECT mid INTO mood_id FROM moods WHERE mood_name = mood_p;
    IF mood_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mood does not exist';
    END IF;

    -- Check and get the record_label_id
    SELECT rid INTO record_label_id FROM record_label WHERE label_name = record_label_p;
    IF record_label_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Record label does not exist';
    END IF;

    -- Check and get the artist_id
    SELECT aid INTO artist_id FROM artists WHERE artist_name = artist_p;
    IF artist_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Artist does not exist';
    END IF;

    -- Check if the album exists, if not create a new album
    SELECT alid INTO album_id FROM albums WHERE album_name = album_title AND artist = artist_p;
    IF album_id IS NULL THEN
        INSERT INTO albums (album_name, artist) VALUES (album_title, artist_p);
        SET album_id = LAST_INSERT_ID();
    END IF;

    -- Insert the new song
    INSERT INTO songs (song_name, album_id, genre_id, mood_id) VALUES (title_p, album_id, genre_id, mood_id);

    -- Assuming that the 'songs' table has a 'producer_id' and the producer is the artist himself
    -- Update the 'artist_performs_song' table
    INSERT INTO artist_performs_song (sid, aid) VALUES (LAST_INSERT_ID(), artist_id);
END //

DELIMITER ;
CALL create_song('Me about You', 'The Turtles', 'Def Jam Recordings', 'Calm', 'Pop', 'Happy Together');


 -- Question 8
DELIMITER //
DROP PROCEDURE IF EXISTS  get_songs_with_mood;

CREATE PROCEDURE  get_songs_with_mood(mood_n VARCHAR(50))
READS SQL DATA
BEGIN
    SELECT s.song_name, m.mood_name, m.mood_description, art.artist_name 
    FROM songs s
    JOIN albums a ON s.album_id = a.alid
    JOIN artists art ON a.artist = art.artist_name
    JOIN record_label rl ON art.record_label_id = rl.rid
    JOIN genres g ON s.genre_id = g.gid
    JOIN moods m ON s.mood_id = m.mid
    WHERE m.mood_name = mood_n;
END //

DELIMITER ;

 -- Question 9
DELIMITER //
-- Check if the column already exists and add it if it doesn't
SELECT COUNT(*) INTO @exists FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'music1_db' -- Replace with your actual database name
AND TABLE_NAME = 'artists' 
AND COLUMN_NAME = 'num_released';

IF @exists = 0 THEN
  ALTER TABLE `artists`
  ADD COLUMN `num_released` INT DEFAULT 0;
END IF;
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS set_num_released_count;

DELIMITER //
CREATE PROCEDURE set_num_released_count(IN artist_name_param VARCHAR(50))
BEGIN
    DECLARE album_count INT;
    
    -- Count the number of albums for the given artist
    SELECT COUNT(*) INTO album_count
    FROM albums
    WHERE artist = artist_name_param;
    
    -- Update the num_released column for the given artist
    UPDATE artists
    SET num_released = album_count
    WHERE artist_name = artist_name_param;
END //
DELIMITER ;

-- Call the procedure and test for the artist 'Vanilla'
CALL set_num_released_count('Vanilla');
SELECT artist_name, num_released FROM artists WHERE artist_name = 'Vanilla';


-- QUestion 10
DELIMITER //
DROP PROCEDURE IF EXISTS update_all_artists_num_releases;
CREATE PROCEDURE update_all_artists_num_releases()
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE artist_name_param VARCHAR(50);
    DECLARE artist_cursor CURSOR FOR SELECT artist_name FROM artists;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN artist_cursor;

    update_loop: LOOP
        FETCH artist_cursor INTO artist_name_param;
        IF finished = 1 THEN 
            LEAVE update_loop;
        END IF;
        CALL set_num_released_count(artist_name_param);
    END LOOP update_loop;

    CLOSE artist_cursor;
END;
//
DELIMITER ;

CALL update_all_artists_num_releases();
SELECT artist_name, num_released FROM artists;

-- Question 11

delimiter //
DROP TRIGGER IF EXISTS artist_update_after_insert_album;

CREATE TRIGGER artist_update_after_insert_album
after insert on albums
for each row 
	begin 
		update artists
        set num_released = num_released + 1
        WHERE artist_name = NEW.artist;
	end;
//
delimiter ;
INSERT INTO albums (album_name, artist) VALUES ('Justice', 'Justin Beiber');
SELECT artist_name, num_released FROM artists WHERE artist_name = 'Justin Beiber';
-- Question 12

-- Question 12: Trigger after DELETE

DELIMITER //

DROP TRIGGER IF EXISTS artist_update_after_delete_album;

CREATE TRIGGER artist_update_after_delete_album
AFTER DELETE ON albums
FOR EACH ROW 
BEGIN 
    UPDATE artists
    SET num_released = num_released - 1
    WHERE artist_name = OLD.artist;
END; //

DELIMITER ;

-- Delete an album to test the trigger
DELETE FROM albums WHERE album_name = 'Justice' AND artist = 'Justin Beiber';
-- Verify that the num_released has been decremented for Justin Beiber
SELECT artist_name, num_released FROM artists WHERE artist_name = 'Justin Beiber';






-- Quesion 13
-- Set session variables for the artist names
SET @artist1 = 'Vanilla';
SET @artist2 = 'The Turtles';
SET @artist3 = 'Vulfpeck';
SET @artist4 = 'Childish Gambino';

-- Prepare the SQL statement
SET @sql = 'SELECT more_followers(?, ?)';
PREPARE st FROM @sql;

-- Execute the prepared statement with different artist pairs
EXECUTE st USING @artist1, @artist2;
EXECUTE st USING @artist3, @artist4;
EXECUTE st USING @artist1, @artist3;

-- Deallocate the prepared statement
DEALLOCATE PREPARE st;









-- Set session variables for the genres
SET @value1 = 'Rock';
SET @value2 = 'Pop';
SET @value3 = 'Country';

-- Prepare the SQL statement
SET @sql = 'SELECT num_songs_with_genre(?)';
PREPARE st FROM @sql;

-- Execute the prepared statement with different genres
EXECUTE st USING @value1;
EXECUTE st USING @value2;
EXECUTE st USING @value3;

-- Deallocate the prepared statement
DEALLOCATE PREPARE st;


