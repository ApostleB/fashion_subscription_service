USE Fitboa;




DROP PROCEDURE IF EXISTS Check_Pay_Status;
 
DELIMITER $$
CREATE PROCEDURE Check_Pay_Status(
    IN PUserId INT,
    OUT PStatus INT #-1: 구독 기록 없음(튜플 없음), 0: 구독 기록 없음(튜플 있음), 1: 미구독, 2: 구독, 3: 이번달 까지 구독
)
BEGIN
    DECLARE DIsFirstMerchant BOOLEAN DEFAULT NULL;
    DECLARE DPayExt TIMESTAMP DEFAULT NULL;
    DECLARE DNextCardId INT DEFAULT NULL;

    DECLARE DUserId INT DEFAULT NULL;

    SELECT Id 
    INTO DUserId 
    FROM Users 
    WHERE Id = PUserId;

    IF DUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '인증 누락';
    END IF;

    SELECT IsFirstMerchant, PayExt, NextCardId
    INTO DIsFirstMerchant, DPayExt, DNextCardId
    FROM UserMerchants 
    WHERE UserId = PUserId;

    IF DIsFirstMerchant IS NULL THEN
        #구독 기록 없음(튜플 없음)
        SET PStatus = -1;
    ELSEIF DIsFirstMerchant = TRUE THEN
        #구독 기록 없음(튜플 있음)
        SET PStatus = 0;
    ELSEIF DPayExt IS NULL THEN
        #미구독
        SET PStatus = 1;
    ELSEIF DATE_FORMAT(DPayExt, '%Y-%m-%d') = DATE_FORMAT(CURRENT_TIMESTAMP, '%Y-%m-%d') THEN
        #재결재 대기
        SET PStatus = 4;
    ELSEIF DPayExt > CURRENT_TIMESTAMP AND DNextCardId IS NOT NULL THEN
        #구독
        SET PStatus = 2;
    ELSEIF DPayExt > CURRENT_TIMESTAMP THEN
        #이번달 까지 구독
        SET PStatus = 3;
    ELSE
        #구독 기간 지남 -> 미구독으로 상태 변경
        UPDATE UserMerchants SET 
            MerchantId = NULL,
            CardId = NULL,
            NextCardId = NULL,
            Price = NULL,
            Type = NULL,
            PayDateTime = NULL,
            PayExt = NULL,
            IsPrevFirstMerchant = FALSE,
            IsFirstMerchant = FALSE,
            PromotionId = NULL,
            PromotionDiscountType = NULL,
            PromotionDiscountRate = NULL,
            PromotionDiscountPrice = NULL,
            PromotionThreshold = NULL,
            Continuity = 0,
            ProductId = NULL,
            ProductName = NULL,
            ProductPrice = NULL
        WHERE UserId = PUserId;

        SET PStatus = 1;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Check_Pay_Status` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Prev_Set_Billing;
#일반적인 결재(최초든 아니든)
DELIMITER $$
CREATE PROCEDURE Prev_Set_Billing(
    IN PUserId INT,
    IN PCardId INT,
    IN PPrice VARCHAR(10),
    IN PProductId INT,
    IN PType INT,
    IN PPromotionId INT
)
BEGIN
    DECLARE DLastId INT DEFAULT NULL;

    DECLARE DUserId INT DEFAULT NULL;

    DECLARE DCardId INT DEFAULT NULL;

    DECLARE DProductId INT DEFAULT NULL;
    DECLARE DProductName VARCHAR(256) DEFAULT NULL;
    DECLARE DProductNo VARCHAR(64) DEFAULT NULL;
    DECLARE DProductPrice INT DEFAULT NULL;
    DECLARE DProductMonthlyPrice INT DEFAULT NULL;
    DECLARE DProductYearlyDiscountRate INT DEFAULT NULL;

    DECLARE DPromotionId INT DEFAULT NULL;
    DECLARE DMonthlyPromotion BOOLEAN DEFAULT NULL;
    DECLARE DYearlyPromotion BOOLEAN DEFAULT NULL;
    DECLARE DPromotionProductId INT DEFAULT NULL;
    DECLARE DPromotionDiscountType INT DEFAULT NULL;
    DECLARE DPromotionDiscountRate DOUBLE DEFAULT NULL;
    DECLARE DPromotionDiscountPrice INT DEFAULT NULL;
    DECLARE DPromotionStartDate TIMESTAMP DEFAULT NULL;
    DECLARE DPromotionEndDate TIMESTAMP DEFAULT NULL;

    DECLARE DPromotionUserId INT DEFAULT NULL;
    DECLARE DPromotionUserIsUse BOOLEAN DEFAULT NULL;

    ############################################################################## Check Condition
    DECLARE DDStatus INT DEFAULT NULL;

    CALL Check_Pay_Status(PUserId, DDStatus);

    IF DDStatus != -1 AND DDStatus != 0 AND DDStatus != 1 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '이미 구독중인 회원입니다.';
    END IF;
    ##############################################################################

    SELECT Id
    INTO DUserId
    FROM Users
    WHERE Id = PUserId;

    SELECT Id
    INTO DCardId
    FROM Cards
    WHERE Id = PCardId AND UserId = DUserId;

    SELECT Id, Name, No, Price, MonthlyPrice, YearlyDiscountRate
    INTO DProductId, DProductName, DProductNo, DProductPrice, DProductMonthlyPrice, DProductYearlyDiscountRate
    FROM Products
    WHERE Id = PProductId AND Status = 0;
    
    SELECT 
        p.Id, p.IsMonthly, p.IsYearly, p.ProductId, 
        p.DiscountType, p.DiscountRate, p.DiscountPrice,
        p.StartDate, p.EndDate,
        pu.Id, pu.IsUse
    INTO 
        DPromotionId, DMonthlyPromotion, DYearlyPromotion, DPromotionProductId,
        DPromotionDiscountType, DPromotionDiscountRate, DPromotionDiscountPrice,
        DPromotionStartDate, DPromotionEndDate,
        DPromotionUserId, DPromotionUserIsUse
    FROM Promotions AS p
    LEFT OUTER JOIN PromotionUsers AS pu ON pu.PromotionId = p.Id AND pu.UserId = PUserId
    WHERE p.Id = PPromotionId;

    IF 
        DUserId IS NULL OR
        DCardId IS NULL OR
        PPrice IS NULL OR
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

    IF PPrice != IF(PType = 0, DProductMonthlyPrice)
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Prev_Set_Billing` TO 'fitboa'@'localhost';






