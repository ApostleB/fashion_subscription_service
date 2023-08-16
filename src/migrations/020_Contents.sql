USE Fitboa;
DROP TABLE IF EXISTS Contents;
CREATE TABLE IF NOT EXISTS Contents
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    Title VARCHAR(256) NOT NULL,
    Author VARCHAR(64) NULL,
    AuthorId INT NOT NULL,

    Threshold INT NOT NULL,

    BodyType INT NOT NULL Comment '0: all, 1: a, ~, 5: e',

    Type VARCHAR(15) NOT NULL DEFAULT '스토리', #스토리, 스타일링 가이드, 1:1 스타일링
    TypeNum INT NOT NULL DEFAULT 0, #스토리: 0, 스타일링 가이드: 1, 1:1 스타일링: 2

    Views INT DEFAULT 0,

    IsExpose BOOLEAN DEFAULT TRUE,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;
 
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('콘텐츠 제목이 노출 됩니다. ALL 긴 제목 ... 처리', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('콘텐츠 제목이 노출 됩니다. A 긴 제목 ... 처리', '황솔루션', 1, 3, 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('콘텐츠 제목이 노출 됩니다. B 긴 제목 ... 처리', '황솔루션', 1, 3, 2);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('콘텐츠 제목이 노출 됩니다. ALL 긴 제목 ... 처리2', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('곧 다가올 봄 준비', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄에 입을옷이 없다면?', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄 여름 가을 겨울 계절별 패션', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('올 여름 패션', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('여름엔 이렇게!', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('여름엔 이렇게!2', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('여름엔 이렇게!3', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄 여름엔 이렇게!', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄엔 이렇게!', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄엔 이렇게!2', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('여름엔 이렇게!4', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('여름엔 이렇게!5', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄엔 이렇게!3', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄엔 이렇게!4', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄엔 이렇게!5', '황솔루션', 1, 3, 0);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType) 
#VALUES ('봄봄봄봄', '황솔루션', 1, 3, 0);
#
#
#
#
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s콘텐츠 제목이 노출 됩니다. ALL 긴 제목 ... 처리', '황솔루션', 1, 3, 1, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s콘텐츠 제목이 노출 됩니다. A 긴 제목 ... 처리', '황솔루션', 1, 3, 1, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s콘텐츠 제목이 노출 됩니다. B 긴 제목 ... 처리', '황솔루션', 1, 3, 2, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s콘텐츠 제목이 노출 됩니다. ALL 긴 제목 ... 처리2', '황솔루션', 1, 3, 2, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s곧 다가올 봄 준비', '황솔루션', 1, 3, 3, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄에 입을옷이 없다면?', '황솔루션', 1, 3, 3, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄 여름 가을 겨울 계절별 패션', '황솔루션', 1, 3, 4, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s올 여름 패션', '황솔루션', 1, 3, 4, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s여름엔 이렇게!', '황솔루션', 1, 3, 5, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s여름엔 이렇게!2', '황솔루션', 1, 3, 5, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s여름엔 이렇게!3', '황솔루션', 1, 3, 1, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄 여름엔 이렇게!', '황솔루션', 1, 3, 2, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄엔 이렇게!', '황솔루션', 1, 3, 3, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄엔 이렇게!2', '황솔루션', 1, 3, 4, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s여름엔 이렇게!4', '황솔루션', 1, 3, 5, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s여름엔 이렇게!5', '황솔루션', 1, 3, 1, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄엔 이렇게!3', '황솔루션', 1, 3, 2, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄엔 이렇게!4', '황솔루션', 1, 3, 3, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄엔 이렇게!5', '황솔루션', 1, 3, 4, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('s봄봄봄봄', '황솔루션', 1, 3, 5, '스타일링 가이드', 1);
#
#INSERT INTO Contents (Title, Author, AuthorId, Threshold, BodyType, Type, TypeNum) 
#VALUES ('1:1 스타일링', '황솔루션', 1, 0, 0, '1:1 스타일링', 2);
#41




INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (1, '1:1 스타일링', '황솔루션', 1, 0, 0, '1:1 스타일링', 2, 0, 1, '2022-04-02 02:02:26', '2022-04-02 02:02:26');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (2, '영화 속 남자들의 하금테(무)', 'Admin', 1, 10, 0, '스토리', 0, 4, 1, '2022-04-03 21:17:28', '2022-04-04 05:38:32');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (4, '겨울 포멀룩 코디(무)', 'Admin', 1, 16, 0, '스토리', 0, 0, 1, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (5, '겨울 캐주얼룩 코디', 'Admin', 1, 17, 0, '스토리', 0, 1, 1, '2022-04-03 21:51:51', '2022-04-03 22:01:15');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (6, '겨울 포멀룩 코디(O형/무)', 'Admin', 1, 17, 0, '스토리', 0, 3, 1, '2022-04-04 00:35:18', '2022-04-04 05:38:47');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (7, '겨울 캐주얼룩 코디(O형/무)', 'Admin', 1, 17, 0, '스토리', 0, 1, 1, '2022-04-04 00:38:43', '2022-04-04 00:48:28');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (8, '겨울 포멀룩 코디 2월 (I형/무)', 'Admin', 1, 17, 0, '스토리', 0, 0, 1, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (9, '겨울 캐주얼룩 코디 2월(I형/유)', 'Admin', 1, 17, 0, '스토리', 0, 3, 1, '2022-04-04 00:43:12', '2022-04-04 05:38:20');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (10, '겨울 포멀룩 코디 2월(O형/무)', 'Admin', 1, 17, 0, '스토리', 0, 2, 1, '2022-04-04 00:44:55', '2022-04-04 05:38:15');

INSERT INTO `Contents` (`Id`, `Title`, `Author`, `AuthorId`, `Threshold`, `BodyType`, `Type`, `TypeNum`, `Views`, `IsExpose`, `CreatedAt`, `UpdatedAt`) 
VALUES (11, '겨울 캐주얼룩 코디 2월(O형/유)', 'Admin', 1, 17, 0, '스토리', 0, 7, 1, '2022-04-04 00:47:51', '2022-04-04 03:44:34');

