/*
 Navicat MySQL Data Transfer

 Source Server         : Fitboa
 Source Server Type    : MariaDB
 Source Server Version : 100605
 Source Host           : 192.168.0.9:3306
 Source Schema         : Fitboa

 Target Server Type    : MariaDB
 Target Server Version : 100605
 File Encoding         : 65001

 Date: 06/02/2022 23:55:31
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ContentImages
-- ----------------------------
DROP TABLE IF EXISTS `ContentImages`;
CREATE TABLE `ContentImages`  (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `ContentId` int(11) NOT NULL,
  `FileName` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `FilePath` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `OriginFileName` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `OrderNum` int(11) NOT NULL,
  `IsThumbnail` tinyint(1) NOT NULL DEFAULT 0,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `ContentId`(`ContentId`) USING BTREE,
  CONSTRAINT `ContentImages_ibfk_1` FOREIGN KEY (`ContentId`) REFERENCES `Contents` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ContentImages
-- ----------------------------
INSERT INTO `ContentImages` VALUES (1, 1, '121c0e5d489ec7e038431758050c4e2c', 'test/', 'thumbnail.jpg', 0, 1, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
INSERT INTO `ContentImages` VALUES (2, 1, '121c0e5d489ec7e038431758050c4e2c', 'test/', '3.jpg', 3, 0, '2022-02-06 23:25:27', '2022-02-06 23:53:22');
INSERT INTO `ContentImages` VALUES (3, 1, '111111111111', 'test/', '1.jpg', 1, 0, '2022-02-06 23:25:27', '2022-02-06 23:54:04');
INSERT INTO `ContentImages` VALUES (4, 1, '222222222222', 'test/', '2.jpg', 2, 0, '2022-02-06 23:25:27', '2022-02-06 23:54:29');
INSERT INTO `ContentImages` VALUES (5, 2, '1209374210981423', 'test/', 'thumbnail.jpg', 0, 1, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
INSERT INTO `ContentImages` VALUES (6, 2, '1209374215313452', 'test/', '3.jpg', 3, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
INSERT INTO `ContentImages` VALUES (7, 2, '1209374210986512', 'test/', '1.jpg', 1, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');
INSERT INTO `ContentImages` VALUES (8, 2, '1209374267453253', 'test/', '2.jpg', 2, 0, '2022-02-06 23:25:27', '2022-02-06 23:25:27');

SET FOREIGN_KEY_CHECKS = 1;
