USE Fitboa;
DROP TABLE IF EXISTS Merchants;
CREATE TABLE IF NOT EXISTS Merchants
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    UserId INT DEFAULT NULL,
    UserName VARCHAR(64) NOT NULL,
    UserContact VARCHAR(13) NOT NULL,
    UserEmail VARCHAR(128) NOT NULL,

    CardId INT DEFAULT NULL,
    CardCd VARCHAR(2) NOT NULL,
    CardNo VARCHAR(16) NOT NULL,
    CardKind VARCHAR(1) NOT NULL,

    #NextCardId INT DEFAULT NULL,

    ResultCode VARCHAR(4) NOT NULL,
    ResultMsg VARCHAR(2048) NOT NULL,

    PayDateTime TIMESTAMP NULL,

    PayAuthCode VARCHAR(64) NOT NULL,

    TId VARCHAR(40) NOT NULL,
    MId VARCHAR(10) NOT NULL,
    MOId VARCHAR(40) NOT NULL,

    Price VARCHAR(10) NOT NULL,

    CardCode VARCHAR(2) NOT NULL,
    CardQuota VARCHAR(2) NOT NULL,

    CheckFlg VARCHAR(1) NOT NULL,

    PrtcCode VARCHAR(1) NOT NULL,

    ProductId INT DEFAULT NULL,
    ProductName VARCHAR(256) NOT NULL,
    ProductNo VARCHAR(64) NOT NULL,
    ProductPrice INT NOT NULL,
    ProductMonthlyPrice INT NOT NULL,
    ProductYearlyDiscountRate INT NOT NULL,

    PromotionId INT NULL,
    PromotionDiscountType INT DEFAULT 0, #0: 원, 1: %
    PromotionDiscountRate DOUBLE NULL,
    PromotionDiscountPrice INT NULL,

    Status INT NOT NULL DEFAULT 0, #-1: 취소 예약, 0: 성공, 1: 실패, 2: 취소, 3: 환불

    Continuity INT NOT NULL DEFAULT 1,

    Type INT NOT NULL DEFAULT 0, #0: Monthly, 1: Yearly
 
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(UserId) REFERENCES Users(Id),
    FOREIGN KEY(CardId) REFERENCES Cards(Id),
    FOREIGN KEY(NextCardId) REFERENCES Cards(Id),
    FOREIGN KEY(ProductId) REFERENCES Products(Id)
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

#INSERT INTO Merchants (
#    UserId, 
#    UserName,
#    UserContact,
#    UserEmail,
#    CardId, 
#    CardCd,
#    CardNo,
#    CardKind,
#    ResultCode, 
#    ResultMsg, 
#    PayDateTime, 
#    PayAuthCode, 
#    TId, 
#    Price, 
#    CardCode, 
#    CardQuota, 
#    CheckFlg, 
#    PrtcCode
#)
#SELECT 
#    u.Id,
#    u.Name,
#    u.Contact,
#    u.Email,
#    c.Id,
#    c.CardCd,
#    c.CardNo,
#    c.CardKind,
#    '00',
#    '[신용카드|빌링이 정상적으로 이루어졌습니다.]',
#    '20220330134223',
#    '00862734',
#    'INIAPICARDINIBillTst20220330134216115138',
#    '1013',
#    '04',
#    '00',
#    '0',
#    '1'
#FROM Users AS u
#INNER JOIN Cards AS c ON c.Id = 1
#WHERE u.Id = 2;