DROP PROCEDURE IF EXISTS Set_Billing;
#일반적인 결재(최초든 아니든)
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
    IN PType INT,
    IN PPromotionId INT
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

    DECLARE DPromotionId INT DEFAULT NULL;
    DECLARE DMonthlyPromotion BOOLEAN DEFAULT NULL;
    DECLARE DYearlyPromotion BOOLEAN DEFAULT NULL;
    DECLARE DPromotionProductId INT DEFAULT NULL;
    DECLARE DPromotionDiscountType INT DEFAULT NULL;
    DECLARE DPromotionDiscountRate DOUBLE DEFAULT NULL;
    DECLARE DPromotionDiscountPrice INT DEFAULT NULL;
    DECLARE DPromotionStartDate TIMESTAMP DEFAULT NULL;
    DECLARE DPromotionEndDate TIMESTAMP DEFAULT NULL;

    DECLARE DPromotionUserId INT DEFAULT NULL;
    DECLARE DPromotionUserIsUse BOOLEAN DEFAULT NULL;

    ############################################################################## Check Condition
    DECLARE DDStatus INT DEFAULT NULL;

    CALL Check_Pay_Status(PUserId, DDStatus);

    IF DDStatus != -1 AND DDStatus != 0 AND DDStatus != 1 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '이미 구독중인 회원입니다.';
    END IF;
    ##############################################################################

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
    WHERE Id = PProductId AND Status = 0 AND StartDate <= CURRENT_TIMESTAMP AND EndDate >= CURRENT_TIMESTAMP;
    
    SELECT 
        p.Id, p.IsMonthly, p.IsYearly, p.ProductId, 
        p.DiscountType, p.DiscountRate, p.DiscountPrice,
        p.StartDate, p.EndDate,
        pu.Id, pu.IsUse
    INTO 
        DPromotionId, DMonthlyPromotion, DYearlyPromotion, DPromotionProductId,
        DPromotionDiscountType, DPromotionDiscountRate, DPromotionDiscountPrice,
        DPromotionStartDate, DPromotionEndDate,
        DPromotionUserId, DPromotionUserIsUse
    FROM Promotions AS p
    LEFT OUTER JOIN PromotionUsers AS pu ON pu.PromotionId = p.Id AND pu.UserId = PUserId
    WHERE 
        p.Id = PPromotionId AND p.ProductId = DProductId AND 
        p.StartDate <= CURRENT_TIMESTAMP AND p.EndDate >= CURRENT_TIMESTAMP AND 
        (p.IsMonthly = IF(PType = 0, TRUE, FALSE) OR p.IsYearly = IF(PType = 1, TRUE, FALSE));

    #SELECT Id 
    #INTO DPromotionId 
    #FROM Promotions 
    #WHERE Id = PPromotionId;
    
    #IF PPromotionId IS NULL THEN
    #    SET DPromotionId = NULL;
    #END IF;

    IF 
        DProductId IS NULL OR
        DProductName IS NULL OR
        DProductNo IS NULL OR
        DProductPrice IS NULL OR
        DProductMonthlyPrice IS NULL OR
        DProductYearlyDiscountRate IS NULL
    THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '구매할 상품이 존재하지 않습니다.';
    ELSEIF (PPromotionId IS NOT NULL AND DPromotionId IS NULL) THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10017, MESSAGE_TEXT = '프로모션이 존재하지 않습니다.';
    ELSEIF DPromotionId IS NOT NULL AND DPromotionUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10016, MESSAGE_TEXT = '프로모션 대상이 아닙니다.';
    ELSEIF 
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
        PromotionId,
        PromotionDiscountType,
        PromotionDiscountRate,
        PromotionDiscountPrice,
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
        DPromotionId,
        0,
        NULL,
        NULL,
        PType
    );

    SET DLastId = LAST_INSERT_ID();

    IF DDStatus = -1 THEN
        INSERT INTO UserMerchants (
            UserId,
            MerchantId,
            CardId,
            NextCardId,
            Price,
            Type,
            PayDateTime,
            PayExt,
            IsPrevFirstMerchant,
            IsFirstMerchant,
            PromotionId,
            PromotionDiscountType,
            PromotionDiscountRate,
            PromotionDiscountPrice,
            PromotionThreshold,
            Continuity,
            ProductId,
            ProductName,
            ProductPrice
        ) VALUES (
            PUserId,
            DLastId,
            PCardId,
            PCardId,
            PPrice,
            PType,
            PPayDateTime,
            DATE_ADD(DATE_ADD(PPayDateTime, INTERVAL + (PType * 11 + 1) MONTH), INTERVAL - 1 DAY),
            TRUE,
            FALSE,
            DPromotionId,
            DPromotionDiscountType,
            DPromotionDiscountPrice,
            DPromotionDiscountRate,
            IF(DPromotionId IS NULL, 0, 1),
            1,
            PProductId,
            DProductName,
            DProductPrice
        );
    ELSEIF DDStatus = 0 THEN
        UPDATE UserMerchants
        SET 
            MerchantId = DLastId,
            CardId = PCardId,
            NextCardId = PCardId,
            Price = PPrice,
            Type = PType,
            PayDateTime = PPayDateTime,
            PayExt = DATE_ADD(PPayDateTime, INTERVAL + (Type * 11 + 1) MONTH),
            IsPrevFirstMerchant = TRUE,
            IsFirstMerchant = FALSE,
            PromotionId = DPromotionId,
            PromotionDiscountType = DPromotionDiscountType,
            PromotionDiscountRate = DPromotionDiscountRate,
            PromotionDiscountPrice = DPromotionDiscountPrice,
            PromotionThreshold = IF(DPromotionId IS NULL, 0, 1),
            Continuity = 1,
            ProductId = PProductId,
            ProductName = DProductName,
            ProductPrice = DProductPrice
        WHERE UserId = PUserId;
    ELSEIF DDStatus = 1 THEN
        UPDATE UserMerchants
        SET 
            MerchantId = DLastId,
            CardId = PCardId,
            NextCardId = PCardId,
            Price = PPrice,
            Type = PType,
            PayDateTime = PPayDateTime,
            PayExt = DATE_ADD(DATE_ADD(PPayDateTime, INTERVAL + (PType * 11 + 1) MONTH), INTERVAL - 1 DAY),
            IsPrevFirstMerchant = FALSE,
            IsFirstMerchant = FALSE,
            PromotionId = DPromotionId,
            PromotionDiscountType = DPromotionDiscountType,
            PromotionDiscountRate = DPromotionDiscountRate,
            PromotionDiscountPrice = DPromotionDiscountPrice,
            PromotionThreshold = IF(DPromotionId IS NULL, 0, 1),
            Continuity = 1,
            ProductId = PProductId,
            ProductName = DProductName,
            ProductPrice = DProductPrice
        WHERE UserId = PUserId;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_Billing` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Prev_Cancel_Billing;

DELIMITER $$
CREATE PROCEDURE Prev_Cancel_Billing(
    IN PMerchantId INT,
    IN PUserId INT
)
BEGIN
    DECLARE D7Days BOOLEAN DEFAULT NULL;
    DECLARE DReadCount INT DEFAULT NULL;

    ############################################################################## Check Condition
    DECLARE DDStatus INT DEFAULT NULL;

    CALL Check_Pay_Status(PUserId, DDStatus);

    IF DDStatus != 2 AND DDStatus != 3 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독중인 상품이 없습니다.';
    END IF;
    ##############################################################################

    IF (SELECT COUNT(Id) FROM UserMerchants WHERE UserId = PUserId AND MerchantId = PMerchantId) != 1 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10006, MESSAGE_TEXT = '결제 취소 조건을 만족하지 않습니다.';
    END IF;

    #7일 이내
    #유료 읽음 안댐
    #구독 시작일
    SELECT IF(DATE_ADD(PayDateTime, INTERVAL + 7 DAY) >= CURRENT_TIMESTAMP, 1, 0), COUNT(ucv.Id)
    INTO D7Days, DReadCount
    FROM UserMerchants AS um
    LEFT OUTER JOIN UserContentViews AS ucv ON ucv.CreatedAt >= PayDateTime AND ContentType != 0
    WHERE um.UserId = PUserId;

    SELECT D7Days AS Is7Days, DReadCount AS ReadCount, DDStatus AS Status;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Prev_Cancel_Billing` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Prev_Cancel_Billing_Detail;

