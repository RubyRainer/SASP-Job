CREATE TABLE IF NOT EXISTS `sasp_incidents` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `incident_id` VARCHAR(32) NOT NULL,
  `title` VARCHAR(120) NOT NULL,
  `category` VARCHAR(64) NOT NULL,
  `details` TEXT NOT NULL,
  `author` VARCHAR(80) NOT NULL,
  `payload` LONGTEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `incident_id_unique` (`incident_id`)
);

CREATE TABLE IF NOT EXISTS `sasp_arrests` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `arrest_id` VARCHAR(32) NOT NULL,
  `officer_id` VARCHAR(80) NOT NULL,
  `target_id` VARCHAR(80) NOT NULL,
  `charges` LONGTEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `arrest_id_unique` (`arrest_id`)
);
