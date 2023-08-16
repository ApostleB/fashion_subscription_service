USE Fitboa;
DROP TABLE IF EXISTS Users;
CREATE TABLE IF NOT EXISTS Users
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    Name VARCHAR(64) NOT NULL,

    Username VARCHAR(128) NOT NULL,
    Password VARCHAR(512) NOT NULL,
    PasswordUpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Password6MonthSetting BOOLEAN NOT NULL DEFAULT FALSE,

    Contact VARCHAR(13) NOT NULL UNIQUE,

    #Address VARCHAR(256) NOT NULL,
    RoadAddress VARCHAR(256) NOT NULL,
    JibunAddress VARCHAR(256) NOT NULL,
    ExtraAddress VARCHAR(256) NULL,
    PostCode VARCHAR(5) NOT NULL,
    AddressType VARCHAR(6) NOT NULL,

    UseTerm BOOLEAN NOT NULL DEFAULT FALSE,
    UseTermTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PrivateTerm BOOLEAN NOT NULL DEFAULT FALSE,
    PrivateTermTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    EmailTerm BOOLEAN NOT NULL DEFAULT FALSE,
    SMSTerm BOOLEAN NOT NULL DEFAULT FALSE,

    #temporary permission
    IsSub BOOLEAN DEFAULT FALSE,

    BodyType INT NULL,
    BodyTypeUpdatedAt TIMESTAMP NULL,

    IsAdmin BOOLEAN NOT NULL DEFAULT FALSE,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

INSERT INTO Users (
    Name, Username, Password, PasswordUpdatedAt, Password6MonthSetting, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType, 
    UseTerm, UseTermTime, PrivateTerm, PrivateTermTime, EmailTerm, SMSTerm, IsSub, BodyType, CreatedAt, UpdatedAt, IsAdmin
)
VALUES (
    'Admin', 'boaAdmin', '123', '2022-02-03 22:20:27', 0, '010-0000-0000', 'test test', 'test test', 'test test', '01234', '도로명', 1, '2022-02-03 22:20:27', 
    1, '2022-02-03 22:20:27', 1, 1, 1, 1, '2022-02-03 22:20:27', '2022-02-03 22:22:11', 1
);

INSERT INTO Users (
    Name, Username, Password, PasswordUpdatedAt, Password6MonthSetting, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType, 
    UseTerm, UseTermTime, PrivateTerm, PrivateTermTime, EmailTerm, SMSTerm, IsSub, BodyType, CreatedAt, UpdatedAt
)
VALUES (
    'Fitboa', 'fitboa', '123', '2022-02-03 22:20:27', 0, '010-0000-0001', 'test test', 'test test', 'test test', '01234', '도로명', 1, '2022-02-03 22:20:27', 
    1, '2022-02-03 22:20:27', 1, 1, 1, 1, '2022-02-03 22:20:27', '2022-02-03 22:22:11'
);

INSERT INTO Users (
    Name, Username, Password, PasswordUpdatedAt, Password6MonthSetting, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType, 
    UseTerm, UseTermTime, PrivateTerm, PrivateTermTime, EmailTerm, SMSTerm, IsSub, CreatedAt, UpdatedAt
)
VALUES (
    'test', 'test', '123', '2022-02-03 22:20:27', 0, '010-0000-0002', 'test test', 'test test', 'test test', '01234', '도로명', 1, '2022-02-03 22:20:27', 
    1, '2022-02-03 22:20:27', 1, 1, 1, '2022-02-03 22:20:27', '2022-02-03 22:22:11'
);

INSERT INTO Users (
    Name, Username, Password, PasswordUpdatedAt, Password6MonthSetting, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType, 
    UseTerm, UseTermTime, PrivateTerm, PrivateTermTime, EmailTerm, SMSTerm, IsSub, CreatedAt, UpdatedAt
)
VALUES (
    'test2', 'test2', '123', '2022-02-03 22:21:39', 0, '010-0000-0003', 'test test', 'test test', 'test test', '01234', '도로명', 1, '2022-02-03 22:21:39', 
    1, '2022-02-03 22:21:39', 1, 1, 0, '2022-02-03 22:21:39', '2022-02-03 22:21:39'
);

INSERT INTO Users (
    Name, Username, Password, PasswordUpdatedAt, Password6MonthSetting, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType, 
    UseTerm, UseTermTime, PrivateTerm, PrivateTermTime, EmailTerm, SMSTerm, IsSub, CreatedAt, UpdatedAt
)
VALUES (
    'jbu', 'jbu', 'password', '2022-02-05 04:49:17', 0, '010-5099-1699', 'test test', 'test test', 'test test', '01234', '도로명', 1, '2022-02-05 04:49:17', 
    1, '2022-02-05 04:49:17', 1, 1, 0, '2022-02-05 04:49:17', '2022-02-05 04:49:17'
);