DELIMITER $$
CREATE PROCEDURE Prev_Cancel_Billing_Detail(
    IN PMerchantId INT,
    IN PUserId INT
)
BEGIN
    DECLARE D7Days BOOLEAN DEFAULT NULL;
    DECLARE DReadCount INT DEFAULT NULL;

    ############################################################################## Check Condition
    DECLARE DDStatus INT DEFAULT NULL;

    CALL Check_Pay_Status(PUserId, DDStatus);

    IF DDStatus != 2 AND DDStatus != 3 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독중인 상품이 없습니다.';
    END IF;
    ##############################################################################

    IF (SELECT COUNT(Id) FROM UserMerchants WHERE UserId = PUserId AND MerchantId = PMerchantId) != 1 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10006, MESSAGE_TEXT = '결제 취소 조건을 만족하지 않습니다.';
    END IF;

    #7일 이내
    #유료 읽음 안댐
    #구독 시작일
    SELECT IF(DATE_ADD(PayDateTime, INTERVAL + 7 DAY) >= CURRENT_TIMESTAMP, 1, 0), COUNT(ucv.Id)
    INTO D7Days, DReadCount
    FROM UserMerchants AS um
    LEFT OUTER JOIN UserContentViews AS ucv ON ucv.CreatedAt >= PayDateTime AND ContentType != 0
    WHERE um.UserId = PUserId;

    IF D7Days = TRUE AND DReadCount = 0 THEN
        SELECT MId, TId FROM Merchants WHERE Id = PMerchantId;
    ELSE 
        SELECT NULL AS MId, NULL AS TId;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Prev_Cancel_Billing_Detail` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Cancel_Billing;

DELIMITER $$
CREATE PROCEDURE Cancel_Billing(
    IN PMerchantId INT,
    IN PUserId INT,
    IN PResultCode VARCHAR(6),
    IN PResultMsg VARCHAR(100),
    IN PCancelDateTime TIMESTAMP,
    IN PDetailResultCode VARCHAR(6),
    IN PReceiptInfo VARCHAR(40),
    IN PCancelType VARCHAR(80),
    IN PCancelDetail VARCHAR(1024)
)
BEGIN
    DECLARE D7Days BOOLEAN DEFAULT NULL;
    DECLARE DReadCount INT DEFAULT NULL;

    ############################################################################## Check Condition
    DECLARE DDStatus INT DEFAULT NULL;

    CALL Check_Pay_Status(PUserId, DDStatus);

    IF DDStatus != 2 AND DDStatus != 3 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독중인 상품이 없습니다.';
    END IF;
    ##############################################################################

    IF (SELECT COUNT(Id) FROM UserMerchants WHERE UserId = PUserId AND MerchantId = PMerchantId) != 1 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10006, MESSAGE_TEXT = '결제 취소 조건을 만족하지 않습니다.';
    END IF;

    IF PCancelType IS NULL OR PCancelType = '' THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10011, MESSAGE_TEXT = '취소 사유를 선택해주세요.';
    END IF;

    IF PCancelType = '기타 사유' AND (PCancelDetail IS NULL OR PCancelDetail = '') THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '기타 사유를 입력해주세요.';
    END IF;

    #7일 이내
    #유료 읽음 안댐
    #구독 시작일
    SELECT IF(DATE_ADD(PayDateTime, INTERVAL + 7 DAY) >= CURRENT_TIMESTAMP, 1, 0), COUNT(ucv.Id)
    INTO D7Days, DReadCount
    FROM UserMerchants AS um
    LEFT OUTER JOIN UserContentViews AS ucv ON ucv.CreatedAt >= PayDateTime AND ContentType != 0
    WHERE um.UserId = PUserId;

    IF D7Days = TRUE AND DReadCount = 0 THEN
        IF 
            PResultCode IS NULL OR
            PResultMsg IS NULL OR
            #PCancelDateTime IS NULL OR
            PDetailResultCode IS NULL OR
            PReceiptInfo IS NULL 
        THEN
            SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10012, MESSAGE_TEXT = '결재 취소가 실패했습니다.';
        END IF;

        INSERT INTO MerchantCancelInfos (
            UserId, 
            MerchantId, 
            ResultCode, 
            ResultMsg, 
            CancelDateTime, 
            DetailResultCode, 
            ReceiptInfo, 
            CancelType, 
            CancelDetail
        ) VALUES (
            PUserId, 
            PMerchantId, 
            PResultCode,
            PResultMsg,
            PCancelDateTime,
            PDetailResultCode,
            PReceiptInfo,
            PCancelType,
            PCancelDetail
        );

        IF PResultCode = '00' THEN
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
                MId,
                MOId,
                Price,
                CardCode,
                CardQuota,
                CheckFlg,
                PrtcCode,
                ProductId,
                ProductName,
                ProductNo,
                ProductPrice,
                ProductMonthlyPrice,
                ProductYearlyDiscountRate,
                PromotionId,
                PromotionDiscountType,
                PromotionDiscountRate,
                PromotionDiscountPrice,
                Status,
                Continuity,
                Type
            )
            SELECT
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
                MId,
                MOId,
                Price,
                CardCode,
                CardQuota,
                CheckFlg,
                PrtcCode,
                ProductId,
                ProductName,
                ProductNo,
                ProductPrice,
                ProductMonthlyPrice,
                ProductYearlyDiscountRate,
                PromotionId,
                PromotionDiscountType,
                PromotionDiscountRate,
                PromotionDiscountPrice,
                2,
                Continuity,
                Type
            FROM Merchants
            WHERE Id = PMerchantId;

            UPDATE UserMerchants SET 
                MerchantId = NULL,
                CardId = NULL,
                NextCardId = NULL,
                Price = NULL,
                Type = NULL,
                PayDateTime = NULL,
                PayExt = NULL,
                IsPrevFirstMerchant = FALSE,
                IsFirstMerchant = IsPrevFirstMerchant,
                PromotionId = NULL,
                PromotionDiscountType = 0,
                PromotionDiscountRate = NULL,
                PromotionDiscountPrice = NULL,
                PromotionThreshold = 0,
                Continuity = 0,
                ProductId = NULL,
                ProductName = NULL,
                ProductPrice = NULL
            WHERE UserId = PUserId;
        ELSE
            IF PResultCode = '01' AND PDetailResultCode = '500626' AND PResultMsg = '기 취소 거래' THEN
                IF (SELECT COUNT(Id) FROM UserMerchants WHERE UserId = PUserId AND MerchantId = PMerchantId) > 0 THEN
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
                        MId,
                        MOId,
                        Price,
                        CardCode,
                        CardQuota,
                        CheckFlg,
                        PrtcCode,
                        ProductId,
                        ProductName,
                        ProductNo,
                        ProductPrice,
                        ProductMonthlyPrice,
                        ProductYearlyDiscountRate,
                        PromotionId,
                        PromotionDiscountType,
                        PromotionDiscountRate,
                        PromotionDiscountPrice,
                        Status,
                        Continuity,
                        Type
                    )
                    SELECT
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
                        MId,
                        MOId,
                        Price,
                        CardCode,
                        CardQuota,
                        CheckFlg,
                        PrtcCode,
                        ProductId,
                        ProductName,
                        ProductNo,
                        ProductPrice,
                        ProductMonthlyPrice,
                        ProductYearlyDiscountRate,
                        PromotionId,
                        PromotionDiscountType,
                        PromotionDiscountRate,
                        PromotionDiscountPrice,
                        2,
                        Continuity,
                        Type
                    FROM Merchants
                    WHERE Id = PMerchantId;

                    UPDATE UserMerchants SET 
                        MerchantId = NULL,
                        CardId = NULL,
                        NextCardId = NULL,
                        Price = NULL,
                        Type = NULL,
                        PayDateTime = NULL,
                        PayExt = NULL,
                        IsPrevFirstMerchant = FALSE,
                        IsFirstMerchant = IsPrevFirstMerchant,
                        PromotionId = NULL,
                        PromotionDiscountType = 0,
                        PromotionDiscountRate = NULL,
                        PromotionDiscountPrice = NULL,
                        PromotionThreshold = 0,
                        Continuity = 0,
                        ProductId = NULL,
                        ProductName = NULL,
                        ProductPrice = NULL
                    WHERE UserId = PUserId;
                ELSE 
                    SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10014, MESSAGE_TEXT = '이미 취소된 결제입니다.';
                END IF;
            ELSE
                SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10012, MESSAGE_TEXT = '결재 취소가 실패했습니다.';
            END IF;
        END IF;
    ELSE
        IF PResultCode = '01' AND PDetailResultCode = '500626' AND PResultMsg = '기 취소 거래' THEN
            IF (SELECT COUNT(Id) FROM UserMerchants WHERE UserId = PUserId AND MerchantId = PMerchantId) > 0 THEN
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
                    MId,
                    MOId,
                    Price,
                    CardCode,
                    CardQuota,
                    CheckFlg,
                    PrtcCode,
                    ProductId,
                    ProductName,
                    ProductNo,
                    ProductPrice,
                    ProductMonthlyPrice,
                    ProductYearlyDiscountRate,
                    PromotionId,
                    PromotionDiscountType,
                    PromotionDiscountRate,
                    PromotionDiscountPrice,
                    PromotionId,
                    PromotionDiscountType,
                    PromotionDiscountRate,
                    PromotionDiscountPrice,
                    Status,
                    Continuity,
                    Type
                )
                SELECT
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
                    MId,
                    MOId,
                    Price,
                    CardCode,
                    CardQuota,
                    CheckFlg,
                    PrtcCode,
                    ProductId,
                    ProductName,
                    ProductNo,
                    ProductPrice,
                    ProductMonthlyPrice,
                    ProductYearlyDiscountRate,
                    PromotionId,
                    PromotionDiscountType,
                    PromotionDiscountRate,
                    PromotionDiscountPrice,
                    PromotionId,
                    PromotionDiscountType,
                    PromotionDiscountRate,
                    PromotionDiscountPrice,
                    2,
                    Continuity,
                    Type
                FROM Merchants
                WHERE Id = PMerchantId;

                UPDATE UserMerchants SET 
                    MerchantId = NULL,
                    CardId = NULL,
                    NextCardId = NULL,
                    Price = NULL,
                    Type = NULL,
                    PayDateTime = NULL,
                    PayExt = NULL,
                    IsPrevFirstMerchant = FALSE,
                    IsFirstMerchant = IsPrevFirstMerchant,
                    PromotionId = NULL,
                    PromotionDiscountType = 0,
                    PromotionDiscountRate = NULL,
                    PromotionDiscountPrice = NULL,
                    PromotionThreshold = 0,
                    Continuity = 0,
                    ProductId = NULL,
                    ProductName = NULL,
                    ProductPrice = NULL
                WHERE UserId = PUserId;
            ELSE 
                SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10014, MESSAGE_TEXT = '이미 취소된 결제입니다.';
            END IF;
        ELSE
            INSERT INTO MerchantCancelInfos (
                UserId, 
                MerchantId, 
                ResultCode, 
                ResultMsg, 
                CancelDateTime, 
                DetailResultCode, 
                ReceiptInfo, 
                CancelType, 
                CancelDetail
            ) VALUES (
                PUserId, 
                PMerchantId, 
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                PCancelType,
                PCancelDetail
            );

            UPDATE UserMerchants SET 
                NextCardId = NULL
            WHERE UserId = PUserId;
        END IF;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Cancel_Billing` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Cancel_Cancel_Next_Billing;

