USE Fitboa;
DROP TABLE IF EXISTS Products;
CREATE TABLE IF NOT EXISTS Products
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    Name VARCHAR(256) NOT NULL,
    No VARCHAR(64) NOT NULL,

    Price INT NOT NULL, #정가
    MonthlyPrice INT NOT NULL, #월간 판매가

    YearlyDiscountRate INT NOT NULL, #연간 결재 할인율

    StartDate TIMESTAMP NULL,
    EndDate TIMESTAMP NULL,

    Description VARCHAR(2048) NULL,

    Status INT NOT NULL DEFAULT 0, # 0: OPEN, 1: CLOSE

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

INSERT INTO Products (Name, No, Price, MonthlyPrice, YearlyDiscountRate, Description, StartDate, EndDate) 
VALUES ('구독상품1', 'sec3453245', 70000, 50000, 30, '콘텐 츠 무제한 열람\n체형 변경 시 맞춤 콘텐츠 변경 노출\n스타일링 상품 사용 시 할인 적용', '2022-01-01', '2023-01-01');