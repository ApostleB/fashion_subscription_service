USE Fitboa;




###########  Products
DROP PROCEDURE IF EXISTS Check_Can_Pay;

DELIMITER $$
CREATE PROCEDURE Check_Can_Pay(
    IN PUserId INT
)
BEGIN
    DECLARE CanPay BOOLEAN DEFAULT NULL;
    DECLARE ExpTime TIMESTAMP DEFAULT NULL;
    DECLARE DStatus INT DEFAULT NULL;

    #SELECT 
    #* 
    #FROM Merchants AS m
    #WHERE DATE_ADD(PayDateTime, INTERVAL + (Type * 11 + 1) MONTH)

    SELECT 
        IF(COUNT(Id) > 0, FALSE, TRUE),
        DATE_ADD(PayDateTime, INTERVAL + (Type * 11 + 1) MONTH),
        Status
    INTO CanPay, ExpTime, DStatus
    FROM Merchants AS m
    WHERE 
        UserId = PUserId AND 
        (Status = 0 OR Status = 3) AND
        DATE_ADD(PayDateTime, INTERVAL + (Type * 11 + 1) MONTH) >= CURRENT_TIMESTAMP;

    IF CanPay = FALSE THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '이미 구독중인 회원입니다.';
    END IF;

    SELECT CanPay, ExpTime;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Check_Can_Pay` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Get_Products;

DELIMITER $$
CREATE PROCEDURE Get_Products(
)
BEGIN
    DECLARE DId INT DEFAULT NULL;
    DECLARE DName VARCHAR(256) DEFAULT NULL;
    DECLARE DNo VARCHAR(64) DEFAULT NULL;
    DECLARE DPrice INT DEFAULT NULL;
    DECLARE DMonthlyPrice INT DEFAULT NULL;
    DECLARE DYearlyDiscountRate INT DEFAULT NULL;
    DECLARE DDescription VARCHAR(2048) DEFAULT NULL;

    SELECT Id, Name, No, Price, MonthlyPrice, YearlyDiscountRate, Description
    INTO DId, DName, DNo, DPrice, DMonthlyPrice, DYearlyDiscountRate, DDescription
    FROM Products
    WHERE 
        DATE_FORMAT(NOW(), '%Y-%m-%d') >= DATE_FORMAT(StartDate, '%Y-%m-%d') AND 
        NOW() < DATE_FORMAT(NOW(), '%Y-%m-%d') <= DATE_FORMAT(EndDate, '%Y-%m-%d') AND 
        Status = 0
    LIMIT 1;

    IF DId IS NULL THEN
        SELECT 
            '현재 판매중인 상품이 없습니다.' AS Description;
    ELSE
        SELECT 
            DId AS Id, 
            DName AS Name, 
            DNo AS No, 
            DPrice AS Price, 
            DMonthlyPrice AS MonthlyPrice, 
            DYearlyDiscountRate AS YearlyDiscountRate, 
            DDescription AS Description;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Products` TO 'fitboa'@'localhost';




#DROP PROCEDURE IF EXISTS Get_Promotions;
#
#DELIMITER $$
#CREATE PROCEDURE Get_Promotions(
#    IN PUserId INT
#)
#BEGIN
#    DECLARE DId INT DEFAULT NULL;
#
#    SELECT Id
#    INTO DId
#    FROM Products
#    WHERE 
#        DATE_FORMAT(NOW(), '%Y-%m-%d') >= DATE_FORMAT(StartDate, '%Y-%m-%d') AND 
#        NOW() < DATE_FORMAT(NOW(), '%Y-%m-%d') <= DATE_FORMAT(EndDate, '%Y-%m-%d') AND
#        Status = 0
#    LIMIT 1;
#
#    IF DId IS NULL THEN
#        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10013, MESSAGE_TEXT = '판매중인 상품이 없습니다.';
#    ELSE
#        SELECT p.Id, p.ProductId, p.Name, p.IsMonthly, p.IsYearly, p.DiscountType, p.DiscountRate, p.DiscountPrice, p.StartDate, p.EndDate
#        FROM Promotions AS p
#        INNER JOIN PromotionUsers AS pu ON p.Id = pu.PromotionId AND pu.UserId = PUserId AND pu.IsUse = FALSE
#        WHERE p.ProductId = DId AND p.StartDate < CURRENT_TIMESTAMP AND p.EndDate > CURRENT_TIMESTAMP;
#    END IF;
#END $$
#DELIMITER ;
#
#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Promotions` TO 'fitboa'@'localhost';






