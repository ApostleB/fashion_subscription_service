USE Fitboa;
DROP TABLE IF EXISTS UserMerchants;
CREATE TABLE IF NOT EXISTS UserMerchants
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    UserId INT DEFAULT NULL,

    MerchantId INT DEFAULT NULL,
    
    CardId INT DEFAULT NULL,
    NextCardId INT DEFAULT NULL,

    Price VARCHAR(10) NULL,

    Type INT DEFAULT 0, #0: Monthly, 1: Yearly

    PayDateTime TIMESTAMP NULL,
    PayExt TIMESTAMP NULL,

    IsPrevFirstMerchant BOOLEAN NOT NULL DEFAULT FALSE,
    IsFirstMerchant BOOLEAN NOT NULL DEFAULT TRUE,

    PromotionId INT DEFAULT NULL,
    PromotionDiscountType INT DEFAULT 0, #0: 원, 1: %

    PromotionDiscountRate DOUBLE NULL,
    PromotionDiscountPrice INT NULL,

    PromotionThreshold INT DEFAULT 0,

    Continuity INT NOT NULL DEFAULT 1,

    ProductId INT DEFAULT NULL,
    ProductName VARCHAR(256) NULL,
    ProductPrice INT NULL,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(UserId) REFERENCES Users(Id),
    FOREIGN KEY(MerchantId) REFERENCES Merchants(Id),
    FOREIGN KEY(CardId) REFERENCES Cards(Id),
    FOREIGN KEY(NextCardId) REFERENCES Cards(Id),
    FOREIGN KEY(PromotionId) REFERENCES Promotions(Id),
    FOREIGN KEY(ProductId) REFERENCES Products(Id)
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;
