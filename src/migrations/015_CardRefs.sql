USE Fitboa;
DROP TABLE IF EXISTS CardRefs;
CREATE TABLE IF NOT EXISTS CardRefs
(
    CardCd VARCHAR(2) NOT NULL,
    Name VARCHAR(128) NOT NULL
) ENGINE = INNODB
DEFAULT CHARSET=UTF8;

INSERT INTO CardRefs (CardCd, Name) VALUES ('11', '비씨카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('14', '신한카드(구.LG카드 포함)');
INSERT INTO CardRefs (CardCd, Name) VALUES ('22', '글로벌 MASTER');
INSERT INTO CardRefs (CardCd, Name) VALUES ('24', '글로벌 아멕스');
INSERT INTO CardRefs (CardCd, Name) VALUES ('26', '중국은련카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('33', '전북카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('35', '산업카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('41', 'NH카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('48', '신협체크카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('52', '제주카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('55', '케이뱅크카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('71', '우체국체크');
INSERT INTO CardRefs (CardCd, Name) VALUES ('01', '외환카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('04', '현대카드');

INSERT INTO CardRefs (CardCd, Name) VALUES ('12', '삼성카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('21', '글로벌 VISA');
INSERT INTO CardRefs (CardCd, Name) VALUES ('23', '글로벌 JCB');
INSERT INTO CardRefs (CardCd, Name) VALUES ('25', '글로벌 다이너스');
INSERT INTO CardRefs (CardCd, Name) VALUES ('32', '광주카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('34', '하나카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('38', '우리카드 (44 사용 시 변경필요)');
INSERT INTO CardRefs (CardCd, Name) VALUES ('43', '씨티카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('51', '수협카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('54', 'MG새마을금고체크');
INSERT INTO CardRefs (CardCd, Name) VALUES ('56', '카카오뱅크');
INSERT INTO CardRefs (CardCd, Name) VALUES ('95', '저축은행체크');
INSERT INTO CardRefs (CardCd, Name) VALUES ('03', '롯데카드');
INSERT INTO CardRefs (CardCd, Name) VALUES ('06', '국민카드');
