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

 Date: 06/02/2022 18:16:26
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for Users
-- ----------------------------
DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users`  (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Username` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Password` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `PasswordUpdatedAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `Password6MonthSetting` tinyint(1) NOT NULL DEFAULT 0,
  `Contact` varchar(13) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Address` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `UseTerm` tinyint(1) NOT NULL DEFAULT 0,
  `UseTermTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `PrivateTerm` tinyint(1) NOT NULL DEFAULT 0,
  `PrivateTermTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `EmailTerm` tinyint(1) NOT NULL DEFAULT 0,
  `SMSTerm` tinyint(1) NOT NULL DEFAULT 0,
  `IsSub` tinyint(1) NULL DEFAULT 0,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `Contact`(`Contact`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of Users
-- ----------------------------
INSERT INTO `Users` VALUES (1, 'test', 'test', '123', '2022-02-03 22:20:27', 0, '010-0000-0000', 'test test', 1, '2022-02-03 22:20:27', 1, '2022-02-03 22:20:27', 1, 1, 1, '2022-02-03 22:20:27', '2022-02-03 22:22:11');
INSERT INTO `Users` VALUES (2, 'test2', 'test2', '123', '2022-02-03 22:21:39', 0, '010-0000-0001', 'test test', 1, '2022-02-03 22:21:39', 1, '2022-02-03 22:21:39', 1, 1, 0, '2022-02-03 22:21:39', '2022-02-03 22:21:39');
INSERT INTO `Users` VALUES (3, 'jbu', 'jbu', 'password', '2022-02-05 04:49:17', 0, '010-5099-1699', 'seoul', 1, '2022-02-05 04:49:17', 1, '2022-02-05 04:49:17', 1, 1, 0, '2022-02-05 04:49:17', '2022-02-05 04:49:17');

SET FOREIGN_KEY_CHECKS = 1;