DROP PROCEDURE IF EXISTS Set_Billing_Key;

DELIMITER $$
CREATE PROCEDURE Set_Billing_Key(
    IN PUserId INT,
    IN PResultCode VARCHAR(4),
    IN PResultMsg VARCHAR(2048),
    IN PPGAuthDateTime TIMESTAMP,
    IN PTId VARCHAR(40),
    IN PMId VARCHAR(10),
    IN POrderId VARCHAR(1024),
    IN PBillKey VARCHAR(40),
    IN PAuthKey VARCHAR(40),
    IN PCardCd VARCHAR(2),
    IN PCardNo VARCHAR(16),
    IN PCardKind VARCHAR(1),
    IN PCheckFlag VARCHAR(1),
    IN PData1 VARCHAR(28),
    IN PMerchantReserved VARCHAR(1024)
)
BEGIN
    IF 
        PUserId IS NULL OR
        PResultCode IS NULL OR
        PResultMsg IS NULL OR
        PPGAuthDateTime IS NULL OR
        PTId IS NULL OR
        PMId IS NULL OR
        POrderId IS NULL OR
        PBillKey IS NULL OR
        PAuthKey IS NULL OR
        PCardCd IS NULL OR 
        PCardNo IS NULL OR
        PCardKind IS NULL OR
        PCheckFlag IS NULL OR
        PData1 IS NULL
    THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '파라미터 누락';
    END IF;

    IF (SELECT COUNT(Id) FROM Users WHERE Id = PUserId AND IsAdmin = FALSE) = 0 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '인증 누락';
    END IF;

    INSERT INTO Cards (
        UserId, 
        ResultCode, 
        ResultMsg, 
        PGAuthDateTime, 
        TId, 
        MId, 
        OrderId, 
        BillKey, 
        AuthKey, 
        CardCd, 
        CardNo, 
        CardKind,
        CheckFlag,
        Data1,
        MerchantReserved
    )
    VALUES (
        PUserId,
        PResultCode,
        PResultMsg,
        PPGAuthDateTime,
        PTId,
        PMId,
        POrderId,
        PBillKey,
        PAuthKey,
        PCardCd,
        PCardNo,
        PCardKind,
        PCheckFlag,
        PData1,
        PMerchantReserved
    );

    SELECT LAST_INSERT_ID() AS CardId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_Billing_Key` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Remove_Billing_Key;

DELIMITER $$
CREATE PROCEDURE Remove_Billing_Key(
    IN PUserId INT,
    IN PCardId INT
)
BEGIN
    DECLARE DCardId INT DEFAULT NULL;
    DECLARE DNowCardId INT DEFAULT NULL;
    DECLARE DNextCardId INT DEFAULT NULL;

    SELECT c.Id, um.CardId, um2.NextCardId
    INTO DCardId, DNowCardId, DNextCardId
    FROM Cards AS c
    LEFT OUTER JOIN UserMerchants AS um ON um.CardId = c.Id AND um.UserId = PUserId
    LEFT OUTER JOIN UserMerchants AS um2 ON um2.NextCardId = c.Id AND um2.UserId = PUserId
    WHERE c.Id = PCardId AND c.UserId = PUserId;

    IF DCardId IS NULL THEN
        #존재하지 않는 카드입니다.
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10018, MESSAGE_TEXT = '존재하지 않는 카드입니다.';
    ELSEIF DNowCardId IS NOT NULL THEN
        #현재 사용중인 카드입니다.
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10019, MESSAGE_TEXT = '현재 사용중인 카드입니다.';
    ELSEIF DNextCardId IS NOT NULL THEN
        #결제 예정인 카드입니다.
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10020, MESSAGE_TEXT = '결제 예정인 카드입니다.';
    END IF;

    UPDATE Merchants SET CardId = NULL WHERE CardId = DCardId;
    DELETE FROM Cards WHERE Id = DCardId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Remove_Billing_Key` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Cards;
 
