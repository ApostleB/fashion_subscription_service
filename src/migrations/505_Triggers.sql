DROP TRIGGER IF EXISTS Insert_Sub;
DROP TRIGGER IF EXISTS Update_Sub;
DROP TRIGGER IF EXISTS Delete_Sub;

DELIMITER $$
CREATE TRIGGER Insert_Sub
AFTER INSERT ON Fitboa.UserMerchants
FOR EACH ROW
BEGIN
    UPDATE Users 
    SET IsSub = IF(
            NEW.PayExt IS NOT NULL AND 
            DATE_ADD(DATE_FORMAT(NEW.PayExt, '%Y-%m-%d'), INTERVAL + 1 DAY) >= CURRENT_TIMESTAMP, 
        TRUE, 
        FALSE
    ) 
    WHERE Id = NEW.UserId;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER Update_Sub
AFTER UPDATE ON Fitboa.UserMerchants
FOR EACH ROW
BEGIN
    IF 
        NEW.PayExt IS NOT NULL AND 
        DATE_ADD(DATE_FORMAT(NEW.PayExt, '%Y-%m-%d'), INTERVAL + 1 DAY) >= CURRENT_TIMESTAMP 
    THEN
        UPDATE Users SET IsSub = TRUE WHERE Id = NEW.UserId;
    ELSE
        UPDATE Users SET IsSub = FALSE WHERE Id = NEW.UserId;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER Delete_Sub
AFTER DELETE ON Fitboa.UserMerchants
FOR EACH ROW
BEGIN
    UPDATE Users SET IsSub = FALSE WHERE Id = OLD.UserId;
END $$
DELIMITER ;
