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

 Date: 06/02/2022 22:53:38
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ContentReviews
-- ----------------------------
DROP TABLE IF EXISTS `ContentReviews`;
CREATE TABLE `ContentReviews`  (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `ContentId` int(11) NOT NULL,
  `UserId` int(11) NOT NULL,
  `ParentReviewId` int(11) NULL DEFAULT NULL,
  `Content` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `ContentId`(`ContentId`) USING BTREE,
  INDEX `UserId`(`UserId`) USING BTREE,
  INDEX `ParentReviewId`(`ParentReviewId`) USING BTREE,
  CONSTRAINT `ContentReviews_ibfk_1` FOREIGN KEY (`ContentId`) REFERENCES `Contents` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `ContentReviews_ibfk_2` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `ContentReviews_ibfk_3` FOREIGN KEY (`ParentReviewId`) REFERENCES `ContentReviews` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ContentReviews
-- ----------------------------
INSERT INTO `ContentReviews` VALUES (1, 1, 1, NULL, 'test', '2022-02-06 22:48:28', '2022-02-06 22:48:28');
INSERT INTO `ContentReviews` VALUES (2, 1, 1, 1, '1 - test', '2022-02-06 22:48:38', '2022-02-06 22:48:38');
INSERT INTO `ContentReviews` VALUES (3, 1, 1, 1, '2 - test', '2022-02-06 22:48:54', '2022-02-06 22:48:54');
INSERT INTO `ContentReviews` VALUES (4, 1, 1, NULL, 'aaaa', '2022-02-06 22:49:15', '2022-02-06 22:49:15');
INSERT INTO `ContentReviews` VALUES (5, 1, 1, 1, '3 - test', '2022-02-06 22:49:36', '2022-02-06 22:49:36');
INSERT INTO `ContentReviews` VALUES (6, 1, 1, 4, '1 - aaaa', '2022-02-06 22:49:47', '2022-02-06 22:49:47');

SET FOREIGN_KEY_CHECKS = 1;