DELIMITER $$
CREATE PROCEDURE Cancel_Cancel_Next_Billing(
    IN PMerchantId INT,
    IN PUserId INT
)
BEGIN
    DECLARE D7Days BOOLEAN DEFAULT NULL;
    DECLARE DReadCount INT DEFAULT NULL;

    ############################################################################## Check Condition
    DECLARE DDStatus INT DEFAULT NULL;

    CALL Check_Pay_Status(PUserId, DDStatus);

    IF DDStatus != 3 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10015, MESSAGE_TEXT = '결제 취소 예정인 상품이 없습니다.';
    END IF;
    ##############################################################################

    IF (SELECT COUNT(Id) FROM UserMerchants WHERE UserId = PUserId AND MerchantId = PMerchantId AND NextCardId IS NULL) != 1 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10015, MESSAGE_TEXT = '결제 취소 예정인 상품이 없습니다.';
    END IF;

    UPDATE MerchantCancelInfos SET IsCancel = TRUE WHERE UserId = PUserId AND MerchantId = PMerchantId;

    UPDATE UserMerchants SET NextCardId = CardId WHERE UserId = PUserId AND MerchantId = PMerchantId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Cancel_Cancel_Next_Billing` TO 'fitboa'@'localhost';






DROP PROCEDURE IF EXISTS Change_Next_Billing_Card;

DELIMITER $$
CREATE PROCEDURE Change_Next_Billing_Card(
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
    DECLARE DCardId INT DEFAULT NULL;

    ############################################################################## Check Condition
    DECLARE DDStatus INT DEFAULT NULL;

    CALL Check_Pay_Status(PUserId, DDStatus);

    IF DDStatus != 2 AND DDStatus != 3 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독중인 상품이 없습니다.';
    END IF;
    ##############################################################################

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

    SET DCardId = LAST_INSERT_ID();

    IF DCardId IS NULL THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10021, MESSAGE_TEXT = '카드등록에 실패했습니다.';
    END IF;

    UPDATE UserMerchants SET NextCardId = DCardId WHERE UserId = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Change_Next_Billing_Card` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Get_Billing_Scheduler;

