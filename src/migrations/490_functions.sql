USE Fitboa;

DROP FUNCTION IF EXISTS BodyCodeToBodyType;

DELIMITER $$
CREATE FUNCTION BodyCodeToBodyType(Code INT) RETURNS VARCHAR(6)
BEGIN
    RETURN CASE 
        WHEN Code = 0 THEN '무료'
        WHEN Code = 1 THEN 'A자형'
        WHEN Code = 2 THEN 'I자형'
        WHEN Code = 3 THEN 'O자형'
        WHEN Code = 4 THEN 'V자형'
        ELSE ''
    END;
END $$
DELIMITER ;





DROP FUNCTION IF EXISTS CardCdToCardName;

DELIMITER $$
CREATE FUNCTION CardCdToCardName(Code VARCHAR(2)) RETURNS VARCHAR(64)
BEGIN
    RETURN CASE 
        WHEN Code = '11' THEN 'BC카드'
        WHEN Code = '12' THEN '삼성카드'
        WHEN Code = '14' THEN '신한카드'
        WHEN Code = '15' THEN '한미카드'
        WHEN Code = '16' THEN 'NH카드'
        WHEN Code = '17' THEN '하나 SK카드'
        WHEN Code = '21' THEN '글로벌 VISA'
        WHEN Code = '22' THEN '글로벌 MASTER'
        WHEN Code = '23' THEN '글로벌 JCB'
        WHEN Code = '24' THEN '글로벌 아멕스'
        WHEN Code = '25' THEN '글로벌 다이너스'
        WHEN Code = '91' THEN '네이버포인트(포인트 100% 사용)'
        WHEN Code = '93' THEN '토스머니(포인트 100% 사용)'
        WHEN Code = '94' THEN 'SSG머니(포인트 100% 사용)'
        WHEN Code = '96' THEN '엘포인트(포인트 100% 사용)'
        WHEN Code = '97' THEN '카카오머니'
        WHEN Code = '98' THEN '페이코(포인트 100% 사용)'
        WHEN Code = '01' THEN '외환카드'
        WHEN Code = '03' THEN '롯데카드'
        WHEN Code = '04' THEN '현대카드'
        WHEN Code = '06' THEN '국민카드'
        ELSE ''
    END;
END $$
DELIMITER ;
