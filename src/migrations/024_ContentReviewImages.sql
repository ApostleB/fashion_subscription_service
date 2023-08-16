USE Fitboa;
DROP TABLE IF EXISTS ContentReviewImages;
CREATE TABLE IF NOT EXISTS ContentReviewImages
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    ReviewId INT NOT NULL,

    FileName VARCHAR(256) NOT NULL,
    FilePath VARCHAR(256) NOT NULL,

    OriginFileName VARCHAR(256) NOT NULL,

    OrderNum INT NOT NULL,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(ReviewId) REFERENCES ContentReviews(Id) ON DELETE CASCADE
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

#INSERT INTO ContentReviewImages (ReviewId, FileName, FilePath, OriginFileName, OrderNum, CreatedAt, UpdatedAt) 
#VALUES (7, 'TEST2', 'uploads/', '0.Thumnail.png', 1, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#
#INSERT INTO ContentReviewImages (ReviewId, FileName, FilePath, OriginFileName, OrderNum, CreatedAt, UpdatedAt) 
#VALUES (7, 'TEST', 'uploads/', '0.Thumnail.png', 0, '2022-02-06 23:25:27', '2022-02-06 23:53:22');