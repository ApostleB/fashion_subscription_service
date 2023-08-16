USE Fitboa;
DROP TABLE IF EXISTS Inquiries;
CREATE TABLE IF NOT EXISTS Inquiries
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    UserId INT NOT NULL,
    ContentId INT NOT NULL,

    Type VARCHAR(20) NOT NULL, #1:1 스타일링, 회원정보, 결제, 기타, 배송
    TypeNum INT NOT NULL, #0, 1, 2, 3, 4

    Title VARCHAR(256) NOT NULL,
    Content VARCHAR(2048) NOT NULL,
    AdminContent VARCHAR(2048),

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(UserId) REFERENCES Users(Id) ON DELETE CASCADE,
    FOREIGN KEY(ContentId) REFERENCES Contents(Id) ON DELETE CASCADE
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

#INSERT INTO Inquiries (UserId, ContentId, Type, TypeNum, Title, Content)
#VALUES (2, 41, '1:1 스타일링', 0, '[1:1] 스타일링 신청', 'test');

INSERT INTO Inquiries (UserId, ContentId, Type, TypeNum, Title, Content)
VALUES (2, 1, '1:1 스타일링', 0, '[1:1] 스타일링 신청', 'test');