DELIMITER $$
CREATE PROCEDURE Get_Cards(
    IN PUserId INTt
)
BEGIN
    DECLARE DCardId INT DEFAULT NULL;

    SELECT CardId 
    INTO DCardId 
    FROM UserMerchants 
    WHERE UserId = PUserId;

    SELECT 
        c.Id, c.CardCd, cr.Name AS CardName, c.CardNo, c.CardKind, c.CreatedAt,
        IF(c.Id = DCardId, TRUE, FALSE) AS IsUse
    FROM Cards AS c
    LEFT OUTER JOIN CardRefs AS cr ON cr.CardCd = c.CardCd
    WHERE UserId = PUserId AND ResultCode = '00'
    ORDER BY c.Id DESC;
    #GROUP BY CardNo, CardCd, CardKind;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Cards` TO 'fitboa'@'localhost';  





DROP PROCEDURE IF EXISTS Delete_Card;

DELIMITER $$
CREATE PROCEDURE Delete_Card(
    IN PUserId INT,
    IN PCardId INT
)
BEGIN
    IF (SELECT COUNT(Id) FROM Cards WHERE Id = PCardId AND UserId = PUserId) != 1 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '카드를 선택해주세요.';
    END IF;

    UPDATE Merchants SET CardId = NULL WHERE CardId = PCardId;
    UPDATE UserMerchants SET CardId = NULL WHERE CardId = PCardId;
    UPDATE UserMerchants SET NextCardId = NULL WHERE NextCardId = PCardId;

    DELETE FROM Cards WHERE Id = PCardId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Delete_Card` TO 'fitboa'@'localhost';  





DROP PROCEDURE IF EXISTS Get_Billing_Key;

DELIMITER $$
CREATE PROCEDURE Get_Billing_Key(
    IN PUserId INT,
    IN PCardId INT
)
BEGIN
    SELECT 
        c.Id AS CardId, c.MId AS MId, c.BillKey AS BillKey,
        u.Id AS UserId, u.Name AS UserName, u.Contact AS UserContact, u.Username AS Username
    FROM Cards AS c
    INNER JOIN Users AS u ON u.Id = c.UserId
    WHERE c.Id = PCardId AND c.UserId = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Billing_Key` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Set_Billing;
 
