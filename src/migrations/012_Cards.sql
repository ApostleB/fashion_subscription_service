USE Fitboa;
DROP TABLE IF EXISTS Cards;
CREATE TABLE IF NOT EXISTS Cards
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    UserId INT NOT NULL,

    ResultCode VARCHAR(4) NOT NULL,
    ResultMsg VARCHAR(2048) NOT NULL,

    PGAuthDateTime TIMESTAMP NULL,
    
    TId VARCHAR(40) NOT NULL,
    MId VARCHAR(10) NOT NULL,

    OrderId VARCHAR(64) NOT NULL,
    BillKey VARCHAR(40) NOT NULL,
    AuthKey VARCHAR(40) NOT NULL,

    CardCd VARCHAR(2) NOT NULL,
    CardNo VARCHAR(16) NOT NULL,
    CardKind VARCHAR(1) NOT NULL,
    
    CheckFlag VARCHAR(1) NOT NULL,

    Data1 VARCHAR(28) NOT NULL,

    MerchantReserved VARCHAR(1024),

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(UserId) REFERENCES Users(Id)
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

#INSERT INTO Cards (
#    UserId, 
#    ResultCode, 
#    ResultMsg, 
#    PGAuthDateTime, 
#    TId, 
#    MId, 
#    OrderId, 
#    BillKey, 
#    AuthKey, 
#    CardCd, 
#    CardNo, 
#    CardKind,
#    CheckFlag,
#    Data1,
#    MerchantReserved
#)
#VALUES (
#    2,
#    '00',
#    '[신용카드|본인인증이 성공하였습니다.]',
#    '20220330133143',
#    'INIpayBillINIBillTst20220330133143944509',
#    'INIBillTst',
#    '01',
#    'a94b3384630058effd9cff593d05ec0ef6145725',
#    'INIBillTst_D1C367FBD76A0F64C92A8DFF25895',
#    '14',
#    '436420*********6',
#    '0',
#    '1',
#    '',
#    ''
#);