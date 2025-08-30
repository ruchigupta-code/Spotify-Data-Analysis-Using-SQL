# Spotify-Data-Analysis-Using-SQL
![Spotify logo](https://github.com/ruchigupta-code/Spotify-Data-Analysis-Using-SQL/blob/main/spotify_logo.jpg)

# Spotify Tracks SQL Project

## Overview

This project analyzes a dataset of tracks from Spotify and YouTube using SQL. The dataset contains information about artists, albums, streams, likes, comments, views, audio features (danceability, energy, loudness, etc.), and metadata such as licensing and official video status. The goal of this project is to demonstrate SQL skills including joins, aggregations, window functions, and CTEs.

## Dataset

The dataset (`cleaned_dataset.csv`) was cleaned and imported into a PostgreSQL table named `spotify`. The schema is as follows:

```sql
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
```

## Key Queries

Here are some example queries written for analysis:

### Basic Analysis

* **Tracks with more than 1B streams:**

```sql
SELECT track
FROM spotify
WHERE stream > 1000000000;
```

* **List albums with their respective artists:**

```sql
SELECT DISTINCT album, artist
FROM spotify;
```

* **Total comments on licensed tracks:**

```sql
SELECT SUM(comments) AS total_comments
FROM spotify
WHERE licensed = TRUE;
```

* **Tracks belonging to album type 'single':**

```sql
SELECT track
FROM spotify
WHERE album_type = 'single';
```

* **Count tracks per artist:**

```sql
SELECT artist, COUNT(*) AS track_count
FROM spotify
GROUP BY artist
ORDER BY track_count DESC;
```

### Intermediate Analysis

* **Average danceability by album:**

```sql
SELECT album, ROUND(AVG(danceability), 3) AS avg_danceability
FROM spotify
GROUP BY album;
```

* **Top 5 highest energy tracks:**

```sql
SELECT track, artist, energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;
```

* **Tracks with official videos (views + likes):**

```sql
SELECT track, artist, views, likes
FROM spotify
WHERE official_video = TRUE;
```

* **Total views by album:**

```sql
SELECT album, SUM(views) AS total_views
FROM spotify
GROUP BY album;
```

* **Tracks streamed more on Spotify than YouTube:**

```sql
SELECT track, artist, stream, views
FROM spotify
WHERE most_playedon = 'Spotify' AND stream > views;
```

### Advanced Analysis

* **Top 3 most-viewed tracks per artist (window function):**

```sql
SELECT artist, track, views
FROM (
    SELECT artist, track, views,
           ROW_NUMBER() OVER (PARTITION BY artist ORDER BY views DESC) AS rn
    FROM spotify
) ranked
WHERE rn <= 3;
```

* **Tracks where liveness is above average:**

```sql
SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);
```

* **Energy range per album using CTE:**

```sql
WITH energy_stats AS (
    SELECT album, MAX(energy) AS max_energy, MIN(energy) AS min_energy
    FROM spotify
    GROUP BY album
)
SELECT album, max_energy, min_energy, (max_energy - min_energy) AS energy_range
FROM energy_stats;
```

## Insights

* Over **300 tracks** in the dataset have more than 1B streams.
* The dataset shows that **album type 'single'** makes up a large portion of tracks.
* Some artists (like Nicki Minaj, \$NOT) appear with the highest track counts.
* Energy and liveness values vary widely across albums, useful for identifying stylistic differences.

## How to Run

1. Create the table using the schema above.
2. Import the CSV using `COPY` or `\copy` in PostgreSQL.
3. Run the queries in `spotify_queries.sql`.

## Project Purpose

This project was created to showcase SQL skills for data analysis, focusing on:

* Aggregations and grouping
* Filtering and conditions
* Window functions
* Common Table Expressions (CTEs)