DELIMITER $$
CREATE PROCEDURE Set_Billing(
    IN PUserId INT,
    IN PUserName VARCHAR(64),
    IN PUserContact VARCHAR(13),
    IN PUserEmail VARCHAR(128),
    IN PCardId INT,
    IN PResultCode VARCHAR(4),
    IN PResultMsg VARCHAR(2048),
    IN PPayDateTime TIMESTAMP,
    IN PPayAuthCode VARCHAR(64),
    IN PTId VARCHAR(40),
    IN PPrice VARCHAR(10),
    IN PCardCode VARCHAR(2),
    IN PCardQuota VARCHAR(2),
    IN PCheckFlg VARCHAR(1),
    IN PPrtcCode VARCHAR(1),
    IN PMOId VARCHAR(40),
    IN PProductId INT,
    IN PType INT
)
BEGIN
    DECLARE DLastId INT DEFAULT NULL;

    DECLARE DStatus INT DEFAULT 0;

    DECLARE DUserId INT DEFAULT NULL;

    DECLARE DCardId INT DEFAULT NULL;
    DECLARE DCardCd VARCHAR(2) DEFAULT NULL;
    DECLARE DCardNo VARCHAR(16) DEFAULT NULL;
    DECLARE DCardKind VARCHAR(1) DEFAULT NULL;
    DECLARE DMId VARCHAR(10) DEFAULT NULL;

    DECLARE DProductId INT DEFAULT NULL;
    DECLARE DProductName VARCHAR(256) DEFAULT NULL;
    DECLARE DProductNo VARCHAR(64) DEFAULT NULL;
    DECLARE DProductPrice INT DEFAULT NULL;
    DECLARE DProductMonthlyPrice INT DEFAULT NULL;
    DECLARE DProductYearlyDiscountRate INT DEFAULT NULL;

    ##
    # 
    CALL Check_Can_Pay(PUserId);
    ##

    IF PResultCode = '00' THEN
        SET DStatus = 0;
    ELSE 
        SET DStatus = 1;
    END IF;

    SELECT Id
    INTO DUserId
    FROM Users
    WHERE Id = PUserId;

    SELECT Id, CardCd, CardNo, CardKind, MId
    INTO DCardId, DCardCd, DCardNo, DCardKind, DMId
    FROM Cards
    WHERE Id = PCardId AND UserId = DUserId;

    SELECT Id, Name, No, Price, MonthlyPrice, YearlyDiscountRate
    INTO DProductId, DProductName, DProductNo, DProductPrice, DProductMonthlyPrice, DProductYearlyDiscountRate
    FROM Products
    WHERE Id = PProductId AND Status = 0;

    IF 
        DUserId IS NULL OR
        PUserName IS NULL OR
        PUserContact IS NULL OR
        PUserEmail IS NULL OR
        DCardId IS NULL OR
        DCardCd IS NULL OR
        DCardNo IS NULL OR
        DCardKind IS NULL OR
        PResultCode IS NULL OR
        PResultMsg IS NULL OR
        PPayDateTime IS NULL OR
        PPayAuthCode IS NULL OR
        PTId IS NULL OR
        PPrice IS NULL OR
        PCardCode IS NULL OR
        PCardQuota IS NULL OR
        PCheckFlg IS NULL OR
        PPrtcCode IS NULL OR
        PMOId IS NULL OR
        (PType != 0 AND PType != 1)
    THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '파라미터 누락';
    ELSEIF 
        DProductId IS NULL OR
        DProductName IS NULL OR
        DProductNo IS NULL OR
        DProductPrice IS NULL OR
        DProductMonthlyPrice IS NULL OR
        DProductYearlyDiscountRate IS NULL
    THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '구매할 상품이 존재하지 않습니다.';
    END IF;

    INSERT INTO Merchants (
        UserId,
        UserName,
        UserContact,
        UserEmail,
        CardId,
        CardCd,
        CardNo,
        CardKind,
        ResultCode,
        ResultMsg,
        PayDateTime,
        PayAuthCode,
        TId,
        Price,
        CardCode,
        CardQuota,
        CheckFlg,
        PrtcCode,
        MOId,
        MId,
        ProductId,
        ProductName,
        ProductNo,
        ProductPrice,
        ProductMonthlyPrice,
        ProductYearlyDiscountRate,
        Type
    )
    VALUES (
        DUserId,
        PUserName,
        PUserContact,
        PUserEmail,
        DCardId,
        DCardCd,
        DCardNo,
        DCardKind,
        PResultCode,
        PResultMsg,
        PPayDateTime,
        PPayAuthCode,
        PTId,
        PPrice,
        PCardCode,
        PCardQuota,
        PCheckFlg,
        PPrtcCode,
        PMOId,
        DMId,
        DProductId,
        DProductName,
        DProductNo,
        DProductPrice,
        DProductMonthlyPrice,
        DProductYearlyDiscountRate,
        PType
    );

    SET DLastId = LAST_INSERT_ID();

    UPDATE Merchants SET Status = -1 WHERE Id != DLastId AND UserId = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_Billing` TO 'fitboa'@'localhost';



DROP PROCEDURE IF EXISTS Get_Billing;

DELIMITER $$
CREATE PROCEDURE Get_Billing(
    IN PMerchantId INT,
    IN PUserId INT
)
BEGIN
    DECLARE DId INT DEFAULT NULL;
    DECLARE DTId VARCHAR(40) DEFAULT NULL;
    DECLARE DMId VARCHAR(10) DEFAULT NULL;
    DECLARE DStatus INT DEFAULT NULL;

    SELECT Id, TId, MId, Status
    INTO DId, DTId, DMId, DStatus
    FROM Merchants
    WHERE Id = PMerchantId AND UserId = PUserId;

    #IF DTId IS NULL OR DStatus IS NULL OR DMId IS NULL THEN
    #거래 없음
    #ELSEIF DStatus = 1 THEN
    #실패한 거래임
    #ELSEIF DStatus != 0 THEN
    #최소된 거래임
    #END IF;

    SELECT DId AS Id, DTId AS TId, DMId AS MId, DStatus AS Status;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Billing` TO 'fitboa'@'localhost';


DROP PROCEDURE IF EXISTS Cancel_Billing;

DELIMITER $$
CREATE PROCEDURE Cancel_Billing(
    IN PMerchantId INT,
    IN PUserId INT
)
BEGIN
    #IF (SELECT COUNT(Id) FROM Merchants WHERE UserId = PUserId AND Id = PMerchantId) != 1 THEN
    #
    #END IF;

    UPDATE Merchants SET Status = 2 WHERE Id = PMerchantId AND UserId = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Cancel_Billing` TO 'fitboa'@'localhost';





