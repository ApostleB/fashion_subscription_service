USE Fitboa;
DROP TABLE IF EXISTS InquiryImages;
CREATE TABLE IF NOT EXISTS InquiryImages
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    InquiryId INT NOT NULL,
    FileName VARCHAR(256) NOT NULL,
    FilePath VARCHAR(256) NOT NULL,

    OriginFileName VARCHAR(256) NOT NULL,

    OrderNum INT NOT NULL,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(InquiryId) REFERENCES Inquiries(Id) ON DELETE CASCADE
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;