DELIMITER $$
CREATE PROCEDURE Get_Billing_Scheduler(
)
BEGIN
    DECLARE DToday TIMESTAMP DEFAULT NULL;

    ############################################################################## Check Condition
    #DECLARE DDStatus INT DEFAULT NULL;
#
    #CALL Check_Pay_Status(PUserId, DDStatus);
#
    #IF DDStatus != 2 AND DDStatus != 3 THEN
    #    SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독중인 상품이 없습니다.';
    #END IF;
    ##############################################################################

    SET DToday = DATE_FORMAT(CURRENT_TIMESTAMP, '%Y-%m-%d');

    UPDATE UserMerchants 
    SET 
        MerchantId = NULL,
        CardId = NULL,
        NextCardId = NULL,
        Price = NULL,
        Type = NULL,
        PayDateTime = NULL,
        PayExt = NULL,
        IsPrevFirstMerchant = FALSE,
        IsFirstMerchant = FALSE,
        PromotionId = NULL,
        PromotionDiscountType = NULL,
        PromotionDiscountRate = NULL,
        PromotionDiscountPrice = NULL,
        PromotionThreshold = NULL,
        Continuity = 0,
        ProductId = NULL,
        ProductName = NULL,
        ProductPrice = NULL
    WHERE 
        #CardId IS NOT NULL AND 
        #NextCardId IS NULL AND 
        DATE_FORMAT(DATE_ADD(PayExt, INTERVAL + 1 DAY), '%Y-%m-%d') > DToday;

    SELECT 
        u.Id, 
        m.MId, 
        m.MOId, 
        um.ProductName, 
        u.Name, 
        u.Username, 
        u.Contact, 
        um.Price, #프로모션에 따라 수정 해야 하는 값
        c.BillKey,
        c.Id AS CardId
    FROM UserMerchants AS um
    INNER JOIN Merchants AS m ON m.Id = um.MerchantId
    INNER JOIN Users AS u ON u.Id = um.UserId
    INNER JOIN Cards AS c ON c.Id = um.NextCardId
    WHERE 
        um.NextCardId IS NOT NULL AND 
        DATE_FORMAT(DATE_ADD(um.PayExt, INTERVAL + 1 DAY), '%Y-%m-%d') = DToday;
    
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Billing_Scheduler` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Set_Billing_Scheduler;

DELIMITER $$
CREATE PROCEDURE Set_Billing_Scheduler(
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
    #IN PProductId INT,
    IN PProductName VARCHAR(256), 
    #IN PProductNo VARCHAR(64), 
    #IN PProductPrice INT, 
    #IN PProductMonthlyPrice INT, 
    #IN PProductYearlyDiscountRate INT, 
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

    DECLARE DMerchantId INT DEFAULT NULL;

    DECLARE DProductId INT DEFAULT NULL;
    DECLARE DProductName VARCHAR(256) DEFAULT NULL;
    DECLARE DProductNo VARCHAR(64) DEFAULT NULL;
    DECLARE DProductPrice INT DEFAULT NULL;
    DECLARE DProductMonthlyPrice INT DEFAULT NULL;
    DECLARE DProductYearlyDiscountRate INT DEFAULT NULL;

    ############################################################################## Check Condition
    DECLARE DDStatus INT DEFAULT NULL;

    CALL Check_Pay_Status(PUserId, DDStatus);

    IF DDStatus != 4 THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10009, MESSAGE_TEXT = '재결재 대상 아님';
    END IF;
    ##############################################################################

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

    SELECT ProductName, MerchantId 
    INTO DProductName, DMerchantId 
    FROM UserMerchants 
    WHERE UserId = PUserId;

    SELECT 
        ProductId,
        ProductNo,
        ProductPrice,
        ProductMonthlyPrice,
        ProductYearlyDiscountRate
    INTO DProductId, DProductNo, DProductPrice, DProductMonthlyPrice, DProductYearlyDiscountRate
    FROM Merchants 
    WHERE Id = DMerchantId;

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
    ELSEIF DMerchantId IS NULL THEN
        SIGNAL SQLSTATE 'FB999' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '구매 내역을 찾을 수 없습니다.';
    ELSEIF 
        PProductName != DProductName OR 
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

    UPDATE UserMerchants
    SET 
        MerchantId = DLastId,
        CardId = PCardId,
        NextCardId = PCardId,
        Price = PPrice,
        Type = PType,
        PayDateTime = PPayDateTime,
        PayExt = DATE_ADD(DATE_ADD(PPayDateTime, INTERVAL + (PType * 11 + 1) MONTH), INTERVAL - 1 DAY),
        IsPrevFirstMerchant = TRUE,
        IsFirstMerchant = FALSE,
        PromotionId = NULL,
        PromotionDiscountType = NULL,
        PromotionDiscountRate = NULL,
        PromotionDiscountPrice = NULL,
        PromotionThreshold = NULL,
        Continuity = 1,
        ProductId = DProductId,
        ProductName = DProductName,
        ProductPrice = DProductPrice
    WHERE UserId = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_Billing_Scheduler` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Get_Merchants;

