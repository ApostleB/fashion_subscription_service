###########  Contents
DROP PROCEDURE IF EXISTS Admin_Post_Content;

DELIMITER $$
CREATE PROCEDURE Admin_Post_Content(
    IN PTitle VARCHAR(256),
    IN PAuthorId INT,
    IN PBodyType INT,
    IN PThreshold INT,
    IN PType VARCHAR(15)
)
BEGIN
    DECLARE DTypeNum INT DEFAULT NULL;
    DECLARE DAuthor VARCHAR(64) DEFAULT NULL;

    #작성자 아이디 검사
    IF PAuthorId IS NULL THEN
        SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '권한이 없습니다.';
    ELSE
        SELECT Name 
        INTO DAuthor
        FROM Users
        WHERE IsAdmin = TRUE AND Id = PAuthorId;

        IF DAuthor IS NULL THEN
            SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '권한이 없습니다.';
        END IF;
    END IF;

    #조건 확인
    IF PTitle IS NULL OR TRIM(PTitle) = '' THEN
        SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '제목을 입력해주세요.';
    END IF;

    #IF PAuthor IS NULL OR TRIM(PAuthor) = '' THEN
    #    SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '작성자를 입력해주세요.';
    #END IF;

    IF PType = '스토리' THEN
        SET DTypeNum = 0;
        IF PBodyType < 0 OR PBodyType > 5 THEN
            #바디타입 범위 벗어남
            SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '체형을 선택해주세요.';
        END IF;
    ELSEIF PType = '스타일링 가이드' THEN
        SET DTypeNum = 1;
        IF PBodyType < 1 OR PBodyType > 5 THEN
            #바디타입 범위 벗어남
            SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10003, MESSAGE_TEXT = '체형을 선택해주세요.';
        END IF;
    ELSE
        #타입 입력 잘못함
        SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '게시글의 타입을 선택해주세요.';
    END IF;

    IF PThreshold < 0 THEN
        SET PThreshold = 0;
    END IF;
    ##

    INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum, IsExpose) 
    VALUES (PTitle, DAuthor, PAuthorId, PThreshold, PBodyType, PType, DTypeNum, FALSE);

    SELECT LAST_INSERT_ID() AS ContentId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Admin_Post_Content` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Admin_Post_Content_Image;

DELIMITER $$
CREATE PROCEDURE Admin_Post_Content_Image(
    IN PContentId INT,
    IN POriginFileName VARCHAR(256),
    IN PFileName VARCHAR(256),
    IN PFilePath VARCHAR(256),
    IN PIsThumbnail BOOLEAN
)
BEGIN
    DECLARE DPrevOrderNum INT DEFAULT NULL;
    DECLARE DId INT DEFAULT NULL;
    DECLARE DThumbnailId INT DEFAULT NULL;

    #조건 확인
    SELECT Id
    INTO DId
    FROM ContentImages
    WHERE FileName = PFileName AND FilePath = PFilePath;

    IF DId IS NOT NULL THEN
        SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10005, MESSAGE_TEXT = '이미지 업로드 에러';
    END IF;
    ##

    SELECT MAX(OrderNum)
    INTO DPrevOrderNum
    FROM ContentImages
    WHERE ContentId = PContentId;

    IF PIsThumbnail = TRUE THEN
        SET DPrevOrderNum = 0;

        SELECT Id
        INTO DThumbnailId
        FROM ContentImages
        WHERE ContentId = PContentId AND IsThumbnail = TRUE AND OrderNum = 0;
    ELSE
        IF DPrevOrderNum IS NULL THEN
            SET DPrevOrderNum = 1;
        ELSE
            SET DPrevOrderNum = DPrevOrderNum + 1;
        END IF;
    END IF;

    IF DThumbnailId IS NOT NULL THEN
        UPDATE ContentImages SET FileName = PFileName, FilePath = PFilePath, OriginFileName = POriginFileName WHERE Id = DThumbnailId;
    ELSE
        INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail) 
        VALUES (PContentId, PFileName, PFilePath, POriginFileName, DPrevOrderNum, IF(PIsThumbnail = TRUE, TRUE, FALSE));
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Admin_Post_Content_Image` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Admin_Post_Content_End;

DELIMITER $$
CREATE PROCEDURE Admin_Post_Content_End(
    IN PContentId INT
)
BEGIN
    UPDATE Contents SET IsExpose = TRUE WHERE Id = PContentId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Admin_Post_Content_End` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Admin_Delete_Content;

DELIMITER $$
CREATE PROCEDURE Admin_Delete_Content(
    IN PContentId INT
)
BEGIN
    DELETE FROM Contents WHERE Id = PContentId;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Admin_Delete_Content` TO 'fitboa'@'localhost';




DROP PROCEDURE IF EXISTS Admin_Change_Content_Image_OrderNum;

