###########  GLOBAL
DROP PROCEDURE IF EXISTS User_Check;

DELIMITER $$
CREATE PROCEDURE User_Check(
    IN PUserId INT,
    OUT PNeedReg BOOLEAN,
    OUT PNeedSub BOOLEAN,
    OUT PNeedBodyType BOOLEAN
)
BEGIN
    #DECLARE PNeedReg BOOLEAN DEFAULT NULL;
    #DECLARE PNeedSub BOOLEAN DEFAULT NULL;
    #DECLARE PNeedBodyType BOOLEAN DEFAULT NULL;

    SELECT IF(u.Id IS NULL, TRUE, FALSE), IF(m.Id IS NULL, TRUE, FALSE), IF(u.BodyType IS NULL, TRUE, FALSE)
    INTO PNeedReg, PNeedSub, PNeedBodyType
    FROM Users AS u
    LEFT OUTER JOIN Merchants AS m ON m.BuyerId = u.Id AND m.ExpTime > CURRENT_TIMESTAMP
    WHERE u.Id = PUserId;

    IF PNeedSub IS NULL THEN
        SET PNeedReg = TRUE;
        SET PNeedSub = TRUE;
        SET PNeedBodyType = TRUE;
    END IF;

    #SELECT PNeedReg, PNeedSub, PNeedBodyType;
END $$
DELIMITER ;

#GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Check` TO 'fitboa'@'localhost';




###########  VERIFY CHECK
DROP PROCEDURE IF EXISTS Create_Verify;

DELIMITER $$
CREATE PROCEDURE Create_Verify(
    IN PContact VARCHAR(13),
    IN PType VARCHAR(32),
    OUT PKey VARCHAR(6)
)
BEGIN
    DECLARE DVerifyKey VARCHAR(6) DEFAULT SUBSTRING(CONCAT('', RAND()), 3, 6);

    IF PContact IS NULL THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
    END IF;

    INSERT INTO VerifyLogs (Contact, Type, VerifyKey) VALUES (PContact, PType, DVerifyKey);

    SELECT VerifyKey
    INTO PKey
    FROM VerifyLogs
    WHERE Id = LAST_INSERT_ID();
END $$
DELIMITER ;

#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Create_Verify` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Verify;

DELIMITER $$
CREATE PROCEDURE Verify(
    IN PContact VARCHAR(13),
    IN PKey VARCHAR(6),
    IN PType VARCHAR(32)
)
BEGIN
    DECLARE DId INT DEFAULT NULL;
    DECLARE DVerifyCount INT DEFAULT NULL;
    DECLARE DVerifyTimeout BOOLEAN DEFAULT NULL;
    DECLARE DKey VARCHAR(6) DEFAULT NULL;

    #IF PId IS NULL THEN
    #    SIGNAL SQLSTATE 'FB003' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '잠시 후 다시 시도해주세요.';
    IF PContact IS NULL THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
    ELSEIF PKey IS NULL THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '인증번호를 입력해주세요.';
    END IF;

    SELECT Id, VerifyCount, VerifyTimeout >= CURRENT_TIMESTAMP, VerifyKey
    INTO DId, DVerifyCount, DVerifyTimeout, DKey
    FROM VerifyLogs
    WHERE Contact = PContact AND Type = PType AND IsVerified = FALSE AND IsUsed = FALSE
    ORDER BY Id DESC
    LIMIT 1;

    IF DId IS NULL OR DVerifyCount >= 3 OR DVerifyTimeout = FALSE THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '인증번호를 재발급해주세요.';
    END IF;

    IF DKey != PKey THEN
        UPDATE VerifyLogs SET VerifyCount = VerifyCount + 1 WHERE Id = DId;
        IF DVerifyCount = 2 THEN
            SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '잘못된 시도가 너무 많습니다. 인증번호를 재발급해주세요.';
        ELSE
            SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '인증번호가 유효하지않습니다.';
        END IF;
    ELSE
        UPDATE VerifyLogs SET IsVerified = TRUE WHERE Id = DId;
        SELECT DId AS Id;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Verify` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Check_Verify;

DELIMITER $$
CREATE PROCEDURE Check_Verify(
    IN PContact VARCHAR(13),
    IN PKey VARCHAR(6),
    IN PType VARCHAR(32),
    IN PId INT
)
BEGIN
    DECLARE DIsVerified BOOLEAN DEFAULT NULL;

    SELECT IsVerified
    INTO DIsVerified
    FROM VerifyLogs
    WHERE Id = PId AND Contact = PContact AND VerifyKey = PKey AND Type = PType AND IsUsed = FALSE;

    IF DIsVerified IS NULL OR DIsVerified = FALSE THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '인증정보가 유효하지않습니다.';
    END IF;
END $$
DELIMITER ;

#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Check_Verify` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Use_Verify;

DELIMITER $$
CREATE PROCEDURE Use_Verify(
    IN PId INT
)
BEGIN
    UPDATE VerifyLogs SET IsUsed = TRUE WHERE Id = PId;
END $$
DELIMITER ;

#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Use_Verify` TO 'fitboa'@'localhost';



###########  USER
DROP PROCEDURE IF EXISTS Register_Check_Username;

DELIMITER $$
CREATE PROCEDURE Register_Check_Username(
    IN PUsername VARCHAR(128)
)
BEGIN
    DECLARE DIsDupKey BOOLEAN DEFAULT FALSE;

    IF PUsername IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '아이디를 입력해주세요.';
    #ELSEIF  THEN
    #    SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '아이디를 이메일 형식으로 입력해주세요.';
    END IF;

    SELECT TRUE
    INTO DIsDupKey
    FROM Users
    WHERE Username = PUsername
    LIMIT 1;

    IF DIsDupKey = TRUE THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '이미 사용중인 아이디입니다.';
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Register_Check_Username` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Register_Check_Contact;

DELIMITER $$
CREATE PROCEDURE Register_Check_Contact(
    IN PContact VARCHAR(13)
)
BEGIN
    DECLARE DIsDupKey BOOLEAN DEFAULT FALSE;

    DECLARE DKey VARCHAR(6) DEFAULT NULL;

    IF PContact IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
    END IF;

    SELECT TRUE
    INTO DIsDupKey
    FROM Users
    WHERE Contact = PContact
    LIMIT 1;

    IF DIsDupKey = TRUE THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10009, MESSAGE_TEXT = '이미 사용중인 휴대번호입니다.';
    ELSE
        CALL Create_Verify(PContact, 'Register', DKey);
        SELECT DKey AS 'Key';
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Register_Check_Contact` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Register;

DELIMITER $$
CREATE PROCEDURE Register(
    IN PName VARCHAR(64), 
    IN PUsername VARCHAR(128), 
    IN PPassword VARCHAR(512), 
    IN PContact VARCHAR(13), 
    IN PVerifyKey VARCHAR(6),
    IN PVerifyId INT,
    #IN PAddress VARCHAR(256), 
    IN PRoadAddress VARCHAR(256),
    IN PJibunAddress VARCHAR(256),
    IN PExtraAddress VARCHAR(256),
    IN PPostCode VARCHAR(5),
    IN PAddressType VARCHAR(6),
    IN PUseTerm BOOLEAN, 
    IN PPrivateTerm BOOLEAN, 
    IN PEmailTerm BOOLEAN, 
    IN PSMSTerm BOOLEAN
)
BEGIN
    IF PName IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '이름을 입력해주세요.';
    END IF;

    CALL Register_Check_Username(PUsername);

    #check password
    IF PPassword IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10006, MESSAGE_TEXT = '비밀번호를 입력해주세요.';
    END IF;

    #check contact
    IF PContact IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
    END IF;

    CALL Check_Verify(PContact, PVerifyKey, 'Register', PVerifyId);

    #check road address
    IF PRoadAddress IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
    END IF;
    #check jibun address
    IF PJibunAddress IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
    END IF;
    #check post code
    IF PPostCode IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
    END IF;
    #check address type
    IF PAddressType IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
    ELSEIF PAddressType != '도로명' AND PAddressType != '지번' THEN
        #지번이랑 도로명 중에 있어야 함
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
    END IF;

    #check useterm
    IF PUseTerm IS NULL OR PUseTerm = FALSE THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '이용약관 동의는 필수사항입니다.';
    END IF;

    #check privateterm
    IF PPrivateTerm IS NULL OR PPrivateTerm = FALSE THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '개인정보 수집 및 이용 동의는 필수사항입니다.';
    END IF;

    #check emailterm
    IF PEmailTerm IS NULL THEN
        SET PEmailTerm = FALSE;
    END IF;

    #check smsterm
    IF PSMSTerm IS NULL THEN
        SET PSMSTerm = FALSE;
    END IF;

    INSERT INTO Users 
    (Name, Username, Password, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType, UseTerm, PrivateTerm, EmailTerm, SMSTerm) 
    VALUES (PName, PUsername, PPassword, PContact, PRoadAddress, PJibunAddress, PExtraAddress, PPostCode, PAddressType, PUseTerm, PPrivateTerm, PEmailTerm, PSMSTerm);
    SELECT TRUE AS LoginResult, LAST_INSERT_ID() AS Id;

    CALL Use_Verify(PVerifyId);

    ############################ 삭제 예정: 임시로 회원 가입 시 프로모션 발급
    #INSERT INTO 
    ############################
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Register` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS User_Login;

DELIMITER $$
CREATE PROCEDURE User_Login(
    IN PUsername VARCHAR(128), 
    IN PPassword VARCHAR(512)
)
BEGIN
    DECLARE DUserId INT DEFAULT NULL;
    DECLARE DPasswordTimeout BOOLEAN DEFAULT NULL;
    DECLARE DFD BOOLEAN DEFAULT FALSE;
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DUsername VARCHAR(128);

    DECLARE DContentReviewNeedCount INT DEFAULT 0;

    SELECT Username
    INTO DUsername
    FROM Users
    WHERE Username = PUsername;

    IF DUsername IS NULL THEN
        SIGNAL SQLSTATE 'FB001' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '등록되지 않은 아이디입니다.';
    END IF;

    SELECT u.Id, DATE_ADD(u.PasswordUpdatedAt, INTERVAL + 3 MONTH) <= NOW(), IF(fd.Id IS NULL AND u.IsSub = TRUE, TRUE, FALSE), IsSub
    INTO DUserId, DPasswordTimeout, DFD, DIsSub
    FROM Users AS u
    LEFT OUTER JOIN FirstDeliveries AS fd ON fd.UserId = u.Id
    WHERE u.Username = PUsername AND u.Password = PPassword;

    IF DUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB001' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '비밀번호가 올바르지 않습니다.';
    ELSE
        SELECT COUNT(c.Id) - COUNT(cr.Id) 
        INTO DContentReviewNeedCount
        FROM Contents AS c
        INNER JOIN Inquiries AS i ON i.ContentId = c.Id AND i.UserId = DUserId
        LEFT OUTER JOIN ContentReviews AS cr ON cr.ContentId = i.ContentId AND cr.UserId = DUserId
        WHERE c.TypeNum = 2;

        SELECT 
            DUserId AS Id, 
            DPasswordTimeout AS PasswordChangeNeeded, 
            DFD AS NeedDelivery, 
            DIsSub AS IsSub,
            DContentReviewNeedCount AS ContentReviewNeedCount;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Login` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS User_Secession;

