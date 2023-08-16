USE Fitboa;
DROP TABLE IF EXISTS CustomerServices;
CREATE TABLE IF NOT EXISTS CustomerServices
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    Title VARCHAR(256) NOT NULL,
    Content VARCHAR(2048) NOT NULL,

    AdminId INT NOT NULL,

    Type VARCHAR(8) NOT NULL DEFAULT '공지사항',
    TypeNum INT NOT NULL DEFAULT 0, #0: 공지사항, 1: FAQ

    Status BOOLEAN NOT NULL DEFAULT TRUE, 

    Views INT NOT NULL DEFAULT 0,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(AdminId) REFERENCES Users(Id) ON DELETE CASCADE
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title1', 'Content1', 'FAQ', 1);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title11', 'Content11', '공지사항', 0);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title2', 'Content2', 'FAQ', 1);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title22', 'Content22', '공지사항', 0);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title3', 'Content3', 'FAQ', 1);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title4', 'Content4', 'FAQ', 1);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title5', 'Content5', 'FAQ', 1);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title6', 'Content6', 'FAQ', 1);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title33', 'Content33', '공지사항', 0);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title44', 'Content44', '공지사항', 0);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title55', 'Content55', '공지사항', 0);

INSERT INTO CustomerServices (AdminId, Title, Content, Type, TypeNum) 
VALUES (1, 'Title66', 'Content66', '공지사항', 0);