DELIMITER $$
CREATE PROCEDURE Admin_Change_Content_Image_OrderNum(
    IN PSrcId INT,
    IN PDstId INT
)
BEGIN
    #PSrcId 이동 할 이미지의 아이디
    #PDstId 이동 할 위치의 전 이미지
    ##PDstId를 NULL로 줄 경우 제일 처음 위치로

    DECLARE DSrcOrderNum INT DEFAULT NULL;
    DECLARE DDstOrderNum INT DEFAULT NULL;

    DECLARE DContentId INT DEFAULT NULL;
    #조건 확인
    IF PSrcId = PDstId THEN 
        #입력 값 잘못 들어온 듯
        SELECT 'TEMPORARY FAIL MESSAGE: PSrcId = PDstId' AS Message;
    END IF;
    ##

    SELECT OrderNum, ContentId
    INTO DSrcOrderNum, DContentId
    FROM ContentImages
    WHERE Id = PSrcId;

    IF DContentId IS NULL THEN
        #잘못된 아이디 값임
        SELECT 'TEMPORARY FAIL MESSAGE: DContentId IS NULL' AS Message;
    ELSEIF DSrcOrderNum IS NULL THEN
        #잘못된 아이디 값임
        SELECT 'TEMPORARY FAIL MESSAGE: DSrcOrderNum IS NULL' AS Message;
    ELSEIF DSrcOrderNum = 0 THEN
        #썸네일은 못 옮김
        SELECT 'TEMPORARY FAIL MESSAGE: DSrcOrderNum = 0' AS Message;
    END IF;

    IF PDstId IS NULL THEN
        SET DDstOrderNum = 0;
    ELSE 
        SELECT OrderNum
        INTO DDstOrderNum
        FROM ContentImages
        WHERE Id = PDstId AND DContentId = ContentId;

        IF DDstOrderNum IS NULL THEN
            #잘못된 아이디 값임 OR 다른 글의 이미지 아이디 불러옴
            SELECT 'TEMPORARY FAIL MESSAGE: DDstOrderNum IS NULL' AS Message;
        END IF;
    END IF;

    IF DSrcOrderNum < DDstOrderNum THEN
        UPDATE ContentImages SET OrderNum = OrderNum - 1 
        WHERE OrderNum > DSrcOrderNum AND OrderNum <= DDstOrderNum;

        UPDATE ContentImages SET OrderNum = DDstOrderNum
        WHERE Id = PSrcId;
    ELSEIF DSrcOrderNum > DDstOrderNum THEN
        UPDATE ContentImages SET OrderNum = OrderNum + 1
        WHERE OrderNum > DDstOrderNum AND OrderNum < DSrcOrderNum;

        UPDATE ContentImages SET OrderNum = DDstOrderNum + 1
        WHERE Id = PSrcId;
    END IF;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Admin_Change_Content_Image_OrderNum` TO 'fitboa'@'localhost';









########### CustomerServices
DROP PROCEDURE IF EXISTS Post_Customer_Services;

DELIMITER $$
CREATE PROCEDURE Post_Customer_Services(
    IN PAdminId INT,
    IN PType VARCHAR(8),
    IN PTitle VARCHAR(256),
    IN PContent VARCHAR(2048)
)
BEGIN
    DECLARE DTypeNum INT DEFAULT NULL;

    IF (SELECT COUNT(*) FROM Users WHERE Id = PAdminId AND IsAdmin = TRUE) <= 0 THEN
        SIGNAL SQLSTATE 'FB100' SET MYSQL_ERRNO=10004, MESSAGE_TEXT = '권한이 없습니다.';
    END IF;

    IF PTitle IS NULL OR TRIM(PTitle) = '' THEN
        SIGNAL SQLSTATE 'FB009' SET MYSQL_ERRNO=10001, MESSAGE_TEXT = '제목을 입력해주세요.';
    END IF;

    IF PContent IS NULL OR TRIM(PContent) = '' THEN
        SIGNAL SQLSTATE 'FB009' SET MYSQL_ERRNO=10002, MESSAGE_TEXT = '내용을 입력해주세요.';
    END IF;

    IF PType = '공지사항' THEN
        SET DTypeNum = 0;
    ELSEIF PType = 'FAQ' THEN
        SET DTypeNum = 1;
    ELSE
        SIGNAL SQLSTATE 'FB009' SET MYSQL_ERRNO=10000, MESSAGE_TEXT = '항목을 선택해주세요.';
    END IF;

    INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum)
    VALUES (PAdminId, PTitle, PContent, PType, DTypeNum);
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`Post_Customer_Services` TO 'fitboa'@'localhost';









########### Promotions
DROP PROCEDURE IF EXISTS TEST_Add_Promotion;

DELIMITER $$
CREATE PROCEDURE TEST_Add_Promotion(
    IN PName VARCHAR(256)
)
BEGIN
    DECLARE DCode VARCHAR(19) DEFAULT '';

    DECLARE DMD5T VARCHAR(32) DEFAULT NULL;
    DECLARE DUUID VARCHAR(36) DEFAULT NULL;

    DECLARE i INT DEFAULT 1;

    DECLARE MAX_WHILE_COUNT INT DEFAULT 999;

    WHILE (i < MAX_WHILE_COUNT) DO
        SET DMD5T = MD5(CURRENT_TIMESTAMP + i);
        SET DUUID = UUID();

        SET DCode = CONCAT(
            SUBSTRING(DMD5T,1,4),'-',
            SUBSTRING(DUUID,1,4),'-',
            SUBSTRING(DUUID,5,4),'-',
            SUBSTRING(DMD5T,13,4)
        );

        SET DCode = UPPER(DCode);

        IF (SELECT Id FROM Promotions WHERE Code = DCode) IS NOT NULL THEN
            SET i = MAX_WHILE_COUNT + 1;
        END IF;

        SET i = i + 1;
    END WHILE;

    IF i = MAX_WHILE_COUNT + 1 THEN
        SIGNAL SQLSTATE 'FB000' SET MYSQL_ERRNO=10011, MESSAGE_TEXT = '잠시 후 다시 시도해주세요.';
    END IF;

    INSERT INTO Promotions (
        Name,
        Code,
        #ProductId,
        IsMonthly,
        IsYearly,
        DiscountType,
        DiscountRate,
        DiscountPrice,
        StartDate,
        EndDate
    ) VALUES ( 
        PName,
        DCode,
        #1,
        TRUE,
        FALSE,
        1, 
        10,
        NULL,
        '2022-04-01',
        '2023-04-01'
    );
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE `Fitboa`.`TEST_Add_Promotion` TO 'fitboa'@'localhost';
