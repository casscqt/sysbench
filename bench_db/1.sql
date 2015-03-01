-- MySQL dump 10.13  Distrib 5.1.68, for pc-linux-gnu (i686)
--
-- Host: localhost    Database: dbbench
-- ------------------------------------------------------
-- Server version	5.1.68-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bench_test_rawdata`
--

DROP TABLE IF EXISTS `bench_test_rawdata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bench_test_rawdata` (
  `id` bigint(13) NOT NULL AUTO_INCREMENT,
  `bench_id` int(10) DEFAULT NULL,
  `bench_type` tinyint(4) DEFAULT NULL,
  `bench_menthod` tinyint(4) DEFAULT NULL,
  `threads` smallint(6) DEFAULT NULL COMMENT '测试的并发线程数',
  `table_size` bigint(12) DEFAULT NULL COMMENT '表大小，以w行为单表示，若为区间范围的表大小，则记录最大区间',
  `tps` int(10) DEFAULT NULL COMMENT '每秒事务数',
  `avg_resp_time` int(10) DEFAULT NULL COMMENT '平均响应时间',
  `extra_stat` varchar(500) DEFAULT NULL COMMENT '测试过程中通过采集数据库状态变量的统计值',
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bench_id` (`bench_id`,`bench_menthod`),
  CONSTRAINT `bench_test_rawdata_ref_bench_model` FOREIGN KEY (`bench_id`) REFERENCES `bench_model` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8 COMMENT='基准测试入库的原始数据';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bench_test_rawdata`
--

LOCK TABLES `bench_test_rawdata` WRITE;
/*!40000 ALTER TABLE `bench_test_rawdata` DISABLE KEYS */;
INSERT INTO `bench_test_rawdata` VALUES (1,5,1,1,4,100000,80,274,'s:911/i:65/d:65/u:130','2013-04-18 14:01:49'),(2,5,1,1,8,100000,83,381,'s:911/i:65/d:65/u:130','2013-04-18 14:01:49'),(3,5,1,1,16,100000,86,467,'s:911/i:65/d:65/u:130','2013-04-18 14:01:49'),(4,5,1,1,32,100000,71,3879,'s:911/i:65/d:65/u:130','2013-04-18 14:01:50'),(5,5,1,1,4,200000,75,384,'s:911/i:65/d:65/u:130','2013-04-18 14:01:50'),(6,5,1,1,8,200000,92,267,'s:911/i:65/d:65/u:130','2013-04-18 14:01:50'),(7,5,1,1,16,200000,76,1770,'s:911/i:65/d:65/u:130','2013-04-18 14:01:51'),(8,5,1,1,32,200000,60,6843,'s:911/i:65/d:65/u:130','2013-04-18 14:01:51'),(9,5,1,1,4,300000,44,745,'s:911/i:65/d:65/u:130','2013-04-18 14:01:51'),(10,5,1,1,8,300000,65,508,'s:911/i:65/d:65/u:130','2013-04-18 14:01:51'),(11,5,1,1,16,300000,74,563,'s:911/i:65/d:65/u:130','2013-04-18 14:01:52'),(12,5,1,1,32,300000,74,961,'s:911/i:65/d:65/u:130','2013-04-18 14:01:52'),(13,5,1,3,4,100000,400,41,'s:0/i:7/d:0/u:342','2013-04-18 16:08:05'),(14,5,1,3,8,100000,430,59,'s:0/i:7/d:0/u:342','2013-04-18 16:08:05'),(15,5,1,3,16,100000,425,184,'s:0/i:7/d:0/u:342','2013-04-18 16:08:06'),(16,5,1,3,32,100000,442,293,'s:0/i:7/d:0/u:342','2013-04-18 16:08:06'),(17,5,1,3,4,200000,436,168,'s:0/i:7/d:0/u:342','2013-04-18 16:08:06'),(18,5,1,3,8,200000,347,125,'s:0/i:7/d:0/u:342','2013-04-18 16:08:07'),(19,5,1,3,16,200000,408,192,'s:0/i:7/d:0/u:342','2013-04-18 16:08:07'),(20,5,1,3,32,200000,415,539,'s:0/i:7/d:0/u:342','2013-04-18 16:08:07'),(21,5,1,3,4,300000,302,173,'s:0/i:7/d:0/u:342','2013-04-18 16:08:08'),(22,5,1,3,8,300000,368,128,'s:0/i:7/d:0/u:342','2013-04-18 16:08:08'),(23,5,1,3,16,300000,321,549,'s:0/i:7/d:0/u:342','2013-04-18 16:08:08'),(24,5,1,3,32,300000,444,379,'s:0/i:7/d:0/u:342','2013-04-18 16:08:08'),(25,5,1,4,4,100000,431,56,'s:0/i:0/d:0/u:387','2013-04-18 20:36:16'),(26,5,1,4,8,100000,481,215,'s:0/i:0/d:0/u:387','2013-04-18 20:36:17'),(27,5,1,4,16,100000,534,96,'s:0/i:0/d:0/u:387','2013-04-18 20:36:17'),(28,5,1,4,32,100000,569,169,'s:0/i:0/d:0/u:387','2013-04-18 20:36:17'),(29,5,1,4,4,200000,374,107,'s:0/i:0/d:0/u:387','2013-04-18 20:36:17'),(30,5,1,4,8,200000,422,100,'s:0/i:0/d:0/u:387','2013-04-18 20:36:18'),(31,5,1,4,16,200000,469,149,'s:0/i:0/d:0/u:387','2013-04-18 20:36:18'),(32,5,1,4,32,200000,477,358,'s:0/i:0/d:0/u:387','2013-04-18 20:36:18'),(33,5,1,4,4,300000,328,165,'s:0/i:0/d:0/u:387','2013-04-18 20:36:18'),(34,5,1,4,8,300000,408,113,'s:0/i:0/d:0/u:387','2013-04-18 20:36:19'),(35,5,1,4,16,300000,433,265,'s:0/i:0/d:0/u:387','2013-04-18 20:36:20'),(36,5,1,4,32,300000,441,577,'s:0/i:0/d:0/u:387','2013-04-18 20:36:20'),(37,5,1,8,4,100000,3662,94,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:37'),(38,5,1,8,8,100000,4439,57,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:38'),(39,5,1,8,16,100000,5354,11,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:38'),(40,5,1,8,32,100000,5381,26,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:38'),(41,5,1,8,4,200000,3661,87,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:38'),(42,5,1,8,8,200000,3679,143,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:39'),(43,5,1,8,16,200000,5472,92,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:39'),(44,5,1,8,32,200000,5334,24,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:39'),(45,5,1,8,4,300000,1715,215,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:39'),(46,5,1,8,8,300000,2595,186,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:39'),(47,5,1,8,16,300000,3400,1059,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:40'),(48,5,1,8,32,300000,3467,1230,'s:2725/i:0/d:0/u:0','2013-04-18 22:41:40');
/*!40000 ALTER TABLE `bench_test_rawdata` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-04-19  0:17:19
