/*
 Navicat Premium Dump SQL

 Source Server         : atyainno
 Source Server Type    : MySQL
 Source Server Version : 50744 (5.7.44-log)
 Source Host           : 127.0.0.1:3306
 Source Schema         : atyainno

 Target Server Type    : MySQL
 Target Server Version : 50744 (5.7.44-log)
 File Encoding         : 65001

 Date: 03/01/2026 11:55:31
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for email_verification
-- ----------------------------
DROP TABLE IF EXISTS `email_verification`;
CREATE TABLE `email_verification`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `verification_code` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `expires_at` datetime NULL DEFAULT NULL,
  `is_used` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of email_verification
-- ----------------------------

-- ----------------------------
-- Table structure for employees
-- ----------------------------
DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `email` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `monthly_salary` decimal(10, 2) NOT NULL,
  `mobile_no` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `username` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `role` varchar(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT 'employee',
  `is_verified` tinyint(1) NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `person_name`(`person_name`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE,
  UNIQUE INDEX `email`(`email`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of employees
-- ----------------------------
INSERT INTO `employees` VALUES (3, 'Pritesh patel', NULL, 12000.00, '9429792431', 'pritesh', 'ai@123', 'employee', 0, '2026-01-03 10:25:55');
INSERT INTO `employees` VALUES (12, 'MANSI B PATEL', NULL, 8000.00, '9429792431', 'mansi', 'ai@123', 'employee', 0, '2026-01-03 10:25:55');
INSERT INTO `employees` VALUES (13, 'aiadmin', NULL, 0.00, '', 'aiadmin', 'admin123', 'admin', 0, '2026-01-03 10:25:55');
INSERT INTO `employees` VALUES (14, 'MEGHA S PATEL', NULL, 8000.00, NULL, 'meghapatel', 'ai@123', 'employee', 0, '2026-01-03 10:25:55');
INSERT INTO `employees` VALUES (15, 'Dipanshu Bharatia', NULL, 15000.00, '9429792431', 'dipanshubharatia', 'ai@123', 'employee', 0, '2026-01-03 10:25:55');

-- ----------------------------
-- Table structure for holidays
-- ----------------------------
DROP TABLE IF EXISTS `holidays`;
CREATE TABLE `holidays`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `holiday_date` date NOT NULL,
  `description` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `holiday_date`(`holiday_date`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of holidays
-- ----------------------------
INSERT INTO `holidays` VALUES (2, '2025-10-18', 'Diwali Break');
INSERT INTO `holidays` VALUES (3, '2025-10-20', 'Diwali Break');
INSERT INTO `holidays` VALUES (4, '2025-10-21', 'Diwali Break');
INSERT INTO `holidays` VALUES (5, '2025-10-22', 'Diwali Break');
INSERT INTO `holidays` VALUES (6, '2025-10-23', 'Diwali Break');
INSERT INTO `holidays` VALUES (7, '2025-10-24', 'Diwali Break');
INSERT INTO `holidays` VALUES (8, '2025-10-25', 'Diwali Break');

-- ----------------------------
-- Table structure for new_report
-- ----------------------------
DROP TABLE IF EXISTS `new_report`;
CREATE TABLE `new_report`  (
  `id` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `datetime` datetime NULL DEFAULT NULL,
  `date` date NULL DEFAULT NULL,
  `time` time NULL DEFAULT NULL,
  `direction` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `device_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `device_serial_no` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `person_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `card_no` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of new_report
-- ----------------------------
INSERT INTO `new_report` VALUES ('2', '2025-10-01 08:52:00', '2025-10-01', '08:52:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-01 18:06:00', '2025-10-01', '18:06:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-03 09:03:00', '2025-10-03', '09:03:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-03 18:11:00', '2025-10-03', '18:11:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-04 08:55:00', '2025-10-04', '08:55:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-04 18:02:00', '2025-10-04', '18:02:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-06 09:05:00', '2025-10-06', '09:05:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-07 09:09:00', '2025-10-07', '09:09:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-07 18:07:00', '2025-10-07', '18:07:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-08 09:04:00', '2025-10-08', '09:04:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-08 18:11:00', '2025-10-08', '18:11:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-09 13:46:00', '2025-10-09', '13:46:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-09 17:55:00', '2025-10-09', '17:55:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-10 09:11:00', '2025-10-10', '09:11:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-10 18:31:00', '2025-10-10', '18:31:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-13 09:09:00', '2025-10-13', '09:09:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-13 18:30:00', '2025-10-13', '18:30:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-14 09:04:00', '2025-10-14', '09:04:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-14 18:07:00', '2025-10-14', '18:07:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-15 09:11:00', '2025-10-15', '09:11:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-15 18:02:00', '2025-10-15', '18:02:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-16 09:33:00', '2025-10-16', '09:33:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-16 18:34:00', '2025-10-16', '18:34:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-17 08:59:00', '2025-10-17', '08:59:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-17 18:02:00', '2025-10-17', '18:02:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-18 09:10:00', '2025-10-18', '09:10:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-27 09:11:00', '2025-10-27', '09:11:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-27 17:59:00', '2025-10-27', '17:59:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-28 09:05:00', '2025-10-28', '09:05:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-28 18:01:00', '2025-10-28', '18:01:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-29 08:51:00', '2025-10-29', '08:51:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-29 18:01:00', '2025-10-29', '18:01:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-30 09:08:00', '2025-10-30', '09:08:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-30 18:05:00', '2025-10-30', '18:05:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-31 09:05:00', '2025-10-31', '09:05:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-31 18:05:00', '2025-10-31', '18:05:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('13', '2025-10-01 08:57:00', '2025-10-01', '08:57:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-01 17:54:00', '2025-10-01', '17:54:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-03 09:07:00', '2025-10-03', '09:07:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-03 16:59:00', '2025-10-03', '16:59:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-04 08:56:00', '2025-10-04', '08:56:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-04 17:59:00', '2025-10-04', '17:59:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-06 08:52:00', '2025-10-06', '08:52:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-06 17:49:00', '2025-10-06', '17:49:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-07 09:09:00', '2025-10-07', '09:09:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-07 17:53:00', '2025-10-07', '17:53:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-08 08:53:00', '2025-10-08', '08:53:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-08 17:51:00', '2025-10-08', '17:51:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-09 09:02:00', '2025-10-09', '09:02:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-09 17:46:00', '2025-10-09', '17:46:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-10 09:06:00', '2025-10-10', '09:06:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-10 17:55:00', '2025-10-10', '17:55:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-13 08:55:00', '2025-10-13', '08:55:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-13 18:01:00', '2025-10-13', '18:01:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-14 09:04:00', '2025-10-14', '09:04:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-14 17:55:00', '2025-10-14', '17:55:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-15 12:13:00', '2025-10-15', '12:13:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-15 17:49:00', '2025-10-15', '17:49:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-16 08:52:00', '2025-10-16', '08:52:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-16 17:55:00', '2025-10-16', '17:55:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-17 09:07:00', '2025-10-17', '09:07:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-17 17:56:00', '2025-10-17', '17:56:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-18 09:33:00', '2025-10-18', '09:33:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-27 09:10:00', '2025-10-27', '09:10:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-27 17:52:00', '2025-10-27', '17:52:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-28 09:04:00', '2025-10-28', '09:04:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-28 17:45:00', '2025-10-28', '17:45:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-29 08:53:00', '2025-10-29', '08:53:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-29 17:53:00', '2025-10-29', '17:53:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-30 09:08:00', '2025-10-30', '09:08:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-30 17:54:00', '2025-10-30', '17:54:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('11', '2025-10-01 09:13:00', '2025-10-01', '09:13:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-01 18:00:00', '2025-10-01', '18:00:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-03 09:12:00', '2025-10-03', '09:12:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-03 18:01:00', '2025-10-03', '18:01:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-04 09:01:00', '2025-10-04', '09:01:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-04 18:00:00', '2025-10-04', '18:00:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-07 09:05:00', '2025-10-07', '09:05:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-07 18:00:00', '2025-10-07', '18:00:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-08 09:12:00', '2025-10-08', '09:12:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-08 17:54:00', '2025-10-08', '17:54:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-09 09:05:00', '2025-10-09', '09:05:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-09 17:55:00', '2025-10-09', '17:55:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-10 09:03:00', '2025-10-10', '09:03:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-10 17:56:00', '2025-10-10', '17:56:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-13 09:09:00', '2025-10-13', '09:09:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-13 18:01:00', '2025-10-13', '18:01:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-14 09:05:00', '2025-10-14', '09:05:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-14 17:57:00', '2025-10-14', '17:57:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-15 09:13:00', '2025-10-15', '09:13:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-15 17:50:00', '2025-10-15', '17:50:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-16 09:22:00', '2025-10-16', '09:22:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-16 17:54:00', '2025-10-16', '17:54:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-17 09:15:00', '2025-10-17', '09:15:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-17 17:57:00', '2025-10-17', '17:57:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-18 09:17:00', '2025-10-18', '09:17:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('2', '2025-10-01 08:52:00', '2025-10-01', '08:52:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-01 18:06:00', '2025-10-01', '18:06:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-03 09:03:00', '2025-10-03', '09:03:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-03 18:11:00', '2025-10-03', '18:11:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-04 08:55:00', '2025-10-04', '08:55:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-04 18:02:00', '2025-10-04', '18:02:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-06 09:05:00', '2025-10-06', '09:05:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-07 09:09:00', '2025-10-07', '09:09:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-07 18:07:00', '2025-10-07', '18:07:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-08 09:04:00', '2025-10-08', '09:04:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-08 18:11:00', '2025-10-08', '18:11:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-09 13:46:00', '2025-10-09', '13:46:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-09 17:55:00', '2025-10-09', '17:55:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-10 09:11:00', '2025-10-10', '09:11:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-10 18:31:00', '2025-10-10', '18:31:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-13 09:09:00', '2025-10-13', '09:09:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-13 18:30:00', '2025-10-13', '18:30:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-14 09:04:00', '2025-10-14', '09:04:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-14 18:07:00', '2025-10-14', '18:07:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-15 09:11:00', '2025-10-15', '09:11:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-15 18:02:00', '2025-10-15', '18:02:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-16 09:33:00', '2025-10-16', '09:33:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-16 18:34:00', '2025-10-16', '18:34:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-17 08:59:00', '2025-10-17', '08:59:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-17 18:02:00', '2025-10-17', '18:02:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-18 09:10:00', '2025-10-18', '09:10:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-27 09:11:00', '2025-10-27', '09:11:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-27 17:59:00', '2025-10-27', '17:59:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-28 09:05:00', '2025-10-28', '09:05:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-28 18:01:00', '2025-10-28', '18:01:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-29 08:51:00', '2025-10-29', '08:51:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-29 18:01:00', '2025-10-29', '18:01:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-30 09:08:00', '2025-10-30', '09:08:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-30 18:05:00', '2025-10-30', '18:05:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-31 09:05:00', '2025-10-31', '09:05:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-10-31 18:05:00', '2025-10-31', '18:05:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('13', '2025-10-01 08:57:00', '2025-10-01', '08:57:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-01 17:54:00', '2025-10-01', '17:54:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-03 09:07:00', '2025-10-03', '09:07:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-03 16:59:00', '2025-10-03', '16:59:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-04 08:56:00', '2025-10-04', '08:56:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-04 17:59:00', '2025-10-04', '17:59:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-06 08:52:00', '2025-10-06', '08:52:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-06 17:49:00', '2025-10-06', '17:49:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-07 09:09:00', '2025-10-07', '09:09:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-07 17:53:00', '2025-10-07', '17:53:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-08 08:53:00', '2025-10-08', '08:53:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-08 17:51:00', '2025-10-08', '17:51:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-09 09:02:00', '2025-10-09', '09:02:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-09 17:46:00', '2025-10-09', '17:46:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-10 09:06:00', '2025-10-10', '09:06:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-10 17:55:00', '2025-10-10', '17:55:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-13 08:55:00', '2025-10-13', '08:55:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-13 18:01:00', '2025-10-13', '18:01:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-14 09:04:00', '2025-10-14', '09:04:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-14 17:55:00', '2025-10-14', '17:55:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-15 12:13:00', '2025-10-15', '12:13:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-15 17:49:00', '2025-10-15', '17:49:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-16 08:52:00', '2025-10-16', '08:52:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-16 17:55:00', '2025-10-16', '17:55:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-17 09:07:00', '2025-10-17', '09:07:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-17 17:56:00', '2025-10-17', '17:56:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-18 09:33:00', '2025-10-18', '09:33:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-27 09:10:00', '2025-10-27', '09:10:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-27 17:52:00', '2025-10-27', '17:52:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-28 09:04:00', '2025-10-28', '09:04:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-28 17:45:00', '2025-10-28', '17:45:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-29 08:53:00', '2025-10-29', '08:53:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-29 17:53:00', '2025-10-29', '17:53:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-30 09:08:00', '2025-10-30', '09:08:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-10-30 17:54:00', '2025-10-30', '17:54:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('11', '2025-10-01 09:13:00', '2025-10-01', '09:13:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-01 18:00:00', '2025-10-01', '18:00:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-03 09:12:00', '2025-10-03', '09:12:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-03 18:01:00', '2025-10-03', '18:01:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-04 09:01:00', '2025-10-04', '09:01:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-04 18:00:00', '2025-10-04', '18:00:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-07 09:05:00', '2025-10-07', '09:05:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-07 18:00:00', '2025-10-07', '18:00:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-08 09:12:00', '2025-10-08', '09:12:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-08 17:54:00', '2025-10-08', '17:54:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-09 09:05:00', '2025-10-09', '09:05:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-09 17:55:00', '2025-10-09', '17:55:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-10 09:03:00', '2025-10-10', '09:03:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-10 17:56:00', '2025-10-10', '17:56:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-13 09:09:00', '2025-10-13', '09:09:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-13 18:01:00', '2025-10-13', '18:01:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-14 09:05:00', '2025-10-14', '09:05:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-14 17:57:00', '2025-10-14', '17:57:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-15 09:13:00', '2025-10-15', '09:13:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-15 17:50:00', '2025-10-15', '17:50:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-16 09:22:00', '2025-10-16', '09:22:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-16 17:54:00', '2025-10-16', '17:54:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-17 09:15:00', '2025-10-17', '09:15:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-17 17:57:00', '2025-10-17', '17:57:00', 'OUT', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('11', '2025-10-18 09:17:00', '2025-10-18', '09:17:00', 'IN', NULL, NULL, 'KINJAL C PATEL', '11');
INSERT INTO `new_report` VALUES ('2', '2025-11-10 09:05:09', '2025-11-10', '09:05:09', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-10 09:05:27', '2025-11-10', '09:05:27', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-10 09:05:35', '2025-11-10', '09:05:35', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-10 09:05:42', '2025-11-10', '09:05:42', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-10 09:05:51', '2025-11-10', '09:05:51', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-10 09:23:44', '2025-11-10', '09:23:44', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-10 09:24:04', '2025-11-10', '09:24:04', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-10 09:24:16', '2025-11-10', '09:24:16', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-10 17:50:54', '2025-11-10', '17:50:54', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-10 17:51:06', '2025-11-10', '17:51:06', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-10 17:51:20', '2025-11-10', '17:51:20', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 17:54:28', '2025-11-10', '17:54:28', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 17:54:40', '2025-11-10', '17:54:40', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 17:54:52', '2025-11-10', '17:54:52', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-10 17:56:12', '2025-11-10', '17:56:12', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-10 17:56:21', '2025-11-10', '17:56:21', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-10 17:56:26', '2025-11-10', '17:56:26', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 18:01:13', '2025-11-10', '18:01:13', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 18:01:42', '2025-11-10', '18:01:42', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-10 18:28:14', '2025-11-10', '18:28:14', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-11 08:51:09', '2025-11-11', '08:51:09', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-11 08:51:14', '2025-11-11', '08:51:14', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-11 08:58:06', '2025-11-11', '08:58:06', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-11 08:59:13', '2025-11-11', '08:59:13', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-11 09:05:36', '2025-11-11', '09:05:36', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-11 09:06:03', '2025-11-11', '09:06:03', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-11 13:40:14', '2025-11-11', '13:40:14', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-10 09:05:00', '2025-11-10', '09:05:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-10 18:28:00', '2025-11-10', '18:28:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('13', '2025-11-10 09:05:00', '2025-11-10', '09:05:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-10 17:51:00', '2025-11-10', '17:51:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('15', '2025-11-10 09:23:00', '2025-11-10', '09:23:00', 'IN', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-10 17:56:00', '2025-11-10', '17:56:00', 'OUT', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('16', '2025-11-10 09:24:00', '2025-11-10', '09:24:00', 'IN', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-10 17:56:00', '2025-11-10', '17:56:00', 'OUT', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('17', '2025-11-10 09:24:00', '2025-11-10', '09:24:00', 'IN', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('20', '2025-11-10 09:05:00', '2025-11-10', '09:05:00', 'IN', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-10 17:50:00', '2025-11-10', '17:50:00', 'OUT', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('21', '2025-11-10 09:05:00', '2025-11-10', '09:05:00', 'IN', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-10 17:56:00', '2025-11-10', '17:56:00', 'OUT', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('23', '2025-11-10 09:05:00', '2025-11-10', '09:05:00', 'IN', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-10 17:51:00', '2025-11-10', '17:51:00', 'OUT', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 17:54:00', '2025-11-10', '17:54:00', 'OUT', NULL, NULL, 'RAJESH BHAI', '152');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 17:54:00', '2025-11-10', '17:54:00', 'OUT', NULL, NULL, 'RAJESH BHAI', '152');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 17:54:00', '2025-11-10', '17:54:00', 'OUT', NULL, NULL, 'RAJESH BHAI', '152');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 17:54:00', '2025-11-10', '17:54:00', 'OUT', NULL, NULL, 'RAJESH BHAI', '152');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 18:01:00', '2025-11-10', '18:01:00', 'OUT', NULL, NULL, 'RAJESH BHAI', '152');
INSERT INTO `new_report` VALUES ('152', '2025-11-10 18:01:00', '2025-11-10', '18:01:00', 'OUT', NULL, NULL, 'RAJESH BHAI', '152');
INSERT INTO `new_report` VALUES ('23', '2025-11-11 17:51:14', '2025-11-11', '17:51:14', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-11 17:51:19', '2025-11-11', '17:51:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-11 17:51:33', '2025-11-11', '17:51:33', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-11 17:56:29', '2025-11-11', '17:56:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-11 17:56:38', '2025-11-11', '17:56:38', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-11 17:56:46', '2025-11-11', '17:56:46', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-12 08:23:54', '2025-11-12', '08:23:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-12 08:54:00', '2025-11-12', '08:54:00', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-12 08:55:31', '2025-11-12', '08:55:31', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-12 09:05:50', '2025-11-12', '09:05:50', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-12 09:06:05', '2025-11-12', '09:06:05', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-12 09:06:35', '2025-11-12', '09:06:35', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-01 09:00:00', '2025-11-01', '09:00:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-01 18:07:00', '2025-11-01', '18:07:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-03 09:36:00', '2025-11-03', '09:36:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-03 17:57:00', '2025-11-03', '17:57:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-04 09:08:00', '2025-11-04', '09:08:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-04 18:18:00', '2025-11-04', '18:18:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-05 09:07:00', '2025-11-05', '09:07:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-05 18:04:00', '2025-11-05', '18:04:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-06 09:03:00', '2025-11-06', '09:03:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-06 18:04:00', '2025-11-06', '18:04:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-08 09:09:00', '2025-11-08', '09:09:00', 'IN', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('2', '2025-11-08 17:11:00', '2025-11-08', '17:11:00', 'OUT', NULL, NULL, 'Pritesh patel', '2');
INSERT INTO `new_report` VALUES ('13', '2025-11-01 09:04:00', '2025-11-01', '09:04:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-01 17:53:00', '2025-11-01', '17:53:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-03 09:12:00', '2025-11-03', '09:12:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-03 17:51:00', '2025-11-03', '17:51:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-04 08:57:00', '2025-11-04', '08:57:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-04 17:52:00', '2025-11-04', '17:52:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-05 09:05:00', '2025-11-05', '09:05:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-05 17:51:00', '2025-11-05', '17:51:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-06 09:03:00', '2025-11-06', '09:03:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-06 17:51:00', '2025-11-06', '17:51:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-07 09:06:00', '2025-11-07', '09:06:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-07 17:51:00', '2025-11-07', '17:51:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-08 09:08:00', '2025-11-08', '09:08:00', 'IN', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('13', '2025-11-08 17:51:00', '2025-11-08', '17:51:00', 'OUT', NULL, NULL, 'PRIYANSHI PATEL', '13');
INSERT INTO `new_report` VALUES ('15', '2025-11-01 09:01:00', '2025-11-01', '09:01:00', 'IN', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-01 17:57:00', '2025-11-01', '17:57:00', 'OUT', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-03 09:13:00', '2025-11-03', '09:13:00', 'IN', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-03 17:55:00', '2025-11-03', '17:55:00', 'OUT', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-04 09:10:00', '2025-11-04', '09:10:00', 'IN', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-04 17:54:00', '2025-11-04', '17:54:00', 'OUT', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-05 09:17:00', '2025-11-05', '09:17:00', 'IN', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-05 17:54:00', '2025-11-05', '17:54:00', 'OUT', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-06 09:03:00', '2025-11-06', '09:03:00', 'IN', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-06 17:54:00', '2025-11-06', '17:54:00', 'OUT', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-07 09:08:00', '2025-11-07', '09:08:00', 'IN', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-07 17:56:00', '2025-11-07', '17:56:00', 'OUT', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-08 09:11:00', '2025-11-08', '09:11:00', 'IN', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('15', '2025-11-08 16:59:00', '2025-11-08', '16:59:00', 'OUT', NULL, NULL, 'NENCY B PATEL', '15');
INSERT INTO `new_report` VALUES ('16', '2025-11-01 09:01:00', '2025-11-01', '09:01:00', 'IN', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-01 17:57:00', '2025-11-01', '17:57:00', 'OUT', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-03 09:13:00', '2025-11-03', '09:13:00', 'IN', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-03 17:55:00', '2025-11-03', '17:55:00', 'OUT', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-04 09:10:00', '2025-11-04', '09:10:00', 'IN', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-04 17:54:00', '2025-11-04', '17:54:00', 'OUT', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-05 09:17:00', '2025-11-05', '09:17:00', 'IN', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-05 17:54:00', '2025-11-05', '17:54:00', 'OUT', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-06 09:03:00', '2025-11-06', '09:03:00', 'IN', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-06 17:55:00', '2025-11-06', '17:55:00', 'OUT', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-07 09:08:00', '2025-11-07', '09:08:00', 'IN', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-07 17:57:00', '2025-11-07', '17:57:00', 'OUT', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-08 09:11:00', '2025-11-08', '09:11:00', 'IN', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('16', '2025-11-08 16:59:00', '2025-11-08', '16:59:00', 'OUT', NULL, NULL, 'ZINAL N PATEL', '16');
INSERT INTO `new_report` VALUES ('17', '2025-11-01 09:01:00', '2025-11-01', '09:01:00', 'IN', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-01 17:57:00', '2025-11-01', '17:57:00', 'OUT', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-03 09:13:00', '2025-11-03', '09:13:00', 'IN', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-03 17:55:00', '2025-11-03', '17:55:00', 'OUT', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-04 09:11:00', '2025-11-04', '09:11:00', 'IN', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-04 17:54:00', '2025-11-04', '17:54:00', 'OUT', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-05 09:17:00', '2025-11-05', '09:17:00', 'IN', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-05 17:54:00', '2025-11-05', '17:54:00', 'OUT', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-06 09:03:00', '2025-11-06', '09:03:00', 'IN', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-06 17:55:00', '2025-11-06', '17:55:00', 'OUT', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-07 09:08:00', '2025-11-07', '09:08:00', 'IN', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-07 17:57:00', '2025-11-07', '17:57:00', 'OUT', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-08 09:12:00', '2025-11-08', '09:12:00', 'IN', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('17', '2025-11-08 17:00:00', '2025-11-08', '17:00:00', 'OUT', NULL, NULL, 'RUTI M PATEL', '17');
INSERT INTO `new_report` VALUES ('20', '2025-11-01 08:55:00', '2025-11-01', '08:55:00', 'IN', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-01 17:53:00', '2025-11-01', '17:53:00', 'OUT', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-03 09:14:00', '2025-11-03', '09:14:00', 'IN', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-03 17:51:00', '2025-11-03', '17:51:00', 'OUT', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-04 09:02:00', '2025-11-04', '09:02:00', 'IN', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-04 17:52:00', '2025-11-04', '17:52:00', 'OUT', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-05 09:05:00', '2025-11-05', '09:05:00', 'IN', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-05 17:50:00', '2025-11-05', '17:50:00', 'OUT', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-06 08:53:00', '2025-11-06', '08:53:00', 'IN', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-06 17:51:00', '2025-11-06', '17:51:00', 'OUT', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-07 08:49:00', '2025-11-07', '08:49:00', 'IN', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-07 17:51:00', '2025-11-07', '17:51:00', 'OUT', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-08 09:08:00', '2025-11-08', '09:08:00', 'IN', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('20', '2025-11-08 17:51:00', '2025-11-08', '17:51:00', 'OUT', NULL, NULL, 'MANSI B PATEL', '20');
INSERT INTO `new_report` VALUES ('21', '2025-11-01 09:03:00', '2025-11-01', '09:03:00', 'IN', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-01 17:57:00', '2025-11-01', '17:57:00', 'OUT', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-03 09:13:00', '2025-11-03', '09:13:00', 'IN', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-03 17:55:00', '2025-11-03', '17:55:00', 'OUT', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-04 09:05:00', '2025-11-04', '09:05:00', 'IN', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-04 13:27:00', '2025-11-04', '13:27:00', 'OUT', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-05 09:04:00', '2025-11-05', '09:04:00', 'IN', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-05 17:54:00', '2025-11-05', '17:54:00', 'OUT', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-06 08:54:00', '2025-11-06', '08:54:00', 'IN', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-06 17:55:00', '2025-11-06', '17:55:00', 'OUT', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-07 09:08:00', '2025-11-07', '09:08:00', 'IN', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-07 17:57:00', '2025-11-07', '17:57:00', 'OUT', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-08 09:08:00', '2025-11-08', '09:08:00', 'IN', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('21', '2025-11-08 17:51:00', '2025-11-08', '17:51:00', 'OUT', NULL, NULL, 'MANSI M RATHOD', '21');
INSERT INTO `new_report` VALUES ('23', '2025-11-01 08:55:00', '2025-11-01', '08:55:00', 'IN', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-01 17:53:00', '2025-11-01', '17:53:00', 'OUT', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-03 09:13:00', '2025-11-03', '09:13:00', 'IN', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-03 17:51:00', '2025-11-03', '17:51:00', 'OUT', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-04 09:02:00', '2025-11-04', '09:02:00', 'IN', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-04 17:52:00', '2025-11-04', '17:52:00', 'OUT', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-05 09:05:00', '2025-11-05', '09:05:00', 'IN', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-05 17:50:00', '2025-11-05', '17:50:00', 'OUT', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-06 08:53:00', '2025-11-06', '08:53:00', 'IN', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-06 17:51:00', '2025-11-06', '17:51:00', 'OUT', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-07 08:48:00', '2025-11-07', '08:48:00', 'IN', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-07 17:51:00', '2025-11-07', '17:51:00', 'OUT', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-08 09:08:00', '2025-11-08', '09:08:00', 'IN', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-08 17:51:00', '2025-11-08', '17:51:00', 'OUT', NULL, NULL, 'MEGHA S PATEL', '23');
INSERT INTO `new_report` VALUES ('23', '2025-11-12 17:51:28', '2025-11-12', '17:51:28', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-12 17:51:36', '2025-11-12', '17:51:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-12 17:53:32', '2025-11-12', '17:53:32', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-12 17:53:36', '2025-11-12', '17:53:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-12 17:53:40', '2025-11-12', '17:53:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-12 17:53:46', '2025-11-12', '17:53:46', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-12 18:07:01', '2025-11-12', '18:07:01', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-12 18:07:04', '2025-11-12', '18:07:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-13 08:48:08', '2025-11-13', '08:48:08', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-13 08:48:27', '2025-11-13', '08:48:27', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-13 08:48:35', '2025-11-13', '08:48:35', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-13 08:56:24', '2025-11-13', '08:56:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-13 09:03:01', '2025-11-13', '09:03:01', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-13 10:32:56', '2025-11-13', '10:32:56', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-13 10:33:03', '2025-11-13', '10:33:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-13 10:33:09', '2025-11-13', '10:33:09', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-13 13:36:54', '2025-11-13', '13:36:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-13 16:07:43', '2025-11-13', '16:07:43', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-13 17:51:34', '2025-11-13', '17:51:34', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-13 17:51:40', '2025-11-13', '17:51:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-13 17:52:20', '2025-11-13', '17:52:20', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-13 18:00:30', '2025-11-13', '18:00:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-13 18:00:35', '2025-11-13', '18:00:35', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-13 18:00:39', '2025-11-13', '18:00:39', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-13 18:07:40', '2025-11-13', '18:07:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-14 08:50:56', '2025-11-14', '08:50:56', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-14 08:51:03', '2025-11-14', '08:51:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-14 08:58:27', '2025-11-14', '08:58:27', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-14 09:01:10', '2025-11-14', '09:01:10', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-14 09:03:23', '2025-11-14', '09:03:23', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-14 09:03:27', '2025-11-14', '09:03:27', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-14 09:03:49', '2025-11-14', '09:03:49', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-14 09:04:20', '2025-11-14', '09:04:20', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-14 13:20:27', '2025-11-14', '13:20:27', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-14 13:20:42', '2025-11-14', '13:20:42', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-14 13:21:10', '2025-11-14', '13:21:10', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-14 17:52:17', '2025-11-14', '17:52:17', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-14 17:52:22', '2025-11-14', '17:52:22', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-14 17:52:25', '2025-11-14', '17:52:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-14 17:52:30', '2025-11-14', '17:52:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-14 18:14:55', '2025-11-14', '18:14:55', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-15 08:56:11', '2025-11-15', '08:56:11', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-15 08:56:16', '2025-11-15', '08:56:16', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-15 08:59:27', '2025-11-15', '08:59:27', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-15 09:05:28', '2025-11-15', '09:05:28', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-15 09:05:33', '2025-11-15', '09:05:33', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-15 09:05:41', '2025-11-15', '09:05:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-15 09:05:46', '2025-11-15', '09:05:46', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-15 09:10:13', '2025-11-15', '09:10:13', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-15 17:51:12', '2025-11-15', '17:51:12', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-15 17:51:17', '2025-11-15', '17:51:17', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-15 17:51:21', '2025-11-15', '17:51:21', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-15 18:00:00', '2025-11-15', '18:00:00', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-15 18:00:04', '2025-11-15', '18:00:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-15 18:00:13', '2025-11-15', '18:00:13', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-15 18:01:00', '2025-11-15', '18:01:00', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-17 08:53:39', '2025-11-17', '08:53:39', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-17 08:54:03', '2025-11-17', '08:54:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-17 08:54:12', '2025-11-17', '08:54:12', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-17 08:58:03', '2025-11-17', '08:58:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-17 08:58:08', '2025-11-17', '08:58:08', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-17 08:58:22', '2025-11-17', '08:58:22', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-17 09:03:07', '2025-11-17', '09:03:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-17 17:51:10', '2025-11-17', '17:51:10', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-17 17:51:20', '2025-11-17', '17:51:20', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-17 17:51:24', '2025-11-17', '17:51:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-17 17:51:32', '2025-11-17', '17:51:32', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-17 17:51:36', '2025-11-17', '17:51:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-17 17:51:40', '2025-11-17', '17:51:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-17 17:55:44', '2025-11-17', '17:55:44', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-17 17:55:47', '2025-11-17', '17:55:47', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-17 17:55:51', '2025-11-17', '17:55:51', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-17 17:56:02', '2025-11-17', '17:56:02', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-18 08:48:20', '2025-11-18', '08:48:20', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-18 08:48:27', '2025-11-18', '08:48:27', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-18 08:51:14', '2025-11-18', '08:51:14', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-18 08:54:54', '2025-11-18', '08:54:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-18 09:02:35', '2025-11-18', '09:02:35', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-18 09:03:52', '2025-11-18', '09:03:52', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-18 17:51:26', '2025-11-18', '17:51:26', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-18 17:51:34', '2025-11-18', '17:51:34', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-18 17:51:41', '2025-11-18', '17:51:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-18 17:54:04', '2025-11-18', '17:54:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-18 17:54:14', '2025-11-18', '17:54:14', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-18 17:54:19', '2025-11-18', '17:54:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-19 08:50:14', '2025-11-19', '08:50:14', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-19 08:50:23', '2025-11-19', '08:50:23', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-19 09:00:29', '2025-11-19', '09:00:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-19 09:03:19', '2025-11-19', '09:03:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-19 09:03:56', '2025-11-19', '09:03:56', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-19 09:08:30', '2025-11-19', '09:08:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-19 09:09:07', '2025-11-19', '09:09:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-19 17:51:21', '2025-11-19', '17:51:21', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-19 17:51:26', '2025-11-19', '17:51:26', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-19 17:51:30', '2025-11-19', '17:51:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-19 17:57:47', '2025-11-19', '17:57:47', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-19 17:57:52', '2025-11-19', '17:57:52', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-19 17:58:02', '2025-11-19', '17:58:02', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-19 17:58:08', '2025-11-19', '17:58:08', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-21 08:55:31', '2025-11-21', '08:55:31', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-21 08:55:37', '2025-11-21', '08:55:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-21 08:57:05', '2025-11-21', '08:57:05', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-21 09:00:48', '2025-11-21', '09:00:48', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-21 09:01:24', '2025-11-21', '09:01:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-21 09:01:28', '2025-11-21', '09:01:28', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-21 11:19:07', '2025-11-21', '11:19:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-21 10:10:57', '2025-11-21', '10:10:57', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-21 11:21:15', '2025-11-21', '11:21:15', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-11-21 10:10:43', '2025-11-21', '10:10:43', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-20 08:52:10', '2025-11-20', '08:52:10', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-20 08:52:15', '2025-11-20', '08:52:15', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-20 08:52:21', '2025-11-20', '08:52:21', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-20 09:03:05', '2025-11-20', '09:03:05', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-20 09:05:31', '2025-11-20', '09:05:31', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-20 09:05:37', '2025-11-20', '09:05:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-20 09:05:41', '2025-11-20', '09:05:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-20 13:02:37', '2025-11-20', '13:02:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-20 17:51:20', '2025-11-20', '17:51:20', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-20 17:51:25', '2025-11-20', '17:51:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-20 17:51:32', '2025-11-20', '17:51:32', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-20 17:53:18', '2025-11-20', '17:53:18', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-20 17:53:25', '2025-11-20', '17:53:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-20 17:53:30', '2025-11-20', '17:53:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-20 17:53:37', '2025-11-20', '17:53:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-11-22 17:05:47', '2025-11-22', '17:05:47', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-22 17:43:24', '2025-11-22', '17:43:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-22 09:03:55', '2025-11-22', '09:03:55', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-22 09:04:03', '2025-11-22', '09:04:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-22 09:04:17', '2025-11-22', '09:04:17', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-22 09:04:22', '2025-11-22', '09:04:22', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-22 09:04:26', '2025-11-22', '09:04:26', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-22 17:43:40', '2025-11-22', '17:43:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-22 09:04:29', '2025-11-22', '09:04:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-22 09:37:00', '2025-11-22', '09:37:00', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-11-22 10:10:01', '2025-11-22', '10:10:01', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-22 10:14:50', '2025-11-22', '10:14:50', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-22 10:15:00', '2025-11-22', '10:15:00', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-22 17:50:36', '2025-11-22', '17:50:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-22 17:50:40', '2025-11-22', '17:50:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-22 10:26:12', '2025-11-22', '10:26:12', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-22 17:05:25', '2025-11-22', '17:05:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-24 09:02:43', '2025-11-24', '09:02:43', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-24 09:02:47', '2025-11-24', '09:02:47', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-22 17:50:45', '2025-11-22', '17:50:45', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-24 09:05:30', '2025-11-24', '09:05:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-24 09:05:36', '2025-11-24', '09:05:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-24 09:15:36', '2025-11-24', '09:15:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-24 10:09:03', '2025-11-24', '10:09:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-11-24 10:15:28', '2025-11-24', '10:15:28', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-22 18:01:10', '2025-11-22', '18:01:10', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-24 11:44:23', '2025-11-24', '11:44:23', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-24 08:57:02', '2025-11-24', '08:57:02', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-24 09:02:37', '2025-11-24', '09:02:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-24 17:50:56', '2025-11-24', '17:50:56', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-24 17:51:09', '2025-11-24', '17:51:09', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-24 17:53:27', '2025-11-24', '17:53:27', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-24 17:53:37', '2025-11-24', '17:53:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-24 17:53:51', '2025-11-24', '17:53:51', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-24 18:01:58', '2025-11-24', '18:01:58', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-25 08:51:11', '2025-11-25', '08:51:11', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-25 08:59:09', '2025-11-25', '08:59:09', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-25 08:59:20', '2025-11-25', '08:59:20', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-25 08:59:51', '2025-11-25', '08:59:51', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-25 10:13:46', '2025-11-25', '10:13:46', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-25 10:13:59', '2025-11-25', '10:13:59', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-25 13:26:47', '2025-11-25', '13:26:47', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-25 14:09:33', '2025-11-25', '14:09:33', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-25 17:50:56', '2025-11-25', '17:50:56', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-25 17:51:03', '2025-11-25', '17:51:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-25 17:52:43', '2025-11-25', '17:52:43', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-25 17:52:51', '2025-11-25', '17:52:51', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-25 18:01:13', '2025-11-25', '18:01:13', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-26 09:14:41', '2025-11-26', '09:14:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-26 09:14:47', '2025-11-26', '09:14:47', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-26 09:14:55', '2025-11-26', '09:14:55', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-26 09:15:00', '2025-11-26', '09:15:00', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-26 09:15:09', '2025-11-26', '09:15:09', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-26 09:15:15', '2025-11-26', '09:15:15', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-26 10:13:40', '2025-11-26', '10:13:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-26 10:19:38', '2025-11-26', '10:19:38', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-26 17:56:39', '2025-11-26', '17:56:39', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-26 17:56:50', '2025-11-26', '17:56:50', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-26 17:57:22', '2025-11-26', '17:57:22', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-26 17:50:52', '2025-11-26', '17:50:52', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-27 08:51:04', '2025-11-27', '08:51:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-27 08:51:11', '2025-11-27', '08:51:11', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-27 08:56:41', '2025-11-27', '08:56:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-27 09:03:26', '2025-11-27', '09:03:26', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-27 09:09:55', '2025-11-27', '09:09:55', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-27 09:09:59', '2025-11-27', '09:09:59', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-27 09:10:05', '2025-11-27', '09:10:05', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-27 09:10:12', '2025-11-27', '09:10:12', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-27 10:07:25', '2025-11-27', '10:07:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-26 17:57:00', '2025-11-26', '17:57:00', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-27 10:38:24', '2025-11-27', '10:38:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-11-27 10:09:52', '2025-11-27', '10:09:52', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-26 17:56:54', '2025-11-26', '17:56:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-27 11:44:09', '2025-11-27', '11:44:09', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-27 17:51:48', '2025-11-27', '17:51:48', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-27 17:51:54', '2025-11-27', '17:51:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-27 17:52:01', '2025-11-27', '17:52:01', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-27 17:53:53', '2025-11-27', '17:53:53', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-27 17:53:58', '2025-11-27', '17:53:58', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-27 17:54:13', '2025-11-27', '17:54:13', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-27 17:54:21', '2025-11-27', '17:54:21', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-27 18:01:01', '2025-11-27', '18:01:01', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-28 08:50:41', '2025-11-28', '08:50:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-28 08:50:50', '2025-11-28', '08:50:50', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-28 08:53:29', '2025-11-28', '08:53:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-28 08:56:24', '2025-11-28', '08:56:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-28 09:02:24', '2025-11-28', '09:02:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-28 09:07:41', '2025-11-28', '09:07:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-28 09:09:37', '2025-11-28', '09:09:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-28 09:09:41', '2025-11-28', '09:09:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-28 10:06:58', '2025-11-28', '10:06:58', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-11-28 10:17:14', '2025-11-28', '10:17:14', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-28 11:46:34', '2025-11-28', '11:46:34', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-28 11:46:42', '2025-11-28', '11:46:42', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-28 12:38:34', '2025-11-28', '12:38:34', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-28 17:50:52', '2025-11-28', '17:50:52', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-28 17:51:03', '2025-11-28', '17:51:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-28 17:51:07', '2025-11-28', '17:51:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('16', '2025-11-28 17:55:41', '2025-11-28', '17:55:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-28 17:55:47', '2025-11-28', '17:55:47', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-28 17:55:58', '2025-11-28', '17:55:58', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-28 17:56:02', '2025-11-28', '17:56:02', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-28 17:59:33', '2025-11-28', '17:59:33', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('15', '2025-11-29 08:57:07', '2025-11-29', '08:57:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `new_report` VALUES ('17', '2025-11-29 08:57:56', '2025-11-29', '08:57:56', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RUTI M PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-11-29 09:05:27', '2025-11-29', '09:05:27', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-11-29 09:06:12', '2025-11-29', '09:06:12', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-11-29 09:06:17', '2025-11-29', '09:06:17', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-11-29 09:06:21', '2025-11-29', '09:06:21', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-11-29 10:06:22', '2025-11-29', '10:06:22', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-11-29 10:17:42', '2025-11-29', '10:17:42', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-11-29 10:43:30', '2025-11-29', '10:43:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('152', '2025-11-29 11:13:32', '2025-11-29', '11:13:32', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('21', '2025-11-29 13:37:51', '2025-11-29', '13:37:51', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-01 17:51:04', '2025-12-01', '17:51:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-01 17:51:11', '2025-12-01', '17:51:11', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-01 17:51:18', '2025-12-01', '17:51:18', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-01 18:03:40', '2025-12-01', '18:03:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-02 08:52:54', '2025-12-02', '08:52:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-02 08:53:34', '2025-12-02', '08:53:34', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-02 08:53:39', '2025-12-02', '08:53:39', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-02 09:18:25', '2025-12-02', '09:18:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-02 10:16:02', '2025-12-02', '10:16:02', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-02 10:30:05', '2025-12-02', '10:30:05', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-02 10:59:04', '2025-12-02', '10:59:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-02 17:51:36', '2025-12-02', '17:51:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-02 17:51:41', '2025-12-02', '17:51:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-02 17:51:46', '2025-12-02', '17:51:46', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-02 18:43:49', '2025-12-02', '18:43:49', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-02 18:44:32', '2025-12-02', '18:44:32', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-03 08:56:37', '2025-12-03', '08:56:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-03 08:56:43', '2025-12-03', '08:56:43', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-03 10:13:22', '2025-12-03', '10:13:22', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-03 10:21:33', '2025-12-03', '10:21:33', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-03 10:45:15', '2025-12-03', '10:45:15', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-03 12:50:07', '2025-12-03', '12:50:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-03 17:52:10', '2025-12-03', '17:52:10', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-03 17:52:14', '2025-12-03', '17:52:14', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-03 18:11:57', '2025-12-03', '18:11:57', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-04 08:59:12', '2025-12-04', '08:59:12', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-04 08:59:19', '2025-12-04', '08:59:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-04 08:59:25', '2025-12-04', '08:59:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-04 10:18:33', '2025-12-04', '10:18:33', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-04 10:23:37', '2025-12-04', '10:23:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-04 10:52:46', '2025-12-04', '10:52:46', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-04 17:50:53', '2025-12-04', '17:50:53', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-04 17:50:57', '2025-12-04', '17:50:57', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-04 17:51:02', '2025-12-04', '17:51:02', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-05 08:56:04', '2025-12-05', '08:56:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-05 08:56:11', '2025-12-05', '08:56:11', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-05 09:09:16', '2025-12-05', '09:09:16', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-05 10:20:29', '2025-12-05', '10:20:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-05 12:06:55', '2025-12-05', '12:06:55', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-05 14:41:19', '2025-12-05', '14:41:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-05 17:45:59', '2025-12-05', '17:45:59', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-05 17:46:06', '2025-12-05', '17:46:06', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-05 17:56:24', '2025-12-05', '17:56:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-06 09:09:19', '2025-12-06', '09:09:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-06 09:09:24', '2025-12-06', '09:09:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-06 09:25:04', '2025-12-06', '09:25:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-06 16:08:10', '2025-12-06', '16:08:10', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-06 16:33:55', '2025-12-06', '16:33:55', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-06 16:34:00', '2025-12-06', '16:34:00', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-08 08:51:11', '2025-12-08', '08:51:11', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-08 08:51:46', '2025-12-08', '08:51:46', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-08 08:51:52', '2025-12-08', '08:51:52', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-08 09:01:41', '2025-12-08', '09:01:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-08 10:20:11', '2025-12-08', '10:20:11', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-08 10:30:29', '2025-12-08', '10:30:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-08 17:52:12', '2025-12-08', '17:52:12', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-08 17:52:19', '2025-12-08', '17:52:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-08 17:52:25', '2025-12-08', '17:52:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-08 18:00:08', '2025-12-08', '18:00:08', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-09 08:53:30', '2025-12-09', '08:53:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-09 09:16:45', '2025-12-09', '09:16:45', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-09 09:16:49', '2025-12-09', '09:16:49', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-09 09:16:54', '2025-12-09', '09:16:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-09 10:14:25', '2025-12-09', '10:14:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-09 10:25:07', '2025-12-09', '10:25:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-09 17:50:58', '2025-12-09', '17:50:58', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-09 17:51:04', '2025-12-09', '17:51:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-09 17:51:09', '2025-12-09', '17:51:09', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-09 18:06:24', '2025-12-09', '18:06:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-10 08:52:04', '2025-12-10', '08:52:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-10 09:03:21', '2025-12-10', '09:03:21', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-10 09:03:25', '2025-12-10', '09:03:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-10 09:03:29', '2025-12-10', '09:03:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-10 10:23:36', '2025-12-10', '10:23:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-10 17:49:19', '2025-12-10', '17:49:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-10 17:49:29', '2025-12-10', '17:49:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-10 17:49:35', '2025-12-10', '17:49:35', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-10 17:56:18', '2025-12-10', '17:56:18', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-10 17:56:25', '2025-12-10', '17:56:25', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-11 08:52:41', '2025-12-11', '08:52:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-11 09:06:26', '2025-12-11', '09:06:26', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-11 09:06:32', '2025-12-11', '09:06:32', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-11 09:06:37', '2025-12-11', '09:06:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-11 10:12:19', '2025-12-11', '10:12:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-11 10:29:07', '2025-12-11', '10:29:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-11 11:27:40', '2025-12-11', '11:27:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-11 13:36:59', '2025-12-11', '13:36:59', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-11 17:51:42', '2025-12-11', '17:51:42', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-11 17:51:49', '2025-12-11', '17:51:49', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-11 18:23:38', '2025-12-11', '18:23:38', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-11 18:34:17', '2025-12-11', '18:34:17', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-11 18:45:50', '2025-12-11', '18:45:50', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-12 09:10:55', '2025-12-12', '09:10:55', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-12 09:11:02', '2025-12-12', '09:11:02', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-12 09:11:06', '2025-12-12', '09:11:06', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-12 09:19:54', '2025-12-12', '09:19:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-12 10:18:23', '2025-12-12', '10:18:23', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-12 10:40:07', '2025-12-12', '10:40:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-12 11:04:44', '2025-12-12', '11:04:44', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-12 17:48:20', '2025-12-12', '17:48:20', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-12 17:48:24', '2025-12-12', '17:48:24', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-12 17:48:29', '2025-12-12', '17:48:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-12 18:08:07', '2025-12-12', '18:08:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-12 18:48:18', '2025-12-12', '18:48:18', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-13 09:08:31', '2025-12-13', '09:08:31', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-13 09:08:42', '2025-12-13', '09:08:42', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-13 09:08:54', '2025-12-13', '09:08:54', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-13 09:09:13', '2025-12-13', '09:09:13', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-13 10:44:36', '2025-12-13', '10:44:36', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-13 11:02:37', '2025-12-13', '11:02:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-13 17:34:37', '2025-12-13', '17:34:37', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-13 17:34:41', '2025-12-13', '17:34:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-13 17:38:04', '2025-12-13', '17:38:04', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-13 17:38:26', '2025-12-13', '17:38:26', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-15 08:55:58', '2025-12-15', '08:55:58', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-15 08:56:18', '2025-12-15', '08:56:18', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-15 09:03:59', '2025-12-15', '09:03:59', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-15 09:04:03', '2025-12-15', '09:04:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-15 10:09:29', '2025-12-15', '10:09:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-15 10:10:30', '2025-12-15', '10:10:30', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-15 10:16:19', '2025-12-15', '10:16:19', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('WL54', '2025-12-15 10:20:40', '2025-12-15', '10:20:40', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Nidhi Kansara', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-15 13:20:01', '2025-12-15', '13:20:01', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-15 17:45:05', '2025-12-15', '17:45:05', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-15 17:45:09', '2025-12-15', '17:45:09', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-15 17:56:29', '2025-12-15', '17:56:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('WL54', '2025-12-15 18:30:41', '2025-12-15', '18:30:41', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Nidhi Kansara', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-15 18:53:50', '2025-12-15', '18:53:50', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-15 18:53:58', '2025-12-15', '18:53:58', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('2', '2025-12-16 08:59:03', '2025-12-16', '08:59:03', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Pritesh patel', '');
INSERT INTO `new_report` VALUES ('13', '2025-12-16 09:04:29', '2025-12-16', '09:04:29', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'PRIYANSHI PATEL', '');
INSERT INTO `new_report` VALUES ('20', '2025-12-16 09:04:33', '2025-12-16', '09:04:33', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI B PATEL', '');
INSERT INTO `new_report` VALUES ('23', '2025-12-16 09:04:38', '2025-12-16', '09:04:38', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MEGHA S PATEL', '');
INSERT INTO `new_report` VALUES ('WL62', '2025-12-16 09:46:56', '2025-12-16', '09:46:56', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Yash Desai', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-16 10:08:09', '2025-12-16', '10:08:09', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');
INSERT INTO `new_report` VALUES ('WL54', '2025-12-16 10:28:18', '2025-12-16', '10:28:18', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Nidhi Kansara', '');
INSERT INTO `new_report` VALUES ('152', '2025-12-16 10:59:53', '2025-12-16', '10:59:53', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `new_report` VALUES ('WL64', '2025-12-16 11:03:31', '2025-12-16', '11:03:31', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Aarchie Soni', '');
INSERT INTO `new_report` VALUES ('AI96', '2025-12-16 11:27:07', '2025-12-16', '11:27:07', 'IN', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'Dipanshu Bharatia', '');

-- ----------------------------
-- Table structure for report
-- ----------------------------
DROP TABLE IF EXISTS `report`;
CREATE TABLE `report`  (
  `id` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `datetime` datetime NULL DEFAULT NULL,
  `date` date NULL DEFAULT NULL,
  `time` time NULL DEFAULT NULL,
  `direction` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `device_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `device_serial_no` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `person_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `card_no` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of report
-- ----------------------------
INSERT INTO `report` VALUES ('15', '2025-11-10 17:56:26', '2025-11-10', '17:56:26', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'NENCY B PATEL ', '');
INSERT INTO `report` VALUES ('16', '2025-11-10 17:56:12', '2025-11-10', '17:56:12', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'ZINAL N PATEL', '');
INSERT INTO `report` VALUES ('21', '2025-11-10 17:56:21', '2025-11-10', '17:56:21', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'MANSI M RATHOD', '');
INSERT INTO `report` VALUES ('152', '2025-11-10 18:01:13', '2025-11-10', '18:01:13', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');
INSERT INTO `report` VALUES ('152', '2025-11-10 18:01:42', '2025-11-10', '18:01:42', 'In', 'atyainno', 'DS-K1T320EFWX20240701V030502ENFM6783265', 'RAJESH BHAI', '');

-- ----------------------------
-- Triggers structure for table report
-- ----------------------------
DROP TRIGGER IF EXISTS `assign_direction`;
delimiter ;;
CREATE TRIGGER `assign_direction` BEFORE INSERT ON `report` FOR EACH ROW BEGIN
  DECLARE last_direction VARCHAR(10);
  SELECT direction INTO last_direction
  FROM attendance_logs
  WHERE person_name = NEW.person_name
    AND date = CURDATE()
  ORDER BY datetime DESC LIMIT 1;

  IF last_direction = 'In' THEN
    SET NEW.direction = 'Out';
  ELSE
    SET NEW.direction = 'In';
  END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
