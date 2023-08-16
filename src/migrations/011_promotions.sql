USE Fitboa;
DROP TABLE IF EXISTS Promotions;
CREATE TABLE IF NOT EXISTS Promotions
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    Name VARCHAR(256) NOT NULL,

    Code VARCHAR(19) NOT NULL,

    #ProductId INT NULL,

    IsMonthly BOOLEAN NOT NULL DEFAULT FALSE,
    IsYearly BOOLEAN NOT NULL DEFAULT FALSE,

    DiscountType INT NOT NULL DEFAULT 0, #0: 원, 1: %

    DiscountRate DOUBLE NULL,
    DiscountPrice INT NULL,

    StartDate TIMESTAMP NULL,
    EndDate TIMESTAMP NULL,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    #FOREIGN KEY(ProductId) REFERENCES Products(Id)
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

INSERT INTO Promotions (
    Name,
    #ProductId,
    IsMonthly,
    IsYearly,
    DiscountType,
    DiscountRate,
    DiscountPrice,
    StartDate,
    EndDate
) VALUES (
    '신규 가입 특가!',
    #1,
    TRUE,
    FALSE,
    1, 
    10,
    NULL,
    '2022-04-01',
    '2023-04-01'
);