DELIMITER $$
CREATE PROCEDURE User_Secession(
    IN PUserId INT, 
    IN PContent VARCHAR(512),
    IN PLongContent BOOLEAN, 
    IN PPassword VARCHAR(512)
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;

    SELECT DATE_FORMAT(PayExt, '%Y-%m-%d') >= DATE_FORMAT(CURRENT_TIMESTAMP, '%Y-%m-%d')
    INTO DIsSub 
    FROM UserMerchants 
    WHERE UserId = PUserId;

    IF DIsSub = TRUE THEN
        SIGNAL SQLSTATE 'FB013' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '고객님! 마이페이지에서\n구독중인 서비스를 먼저 해지하신 후 탈퇴 부탁 드립니다.';
    END IF;

    IF (SELECT Id FROM Users WHERE Id = PUserId AND Password = PPassword) IS NULL THEN
        SIGNAL SQLSTATE 'FB001' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '비밀번호가 올바르지 않습니다.';
    END IF;

    INSERT INTO UserSecessions (SecessionContent, LongContent) VALUES (PContent, PLongContent);

    #UPDATE Cards SET UserId = NULL WHERE UserId = PUserId;
    UPDATE Merchants SET UserId = NULL, CardId = NULL WHERE UserId = PUserId;
    UPDATE UserMerchants SET UserId = NULL, CardId = NULL, NextCardId = NULL WHERE UserId = PUserId;
    UPDATE PromotionUsers SET UserId = NULL WHERE UserId = PUserId;

    DELETE FROM Cards WHERE UserId = PUserId;
    DELETE FROM Users WHERE Id = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Secession` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS User_Login_Once;

DELIMITER $$
CREATE PROCEDURE User_Login_Once(
    IN PUserId INT, 
    IN PPassword VARCHAR(512)
)
BEGIN
    IF (SELECT COUNT(Id) FROM Users WHERE Id = PUserId AND Password = PPassword) = 1 THEN
        SELECT TRUE AS LoginResult;
    ELSE
        SIGNAL SQLSTATE 'FB001' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '비밀번호가 올바르지 않습니다.';
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Login_Once` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS User_Password_Change;

DELIMITER $$
CREATE PROCEDURE User_Password_Change(
    IN PUserId INT, 
    IN POldPassword VARCHAR(512),
    IN PNewPassword VARCHAR(512)
)
BEGIN
    IF (SELECT Id FROM Users WHERE Id = PUserId AND Password = POldPassword) IS NULL THEN
        SIGNAL SQLSTATE 'FB001' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '비밀번호가 일치하지 않습니다.';
    END IF;

    UPDATE Users SET Password = PNewPassword WHERE Id = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Password_Change` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS User_Change_Contact_Check;

DELIMITER $$
CREATE PROCEDURE User_Change_Contact_Check(
    IN PUserId INT,
    IN PContact VARCHAR(13)
)
BEGIN
    DECLARE DIsDupKey BOOLEAN DEFAULT FALSE;

    DECLARE DKey VARCHAR(6) DEFAULT NULL;

    IF PContact IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
    END IF;

    SELECT TRUE
    INTO DIsDupKey
    FROM Users
    WHERE Contact = PContact
    LIMIT 1;

    IF DIsDupKey = TRUE THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10009, MESSAGE_TEXT = '이미 사용중인 휴대번호입니다.';
    ELSE
        CALL Create_Verify2(PContact, 'Change_Contact', PUserId, DKey);
        SELECT DKey AS 'Key';
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Change_Contact_Check` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS User_Change_Contact_Confirm;

DELIMITER $$
CREATE PROCEDURE User_Change_Contact_Confirm(
    IN PUserId INT,
    IN PContact VARCHAR(13),
    IN PVerifyKey VARCHAR(6)
)
BEGIN
    DECLARE DVerifyId INT DEFAULT NULL;

    CALL Verify3(PContact, PVerifyKey, 'Change_Contact', PUserId, DVerifyId);

    SELECT DVerifyId AS VerifyId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Change_Contact_Confirm` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS User_Change_Contact;

DELIMITER $$
CREATE PROCEDURE User_Change_Contact(
    IN PUserId INT,
    IN PContact VARCHAR(13),
    IN PVerifyId INT
)
BEGIN
    IF (SELECT Id FROM VerifyLogs WHERE Id = PVerifyId and Contact = PContact AND UserId = PUserId AND IsUsed = FALSE) IS NULL THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '인증정보가 유효하지않습니다.';
    END IF;

    UPDATE Users SET Contact = PContact WHERE Id = PUserId;

    CALL Use_Verify(PVerifyId);
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Change_Contact` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_User_Mypage_Info;

DELIMITER $$
CREATE PROCEDURE Get_User_Mypage_Info(
    IN PUserId INT
)
BEGIN
    IF PUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB003' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    SELECT 
        Name, 
        Username, 
        Contact, 
        RoadAddress, 
        JibunAddress, 
        ExtraAddress, 
        PostCode, 
        AddressType, 
        EmailTerm, 
        SMSTerm
        FROM Users WHERE Id = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_User_Mypage_Info` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS User_Info_Change;

DELIMITER $$
CREATE PROCEDURE User_Info_Change(
    IN PUserId INT,
    IN PRoadAddress VARCHAR(256),
    IN PJibunAddress VARCHAR(256),
    IN PExtraAddress VARCHAR(256),
    IN PPostCode VARCHAR(5),
    IN PAddressType VARCHAR(6),
    IN PEmailTerm BOOLEAN, 
    IN PSMSTerm BOOLEAN
)
BEGIN
    #check road address
    IF PRoadAddress IS NOT NULL THEN
        IF PRoadAddress IS NULL THEN
            SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
        END IF;
        #check jibun address
        IF PJibunAddress IS NULL THEN
            SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
        END IF;
        #check post code
        IF PPostCode IS NULL THEN
            SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
        END IF;
        #check address type
        IF PAddressType IS NULL THEN
            SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
        ELSEIF PAddressType != '도로명' AND PAddressType != '지번' THEN
            #지번이랑 도로명 중에 있어야 함
            SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '주소를 입력해주세요.';
        END IF;

        UPDATE Users 
        SET 
            RoadAddress = PRoadAddress, 
            JibunAddress = PJibunAddress, 
            ExtraAddress = PExtraAddress,
            PostCode = PPostCode,
            AddressType = PAddressType
        WHERE Id = PUserId;
    END IF;

    IF PEmailTerm IS NOT NULL THEN
        UPDATE Users
        SET 
            EmailTerm = PEmailTerm
        WHERE Id = PUserId;
    END IF;   

    IF PSMSTerm IS NOT NULL THEN
        UPDATE Users
        SET 
            SMSTerm = PSMSTerm
        WHERE Id = PUserId;
    END IF;    
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`User_Info_Change` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Subscribe;

DELIMITER $$
CREATE PROCEDURE Subscribe(
    IN PUserId INT
)
BEGIN
    UPDATE Users SET IsSub = TRUE WHERE Id = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Subscribe` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Add_Delivery;

DELIMITER $$
CREATE PROCEDURE Add_Delivery(
    IN PUserId INT,
    IN PName VARCHAR(64),
    IN PContact VARCHAR(13),
    IN PRoadAddress VARCHAR(256),
    IN PJibunAddress VARCHAR(256),
    IN PExtraAddress VARCHAR(256),
    IN PPostCode VARCHAR(5),
    IN PAddressType VARCHAR(6)
)
BEGIN
    DECLARE DId INT DEFAULT NULL;
    DECLARE DIsEnd BOOLEAN DEFAULT NULL;

    SELECT IsEnd, Id
    INTO DIsEnd, DId
    FROM FirstDeliveries
    WHERE UserId = PUserId;

    IF DId IS NULL THEN
        INSERT INTO FirstDeliveries (UserId, Name, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType)
        VALUES (PUserId, PName, PContact, PRoadAddress, PJibunAddress, PExtraAddress, PPostCode, PAddressType);
    ELSE
        IF DIsEnd = FALSE THEN
            UPDATE FirstDeliveries 
            SET Name = PName, Contact = PContact, RoadAddress = PRoadAddress, JibunAddress = PJibunAddress,
            ExtraAddress = PExtraAddress, PostCode = PPostCode, AddressType = PAddressType
            WHERE Id = DId;
        ELSE
            SIGNAL SQLSTATE 'FB007' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '이미 배송되었거나, 배송이 시작되었습니다.';
        END IF;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Add_Delivery` TO 'fitboa'@'localhost';




#DROP PROCEDURE IF EXISTS FindUsername_Check_Contact;
#
#DELIMITER $$
#CREATE PROCEDURE FindUsername_Check_Contact(
#    IN PContact VARCHAR(13)
#)
#BEGIN
#    DECLARE DKey VARCHAR(6) DEFAULT NULL;
#
#    IF PContact IS NULL THEN
#        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
#    END IF;
#
#    CALL Create_Verify(PContact, 'FindUsername', DKey);
#    SELECT DKey AS 'Key';
#END $$
#DELIMITER ;
#
#GRANT EXECUTE ON PROCEDURE `Fitboa`.`FindUsername_Check_Contact` TO 'fitboa'@'localhost';




###########  Products

## moved to 502_PayProcedures.sql
#DROP PROCEDURE IF EXISTS Get_Products;
#
#DELIMITER $$
#CREATE PROCEDURE Get_Products(
#)
#BEGIN
#    DECLARE DId INT DEFAULT NULL;
#    DECLARE DMonthlyPrice INT DEFAULT NULL;
#    DECLARE DYearlyPrice INT DEFAULT NULL;
#    DECLARE DMonthlyDisplayPrice INT DEFAULT NULL;
#    DECLARE DYearlyDisplayPrice INT DEFAULT NULL;
#    DECLARE DDescription VARCHAR(1024) DEFAULT NULL;
#
#    SELECT Id, MonthlyPrice, YearlyPrice, MonthlyDisplayPrice, YearlyDisplayPrice, Description
#    INTO DId, DMonthlyPrice, DYearlyPrice, DMonthlyDisplayPrice, DYearlyDisplayPrice, DDescription
#    FROM Products
#    WHERE 
#        DATE_FORMAT(NOW(), '%Y-%m-%d') >= DATE_FORMAT(StartDate, '%Y-%m-%d') AND 
#        NOW() < DATE_FORMAT(NOW(), '%Y-%m-%d') <= DATE_FORMAT(EndDate, '%Y-%m-%d')
#    ORDER BY Id DESC
#    LIMIT 1;
#
#    IF DId IS NULL THEN
#        SELECT '현재 판매중인 상품이 없습니다.' AS Description;
#    ELSE
#        SELECT 
#            DId AS Id, 
#            DMonthlyPrice AS MonthlyPrice, 
#            DYearlyPrice AS YearlyPrice, 
#            DMonthlyDisplayPrice AS MonthlyDisplayPrice, 
#            DYearlyDisplayPrice AS YearlyDisplayPrice, 
#            DDescription AS Description;
#    END IF;
#END $$
#DELIMITER ;
#
#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Products` TO 'fitboa'@'localhost';




###########  Contents
DROP PROCEDURE IF EXISTS Check_Can_Custom;

DELIMITER $$
CREATE PROCEDURE Check_Can_Custom(
    IN PUserId INT
)
BEGIN
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DIsSub BOOLEAN DEFAULT NULL;

    #조건 확인
    SELECT BodyType, IsSub
    INTO DBodyType, DIsSub
    FROM Users
    WHERE Id = PUserId;

    IF DIsSub IS NULL THEN
        SELECT TRUE AS NeddReg, TRUE AS NeedSub, TRUE AS NeedBodyType;
    ELSEIF DIsSub = FALSE THEN
        SELECT FALSE AS NeedReg, TRUE AS NeedSub, TRUE AS NeedBodyType;
    ELSEIF DBodyType IS NULL THEN
        SELECT FALSE AS NeedReg, FALSE AS NeedSub, TRUE AS NeedBodyType;
    ELSE
        SELECT FALSE AS NeedReg, FALSE AS NeedSub, FALSE AS NeedBodyType;
    END IF;
    ##
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Check_Can_Custom` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Get_Main_Contents;

DELIMITER $$
CREATE PROCEDURE Get_Main_Contents(
    IN PIsCustom BOOLEAN,
    IN PUserId INT
)
BEGIN
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DIsSub BOOLEAN DEFAULT NULL;

    #조건 확인
    IF PIsCustom = TRUE THEN
        SELECT BodyType, IsSub
        INTO DBodyType, DIsSub
        FROM Users
        WHERE Id = PUserId;

        IF DIsSub IS NULL THEN
            SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '[비회원]\n정기구독하시면, 매달 회원님의 체형 맞춤 콘텐츠를 확인하실수 있습니다.\n\n정기구독 후 맞춤 스타일을 추천 받으시겠어요?';
        ELSEIF DIsSub = FALSE THEN
            SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = 'G[회원 중 미구독]\n정기구독하시면, 매달 회원님의 체형 맞춤 콘텐츠를 확인하실수 있습니다.\n\n정기구독 후 맞춤 스타일을 추천 받으시겠어요?';
        ELSEIF DBodyType IS NULL THEN
            SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '[구독 회원 중 채촌 등록 안함]\n회원님! 체형 등록 부탁 드립니다. 마이페이지에서 등록하실 수 있어요!';
        END IF;
    END IF;
    ##

    SELECT c.Id, c.Title, c.Author, c.BodyType, ci.FileName AS Image FROM Contents AS c
    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
    WHERE ((PIsCustom = FALSE AND c.BodyType = 0) OR (PIsCustom = TRUE AND c.BodyType = DBodyType)) AND c.TypeNum = 0 AND c.IsExpose = TRUE
    ORDER BY c.Id DESC
    LIMIT 6;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Main_Contents` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Contents;

DELIMITER $$
CREATE PROCEDURE Get_Contents(
    IN PIsCustom BOOLEAN,
    IN PUserId INT,
    IN PSearch VARCHAR(64),
    IN PPage INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT FALSE;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DSkip INT DEFAULT 0;

    IF PIsCustom IS NULL THEN
        SET PIsCustom = FALSE;
    END IF;

    IF PPage < 1 OR PPage IS NULL THEN
        SET PPage = 1;
    END IF;

    SET DSkip = (PPage - 1) * 5;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    IF PIsCustom = TRUE THEN
        IF DIsSub = TRUE THEN
            IF DBodyType IS NULL THEN
                SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '[구독 회원 중 채촌 등록 안함]\n회원님! 체형 등록 부탁 드립니다. 마이페이지에서 등록하실 수 있어요!';
            END IF;
        ELSE
            SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '[비회원][회원 중 미구독]\n정기구독하시면, 매달 회원님의 체형 맞춤 콘텐츠를 확인하실수 있습니다.\n\n정기구독 후 맞춤 스타일을 추천 받으시겠어요?';
        END IF;
    END IF;

    IF PSearch IS NOT NULL AND TRIM(PSearch) != '' THEN
        SELECT
        c.Id AS Id,
        c.Title AS Title,
        c.Author AS Author,
        c.BodyType AS BodyType,
        c.BodyType AS BodyCode,
        ci.FileName AS Image,
        IF(b.Id IS NULL, FALSE, TRUE) AS Bookmarked
        FROM Contents AS c
        LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.OrderNum = 0 AND ci.IsThumbnail = TRUE
        LEFT OUTER JOIN Bookmarks AS b ON b.ContentId = c.Id AND b.UserId = PUserId
        WHERE (((PIsCustom = TRUE AND c.BodyType = DBodyType) OR (PIsCustom = FALSE AND (c.BodyType = 0 OR DIsSub IS NOT NULL))) AND c.Title LIKE CONCAT('%', PSearch, '%')) AND c.TypeNum = 0 AND c.IsExpose = TRUE
        ORDER BY c.Id DESC
        LIMIT DSkip, 5;

        SELECT COUNT(*) AS ContentsCount
        FROM Contents AS c
        WHERE (((PIsCustom = TRUE AND c.BodyType = DBodyType) OR (PIsCustom = FALSE AND (c.BodyType = 0 OR DIsSub IS NOT NULL))) AND c.Title LIKE CONCAT('%', PSearch, '%')) AND c.TypeNum = 0 AND c.IsExpose = TRUE;
    ELSE
        SELECT
        c.Id AS Id,
        c.Title AS Title,
        c.Author AS Author,
        c.BodyType AS BodyType,
        c.BodyType AS BodyCode,
        ci.FileName AS Image,
        IF(b.Id IS NULL, FALSE, TRUE) AS Bookmarked
        FROM Contents AS c
        LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.OrderNum = 0 AND ci.IsThumbnail = TRUE
        LEFT OUTER JOIN Bookmarks AS b ON b.ContentId = c.Id AND b.UserId = PUserId
        WHERE ((PIsCustom = TRUE AND c.BodyType = DBodyType) OR (PIsCustom = FALSE AND (c.BodyType = 0 OR DIsSub IS NOT NULL))) AND c.TypeNum = 0 AND c.IsExpose = TRUE
        ORDER BY c.Id DESC
        LIMIT DSkip, 5;

        SELECT
        COUNT(*) AS ContentsCount
        FROM Contents AS c
        WHERE ((PIsCustom = TRUE AND c.BodyType = DBodyType) OR (PIsCustom = FALSE AND (c.BodyType = 0 OR DIsSub IS NOT NULL))) AND c.TypeNum = 0 AND c.IsExpose = TRUE;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Contents` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Content;

DELIMITER $$
CREATE PROCEDURE Get_Content(
    IN PUserId INT,
    IN PContentId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DBodyType2 VARCHAR(6) DEFAULT NULL;
    DECLARE DNeedReg BOOLEAN DEFAULT NULL;
    DECLARE DNeedSub BOOLEAN DEFAULT NULL;

    DECLARE DContentTypeNum INT DEFAULT NULL;

    SELECT IsSub
    INTO DIsSub
    FROM Users
    WHERE Id = PUserId;

    SELECT BodyType, TypeNum
    INTO DBodyType, DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    #SET DBodyType2 = BodyCodeToBodyType(DBodyType);
    SET DNeedReg = IF(DIsSub IS NULL, TRUE, FALSE);
    SET DNeedSub = IF((DIsSub != TRUE OR DIsSub IS NULL) AND DBodyType != 0, TRUE, FALSE);

    IF DBodyType IS NULL OR DContentTypeNum IS NULL OR DContentTypeNum != 0 THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '컨텐츠가 존재하지 않습니다.';
    #ELSEIF DBodyType != 0 THEN
    #    IF DIsSub IS NULL 
    #    #OR DIsSub = FALSE 
    #    THEN
    #        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '[비회원][회원 중 미구독]\n정기구독하시면, 매달 회원님의 체형 맞춤 콘텐츠를 확인하실수 있습니다.\n\n정기구독 후 맞춤 스타일을 추천 받으시겠어요?';
    #    END IF;
    END IF;

    UPDATE Contents SET Views = Views + 1 WHERE Id = PContentId;

    ## Monthly View Count
    IF (SELECT COUNT(*) FROM ContentViews WHERE Year = YEAR(NOW()) AND MONTH(NOW())) < 1 THEN
        INSERT INTO ContentViews (ContentId, Year, Month, Views) VALUES (PContentId, YEAR(NOW()), MONTH(NOW()), 1);
    ELSE
        UPDATE ContentViews SET Views = Views + 1 WHERE Year = YEAR(NOW()) AND Month = MONTH(NOW());
    END IF;
    ##

    SELECT 
    c.Id AS Id,
    c.Title AS Title,
    c.Author AS Author,
    #DBodyType2 AS BodyType,
    c.BodyType AS BodyType,
    c.Views AS Views,
    ci.FileName AS Image,
    ci.OrderNum AS OrderNum,
    ci.IsThumbnail AS IsThumbnail,
    DNeedReg AS NeedReg,
    DNeedSub AS NeedSub,
    c.CreatedAt AS CreatedAt,
    c.Threshold AS Threshold,
    IF(b.Id IS NULL, FALSE, TRUE) AS Bookmarked
    FROM Contents AS c
    LEFT OUTER JOIN Bookmarks AS b ON b.ContentId = c.Id AND b.UserId = PUserId
    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id 
        AND (
            #DIsSub = TRUE OR 
            #(DIsSub = FALSE AND (DBodyType = 0 OR (DBodyType != 0 AND ci.OrderNum <= c.Threshold))) OR
            #(DIsSub IS NULL AND DBodyType = 0 AND ci.OrderNum <= c.Threshold)
            DIsSub = TRUE 
            OR (ci.OrderNum <= c.Threshold)
        )
    WHERE c.Id = PContentId AND c.IsExpose = TRUE
    ORDER BY ci.OrderNum ASC;

    IF PUserId IS NOT NULL AND DIsSub IS NOT NULL THEN
        INSERT INTO UserContentViews (UserId, ContentId, ContentType) VALUES (PUserId, PContentId, DBodyType);
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Content` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Next_Content;

DELIMITER $$
CREATE PROCEDURE Get_Next_Content(
    IN PUserId INT,
    IN PContentId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DContentBodyType INT DEFAULT NULL;

    DECLARE DContentTypeNum INT DEFAULT NULL;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    SELECT BodyType, TypeNum
    INTO DContentBodyType, DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    IF DContentBodyType IS NULL OR DContentTypeNum IS NULL OR DContentTypeNum != 0 THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '컨텐츠가 없거나 삭제되었습니다.';
    END IF;

    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    SELECT 
    -1 AS Move,
    c.Id AS Id,
    c.Title AS Title,
    ci.FileName AS Image
    FROM Contents AS c
    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
    WHERE 
        c.Id < PContentId AND c.TypeNum = 0 AND c.IsExpose = TRUE AND 
        (((DBodyType IS NULL OR DIsSub = FALSE) AND c.BodyType = 0) OR 
        ((DBodyType IS NOT NULL AND DIsSub = TRUE) AND c.BodyType = DBodyType))
    ORDER BY c.Id DESC
    LIMIT 1;

    SELECT 
    1 AS Move,
    c.Id AS Id,
    c.Title AS Title,
    ci.FileName as Image
    FROM Contents AS c
    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
    WHERE 
        c.Id > PContentId AND c.TypeNum = 0 AND c.IsExpose = TRUE AND 
        (((DBodyType IS NULL OR DIsSub = FALSE) AND c.BodyType = 0) OR 
        ((DBodyType IS NOT NULL AND DIsSub = TRUE) AND c.BodyType = DBodyType))
    ORDER BY c.Id ASC
    LIMIT 1;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Next_Content` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS High_View_Contents;

DELIMITER $$
CREATE PROCEDURE High_View_Contents(
    IN PUserId INT,
    IN PContentId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DContentBodyType INT DEFAULT NULL;

    DECLARE DContentTypeNum INT DEFAULT NULL;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    SELECT BodyType, TypeNum 
    INTO DContentBodyType, DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    IF DContentBodyType IS NULL OR DContentTypeNum IS NULL OR DContentTypeNum != 0 THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '컨텐츠가 없거나 삭제되었습니다.';
    END IF;

    # 비회원 불가 
    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    ELSEIF DIsSub = FALSE OR DBodyType IS NULL THEN
        # 미구독 회원
        SELECT 
        c.Id, c.Title, c.Author, ci.FileName AS Image
        FROM Contents AS c
        LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
        LEFT OUTER JOIN ContentViews AS cv ON cv.ContentId = c.Id
        WHERE c.BodyType = 0 AND c.Id != PContentId AND c.TypeNum = 0 AND c.IsExpose = TRUE
        ORDER BY cv.Views DESC, c.Id DESC
        LIMIT 3;
    ELSE
        SELECT 
        c.Id, c.Title, c.Author, ci.FileName AS Image
        FROM Contents AS c
        LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
        LEFT OUTER JOIN ContentViews AS cv ON cv.ContentId = c.Id
        WHERE c.BodyType = DContentBodyType AND c.Id != PContentId AND c.TypeNum = 0 AND c.IsExpose = TRUE
        ORDER BY cv.Views DESC, c.Id DESC
        LIMIT 3;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`High_View_Contents` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Popular_Contents;

#DELIMITER $$
#CREATE PROCEDURE Get_Popular_Contents(
#    IN PUserId INT,
#    IN PContentId INT
#)
#BEGIN
#    DECLARE DIsSub BOOLEAN DEFAULT NULL;
#    DECLARE DBodyType INT DEFAULT NULL;
#
#    SELECT IsSub, BodyType
#    INTO DIsSub, DBodyType
#    FROM Users
#    WHERE Id = PUserId;
#
#    IF DIsSub IS NULL THEN
#        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
#    END IF;
#
#    SELECT 
#    c.Id AS Id,
#    c.Title AS Title,
#    c.Author AS Author,
#    BodyCodeToBodyType(c.BodyType) AS BodyType,
#    c.BodyType AS BodyCode,
#    ci.FileName AS Image
#    FROM Contents AS c
#    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.OrderNum = 0 AND ci.IsThumbnail = TRUE
#    WHERE 
#        (
#            ((DBodyType IS NULL OR DIsSub = FALSE) AND c.BodyType = 0) OR 
#            ((DBodyType IS NOT NULL AND DIsSub = TRUE) AND c.BodyType = DBodyType)
#        )
#    ORDER BY c.Views DESC
#    LIMIT 3;
#END $$
#DELIMITER ;
#
#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Popular_Contents` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Content_Reviews;

DELIMITER $$
CREATE PROCEDURE Get_Content_Reviews(
    IN PUserId INT,
    IN PContentId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DContentTypeNum INT DEFAULT NULL;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    SELECT TypeNum
    INTO DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    # 콘텐츠 없으면 튕구기
    IF DContentTypeNum IS NULL THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '컨텐츠가 없거나 삭제되었습니다.';
    END IF;
    #

    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    # 콘텐츠 별 권한 체크
    #

    SELECT 
        cr.Id AS Id,
        u.Name AS Name,
        cr.CreatedAt AS CreatedAt,
        cr.Content AS Content,
        cr.Rate AS Rate,
        cr.ParentReviewId AS ParentReviewId,
        GROUP_CONCAT(cri.FileName SEPARATOR ',') AS Images
    FROM ContentReviews AS cr
    INNER JOIN Users AS u ON u.Id = cr.UserId
    LEFT OUTER JOIN ContentReviewImages AS cri ON cri.ReviewId = cr.Id
    WHERE cr.ContentId = PContentId
    GROUP BY cr.Id, u.Name, cr.CreatedAt, cr.Content, cr.Rate, cr.ParentReviewId, cr.GroupCode
    ORDER BY cr.GroupCode ASC, cr.Id ASC, cri.OrderNum ASC;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Content_Reviews` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Post_Content_Review;

DELIMITER $$
CREATE PROCEDURE Post_Content_Review(
    IN PUserId INT,
    IN PContentId INT,
    IN PReviewId INT,
    IN PReviewContent VARCHAR(1024)
)
BEGIN
    DECLARE DContentId INT DEFAULT NULL;
    DECLARE DParentReviewId INT DEFAULT NULL;
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DBodyType2 INT DEFAULT NULL;
    DECLARE DContentTypeNum INT DEFAULT NULL;

    DECLARE LastId INT DEFAULT NULL;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    SELECT BodyType, TypeNum
    INTO DBodyType2, DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    IF DBodyType2 IS NULL OR DContentTypeNum != 0 THEN
        #게시글 없음
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '컨텐츠가 존재하지 않습니다.';
    ELSEIF DBodyType2 != 0 AND DIsSub = FALSE THEN
        #구독 해야함
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독이 필요합니다.';
    END IF;

    IF PReviewId IS NOT NULL THEN
        SELECT ContentId, ParentReviewId
        INTO DContentId, DParentReviewId
        FROM ContentReviews
        WHERE Id = PReviewId;

        IF DContentId IS NULL THEN
            #답글 달 리뷰 없음
            SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '답글을 작성할 리뷰가 없습니다.';
        ELSEIF DContentId != PContentId THEN
            #답글 달 댓글이 다른 게시물에 있음
            SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '답글을 작성할 리뷰가 없습니다.';
        END IF;
    END IF;

    INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content) 
    VALUES (PContentId, PUserId, IF(DParentReviewId IS NULL, PReviewId, DParentReviewId), PReviewContent);

    SET LastId = LAST_INSERT_ID();

    UPDATE ContentReviews SET GroupCode = IF(ParentReviewId IS NULL, Id, ParentReviewId) WHERE Id = LastId;

    SELECT 
        cr.Id AS Id,
        u.Name AS Name,
        cr.CreatedAt AS CreatedAt,
        cr.Content AS Content,
        cr.ParentReviewId AS ParentReviewId
    FROM ContentReviews AS cr
    INNER JOIN Users AS u ON u.Id = cr.UserId
    WHERE cr.Id = LastId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Post_Content_Review` TO 'fitboa'@'localhost';




###########  Style guide
DROP PROCEDURE IF EXISTS Get_SG_Contents;

DELIMITER $$
CREATE PROCEDURE Get_SG_Contents(
    #IN PIsCustom BOOLEAN,
    IN PUserId INT,
    IN PSearch VARCHAR(64),
    IN PPage INT
)
BEGIN
    DECLARE DUserId INT DEFAULT NULL;
    DECLARE DIsSub BOOLEAN DEFAULT FALSE;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DSkip INT DEFAULT 0;

    #IF PIsCustom IS NULL THEN
    #    SET PIsCustom = FALSE;
    #END IF;

    IF PPage < 1 OR PPage IS NULL THEN
        SET PPage = 1;
    END IF;

    SET DSkip = (PPage - 1) * 5;

    SELECT Id, IsSub, BodyType
    INTO DUserId, DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    #IF DUserId IS NULL THEN
    #    SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    #END IF;

    #IF DIsSub = FALSE THEN
    #    SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '[비회원][회원 중 미구독]\n정기구독하시면, 매달 회원님의 체형 맞춤 콘텐츠를 확인하실수 있습니다.\n\n정기구독 후 맞춤 스타일을 추천 받으시겠어요?';
    #END IF;

    #IF PIsCustom = TRUE THEN
        #IF DIsSub = TRUE THEN
        #    IF DBodyType IS NULL THEN
        #        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '[구독 회원 중 채촌 등록 안함]\n회원님! 체형 등록 부탁 드립니다. 마이페이지에서 등록하실 수 있어요!';
        #    END IF;
        #ELSE
        #    SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '[비회원][회원 중 미구독]\n정기구독하시면, 매달 회원님의 체형 맞춤 콘텐츠를 확인하실수 있습니다.\n\n정기구독 후 맞춤 스타일을 추천 받으시겠어요?';
        #END IF;
    #END IF;

    IF PSearch IS NOT NULL AND TRIM(PSearch) != '' THEN
        SELECT
        c.Id AS Id,
        c.Title AS Title,
        c.Author AS Author,
        c.BodyType AS BodyType,
        c.BodyType AS BodyCode,
        ci.FileName AS Image,
        IF(b.Id IS NULL, FALSE, TRUE) AS Bookmarked
        FROM Contents AS c
        LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.OrderNum = 0 AND ci.IsThumbnail = TRUE
        LEFT OUTER JOIN Bookmarks AS b ON b.ContentId = c.Id AND b.UserId = PUserId
        WHERE (
            #((PIsCustom = TRUE AND c.BodyType = DBodyType) OR PIsCustom = FALSE) AND 
            c.Title LIKE CONCAT('%', PSearch, '%')
        ) AND c.TypeNum = 1 AND c.IsExpose = TRUE
        ORDER BY c.Id DESC
        LIMIT DSkip, 5;

        SELECT COUNT(*) AS ContentsCount
        FROM Contents AS c
        WHERE (
            #((PIsCustom = TRUE AND c.BodyType = DBodyType) OR PIsCustom = FALSE) AND 
            c.Title LIKE CONCAT('%', PSearch, '%')
        ) AND c.TypeNum = 1 AND c.IsExpose = TRUE;
    ELSE
        SELECT
        c.Id AS Id,
        c.Title AS Title,
        c.Author AS Author,
        c.BodyType AS BodyType,
        c.BodyType AS BodyCode,
        ci.FileName AS Image,
        IF(b.Id IS NULL, FALSE, TRUE) AS Bookmarked
        FROM Contents AS c
        LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.OrderNum = 0 AND ci.IsThumbnail = TRUE
        LEFT OUTER JOIN Bookmarks AS b ON b.ContentId = c.Id AND b.UserId = PUserId
        WHERE 
            #((PIsCustom = TRUE AND c.BodyType = DBodyType) OR PIsCustom = FALSE) AND 
            c.TypeNum = 1 AND c.IsExpose = TRUE
        ORDER BY c.Id DESC
        LIMIT DSkip, 5;

        SELECT
        COUNT(*) AS ContentsCount
        FROM Contents AS c
        WHERE 
            #((PIsCustom = TRUE AND c.BodyType = DBodyType) OR PIsCustom = FALSE) AND 
            c.TypeNum = 1 AND c.IsExpose = TRUE;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_SG_Contents` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_SG_Content;

DELIMITER $$
CREATE PROCEDURE Get_SG_Content(
    IN PUserId INT,
    IN PContentId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DBodyType2 VARCHAR(6) DEFAULT NULL;
    DECLARE DNeedReg BOOLEAN DEFAULT NULL;
    DECLARE DNeedSub BOOLEAN DEFAULT NULL;

    DECLARE DContentTypeNum INT DEFAULT NULL;

    SELECT IsSub
    INTO DIsSub
    FROM Users
    WHERE Id = PUserId;

    SELECT BodyType, TypeNum
    INTO DBodyType, DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    #SET DBodyType2 = BodyCodeToBodyType(DBodyType);
    SET DNeedReg = IF(DIsSub IS NULL, TRUE, FALSE);
    SET DNeedSub = IF((DIsSub != TRUE OR DIsSub IS NULL) AND DBodyType != 1, TRUE, FALSE);

    #IF DIsSub IS NULL OR DIsSub = FALSE THEN
    #    SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '[비회원][회원 중 미구독]\n정기구독하시면, 매달 회원님의 체형 맞춤 콘텐츠를 확인하실수 있습니다.\n\n정기구독 후 맞춤 스타일을 추천 받으시겠어요?';
    #END IF;

    IF DBodyType IS NULL OR DContentTypeNum IS NULL OR DContentTypeNum != 1 THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '컨텐츠가 존재하지 않습니다.';
    #ELSEIF DBodyType != 0 THEN
        #IF DIsSub IS NULL OR DIsSub = FALSE THEN
        #    SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '[비회원][회원 중 미구독]\n정기구독하시면, 매달 회원님의 체형 맞춤 콘텐츠를 확인하실수 있습니다.\n\n정기구독 후 맞춤 스타일을 추천 받으시겠어요?';
        #END IF;
    END IF;

    UPDATE Contents SET Views = Views + 1 WHERE Id = PContentId;

    ## Monthly View Count
    IF (SELECT COUNT(*) FROM ContentViews WHERE Year = YEAR(NOW()) AND MONTH(NOW())) < 1 THEN
        INSERT INTO ContentViews (ContentId, Year, Month, Views) VALUES (PContentId, YEAR(NOW()), MONTH(NOW()), 1);
    ELSE
        UPDATE ContentViews SET Views = Views + 1 WHERE Year = YEAR(NOW()) AND Month = MONTH(NOW());
    END IF;
    ##

    SELECT 
    c.Id AS Id,
    c.Title AS Title,
    c.Author AS Author,
    #DBodyType2 AS BodyType,
    c.BodyType AS BodyType,
    c.Views AS Views,
    ci.FileName AS Image,
    ci.OrderNum AS OrderNum,
    ci.IsThumbnail AS IsThumbnail,
    DNeedReg AS NeedReg,
    DNeedSub AS NeedSub,
    c.CreatedAt AS CreatedAt,
    c.Threshold AS Threshold,
    IF(b.Id IS NULL, FALSE, TRUE) AS Bookmarked
    FROM Contents AS c
    LEFT OUTER JOIN Bookmarks AS b ON b.ContentId = c.Id AND b.UserId = PUserId
    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id 
        AND (
            DIsSub = TRUE 
            OR (ci.OrderNum <= c.Threshold)
        )
    WHERE c.Id = PContentId
    ORDER BY ci.OrderNum ASC;

    IF PUserId IS NOT NULL AND DIsSub IS NOT NULL THEN
        INSERT INTO UserContentViews (UserId, ContentId, ContentType) VALUES (PUserId, PContentId, DBodyType);
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_SG_Content` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Next_SG_Content;

DELIMITER $$
CREATE PROCEDURE Get_Next_SG_Content(
    IN PUserId INT,
    IN PContentId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DContentBodyType INT DEFAULT NULL;

    DECLARE DContentTypeNum INT DEFAULT NULL;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    SELECT BodyType, TypeNum
    INTO DContentBodyType, DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    IF DContentBodyType IS NULL OR DContentTypeNum IS NULL OR DContentTypeNum != 1 THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '컨텐츠가 없거나 삭제되었습니다.';
    END IF;

    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    ELSEIF DIsSub = FALSE THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독이 필요합니다.';
    END IF;

    SELECT 
    -1 AS Move,
    c.Id AS Id,
    c.Title AS Title,
    ci.FileName AS Image
    FROM Contents AS c
    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
    WHERE 
        c.Id < PContentId AND c.TypeNum = 1 AND c.IsExpose = TRUE 
        #AND 
        #(((DBodyType IS NULL OR DIsSub = FALSE) AND c.BodyType = 0) OR 
        #((DBodyType IS NOT NULL AND DIsSub = TRUE) AND c.BodyType = DBodyType))
    ORDER BY c.Id DESC
    LIMIT 1;

    SELECT 
    1 AS Move,
    c.Id AS Id,
    c.Title AS Title,
    ci.FileName as Image
    FROM Contents AS c
    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
    WHERE 
        c.Id > PContentId AND c.TypeNum = 1 AND c.IsExpose = TRUE 
        #AND 
        #(((DBodyType IS NULL OR DIsSub = FALSE) AND c.BodyType = 0) OR 
        #((DBodyType IS NOT NULL AND DIsSub = TRUE) AND c.BodyType = DBodyType))
    ORDER BY c.Id ASC
    LIMIT 1;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Next_SG_Content` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS High_View_SG_Contents;

DELIMITER $$
CREATE PROCEDURE High_View_SG_Contents(
    IN PUserId INT,
    IN PContentId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DContentBodyType INT DEFAULT NULL;

    DECLARE DContentTypeNum INT DEFAULT NULL;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    SELECT BodyType, TypeNum 
    INTO DContentBodyType, DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    IF DContentBodyType IS NULL OR DContentTypeNum IS NULL OR DContentTypeNum != 1 THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '컨텐츠가 없거나 삭제되었습니다.';
    END IF;

    # 비회원 불가 
    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    ELSEIF DIsSub = FALSE THEN
        # 미구독 회원
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독이 필요합니다.';
    ELSE
        SELECT 
        c.Id, c.Title, c.Author, ci.FileName AS Image
        FROM Contents AS c
        LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
        LEFT OUTER JOIN ContentViews AS cv ON cv.ContentId = c.Id
        WHERE c.Id != PContentId AND c.TypeNum = 1 AND c.IsExpose = TRUE
        ORDER BY cv.Views DESC, c.Id DESC
        LIMIT 3;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`High_View_SG_Contents` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Post_SG_Content_Review;

DELIMITER $$
CREATE PROCEDURE Post_SG_Content_Review(
    IN PUserId INT,
    IN PContentId INT,
    IN PReviewId INT,
    IN PReviewContent VARCHAR(1024)
    #,
    #IN PRate FLOAT,
    #IN PImageFilePath VARCHAR(128),
    #IN PImage1 VARCHAR(128),
    #IN PImageOriginName1 VARCHAR(128),
    #IN PImage2 VARCHAR(128),
    #IN PImageOriginName2 VARCHAR(128),
    #IN PImage3 VARCHAR(128),
    #IN PImageOriginName3 VARCHAR(128),
    #IN PImage4 VARCHAR(128),
    #IN PImageOriginName4 VARCHAR(128),
    #IN PImage5 VARCHAR(128),
    #IN PImageOriginName5 VARCHAR(128)
)
BEGIN
    DECLARE DContentId INT DEFAULT NULL;
    DECLARE DParentReviewId INT DEFAULT NULL;
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DBodyType2 INT DEFAULT NULL;
    DECLARE DContentTypeNum INT DEFAULT NULL;

    DECLARE LastId INT DEFAULT NULL;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    SELECT BodyType, TypeNum
    INTO DBodyType2, DContentTypeNum
    FROM Contents
    WHERE Id = PContentId AND IsExpose = TRUE;

    IF DBodyType2 IS NULL OR DContentTypeNum != 0 THEN
        #게시글 없음
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '컨텐츠가 존재하지 않습니다.';
    ELSEIF DBodyType2 != 0 AND DIsSub = FALSE THEN
        #구독 해야함
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '구독이 필요합니다.';
    END IF;

    IF PReviewId IS NOT NULL THEN
        SELECT ContentId, ParentReviewId
        INTO DContentId, DParentReviewId
        FROM ContentReviews
        WHERE Id = PReviewId;

        IF DContentId IS NULL THEN
            #답글 달 리뷰 없음
            SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '답글을 작성할 리뷰가 없습니다.';
        ELSEIF DContentId != PContentId THEN
            #답글 달 댓글이 다른 게시물에 있음
            SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '답글을 작성할 리뷰가 없습니다.';
        END IF;
    END IF;

    INSERT INTO ContentReviews (ContentId, UserId, ParentReviewId, Content) 
    VALUES (PContentId, PUserId, IF(DParentReviewId IS NULL, PReviewId, DParentReviewId), PReviewContent);

    SET LastId = LAST_INSERT_ID();

    UPDATE ContentReviews SET GroupCode = IF(ParentReviewId IS NULL, Id, ParentReviewId) WHERE Id = LastId;

    SELECT 
        cr.Id AS Id,
        u.Name AS Name,
        cr.CreatedAt AS CreatedAt,
        cr.Content AS Content,
        cr.ParentReviewId AS ParentReviewId
    FROM ContentReviews AS cr
    INNER JOIN Users AS u ON u.Id = cr.UserId
    WHERE cr.Id = LastId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Post_SG_Content_Review` TO 'fitboa'@'localhost';




###########  MyPage
DROP PROCEDURE IF EXISTS Set_BodyType_Service;

DELIMITER $$
CREATE PROCEDURE Set_BodyType_Service(
    IN PUserId INT,
    IN PShoulder DOUBLE,
    IN PChest DOUBLE,
    IN PWaist DOUBLE,
    IN PArm DOUBLE,
    IN PLeg DOUBLE,
    IN PThigh DOUBLE
)
BEGIN
    CALL Set_BodyType_Service_Check(PUserId);

    INSERT INTO BodyTypeServices (UserId, Shoulder, Chest, Waist, Arm, Leg, Thigh) VALUES (PUserId, PShoulder, PChest, PWaist, PArm, PLeg, PThigh);

    #SELECT * FROM (SELECT PShoulder, PChest, PWaist, PArm, PLeg, PThigh) AS tmp
    #WHERE NOT EXISTS (
    #    SELECT Id FROM BodyTypeServices WHERE UserId = PUserId AND IsEnd = FALSE
    #) LIMIT 1;

    #UPDATE BodyTypeServices
    #    SET Shoulder = PShoulder, Chest = PChest, Waist = PWaist, Arm = PArm, Leg = PLeg, Thigh = PThigh
    #    WHERE Id = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_BodyType_Service` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Set_BodyType_Service2;

DELIMITER $$
CREATE PROCEDURE Set_BodyType_Service2(
    IN PUserId INT,
    IN PBodyType INT
)
BEGIN
    CALL Set_BodyType_Service_Check(PUserId);

    IF PBodyType > 0 AND PBodyType < 6 THEN
        UPDATE Users SET BodyType = PBodyType, BodyTypeUpdatedAt = CURRENT_TIMESTAMP WHERE Id = PUserId;
    ELSE
        SIGNAL SQLSTATE 'FB008' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '체형을 선택해주세요.';
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_BodyType_Service2` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Set_BodyType_Service_Check;

DELIMITER $$
CREATE PROCEDURE Set_BodyType_Service_Check(
    IN PUserId INT
)
BEGIN
    DECLARE DId INT DEFAULT NULL;
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    
    SELECT IsSub
    INTO DIsSub
    FROM Users
    WHERE Id = PUserId;

    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '회원가입이 필요한 컨텐츠입니다.';
    ELSEIF DIsSub = FALSE THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '구독이 필요한 컨텐츠입니다.';
    ELSE
        IF (SELECT COUNT(*) FROM BodyTypeServices WHERE IsEnd = FALSE AND UserId = PUserId) > 0 THEN
            SIGNAL SQLSTATE 'FB008' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '핏봐 운영팀에서 체형 분류중입니다.';
        END IF;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_BodyType_Service_Check` TO 'fitboa'@'localhost';



############### 유저 정보 내리는 부분 일단 프론트 요청대로 모든 정보 내림 나중에 정보 제한 해야함
DROP PROCEDURE IF EXISTS Get_User_Info;

DELIMITER $$
CREATE PROCEDURE Get_User_Info(
    IN PUserId INT
)
BEGIN
    IF PUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB003' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    SELECT * FROM Users WHERE Id = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_User_Info` TO 'fitboa'@'localhost';






########### Image Permission
DROP PROCEDURE IF EXISTS Image_Permission_Check;

DELIMITER $$
CREATE PROCEDURE Image_Permission_Check(
    IN PUserId INT,
    IN PImageName VARCHAR(256)
)
BEGIN
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DIsThumbnail BOOLEAN DEFAULT NULL;
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DFileName VARCHAR(256) DEFAULT NULL;

    DECLARE DOrderNum INT DEFAULT NULL;
    DECLARE DThreshold INT DEFAULT 0;

    SELECT c.BodyType, ci.IsThumbnail, ci.OriginFileName, c.Threshold, ci.OrderNum
    INTO DBodyType, DIsThumbnail, DFileName, DThreshold, DOrderNum
    FROM ContentImages as ci
    INNER JOIN Contents as c on c.Id = ci.ContentId
    WHERE ci.FileName = PImageName;

    IF DBodyType IS NULL OR DOrderNum IS NULL OR DFileName IS NULL THEN
        #게시글 없음
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '컨텐츠가 없거나 삭제되었습니다.';
    ELSEIF 
        DIsThumbnail = FALSE AND 
        DOrderNum > DThreshold AND 
        DBodyType != 0 THEN

        #유료
        IF PUserId IS NULL THEN
            #비회원
            SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '회원가입이 필요한 컨텐츠입니다.';
        ELSE 
            #회원
            SELECT IsSub
            INTO DIsSub
            FROM Users
            WHERE Id = PUserId;

            IF DIsSub IS NULL THEN
                #회원정보 불일치(비회원)
                SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '회원가입이 필요한 컨텐츠입니다.';
            ELSEIF DIsSub = FALSE THEN
                #미구독자
                SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '구독이 필요한 컨텐츠입니다.';
            END IF;
        END IF;
    END IF;

    SELECT DFileName AS FileName;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Image_Permission_Check` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Image_Name_Check;

DELIMITER $$
CREATE PROCEDURE Image_Name_Check(
    IN PUserId INT,
    IN PImageName VARCHAR(256)
)
BEGIN
    SELECT OriginFileName FROM ContentReviewImages WHERE FileName = PImageName;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Image_Name_Check` TO 'fitboa'@'localhost';




########### Bookmarks
DROP PROCEDURE IF EXISTS Add_Bookmark;

DELIMITER $$
CREATE PROCEDURE Add_Bookmark(
    IN PUserId INT,
    IN PContentId INT,
    IN PIsAdd BOOLEAN
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DContentBodyType INT DEFAULT NULL;

    IF PIsAdd IS NULL THEN
        SET PIsAdd = TRUE;
    END IF;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    SELECT BodyType 
    INTO DContentBodyType
    FROM Contents
    WHERE Id = PContentId;

    IF DContentBodyType IS NULL THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '컨텐츠가 없거나 삭제되었습니다.';
    END IF;

    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    ## 사용자 별 권한 체크
    IF DContentBodyType != 0 AND (DIsSub IS NULL OR DIsSub = FALSE) THEN
        # 미 구독자는 컨텐츠 북마크 못함
        SIGNAL SQLSTATE 'FB006' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '구독자 전용 컨텐츠입니다.'; 
    END IF;
    ##

    IF (SELECT COUNT(*) FROM Bookmarks WHERE UserId = PUserId AND ContentId = PContentId) > 0 THEN
        IF PIsAdd = TRUE THEN
            SIGNAL SQLSTATE 'FB006' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '북마크가 이미 등록되어있습니다.';
        ELSE
            DELETE FROM Bookmarks WHERE ContentId = PContentId AND UserId = PUserId;
        END IF;
    ELSE
        IF PIsAdd = TRUE THEN
            INSERT INTO Bookmarks (ContentId, UserId) VALUES (PContentId, PUserId);
        ELSE
            SIGNAL SQLSTATE 'FB006' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '북마크가 존재하지 않습니다.';
        END IF;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Add_Bookmark` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Bookmarks;

DELIMITER $$
CREATE PROCEDURE Get_Bookmarks(
    IN PUserId INT
)
BEGIN
    DECLARE DUserId INT DEFAULT NULL;

    SELECT Id
    INTO DUserId
    FROM Users
    WHERE Id = PUserId;

    IF DUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB006' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    SELECT c.Id AS ContentId, c.Title AS Title, c.TypeNum AS TypeNum, ci.FileName AS Image, c.Author AS Author, DATE_FORMAT(b.CreatedAt, '%Y/%m') AS Date
    FROM Bookmarks AS b
    INNER JOIN Contents AS c ON c.Id = b.ContentId
    LEFT OUTER JOIN ContentImages AS ci ON ci.ContentId = c.Id AND ci.IsThumbnail = TRUE
    WHERE UserId = PUserId
    ORDER BY b.Id DESC;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Bookmarks` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Bookmark;

DELIMITER $$
CREATE PROCEDURE Get_Bookmark(
    IN PUserId INT,
    IN PContentId INT
)
BEGIN
    DECLARE DIsSub BOOLEAN DEFAULT NULL;
    DECLARE DBodyType INT DEFAULT NULL;
    DECLARE DContentBodyType INT DEFAULT NULL;

    DECLARE DBookmarked BOOLEAN DEFAULT FALSE;

    SELECT IsSub, BodyType
    INTO DIsSub, DBodyType
    FROM Users
    WHERE Id = PUserId;

    SELECT BodyType 
    INTO DContentBodyType
    FROM Contents
    WHERE Id = PContentId;

    IF DContentBodyType IS NULL THEN
        SIGNAL SQLSTATE 'FB005' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '컨텐츠가 없거나 삭제되었습니다.';
    END IF;

    IF DIsSub IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    SELECT IF(b.Id IS NULL, FALSE, TRUE)
    INTO DBookmarked
    FROM Bookmarks AS b
    INNER JOIN Contents AS c ON c.Id = b.ContentId
    WHERE ContentId = PContentId AND UserId = PUserId;

    SELECT DBookmarked AS Bookmarked;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Bookmark` TO 'fitboa'@'localhost';





########### Setting
DROP PROCEDURE IF EXISTS Get_Settings;

DELIMITER $$
CREATE PROCEDURE Get_Settings(
    IN PUserId INT
)
BEGIN
    IF PUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    END IF;

    SELECT SMSTerm, EmailTerm
    FROM Users
    WHERE Id = PUserId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Settings` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Set_SMS_Agree;

DELIMITER $$
CREATE PROCEDURE Set_SMS_Agree(
    IN PUserId INT,
    IN PIsOn BOOLEAN
)
BEGIN
    DECLARE DUserId INT DEFAULT NULL;

    SELECT Id
    INTO DUserId
    FROM Users
    WHERE Id = PUserId;

    IF DUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    ELSEIF PIsOn IS NULL THEN
        UPDATE Users SET SMSTerm = FALSE WHERE Id = DUserId;
    ELSE
        UPDATE Users SET SMSTerm = PIsOn WHERE Id = DUserId;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_SMS_Agree` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Set_Email_Agree;

DELIMITER $$
CREATE PROCEDURE Set_Email_Agree(
    IN PUserId INT,
    IN PIsOn BOOLEAN
)
BEGIN
    DECLARE DUserId INT DEFAULT NULL;

    SELECT Id
    INTO DUserId
    FROM Users
    WHERE Id = PUserId;

    IF DUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB004' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '로그인이 필요합니다.';
    ELSEIF PIsOn IS NULL THEN
        UPDATE Users SET EmailTerm = FALSE WHERE Id = DUserId;
    ELSE
        UPDATE Users SET EmailTerm = PIsOn WHERE Id = DUserId;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Set_Email_Agree` TO 'fitboa'@'localhost';









########### CustomerServices
DROP PROCEDURE IF EXISTS Get_Customer_Services;

DELIMITER $$
CREATE PROCEDURE Get_Customer_Services(
    IN PTypeNum INT,
    IN PSearch VARCHAR(256)
)
BEGIN
    DECLARE DSearch VARCHAR(258) DEFAULT NULL;

    IF PSearch IS NOT NULL AND TRIM(PSearch) != '' THEN
        SET DSearch = CONCAT('%', PSearch, '%');
    END IF;

    IF PTypeNum IS NULL THEN
        IF DSearch IS NULL THEN
            (SELECT Id, Title, NULL AS Content, Type, UpdatedAt
            FROM CustomerServices 
            WHERE TypeNum = 0
            ORDER BY Id DESC
            LIMIT 5)
            UNION 
            (SELECT Id, Title, Content, Type, UpdatedAt
            FROM CustomerServices 
            WHERE TypeNum = 1
            ORDER BY Id DESC
            LIMIT 5);
        ELSE
            (SELECT Id, Title, NULL AS Content, Type, UpdatedAt
            FROM CustomerServices 
            WHERE TypeNum = 0
            ORDER BY Id DESC
            LIMIT 5)
            UNION 
            (SELECT Id, Title, Content, Type, UpdatedAt
            FROM CustomerServices 
            WHERE TypeNum = 1 AND Title LIKE DSearch
            ORDER BY Id DESC
            LIMIT 5);
        END IF;
    ELSEIF PTypeNum = 0 OR PTypeNum = 1 THEN
        IF DSearch IS NULL THEN
            SELECT Id, Title, NULL AS Content, Type, UpdatedAt
            FROM CustomerServices 
            WHERE TypeNum = PTypeNum
            ORDER BY Id DESC;
        ELSE
            SELECT Id, Title, Content, Type, UpdatedAt
            FROM CustomerServices 
            WHERE TypeNum = PTypeNum AND Title LIKE DSearch
            ORDER BY Id DESC;
        END IF;
    ELSE
        SIGNAL SQLSTATE 'FB009' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '항목을 선택해주세요.';
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Customer_Services` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Customer_Services_Detail;

DELIMITER $$
CREATE PROCEDURE Get_Customer_Services_Detail(
    IN PId INT
)
BEGIN
    SELECT Id, Title, Content, Type, UpdatedAt
    FROM CustomerServices
    WHERE Id = PId;

    UPDATE CustomerServices SET Views = Views + 1 WHERE Id = PId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Customer_Services_Detail` TO 'fitboa'@'localhost';









########### Inquiries
DROP PROCEDURE IF EXISTS Get_Inquiries;

DELIMITER $$
CREATE PROCEDURE Get_Inquiries(
    IN PUserId INT
)
BEGIN
    SELECT Id, ContentId, Type, TypeNum, Title, Content, CreatedAt
    FROM Inquiries
    WHERE UserId = PUserId
    ORDER BY Id DESC;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Inquiries` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Post_Styling_Inquiry;

DELIMITER $$
CREATE PROCEDURE Post_Styling_Inquiry(
    IN PUserId INT,
    IN PType VARCHAR(10),
    IN PTitle VARCHAR(256),
    IN PContent VARCHAR(2048),
    IN PImageFilePath VARCHAR(128),
    IN PImage1 VARCHAR(128),
    IN PImageOriginName1 VARCHAR(128),
    IN PImage2 VARCHAR(128),
    IN PImageOriginName2 VARCHAR(128),
    IN PImage3 VARCHAR(128),
    IN PImageOriginName3 VARCHAR(128),
    IN PImage4 VARCHAR(128),
    IN PImageOriginName4 VARCHAR(128),
    IN PImage5 VARCHAR(128),
    IN PImageOriginName5 VARCHAR(128)
)
BEGIN
    DECLARE DTypeNum INT DEFAULT NULL;
    DECLARE DInquiryId INT DEFAULT NULL;
    DECLARE PContentId INT DEFAULT NULL;#41;

    IF (SELECT COUNT(*) FROM Users WHERE Id = PUserId) <= 0 THEN
        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '회원전용 컨텐츠입니다.';
    END IF;

    SELECT Id 
    INTO PContentId 
    FROM Contents 
    WHERE TypeNum = 2 AND IsExpose = TRUE
    LIMIT 1;

    IF PContentId IS NULL AND PType = '1:1 스타일링' THEN
        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '현재 1:1 스타일링을 신청할 수 없습니다.';
    END IF;

    IF PType = '1:1 스타일링' THEN
        IF (SELECT Id FROM Inquiries WHERE UserId = PUserId AND ContentId = PContentId) IS NOT NULL THEN
            SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10006, MESSAGE_TEXT = '이미 1:1 스타일링을 신청했습니다.';
        END IF;
    END IF;

    IF PType = '1:1 스타일링' THEN
        SET DTypeNum = 0;
    ELSEIF PType = '회원정보' THEN
        SET DTypeNum = 1;
    ELSEIF PType = '결제' THEN
        SET DTypeNum = 2;
    ELSEIF PType = '기타' THEN
        SET DTypeNum = 3;
    ELSEIF PType = '배송' THEN
        SET DTypeNum = 4;
    ELSE
        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '문의 유형을 선택해주세요.';
    END IF;

    IF PTitle IS NULL OR TRIM(PTitle) = '' THEN
        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '제목을 입력해주세요.';
    END IF;

    IF PContent IS NULL OR TRIM(PContent) = '' THEN
        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '내용을 입력해주세요.';
    END IF;

    IF PImageFilePath IS NULL THEN
        SET PImage1 = NULL;
        SET PImage2 = NULL;
        SET PImage3 = NULL;
        SET PImage4 = NULL;
        SET PImage5 = NULL;

        SET PImageOriginName1 = NULL;
        SET PImageOriginName2 = NULL;
        SET PImageOriginName3 = NULL;
        SET PImageOriginName4 = NULL;
        SET PImageOriginName5 = NULL;
    ELSE
        IF 
            (PImage5 IS NULL XOR PImageOriginName5 IS NULL) OR 
            (PImage4 IS NULL XOR PImageOriginName4 IS NULL) OR
            (PImage3 IS NULL XOR PImageOriginName3 IS NULL) OR
            (PImage2 IS NULL XOR PImageOriginName2 IS NULL) OR
            (PImage1 IS NULL XOR PImageOriginName1 IS NULL)
        THEN
            SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '이미지 파일 에러';
        END IF;
    END IF;

    INSERT INTO Inquiries (UserId, ContentId, Type, TypeNum, Title, Content) 
    VALUES (PUserId, PContentId, PType, DTypeNum, PTitle, PContent);

    SET DInquiryId = LAST_INSERT_ID();

    IF DInquiryId IS NOT NULL THEN
        IF PImage1 IS NOT NULL AND PImageOriginName1 IS NOT NULL THEN
            INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
            VALUES (DInquiryId, PImage1, PImageFilePath, PImageOriginName1, 1);

            IF PImage2 IS NOT NULL AND PImageOriginName2 IS NOT NULL THEN
                INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
                VALUES (DInquiryId, PImage2, PImageFilePath, PImageOriginName2, 2);

                IF PImage3 IS NOT NULL AND PImageOriginName3 IS NOT NULL THEN
                    INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
                    VALUES (DInquiryId, PImage3, PImageFilePath, PImageOriginName3, 3);

                    IF PImage4 IS NOT NULL AND PImageOriginName4 IS NOT NULL THEN
                        INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
                        VALUES (DInquiryId, PImage4, PImageFilePath, PImageOriginName4, 4);

                        IF PImage5 IS NOT NULL AND PImageOriginName5 IS NOT NULL THEN
                            INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
                            VALUES (DInquiryId, PImage5, PImageFilePath, PImageOriginName5, 5);
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Post_Styling_Inquiry` TO 'fitboa'@'localhost';




#DROP PROCEDURE IF EXISTS Post_Styling_Inquiry_Image;
#
#DELIMITER $$
#CREATE PROCEDURE Post_Styling_Inquiry_Image(
#    IN PUserId INT,
#    IN PReviewId INT,
#    IN PImageFilePath VARCHAR(128),
#    IN PImage VARCHAR(128),
#    IN PImageOriginName VARCHAR(128)
#)
#BEGIN
#    DECLARE DTypeNum INT DEFAULT NULL;
#    DECLARE DInquiryId INT DEFAULT NULL;
#
#    SELECT *
#    FROM ContentReviews
#    WHERE Id = PReviewId AND UserId = PUserId;
#
#    IF (SELECT COUNT(*) FROM Users WHERE Id = PUserId) <= 0 THEN
#        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '회원전용 컨텐츠입니다.';
#    END IF;
#
#    IF PType = '1:1 스타일링' THEN
#        SET DTypeNum = 0;
#    ELSEIF PType = '회원정보' THEN
#        SET DTypeNum = 1;
#    ELSEIF PType = '결제' THEN
#        SET DTypeNum = 2;
#    ELSEIF PType = '기타' THEN
#        SET DTypeNum = 3;
#    ELSEIF PType = '배송' THEN
#        SET DTypeNum = 4;
#    ELSE
#        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '문의 유형을 선택해주세요.';
#    END IF;
#
#    IF PTitle IS NULL OR TRIM(PTitle) = '' THEN
#        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '제목을 입력해주세요.';
#    END IF;
#
#    IF PContent IS NULL OR TRIM(PContent) = '' THEN
#        SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '내용을 입력해주세요.';
#    END IF;
#
#    IF PImageFilePath IS NULL THEN
#        SET PImage1 = NULL;
#        SET PImage2 = NULL;
#        SET PImage3 = NULL;
#        SET PImage4 = NULL;
#        SET PImage5 = NULL;
#
#        SET PImageOriginName1 = NULL;
#        SET PImageOriginName2 = NULL;
#        SET PImageOriginName3 = NULL;
#        SET PImageOriginName4 = NULL;
#        SET PImageOriginName5 = NULL;
#    ELSE
#        IF 
#            (PImage5 IS NULL XOR PImageOriginName5 IS NULL) OR 
#            (PImage4 IS NULL XOR PImageOriginName4 IS NULL) OR
#            (PImage3 IS NULL XOR PImageOriginName3 IS NULL) OR
#            (PImage2 IS NULL XOR PImageOriginName2 IS NULL) OR
#            (PImage1 IS NULL XOR PImageOriginName1 IS NULL)
#        THEN
#            SIGNAL SQLSTATE 'FB010' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '이미지 파일 에러';
#        END IF;
#    END IF;
#
#    INSERT INTO Inquiries (UserId, Type, TypeNum, Title, Content) 
#    VALUES (PUserId, PType, DTypeNum, PTitle, PContent);
#
#    SET DInquiryId = LAST_INSERT_ID();
#
#    IF DInquiryId IS NOT NULL THEN
#        IF PImage1 IS NOT NULL AND PImageOriginName1 IS NOT NULL THEN
#            INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
#            VALUES (DInquiryId, PImage1, PImageOriginName1, 1);
#
#            IF PImage2 IS NOT NULL AND PImageOriginName2 IS NOT NULL THEN
#                INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
#                VALUES (DInquiryId, PImage2, PImageOriginName2, 2);
#
#                IF PImage3 IS NOT NULL AND PImageOriginName3 IS NOT NULL THEN
#                    INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
#                    VALUES (DInquiryId, PImage3, PImageOriginName3, 3);
#
#                    IF PImage4 IS NOT NULL AND PImageOriginName4 IS NOT NULL THEN
#                        INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
#                        VALUES (DInquiryId, PImage4, PImageOriginName4, 4);
#
#                        IF PImage5 IS NOT NULL AND PImageOriginName5 IS NOT NULL THEN
#                            INSERT INTO InquiryImages (InquiryId, FileName, FilePath, OriginFileName, OrderNum)
#                            VALUES (DInquiryId, PImage5, PImageOriginName5, 5);
#                        END IF;
#                    END IF;
#                END IF;
#            END IF;
#        END IF;
#    END IF;
#END $$
#DELIMITER ;
#
#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Post_Styling_Inquiry_Image` TO 'fitboa'@'localhost';




########### Reviews
DROP PROCEDURE IF EXISTS Post_Review;

DELIMITER $$
CREATE PROCEDURE Post_Review(
    IN PUserId INT,
    #IN PContentId INT,
    IN PContent VARCHAR(1024),
    IN PRate FLOAT,
    IN PImageFilePath VARCHAR(128),
    IN PImage1 VARCHAR(128),
    IN PImageOriginName1 VARCHAR(128),
    IN PImage2 VARCHAR(128),
    IN PImageOriginName2 VARCHAR(128),
    IN PImage3 VARCHAR(128),
    IN PImageOriginName3 VARCHAR(128),
    IN PImage4 VARCHAR(128),
    IN PImageOriginName4 VARCHAR(128),
    IN PImage5 VARCHAR(128),
    IN PImageOriginName5 VARCHAR(128)
)
BEGIN
    DECLARE DReviewId INT DEFAULT NULL;
    DECLARE PContentId INT DEFAULT 1;#41;

    IF (SELECT COUNT(*) FROM Users WHERE Id = PUserId) <= 0 THEN
        SIGNAL SQLSTATE 'FB011' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '회원전용 컨텐츠입니다.';
    END IF;

    IF PContent IS NULL OR TRIM(PContent) = '' THEN
        SIGNAL SQLSTATE 'FB011' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '내용을 입력해주세요.';
    END IF;

    IF PRate < 0 OR PRate > 5 OR PRate MOD 0.5 != 0 THEN
        SIGNAL SQLSTATE 'FB011' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '별점을 입력해주세요.';
    END IF;

    IF PImageFilePath IS NULL THEN
        SET PImage1 = NULL;
        SET PImage2 = NULL;
        SET PImage3 = NULL;
        SET PImage4 = NULL;
        SET PImage5 = NULL;

        SET PImageOriginName1 = NULL;
        SET PImageOriginName2 = NULL;
        SET PImageOriginName3 = NULL;
        SET PImageOriginName4 = NULL;
        SET PImageOriginName5 = NULL;
    ELSE
        IF 
            (PImage5 IS NULL XOR PImageOriginName5 IS NULL) OR 
            (PImage4 IS NULL XOR PImageOriginName4 IS NULL) OR
            (PImage3 IS NULL XOR PImageOriginName3 IS NULL) OR
            (PImage2 IS NULL XOR PImageOriginName2 IS NULL) OR
            (PImage1 IS NULL XOR PImageOriginName1 IS NULL)
        THEN
            SIGNAL SQLSTATE 'FB011' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '이미지 파일 에러';
        END IF;
    END IF;

    #IF (SELECT COUNT(*) FROM ContentReviews WHERE ContentId = PContentId) > 0 THEN
    #    SIGNAL SQLSTATE 'FB011' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '이미 후기를 작성하셨습니다.';
    #END IF;

    INSERT INTO ContentReviews (UserId, ContentId, Content, Rate) 
    VALUES (PUserId, 
        PContentId
        , PContent, PRate);

    SET DReviewId = LAST_INSERT_ID();

    IF DReviewId IS NOT NULL THEN
        IF PImage1 IS NOT NULL AND PImageOriginName1 IS NOT NULL THEN
            INSERT INTO ContentReviewImages (ReviewId, FileName, FilePath, OriginFileName, OrderNum)
            VALUES (DReviewId, PImage1, PImageFilePath, PImageOriginName1, 1);

            IF PImage2 IS NOT NULL AND PImageOriginName2 IS NOT NULL THEN
                INSERT INTO ContentReviewImages (ReviewId, FileName, FilePath, OriginFileName, OrderNum)
                VALUES (DReviewId, PImage2, PImageFilePath, PImageOriginName2, 2);

                IF PImage3 IS NOT NULL AND PImageOriginName3 IS NOT NULL THEN
                    INSERT INTO ContentReviewImages (ReviewId, FileName, FilePath, OriginFileName, OrderNum)
                    VALUES (DReviewId, PImage3, PImageFilePath, PImageOriginName3, 3);

                    IF PImage4 IS NOT NULL AND PImageOriginName4 IS NOT NULL THEN
                        INSERT INTO ContentReviewImages (ReviewId, FileName, FilePath, OriginFileName, OrderNum)
                        VALUES (DReviewId, PImage4, PImageFilePath, PImageOriginName4, 4);

                        IF PImage5 IS NOT NULL AND PImageOriginName5 IS NOT NULL THEN
                            INSERT INTO ContentReviewImages (ReviewId, FileName, FilePath, OriginFileName, OrderNum)
                            VALUES (DReviewId, PImage5, PImageFilePath, PImageOriginName5, 5);
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Post_Review` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Reviews;

DELIMITER $$
CREATE PROCEDURE Get_Reviews(
    IN PUserId INT,
    #IN PContentId INT,
    IN PPage INT,
    IN PMyPage BOOLEAN
)
BEGIN
    DECLARE DContentId INT DEFAULT NULL;

    SELECT Id 
    INTO DContentId
    FROM Contents 
    WHERE IsExpose = TRUE AND TypeNum = 2
    LIMIT 1;

    IF PPage < 1 OR PPage IS NULL THEN
        SET PPage = 1;
    END IF;

    SET PPage = (PPage - 1) * 5;

    SELECT COUNT(*) AS ItemCount FROM ContentReviews
    WHERE ((PMyPage = TRUE AND UserId = PUserId) OR (PMyPage IS NULL OR PMyPage = FALSE)) AND ContentId = DContentId;

    SELECT 
        t.ReviewId, t.Rate, t.UserId, t.UserName, t.Content, 
        cri.FileName AS Image, cri.OrderNum AS OrderNum, t.AdminReply
    FROM (
        SELECT 
            cr.Id AS ReviewId, cr.Rate AS Rate, u.Id AS UserId, u.Name AS UserName, cr.Content AS Content, 
            NULL AS AdminReply
        FROM ContentReviews AS cr
        INNER JOIN Users AS u ON u.Id = cr.UserId
        WHERE ((PMyPage = TRUE AND cr.UserId = PUserId) OR (PMyPage IS NULL OR PMyPage = FALSE)) AND cr.ContentId = DContentId
        ORDER BY cr.Id DESC
        LIMIT PPage, 5
    ) AS t
    LEFT OUTER JOIN ContentReviewImages AS cri ON cri.ReviewId = t.ReviewId
    ORDER BY t.ReviewId DESC, cri.OrderNum ASC;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Reviews` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Need_Reviews;

DELIMITER $$
CREATE PROCEDURE Get_Need_Reviews(
    IN PUserId INT
)
BEGIN
    SELECT i.Title, i.CreatedAt, i.ContentId
    FROM Inquiries AS i
    LEFT OUTER JOIN ContentReviews AS cr ON cr.ContentId = i.ContentId
    WHERE i.TypeNum = 0 AND cr.Id IS NULL;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Need_Reviews` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Get_Review;

DELIMITER $$
CREATE PROCEDURE Get_Review(
    IN PUserId INT,
    IN PReviewId INT
)
BEGIN
    SELECT 
        cr.Id AS ReviewId, 
        cr.Rate AS Rate, 
        u.Id AS UserId, 
        u.Name AS UserName, 
        cr.Content AS Content, 
        cri.FileName AS Image, 
        cri.OrderNum AS OrderNum, 
        NULL AS AdminReply,
        cr.CreatedAt,
        cr.UpdatedAt AS AdminReplyUpdatedAt
    FROM ContentReviews AS cr
    INNER JOIN Users AS u ON u.Id = cr.UserId
    LEFT OUTER JOIN ContentReviewImages AS cri ON cri.ReviewId = cr.Id
    WHERE cr.Id = PReviewId AND cr.ContentId = 1;#41; # PConetntId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Review` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Delete_Review;

DELIMITER $$
CREATE PROCEDURE Delete_Review(
    IN PUserId INT,
    IN PReviewId INT
)
BEGIN
    DECLARE DId INT DEFAULT NULL;

    SELECT Id
    INTO DId
    FROM ContentReviews
    WHERE Id = PReviewId AND UserId = PUserId;

    SELECT * FROM ContentReviewImages
    WHERE ReviewId = DId;

    IF DId IS NULL THEN
        SIGNAL SQLSTATE 'FB011' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '권한이 없습니다.';
    ELSE
        DELETE FROM ContentReviews WHERE Id = DId;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Delete_Review` TO 'fitboa'@'localhost';









###########  Promotions
DROP PROCEDURE IF EXISTS Get_Promotions;

DELIMITER $$
CREATE PROCEDURE Get_Promotions(
    IN PUserId INT
)
BEGIN
    SELECT 
        p.Id AS PromotionId, 
        p.Code AS PromotionCode, 
        p.IsMonthly AS PromotionIsMonthly, 
        p.IsYearly AS PromotionIsYearly,
        p.Name AS PromotionName, 
        pu.CreatedAt AS PromotionDate, 
        IF(p.DiscountType = 0, DiscountPrice, DiscountRate) AS PromotionDiscount, 
        IF(p.DiscountType = 0, '원', '%') AS PromotionDiscountType
    FROM PromotionUsers AS pu
    INNER JOIN Promotions AS p ON p.Id = pu.PromotionId
    WHERE pu.UserId = PUserId AND pu.IsUse = FALSE;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Get_Promotions` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Add_Promotion;

DELIMITER $$
CREATE PROCEDURE Add_Promotion(
    IN PUserId INT,
    IN PPromotionCode VARCHAR(19)
)
BEGIN
    DECLARE DPromotionId INT DEFAULT NULL;

    SELECT Id 
    INTO DPromotionId 
    FROM Promotions 
    WHERE 
        Code = PPromotionCode AND 
        StartDate <= CURRENT_TIMESTAMP AND
        EndDate >= CURRENT_TIMESTAMP;

    IF DPromotionId IS NULL THEN
        SIGNAL SQLSTATE 'FB012' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '프로모션 코드가 존재하지않습니다.';
    END IF;

    IF (SELECT Id FROM PromotionUsers WHERE UserId = PUserId AND PromotionId = DPromotionId) IS NOT NULL THEN
        SIGNAL SQLSTATE 'FB012' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '프로모션 코드를 이미 등록했습니다.';
    END IF;

    INSERT INTO PromotionUsers (UserId, PromotionId) VALUES (PUserId, DPromotionId);
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Add_Promotion` TO 'fitboa'@'localhost';







#source /home/yotoz/Desktop/fitboa/src/migrations/500_procedures.sql

















