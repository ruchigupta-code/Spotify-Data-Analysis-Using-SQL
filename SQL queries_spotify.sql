CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views BIGINT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energyliveness FLOAT,
    most_playedon VARCHAR(50)
);


UPDATE spotify
SET licensed = (licensed::TEXT ILIKE 'true'),
    official_video = (official_video::TEXT ILIKE 'true')

-- 1) Top 10 most streamed tracks
SELECT track, artist, stream
FROM spotify
ORDER BY stream DESC
LIMIT 10;

-- 2) Average likes and comments per channel
SELECT channel,
       ROUND(AVG(likes), 0) AS avg_likes,
       ROUND(AVG(comments), 0) AS avg_comments
FROM spotify
GROUP BY channel
ORDER BY avg_likes DESC;

-- 3) Distribution of tracks by album type
SELECT album_type, COUNT(*) AS track_count
FROM spotify
GROUP BY album_type
ORDER BY track_count DESC;

-- 4) Artists with the highest average streams per track
SELECT artist,
       ROUND(AVG(stream), 0) AS avg_streams
FROM spotify
GROUP BY artist
HAVING COUNT(*) >= 5   -- only artists with at least 5 tracks in dataset
ORDER BY avg_streams DESC
LIMIT 10;

-- 5) Tracks where views are greater than streams (rare cases)
SELECT track, artist, views, stream
FROM spotify
WHERE views > stream;

-- 6) Correlation check: do higher energy tracks get more streams?
SELECT CASE 
           WHEN energy >= 0.7 THEN 'High Energy'
           WHEN energy >= 0.4 THEN 'Medium Energy'
           ELSE 'Low Energy'
       END AS energy_level,
       ROUND(AVG(stream), 0) AS avg_streams
FROM spotify
GROUP BY energy_level
ORDER BY avg_streams DESC;

-- 7) Most popular platform for tracks
SELECT most_playedon, COUNT(*) AS track_count
FROM spotify
GROUP BY most_playedon
ORDER BY track_count DESC;

-- 8) Top 10 most liked official videos
SELECT track, artist, likes
FROM spotify
WHERE official_video = TRUE
ORDER BY likes DESC
LIMIT 10;

-- 1) Average danceability of tracks in each album
SELECT album,
       ROUND(AVG(danceability), 3) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY avg_danceability DESC;

-- 2) Top 5 tracks with the highest energy values
SELECT track, artist, energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;

-- 3) Tracks with their views and likes where official_video = TRUE
SELECT track, artist, views, likes
FROM spotify
WHERE official_video = TRUE
ORDER BY views DESC;

-- 4) For each album, total views of all associated tracks
SELECT album,
       SUM(views) AS total_views
FROM spotify
GROUP BY album
ORDER BY total_views DESC;

-- 5) Tracks streamed more on Spotify than YouTube
-- (assuming 'most_playedon' column has values like 'Spotify' or 'YouTube')
SELECT track, artist, stream, views, most_playedon
FROM spotify
WHERE most_playedon = 'Spotify' AND stream > views

-- 1) Top 3 most-viewed tracks for each artist using window functions
SELECT artist, track, views
FROM (
    SELECT artist,
           track,
           views,
           ROW_NUMBER() OVER (PARTITION BY artist ORDER BY views DESC) AS rn
    FROM spotify
) ranked
WHERE rn <= 3
ORDER BY artist, views DESC;

-- 2) Tracks where the liveness score is above the average
SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
ORDER BY liveness DESC;

-- 3) Difference between highest and lowest energy values for tracks in each album (using WITH)
WITH energy_stats AS (
    SELECT album,
           MAX(energy) AS max_energy,
           MIN(energy) AS min_energy
    FROM spotify
    GROUP BY album
)
SELECT album,
       max_energy,
       min_energy,
       (max_energy - min_energy) AS energy_range
FROM energy_stats
ORDER BY energy_range DESC;