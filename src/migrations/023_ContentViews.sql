USE Fitboa;
DROP TABLE IF EXISTS ContentViews;
CREATE TABLE IF NOT EXISTS ContentViews
(
    Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,

    ContentId INT NOT NULL,

    Year INT NOT NULL,
    Month INT NOT NULL,

    Views INT NOT NULL DEFAULT 0,

    FOREIGN KEY(ContentId) REFERENCES Contents(Id) ON DELETE CASCADE
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;