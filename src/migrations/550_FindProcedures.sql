USE Fitboa;

DROP PROCEDURE IF EXISTS FindUsername_Check_Contact;

DELIMITER $$
CREATE PROCEDURE FindUsername_Check_Contact(
    IN PName VARCHAR(64),
    IN PContact VARCHAR(13)
)
BEGIN
    DECLARE DKey VARCHAR(6) DEFAULT NULL;

    IF PName IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '이름을 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    ELSEIF PContact IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    IF (SELECT Id FROM Users WHERE Name = PName AND Contact = PContact) IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    CALL Create_Verify(PContact, 'FindUsername', DKey);
    SELECT DKey AS 'Key';
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`FindUsername_Check_Contact` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Find_Username;

DELIMITER $$
CREATE PROCEDURE Find_Username(
    IN PName VARCHAR(64), 
    IN PContact VARCHAR(13), 
    IN PVerifyKey VARCHAR(6)
)
BEGIN
    DECLARE DVerifyId INT DEFAULT NULL;

    DECLARE DUsername VARCHAR(128) DEFAULT NULL;
    DECLARE DDI1 VARCHAR(128) DEFAULT '';
    DECLARE DDILen1 INT DEFAULT 0;
    DECLARE DDI2 VARCHAR(128) DEFAULT '';
    DECLARE DDeIdentiUsername VARCHAR(128) DEFAULT '';

    IF PName IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '이름을 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    #check contact
    IF PContact IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    IF (SELECT Id FROM Users WHERE Name = PName AND Contact = PContact) IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    CALL Verify2(PContact, PVerifyKey, 'FindUsername', DVerifyId);

    SELECT Username
    INTO DUsername
    FROM Users
    WHERE Name = PName AND Contact = PContact;

    IF DUsername IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    #De-identification
    #SET DDI1 = SUBSTRING(DUsername, 1, POSITION('@' IN DUsername) - 1);
    #SET DDILen1 = LENGTH(DDI1) / 2;
    #SET DDI2 = SUBSTRING(DUsername, POSITION('@' IN DUsername), LENGTH(DUsername) - LENGTH(DDI1));
#
    #IF DDILen1 < 1 THEN
    #    SET DDILen1 = 1;
    #END IF;
#
    #SET DDeIdentiUsername = CONCAT(
    #    SUBSTRING(DDI1, 1, DDILen1),
    #    REPEAT('*', LENGTH(DDI1) - DDILen1),
    #    DDI2
    #);

    #SELECT DDeIdentiUsername AS Username;
    #De-identification End

    SELECT DUsername AS Username;

    CALL Use_Verify(DVerifyId);
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Find_Username` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Verify2;

DELIMITER $$
CREATE PROCEDURE Verify2(
    IN PContact VARCHAR(13),
    IN PKey VARCHAR(6),
    IN PType VARCHAR(32),
    OUT PVerifyId INT
)
BEGIN
    DECLARE DId INT DEFAULT NULL;
    DECLARE DVerifyCount INT DEFAULT NULL;
    DECLARE DVerifyTimeout BOOLEAN DEFAULT NULL;
    DECLARE DKey VARCHAR(6) DEFAULT NULL;

    #IF PId IS NULL THEN
    #    SIGNAL SQLSTATE 'FB003' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '잠시 후 다시 시도해주세요.';
    IF PContact IS NULL THEN
        #SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    ELSEIF PKey IS NULL THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '인증정보를 다시 확인해주세요.';
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
        SET PVerifyId = DId;
    END IF;
END $$
DELIMITER ;

#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Verify2` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Create_Verify2;

DELIMITER $$
CREATE PROCEDURE Create_Verify2(
    IN PContact VARCHAR(13),
    IN PType VARCHAR(32),
    IN PUserId INT, 
    OUT PKey VARCHAR(6)
)
BEGIN
    DECLARE DVerifyKey VARCHAR(6) DEFAULT SUBSTRING(CONCAT('', RAND()), 3, 6);

    IF PContact IS NULL THEN
        #SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    INSERT INTO VerifyLogs (Contact, Type, VerifyKey, UserId) VALUES (PContact, PType, DVerifyKey, PUserId);

    SET PKey = DVerifyKey;
END $$
DELIMITER ;

#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Create_Verify2` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS FindPassword_Check_Username;

DELIMITER $$
CREATE PROCEDURE FindPassword_Check_Username(
    IN PUsername VARCHAR(128)
)
BEGIN
    IF (SELECT Id FROM Users WHERE Username = PUsername) IS NULL THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10008, MESSAGE_TEXT = '등록되지 않은 아이디입니다.';
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`FindPassword_Check_Username` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS FindPassword_Check_Contact;

DELIMITER $$
CREATE PROCEDURE FindPassword_Check_Contact(
    IN PUsername VARCHAR(128), 
    IN PName VARCHAR(64), 
    IN PContact VARCHAR(13)
)
BEGIN
    DECLARE DKey VARCHAR(6) DEFAULT NULL;
    DECLARE DUserId INT DEFAULT NULL;

    IF PUsername IS NULL THEN 
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '아이디를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    ELSEIF PName IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '이름을 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    ELSEIF PContact IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    SELECT Id 
    INTO DUserId
    FROM Users 
    WHERE Username = PUsername AND Name = PName AND Contact = PContact;

    IF DUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    CALL Create_Verify2(PContact, 'FindPassword', DUserId, DKey);
    SELECT DKey AS 'Key';
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`FindPassword_Check_Contact` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Verify3;

