USE Fitboa;
DROP TABLE IF EXISTS ContentImages;
CREATE TABLE IF NOT EXISTS ContentImages
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    ContentId INT NOT NULL,
    FileName VARCHAR(256) NOT NULL,
    FilePath VARCHAR(256) NOT NULL,

    OriginFileName VARCHAR(256) NOT NULL,

    OrderNum INT NOT NULL,

    IsThumbnail BOOLEAN NOT NULL DEFAULT FALSE,

    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(ContentId) REFERENCES Contents(Id) ON DELETE CASCADE
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '5c3c434750bb77fe2cf77332aa7f20db', 'uploads/', '0.Thumnail.png', 0, 1, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, 'c172b85428cf75943f4729bb0be863df', 'uploads/', '1.jpg', 1, 0, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, 'fe2f2f30dce7bb8f6601c50db360f980', 'uploads/', '2.jpg', 2, 0, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '3cb3f2cd05b32a0b5fddf8f89ad678f3', 'uploads/', '3.jpg', 3, 0, '2022-02-06 23:25:27', '2022-02-06 23:54:04');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '2f9ecf8b99109c19cf02d4cbce288917', 'uploads/', '4.jpg', 4, 0, '2022-02-06 23:25:27', '2022-02-06 23:54:29');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, 'e47f62d71d29f672df536dedc7124940', 'uploads/', '5.jpg', 5, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '60ffd4c85ed3d2c3372b5af08d137f94', 'uploads/', '6.jpg', 6, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '35e1de00b926709b79892c3560cbeecd', 'uploads/', '7.jpg', 7, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '2aafc33dbe5715b42217302d88a59fb5', 'uploads/', '8.jpg', 8, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '22e356956ca656fb44025b29fc12f7a3', 'uploads/', '9.jpg', 9, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '4e1024039806678ff9913e6a235a681c', 'uploads/', '10.jpg', 10, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '0296eeac9f30b5fd2498b200c7b3d18b', 'uploads/', '11.jpg', 11, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '07c33cb8a48db1ff24bbbcdf8e4e43a2', 'uploads/', '12.jpg', 12, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '7908a650b747e50e1302ed8758e9c1c1', 'uploads/', '13.jpg', 13, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '0ebfe88c5298757596b82748c50b9464', 'uploads/', '14.jpg', 14, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, 'd0d13def1f383fa466dcc7805ce2c807', 'uploads/', '15.jpg', 15, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, 'c68b92d77d49bbf65e5eefe5fc0ddb6e', 'uploads/', '16.jpg', 16, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (1, '38645546ffc3981089488de5b4192239', 'uploads/', '17.jpg', 17, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#
#
#
#
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '5c3c434750bb77fe2cf77332aa7f20db01', 'uploads/', '0.Thumnail.png', 0, 1, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, 'c172b85428cf75943f4729bb0be863df01', 'uploads/', '1.jpg', 1, 0, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, 'fe2f2f30dce7bb8f6601c50db360f98001', 'uploads/', '2.jpg', 2, 0, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '3cb3f2cd05b32a0b5fddf8f89ad678f301', 'uploads/', '3.jpg', 3, 0, '2022-02-06 23:25:27', '2022-02-06 23:54:04');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '2f9ecf8b99109c19cf02d4cbce28891701', 'uploads/', '4.jpg', 4, 0, '2022-02-06 23:25:27', '2022-02-06 23:54:29');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, 'e47f62d71d29f672df536dedc712494001', 'uploads/', '5.jpg', 5, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '60ffd4c85ed3d2c3372b5af08d137f9401', 'uploads/', '6.jpg', 6, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '35e1de00b926709b79892c3560cbeecd01', 'uploads/', '7.jpg', 7, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '2aafc33dbe5715b42217302d88a59fb501', 'uploads/', '8.jpg', 8, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '22e356956ca656fb44025b29fc12f7a301', 'uploads/', '9.jpg', 9, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '4e1024039806678ff9913e6a235a681c01', 'uploads/', '10.jpg', 10, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '0296eeac9f30b5fd2498b200c7b3d18b01', 'uploads/', '11.jpg', 11, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '07c33cb8a48db1ff24bbbcdf8e4e43a201', 'uploads/', '12.jpg', 12, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '7908a650b747e50e1302ed8758e9c1c101', 'uploads/', '13.jpg', 13, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '0ebfe88c5298757596b82748c50b946401', 'uploads/', '14.jpg', 14, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, 'd0d13def1f383fa466dcc7805ce2c80701', 'uploads/', '15.jpg', 15, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, 'c68b92d77d49bbf65e5eefe5fc0ddb6e01', 'uploads/', '16.jpg', 16, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (2, '38645546ffc3981089488de5b419223901', 'uploads/', '17.jpg', 17, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#
#
#
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '5c3c434750bb77fe2cf77332aa7f20db02', 'uploads/', '0.Thumnail.png', 0, 1, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, 'c172b85428cf75943f4729bb0be863df02', 'uploads/', '1.jpg', 1, 0, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, 'fe2f2f30dce7bb8f6601c50db360f98002', 'uploads/', '2.jpg', 2, 0, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '3cb3f2cd05b32a0b5fddf8f89ad678f302', 'uploads/', '3.jpg', 3, 0, '2022-02-06 23:25:27', '2022-02-06 23:54:04');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '2f9ecf8b99109c19cf02d4cbce28891702', 'uploads/', '4.jpg', 4, 0, '2022-02-06 23:25:27', '2022-02-06 23:54:29');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, 'e47f62d71d29f672df536dedc712494002', 'uploads/', '5.jpg', 5, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '60ffd4c85ed3d2c3372b5af08d137f9402', 'uploads/', '6.jpg', 6, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '35e1de00b926709b79892c3560cbeecd02', 'uploads/', '7.jpg', 7, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '2aafc33dbe5715b42217302d88a59fb502', 'uploads/', '8.jpg', 8, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '22e356956ca656fb44025b29fc12f7a302', 'uploads/', '9.jpg', 9, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '4e1024039806678ff9913e6a235a681c02', 'uploads/', '10.jpg', 10, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '0296eeac9f30b5fd2498b200c7b3d18b02', 'uploads/', '11.jpg', 11, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '07c33cb8a48db1ff24bbbcdf8e4e43a202', 'uploads/', '12.jpg', 12, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '7908a650b747e50e1302ed8758e9c1c102', 'uploads/', '13.jpg', 13, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '0ebfe88c5298757596b82748c50b946402', 'uploads/', '14.jpg', 14, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, 'd0d13def1f383fa466dcc7805ce2c80702', 'uploads/', '15.jpg', 15, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, 'c68b92d77d49bbf65e5eefe5fc0ddb6e02', 'uploads/', '16.jpg', 16, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
#INSERT INTO ContentImages (ContentId, FileName, FilePath, OriginFileName, OrderNum, IsThumbnail, CreatedAt, UpdatedAt) 
#VALUES (21, '38645546ffc3981089488de5b419223902', 'uploads/', '17.jpg', 17, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');





INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (1, 2, '06dd97ccef2f36726476ccae14f6c8e3', 'uploads/', '스토리 썸네일.jpeg', 0, 1, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (2, 2, '49b38f79f76eb91edee0aebd6494b510', 'uploads/', '슬라이드1.jpeg', 1, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (3, 2, '4dc6facc2f0968f5fc65a27adc7c8a08', 'uploads/', '슬라이드3.jpeg', 2, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (4, 2, '28c09773f1ca61d755decc58ecdc0a81', 'uploads/', '슬라이드4.jpeg', 3, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (5, 2, '0509f4ed0b04af9f389eabc593841084', 'uploads/', '슬라이드2.jpeg', 4, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (6, 2, 'c74ab5f654c9e6d7154345d70cab0e27', 'uploads/', '슬라이드5.jpeg', 5, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (7, 2, 'aec99cbce152c339bc66ca1ab659c3b2', 'uploads/', '슬라이드8.jpeg', 6, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (8, 2, 'cdb6cdcbb18f5569b1c676ac53507cc7', 'uploads/', '슬라이드10.jpeg', 7, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (9, 2, '8ba55b3d35908e03ac26c6f5e7dcb790', 'uploads/', '슬라이드9.jpeg', 8, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (10, 2, '22f3889d5d8ba793c96d92891bbb0992', 'uploads/', '슬라이드6.jpeg', 9, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (11, 2, 'c9d47aef88f25c7a7eeef0e39276ee4b', 'uploads/', '슬라이드7.jpeg', 10, 0, '2022-04-03 21:17:28', '2022-04-03 21:17:28');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (12, 4, '15d31f3b26c9cded8ea916fcbb768c26', 'uploads/', '0.썸네일.png', 0, 1, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (13, 4, '5cda35a3e4bbf85a06d4a1c54934cb1a', 'uploads/', '1.jpg', 1, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (14, 4, '0a4f2f74a7ca73078686579cfade6155', 'uploads/', '2.jpg', 2, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (15, 4, '0c1e67158986716332e9fe0a742f1273', 'uploads/', '3.jpg', 3, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (16, 4, '36cf5c9317876adcee77220b1afd40fa', 'uploads/', '4.jpg', 4, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (17, 4, '4f4e538d600006baa9572f85eb452f84', 'uploads/', '5.jpg', 5, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (18, 4, 'ee8d623c68dbf07af10f8b5f43025363', 'uploads/', '6.jpg', 6, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (19, 4, '773b19936edbe539bf1676f23b18432c', 'uploads/', '7.jpg', 7, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (20, 4, '6c29545b66e26e6c8e746b6ed1d75e52', 'uploads/', '8.jpg', 8, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (21, 4, '9cc8bab9b033dc2517f1b54ee9a2dda2', 'uploads/', '9.jpg', 9, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (22, 4, '481fb276543d82c4c7e0f33954b53834', 'uploads/', '10.jpg', 10, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (23, 4, '4d508774856a0f8eef9ff8f780d37aa1', 'uploads/', '11.jpg', 11, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (24, 4, 'e17504639ddac0bec1a1ccdf31077e0d', 'uploads/', '12.jpg', 12, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (25, 4, '5aa887601b441422d004edf9d5702d2c', 'uploads/', '13.jpg', 13, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (26, 4, '12dd444b932fa1dba6a31cb929369983', 'uploads/', '14.jpg', 14, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (27, 4, '41704e3bf2901b93c5a32709ce3a6490', 'uploads/', '15.jpg', 15, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (28, 4, 'fee990a9974ede2a81b275688f737ea4', 'uploads/', '16.jpg', 16, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (29, 4, '60d372dfeacb2a0248bab418ac9567d3', 'uploads/', '17.jpg', 17, 0, '2022-04-03 21:23:54', '2022-04-03 21:23:54');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (30, 5, '83fc6ab5e691fe3906ed5193b33e30a0', 'uploads/', '썸네일.png', 0, 1, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (31, 5, '07f91d485e49bc0fba13fdc8d4557246', 'uploads/', '1.jpg', 1, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (32, 5, '4deb4b9d42084a56d11c39698f2edee5', 'uploads/', '2.jpg', 2, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (33, 5, '625162afc9494329116fb482b17efbdc', 'uploads/', '3.jpg', 3, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (34, 5, '1de187757e620d7e502b2d443735bb8a', 'uploads/', '4.jpg', 4, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (35, 5, 'ae4bd2b0121df5e6f758677dcd208d25', 'uploads/', '5.jpg', 5, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (36, 5, '4c6a20d44b8e67125a631026a9119cc3', 'uploads/', '6.jpg', 6, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (37, 5, '12dea8f2cfe9d93d860cbefbdeaa4153', 'uploads/', '7.jpg', 7, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (38, 5, '9d8b3f23a08733548f20c06cf1932098', 'uploads/', '8.jpg', 8, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (39, 5, '6f22f2129580e3a79541a5b9a0b1ed5b', 'uploads/', '9.jpg', 9, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (40, 5, 'e14e12b95fe9c02d5ce471aec35a7ef6', 'uploads/', '10.jpg', 10, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (41, 5, '1b254316fc6fb9d4eec7adad91c20d4f', 'uploads/', '11.jpg', 11, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (42, 5, 'f3a0dcafadae99f27d50ed755a19a00d', 'uploads/', '12.jpg', 12, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (43, 5, '65e0d7591bcc76392402af50e5256550', 'uploads/', '13.jpg', 13, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (44, 5, '2cfabf93405879014b1614a59bc4879e', 'uploads/', '14.jpg', 14, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (45, 5, '7b166aa3b0cc9207ff81cac001932ee3', 'uploads/', '15.jpg', 15, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (46, 5, '9470e6d617ab584d8e5c3ea808777352', 'uploads/', '16.jpg', 16, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (47, 5, '70468b1c588dbec1b91db2bebc5be3c1', 'uploads/', '17.jpg', 17, 0, '2022-04-03 21:51:51', '2022-04-03 21:51:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (48, 6, 'c87bd056235d1658b42b3eecc6efb7d6', 'uploads/', '썸네일.png', 0, 1, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (49, 6, '0be0dc85984e2be5078720c6dfa800ee', 'uploads/', '1.jpg', 1, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (50, 6, '22cca19a8a121759b3e67c74c47fcd5b', 'uploads/', '2.jpg', 2, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (51, 6, '2fc38d559a8c49bdd32c7c81c15b4ec2', 'uploads/', '3.jpg', 3, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (52, 6, 'b9c8266a3ac33b57a5622e46185f83d6', 'uploads/', '4.jpg', 4, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (53, 6, '0d6215240da1b4b745aa28f775209dab', 'uploads/', '5.jpg', 5, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (54, 6, '321f02bb69b2221cf69bc45245786eee', 'uploads/', '6.jpg', 6, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (55, 6, '62c22010ab14d4fa6f5b23e92d4bf046', 'uploads/', '7.jpg', 7, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (56, 6, 'c7ce6cde66b14c76062c12a668bf9963', 'uploads/', '8.jpg', 8, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (57, 6, '0ebb13ac7fd9bb52aa2294c3227e5c84', 'uploads/', '9.jpg', 9, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (58, 6, '25b35c329f0f6bc9fa1c647b73c27fe9', 'uploads/', '10.jpg', 10, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (59, 6, 'd6bc1e9327fc96211abaa6d76c415c8a', 'uploads/', '11.jpg', 11, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (60, 6, '8e5595cd16ed9bdeed6dcf6df5b847d5', 'uploads/', '12.jpg', 12, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (61, 6, 'fde5e4f6a667906ef463bad34ee2cae9', 'uploads/', '13.jpg', 13, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (62, 6, '5e5a32f45cddc85201f842b90be5ec7d', 'uploads/', '14.jpg', 14, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (63, 6, '992b1709eb6f36e0f6e3cd1b6cb34c3d', 'uploads/', '15.jpg', 15, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (64, 6, 'b027d35a716a95afb8cc9241c14737ba', 'uploads/', '16.jpg', 16, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (65, 6, 'ac90ca533c66da77261f0061aeadaccf', 'uploads/', '17.jpg', 17, 0, '2022-04-04 00:35:18', '2022-04-04 00:35:18');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (66, 7, '345bf3752746ec2a2677dd09cd929524', 'uploads/', '썸네일.png', 0, 1, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (67, 7, 'dd5b5050744d216e5dcb021834f9d500', 'uploads/', '1.jpg', 1, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (68, 7, '654f85dc7e16a633bc990961b397971e', 'uploads/', '2.jpg', 2, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (69, 7, 'f366e23e634b5aa79342f417b0b71c42', 'uploads/', '3.jpg', 3, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (70, 7, 'a6c9a88c02f3507565e2e83c453ea0bf', 'uploads/', '4.jpg', 4, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (71, 7, '42a0fea1144bd877ecbe9e9c9dd65de3', 'uploads/', '5.jpg', 5, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (72, 7, 'de4ed48900bb5699ce1b6f5d249f83b1', 'uploads/', '6.jpg', 6, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (73, 7, '61bddd68c7e4952931aae4e2de830107', 'uploads/', '7.jpg', 7, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (74, 7, '09597fb5312c5625e4bf62a253bd5dcf', 'uploads/', '8.jpg', 8, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (75, 7, '41248083a5301fb8fa6881258fe64dc1', 'uploads/', '9.jpg', 9, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (76, 7, '7a8a8cbd5d28908116fce03322f7f64d', 'uploads/', '10.jpg', 10, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (77, 7, 'b5024177061317dbb4fad58de741ef7d', 'uploads/', '11.jpg', 11, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (78, 7, '720f4b7927e4ba935f0d54e57da83bce', 'uploads/', '12.jpg', 12, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (79, 7, '46881a7dbbcaa1e4316821cc52eec1a2', 'uploads/', '13.jpg', 13, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (80, 7, 'e9ab9b334dc985db95f847e0efc91dce', 'uploads/', '14.jpg', 14, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (81, 7, 'e845d85464dfc9bfa6da0054d074e964', 'uploads/', '15.jpg', 15, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (82, 7, 'f0081b372f07e0f0a04d1bc4186d34d2', 'uploads/', '16.jpg', 16, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (83, 7, '14c790cd94a38fbc0d1a5f86f74cc36e', 'uploads/', '17.jpg', 17, 0, '2022-04-04 00:38:43', '2022-04-04 00:38:43');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (84, 8, '6c0ae05aab1ba5cceca378019a624b54', 'uploads/', '썸네일.png', 0, 1, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (85, 8, 'e625ba91590eda22900622ed86f3b667', 'uploads/', '1.jpg', 1, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (86, 8, '3c57fe116a531f58b256afbb7284c498', 'uploads/', '2.jpg', 2, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (87, 8, 'd8a93341c51053b9a22a67a27b8c063d', 'uploads/', '3.jpg', 3, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (88, 8, 'a9095b654840d177bea2ac6834ee395a', 'uploads/', '4.jpg', 4, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (89, 8, '6cbe1f5cef162491c56f5e63cb629d80', 'uploads/', '5.jpg', 5, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (90, 8, '4b282e55807691e5b991e84649e3b2a0', 'uploads/', '6.jpg', 6, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (91, 8, 'e54afb1b3a2c88cb4ecb04640e3ce3f3', 'uploads/', '7.jpg', 7, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (92, 8, 'ea9b6f5c47a171f924b276a6e657f5a4', 'uploads/', '8.jpg', 8, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (93, 8, 'c823ce93ca3ec0de2256b59dd1720385', 'uploads/', '9.jpg', 9, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (94, 8, '9b2af90ca7c21f5794fe368509131e39', 'uploads/', '10.jpg', 10, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (95, 8, '0cd8ebeb60b62b7a68bf765108bdf4a3', 'uploads/', '11.jpg', 11, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (96, 8, 'd7dd9afafaf163ab9e2d3ec725794a18', 'uploads/', '12.jpg', 12, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (97, 8, '1fd8552d68098fb64c7b6d665cb98b8b', 'uploads/', '13.jpg', 13, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (98, 8, 'dd0de64c2d53dcd7cd2e1802d0a859e2', 'uploads/', '14.jpg', 14, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (99, 8, '6e1354e01ab686a6df4642f19da719d8', 'uploads/', '16.jpg', 15, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (100, 8, '72ec327a31758314d93cb2cec9455ca9', 'uploads/', '17.jpg', 16, 0, '2022-04-04 00:41:26', '2022-04-04 00:41:26');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (101, 9, '8b8d08ce6254b620b00d74582e0962eb', 'uploads/', '썸네일.png', 0, 1, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (102, 9, '8775efe79ec10b06f152a330e9c1f264', 'uploads/', '1.jpg', 1, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (103, 9, '3095eafaee516c935da0a0c2df7bd27f', 'uploads/', '2.jpg', 2, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (104, 9, '3ea9ee13211ef40dc2439ef047026a43', 'uploads/', '3.jpg', 3, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (105, 9, '4a3181242fbb47fc8eda3e94cc3c4b11', 'uploads/', '4.jpg', 4, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (106, 9, '9eb3c1f44b6bb1afcf649398ddfff8d3', 'uploads/', '5.jpg', 5, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (107, 9, '125b639a49573302f713ec808cf0e6ee', 'uploads/', '6.jpg', 6, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (108, 9, 'a5500ac451a6abc8a7da8c91335861db', 'uploads/', '7.jpg', 7, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (109, 9, 'eb97673540174145e665ddea7a6c8215', 'uploads/', '8.jpg', 8, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (110, 9, '217ba3c7423c57e57e4450a552fbd34d', 'uploads/', '9.jpg', 9, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (111, 9, 'de97ddb8980c111ff4d354658c90827c', 'uploads/', '10.jpg', 10, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (112, 9, '0752e78c4f34862bba3e5791e996af42', 'uploads/', '11.jpg', 11, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (113, 9, '5c38e7a905f62888855e7cceefe1fa2d', 'uploads/', '12.jpg', 12, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (114, 9, 'b4133cb6612711fe81873888f830573b', 'uploads/', '13.jpg', 13, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (115, 9, '93d6a1247ff20c4fac2371d8ac71c7a3', 'uploads/', '14.jpg', 14, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (116, 9, '4b2f05cb5eb793a44b886d8cb985364b', 'uploads/', '15.jpg', 15, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (117, 9, '6554eeea9392f7c667f623882a349787', 'uploads/', '16.jpg', 16, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (118, 9, '6e6e5f5562e26ab1402381b61b290c2a', 'uploads/', '17.jpg', 17, 0, '2022-04-04 00:43:12', '2022-04-04 00:43:12');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (119, 10, '7e6f1bba7f9d81fbf12222d674da486e', 'uploads/', '썸네일.png', 0, 1, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (120, 10, 'e992243c434df6559d3b897403fc83a2', 'uploads/', '1.jpg', 1, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (121, 10, '9373d8c8c9262454db51676f197678df', 'uploads/', '2.jpg', 2, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (122, 10, '223ddea2bbdc553965572d6f948f85e3', 'uploads/', '3.jpg', 3, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (123, 10, 'ae4f72ad5b5ba37cdc5aff2a697a8972', 'uploads/', '4.jpg', 4, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (124, 10, '66b05caf656b921c4d4582ed5088eeec', 'uploads/', '5.jpg', 5, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (125, 10, '82a3276e5981de26d3cef035fc7e7cb6', 'uploads/', '6.jpg', 6, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (126, 10, '57b546d2da0e17930af6a7cdd18b8e6d', 'uploads/', '7.jpg', 7, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (127, 10, '0d23db71503f91f8a0f7d16098b3145e', 'uploads/', '8.jpg', 8, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (128, 10, '60cd1564f41c7262c4c1480636012e0b', 'uploads/', '9.jpg', 9, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (129, 10, '030fc7fc502d4c02bbbcc3ce3e13d101', 'uploads/', '10.jpg', 10, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (130, 10, '89754dfa54d47d9c46292dea4883953d', 'uploads/', '11.jpg', 11, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (131, 10, 'd43236aa248e5905701f61c8e15a1622', 'uploads/', '12.jpg', 12, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (132, 10, '3dc990369a343b058d836ea34f3339bb', 'uploads/', '13.jpg', 13, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (133, 10, '9005fbf21b589643ecc416de275d5ca4', 'uploads/', '14.jpg', 14, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (134, 10, '4b995bd5e5e0fa74f911fb8706514877', 'uploads/', '16.jpg', 15, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (135, 10, 'c8091f10ce927b5a2c4a4c247bd89607', 'uploads/', '17.jpg', 16, 0, '2022-04-04 00:44:55', '2022-04-04 00:44:55');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (136, 11, '1d86ddb14c45daf72696f0c9e1d38861', 'uploads/', '썸네일.png', 0, 1, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (137, 11, '13248e1ba3ec4df799ce755068e5063d', 'uploads/', '1.jpg', 1, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (138, 11, '18462e96afa4f663f1d1d05cb02b8705', 'uploads/', '2.jpg', 2, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (139, 11, 'a06ef31ccc2e0519480a73428de2b4b1', 'uploads/', '3.jpg', 3, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (140, 11, 'a5f86bfd64f5e49740d9d8c96432291e', 'uploads/', '4.jpg', 4, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (141, 11, '243e92cf65693566eda67948ea46e571', 'uploads/', '5.jpg', 5, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (142, 11, 'd46317b04c7d47e7dcc340a6fa1782cf', 'uploads/', '6.jpg', 6, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (143, 11, '5965420885d62d0bc918b79c433b2f46', 'uploads/', '7.jpg', 7, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (144, 11, '78bd4cae72cadaa87d2087ad8886c9b9', 'uploads/', '8.jpg', 8, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (145, 11, '91f2767c9321f28bd3e8d76f075ec5c9', 'uploads/', '9.jpg', 9, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (146, 11, 'c970e056416d0846d5b618042fb0d661', 'uploads/', '10.jpg', 10, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (147, 11, '67502172287c400418db4acea7581c93', 'uploads/', '11.jpg', 11, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (148, 11, '4b091e2baf19ad54efdaee7e9815fbb1', 'uploads/', '12.jpg', 12, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (149, 11, '1727ccc7b647168cd59f8afe17a9f01c', 'uploads/', '13.jpg', 13, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (150, 11, '4cc054c6274d51e0146d4a9cf3e41451', 'uploads/', '14.jpg', 14, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (151, 11, 'e6b5488c4382e7e3c2ee7032bd53ca4c', 'uploads/', '15.jpg', 15, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (152, 11, 'f057cfcced3e744984ca5e83d870bf69', 'uploads/', '16.jpg', 16, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

INSERT INTO `ContentImages` (`Id`, `ContentId`, `FileName`, `FilePath`, `OriginFileName`, `OrderNum`, `IsThumbnail`, `CreatedAt`, `UpdatedAt`) 
VALUES (153, 11, 'c33c5f8875f523077cc1b0af4c8d93bb', 'uploads/', '17.jpg', 17, 0, '2022-04-04 00:47:51', '2022-04-04 00:47:51');

