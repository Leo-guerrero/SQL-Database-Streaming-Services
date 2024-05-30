CREATE DATABASE stream_accounts;
USE stream_accounts;

-- User Table
CREATE TABLE User (
    UserID INT UNIQUE PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    SubscriptionTier VARCHAR(20) 
);

-- Content Table
CREATE TABLE Content (
    ContentID INT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Genre VARCHAR(50),
    ReleaseYear INT,
    Duration INT
);

-- User_Content_Interaction Table
CREATE TABLE User_Content_Interaction (
    InteractionID INT PRIMARY KEY,
    UserID INT,
    ContentID INT,
    Rating INT NOT NULL, -- Add NOT NULL constraint for Rating
    Review TEXT,
    WatchHistory INT,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (ContentID) REFERENCES Content(ContentID)
);

-- Add NOT NULL constraints
ALTER TABLE User
MODIFY Username VARCHAR(50) NOT NULL;

ALTER TABLE Content
MODIFY Title VARCHAR(100) NOT NULL;

-- Add trigger to enforce rating constraint
DELIMITER //
CREATE TRIGGER check_rating_range
BEFORE INSERT ON User_Content_Interaction
FOR EACH ROW
BEGIN
    IF NEW.Rating < 1 OR NEW.Rating > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
END;
//
DELIMITER ;

-- Add indexes
ALTER TABLE User_Content_Interaction
ADD INDEX idx_user_id (UserID),
ADD INDEX idx_content_id (ContentID);


-- Insert sample data into User table
INSERT INTO User (UserID, Username, SubscriptionTier)
VALUES
    (1, 'user1', 'Basic'),
    (2, 'user2', 'Plus'),
    (3, 'user3', 'Premium');

-- Insert sample data into Content table
INSERT INTO Content (ContentID, Title, Genre, ReleaseYear, Duration)
VALUES
    (101, 'Spiderman 2', 'Action', 2002, 120),
    (102, 'Breaking Bad', 'Drama', 2019, 45),
    (103, 'Friends', 'Comedy', 1999, 30),
    (104, 'Dune', 'Sci-fi', 2021, 200),
    (105, 'Game of Thrones', 'Drama', 2019, 85),
    (106, 'The Batman', 'Action', 2022, 130);
    

-- Insert sample data into User_Content_Interaction table
INSERT INTO User_Content_Interaction (InteractionID, UserID, ContentID, Rating, Review, WatchHistory)
VALUES
    (1, 1, 101, 5, 'excellent', 90),
    (2, 1, 102, 4, 'Enjoyed it', 50),
    (3, 2, 101, 3, 'Okay', 100),
    (4, 3, 103, 5, 'Hilarious!', 70),
    (5, 3, 102, 4, 'Entertaining', 60);

-- 1
SELECT U.Username, UCI.Review
FROM User U
JOIN User_Content_Interaction UCI ON U.UserID = UCI.UserID
WHERE UCI.Rating > 4;


-- 2
SELECT DISTINCT C.Title
FROM Content C
JOIN User_Content_Interaction UCI ON C.ContentID = UCI.ContentID
WHERE UCI.Review LIKE '%Entertaining%';

-- 3 Window Function
SELECT
    C.Title,
    AVG(UCI.Rating) OVER (PARTITION BY UCI.ContentID) AS AverageRating,
    COUNT(*) OVER (PARTITION BY UCI.ContentID) AS TotalReviews
FROM
    Content C
JOIN
    User_Content_Interaction UCI ON C.ContentID = UCI.ContentID;



-- 4
SELECT U.Username, COUNT(UCI.InteractionID) AS TotalReviews
FROM User U
JOIN User_Content_Interaction UCI ON U.UserID = UCI.UserID
GROUP BY U.UserID
ORDER BY TotalReviews DESC
LIMIT 3;


-- 5 Transaction / update
START TRANSACTION;

-- Update review for a specific user and content
UPDATE User_Content_Interaction
SET Review = 'Updated review text'
WHERE UserID = 123 AND ContentID = 456;

-- Update another review for a different user and content
UPDATE User_Content_Interaction
SET Review = 'Another updated review'
WHERE UserID = 456 AND ContentID = 789;

-- Add a new review for a different user and content
INSERT INTO User_Content_Interaction (UserID, ContentID, Rating, Review, WatchHistory)
VALUES (789, 123, 4, 'AMAZING', 120);

COMMIT;



-- 6
SELECT U.Username, AVG(UCI.Rating) AS AverageRating
FROM User U
JOIN User_Content_Interaction UCI ON U.UserID = UCI.UserID
GROUP BY U.UserID
ORDER BY AverageRating DESC
LIMIT 3;


-- 7
DELETE FROM User_Content_Interaction
WHERE Rating < 3;



