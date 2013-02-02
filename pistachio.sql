SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE `players` (
  `Key` tinyint(10) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `SteamID` varchar(64) NOT NULL,
  `Karma` tinyint(4) NOT NULL,
  `Money` int(150) NOT NULL,
  `Bank` int(150) NOT NULL,
  `Title` text NOT NULL,
  `Particle` varchar(250) NOT NULL,
  `Color` varchar(50) NOT NULL,
  `Hat` varchar(250) NOT NULL,
  `Model` varchar(250) NOT NULL,
  PRIMARY KEY (`Key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;