DELIMITER $$
CREATE PROCEDURE Get_Merchants(
    IN PUserId INT
)
BEGIN
    SELECT 
        m.Id, 
        m.PayDateTime, 
        m.ProductName, 
        m.Price, 
        m.ProductNo, 
        m.MOId, 
        IF(m2.Status IS NULL, IF(um.Id IS NOT NULL AND um.NextCardId IS NULL, -1, m.Status), m2.Status) AS Status
    FROM Merchants AS m
    LEFT OUTER JOIN Merchants AS m2 ON m2.TId = m.TId AND m2.Status = 2
    LEFT OUTER JOIN UserMerchants AS um ON um.MerchantId = m.Id AND um.UserId = PUserId
    WHERE m.UserId = PUserId AND m.Status = 0
    ORDER BY m.Id DESC;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Merchants` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Get_Merchant;

DELIMITER $$
CREATE PROCEDURE Get_Merchant(
    IN PUserId INT,
    IN PMerchantId INT
)
BEGIN
    SELECT 
        m.Id, 
        m.PayDateTime, 
        m.ProductName, 
        m.Price, 
        m.ProductNo,
        m.MOId, 
        m.UserName, 
        m.UserContact, 
        m.ProductPrice, 
        m.ProductMonthlyPrice, 
        m.ProductYearlyDiscountRate, 
        m.Type, 
        mci.CancelType, 
        mci.CancelDetail, 
        IF(m2.Status IS NULL, IF(um.Id IS NOT NULL AND um.NextCardId IS NULL, -1, m.Status), m2.Status) AS Status
    FROM Merchants AS m
    LEFT OUTER JOIN Merchants AS m2 ON m2.TId = m.TId AND m2.Status = 2
    LEFT OUTER JOIN UserMerchants AS um ON um.MerchantId = m.Id AND um.UserId = PUserId
    LEFT OUTER JOIN MerchantCancelInfos AS mci ON mci.MerchantId = m.Id AND mci.UserId = PUserId AND IsCancel = FALSE
    WHERE m.Id = PMerchantId AND m.UserId = PUserId AND m.Status = 0;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Merchant` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_My_Sub_Info;

DELIMITER $$
CREATE PROCEDURE Get_My_Sub_Info(
    IN PUserId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT FALSE;

    SELECT IsSub 
    INTO DIsSub 
    FROM Users 
    WHERE Id = PUserId;

    IF DIsSub IS NULL OR DIsSub = FALSE THEN
        SELECT 
            NULL AS SubExt,
            NULL AS NextPay,
            NULL AS ProductName,
            NULL AS ProductPrice,
            NULL AS CardInfo
        ;
    ELSE 
        SELECT 
            DATE_FORMAT(um.PayExt, '%Y-%m-%d') AS SubExt,
            IF(um.NextCardId IS NOT NULL,DATE_FORMAT(DATE_ADD(um.PayExt, INTERVAL + 1 DAY), '%Y-%m-%d'),NULL) AS NextPay,
            um.ProductName AS ProductName,
            um.ProductPrice AS ProductPrice,
            CONCAT('신용카드 (',CardCdToCardName(m.CardCd),')') AS CardInfo
        FROM UserMerchants AS um
        LEFT OUTER JOIN Merchants AS m ON m.Id = um.MerchantId
        WHERE um.UserId = PUserId;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_My_Sub_Info` TO 'fitboa'@'localhost';
