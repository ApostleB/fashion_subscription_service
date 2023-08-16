#source /home/fitboa/Fitboa/src/migrations/000_migration.sql;


source /home/fitboa/Fitboa/src/migrations/001_createdb.sql;

DROP TABLE IF EXISTS CustomerServices;
DROP TABLE IF EXISTS UserSecessions;
DROP TABLE IF EXISTS InquiryImages;
DROP TABLE IF EXISTS Inquiries;
DROP TABLE IF EXISTS UserContentViews;
DROP TABLE IF EXISTS Bookmarks;
DROP TABLE IF EXISTS ContentReviewImages;
DROP TABLE IF EXISTS ContentViews;
DROP TABLE IF EXISTS ContentReviews;
DROP TABLE IF EXISTS ContentImages;
DROP TABLE IF EXISTS Contents;
DROP TABLE IF EXISTS CardRefs;
DROP TABLE IF EXISTS Merchants;
DROP TABLE IF EXISTS Cards;
DROP TABLE IF EXISTS Promotions;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS BodyTypeServices;
DROP TABLE IF EXISTS FirstDeliveries;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS VerifyLogs;


source /home/fitboa/Fitboa/src/migrations/004_verifylogs.sql;
source /home/fitboa/Fitboa/src/migrations/005_users.sql;
source /home/fitboa/Fitboa/src/migrations/007_FirstDeliveries.sql;
source /home/fitboa/Fitboa/src/migrations/008_BodyTypeServices.sql;
source /home/fitboa/Fitboa/src/migrations/010_products.sql;
source /home/fitboa/Fitboa/src/migrations/011_promotions.sql;
source /home/fitboa/Fitboa/src/migrations/012_Cards.sql;
source /home/fitboa/Fitboa/src/migrations/013_Merchants.sql;
source /home/fitboa/Fitboa/src/migrations/015_CardRefs.sql;
source /home/fitboa/Fitboa/src/migrations/020_Contents.sql;
source /home/fitboa/Fitboa/src/migrations/021_ContentImages.sql;
source /home/fitboa/Fitboa/src/migrations/022_ContentReviews.sql;
source /home/fitboa/Fitboa/src/migrations/023_ContentViews.sql;
source /home/fitboa/Fitboa/src/migrations/024_ContentReviewImages.sql;
source /home/fitboa/Fitboa/src/migrations/040_Bookmarks.sql;
source /home/fitboa/Fitboa/src/migrations/050_UserContentViews.sql;
source /home/fitboa/Fitboa/src/migrations/060_Inquiries.sql;
source /home/fitboa/Fitboa/src/migrations/061_InquiryImages.sql;
source /home/fitboa/Fitboa/src/migrations/080_UserSecessions.sql;
source /home/fitboa/Fitboa/src/migrations/100_CustomerServices.sql;

source /home/fitboa/Fitboa/src/migrations/490_functions.sql;
source /home/fitboa/Fitboa/src/migrations/500_procedures.sql;
source /home/fitboa/Fitboa/src/migrations/501_AdminProcedures.sql;
source /home/fitboa/Fitboa/src/migrations/502_PayProcedures.sql;
source /home/fitboa/Fitboa/src/migrations/503_PayProcedures2.sql;
source /home/fitboa/Fitboa/src/migrations/505_Triggers.sql;
