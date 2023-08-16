USE Fitboa;
DROP TABLE IF EXISTS ContentReviews;
CREATE TABLE IF NOT EXISTS ContentReviews
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    ContentId INT NOT NULL,
    UserId INT NOT NULL,

    ParentReviewId INT NULL,
    GroupCode INT NULL,

    Content VARCHAR(1024) NULL,

    Rate FLOAT NOT NULL DEFAULT 0,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(ContentId) REFERENCES Contents(Id) ON DELETE CASCADE,
    FOREIGN KEY(UserId) REFERENCES Users(Id) ON DELETE CASCADE,
    FOREIGN KEY(ParentReviewId) REFERENCES ContentReviews(Id) ON DELETE CASCADE
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;
 
#INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content, CreatedAt, UpdatedAt, GroupCode)
#VALUES (1, 2, NULL, 'test', '2022-02-06 22:48:28', '2022-02-06 22:48:28', 1);
#INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content, CreatedAt, UpdatedAt, GroupCode)
#VALUES (1, 2, 1, '1 - test', '2022-02-06 22:48:38', '2022-02-06 22:48:38', 1);
#INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content, CreatedAt, UpdatedAt, GroupCode)
#VALUES (1, 2, 1, '2 - test', '2022-02-06 22:48:54', '2022-02-06 22:48:54', 1);
#INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content, CreatedAt, UpdatedAt, GroupCode)
#VALUES (1, 2, NULL, 'aaaa', '2022-02-06 22:49:15', '2022-02-06 22:49:15', 4);
#INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content, CreatedAt, UpdatedAt, GroupCode)
#VALUES (1, 2, 1, '3 - test', '2022-02-06 22:49:36', '2022-02-06 22:49:36', 1);
#INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content, CreatedAt, UpdatedAt, GroupCode)
#VALUES (1, 2, 4, '1 - aaaa', '2022-02-06 22:49:47', '2022-02-06 22:49:47', 4);
#
#INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content, CreatedAt, UpdatedAt, GroupCode)
#VALUES (21, 2, NULL, 'aaaa', '2022-02-06 22:49:47', '2022-02-06 22:49:47', 7);

#INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content)
#VALUES (41, 2, NULL, 'aaaa');