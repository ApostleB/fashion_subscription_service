USE Fitboa;
DROP TABLE IF EXISTS PromotionUsers;
CREATE TABLE IF NOT EXISTS PromotionUsers
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    UserId INT NULL,
    PromotionId INT NULL,
    IsUse BOOLEAN NOT NULL DEFAULT FALSE,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(UserId) REFERENCES Users(Id),
    FOREIGN KEY(PromotionId) REFERENCES Promotions(Id) 
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;