DELIMITER $$
CREATE PROCEDURE Verify3(
    IN PContact VARCHAR(13),
    IN PKey VARCHAR(6),
    IN PType VARCHAR(32),
    IN PUserId INT, 
    OUT PVerifyId INT
)
BEGIN
    DECLARE DId INT DEFAULT NULL;
    DECLARE DVerifyCount INT DEFAULT NULL;
    DECLARE DVerifyTimeout BOOLEAN DEFAULT NULL;
    DECLARE DKey VARCHAR(6) DEFAULT NULL;

    #IF PId IS NULL THEN
    #    SIGNAL SQLSTATE 'FB003' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '잠시 후 다시 시도해주세요.';
    IF PContact IS NULL THEN
        #SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    ELSEIF PKey IS NULL THEN
        #SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '인증번호를 입력해주세요.';
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '인증정보를 다시 확인해주세요.';
    END IF;

    SELECT Id, VerifyCount, VerifyTimeout >= CURRENT_TIMESTAMP, VerifyKey
    INTO DId, DVerifyCount, DVerifyTimeout, DKey
    FROM VerifyLogs
    WHERE Contact = PContact AND Type = PType AND IsVerified = FALSE AND IsUsed = FALSE AND UserId = PUserId
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
        SET PVerifyId = DId;
    END IF;
END $$
DELIMITER ;

#GRANT EXECUTE ON PROCEDURE `Fitboa`.`Verify3` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Find_Password;

DELIMITER $$
CREATE PROCEDURE Find_Password(
    IN PUsername VARCHAR(128), 
    IN PName VARCHAR(64), 
    IN PContact VARCHAR(13), 
    IN PVerifyKey VARCHAR(6)
)
BEGIN
    DECLARE DVerifyId INT DEFAULT NULL;

    DECLARE DUsername VARCHAR(128) DEFAULT NULL;
    DECLARE DDI1 VARCHAR(128) DEFAULT '';
    DECLARE DDILen1 INT DEFAULT 0;
    DECLARE DDI2 VARCHAR(128) DEFAULT '';
    DECLARE DDeIdentiUsername VARCHAR(128) DEFAULT '';

    DECLARE DUserId INT DEFAULT NULL;


    IF PUsername IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '아이디를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    IF PName IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '이름을 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    #check contact
    IF PContact IS NULL THEN
        #SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10007, MESSAGE_TEXT = '휴대번호를 입력해주세요.';
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    SELECT Id 
    INTO DUserId
    FROM Users 
    WHERE Username = PUsername AND Name = PName AND Contact = PContact;

    IF DUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    CALL Verify3(PContact, PVerifyKey, 'FindPassword', DUserId, DVerifyId);

    SELECT Username
    INTO DUsername
    FROM Users
    WHERE Username = PUsername AND Name = PName AND Contact = PContact;

    IF DUsername IS NULL THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10010, MESSAGE_TEXT = '등록되지 않은 회원정보입니다.';
    END IF;

    SELECT DVerifyId AS VerifyId;

    #CALL Use_Verify(DVerifyId);
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Find_Password` TO 'fitboa'@'localhost';





DROP PROCEDURE IF EXISTS Change_Password;

DELIMITER $$
CREATE PROCEDURE Change_Password(
    IN PVerifyId INT,
    IN PNewPassword VARCHAR(512)
)
BEGIN
    DECLARE DIsUsed BOOLEAN DEFAULT NULL;
    DECLARE DType VARCHAR(32) DEFAULT NULL;
    DECLARE DUpdatedAt TIMESTAMP DEFAULT NULL;

    DECLARE DUserId INT DEFAULT NULL;

    SELECT IsUsed, Type, UpdatedAt, UserId
    INTO DIsUsed, DType, DUpdatedAt, DUserId
    FROM VerifyLogs 
    WHERE Id = PVerifyId;

    IF DIsUsed IS NULL THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '인증정보가 유효하지않습니다.';
    ELSEIF DIsUsed = TRUE THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10006, MESSAGE_TEXT = '인증정보가 만료되었습니다.';
    ELSEIF DType IS NULL OR DType != 'FindPassword' THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '인증정보가 유효하지않습니다.';
    ELSEIF DUpdatedAt > DATE_ADD(CURRENT_TIMESTAMP, INTERVAL + 30 MINUTE) THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10006, MESSAGE_TEXT = '인증정보가 만료되었습니다.';
    ELSEIF DUserId IS NULL THEN
        SIGNAL SQLSTATE 'FB002' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '인증정보가 유효하지않습니다.';
    END IF;

    UPDATE Users SET Password = PNewPassword WHERE Id = DUserId;

    CALL Use_Verify(PVerifyId);
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Change_Password` TO 'fitboa'@'localhost';
