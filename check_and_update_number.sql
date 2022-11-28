USE girl_front_line;
/*按照number_and_lv之格式寫入temp_num_lv.txt，ftp至/var/lib/mysql-files/temp_number_and_lv.csv*/
/*CREATE TABLE temp_number_and_lv*/
CREATE TABLE temp_number_and_lv LIKE number_and_lv
;

LOAD DATA INFILE '/var/lib/mysql-files/temp_number_and_lv.txt'
INTO TABLE temp_number_and_lv
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
ignore 1 lines
(gunname,Dummy_link,inventory,LV,MODIFICATION);
/* 一、-找出沒有在id_gunname table 之資訊 gunname*/
SELECT
    A.gunname
FROM
    temp_number_and_lv A
    left join
        id_m_gunname B
        on
            A.gunname = B.gunname
WHERE
    B.gunname is NULL
;

/*A 為temp_number_and_lv , B 為 id_m_gunname*/
/*SELECT * FROM temp_number_and_lv A left join id_m_gunname B on A.gunname = B.gunname WHERE B.gunname is NULL;*/
/*待更新id_m_gunname名單*/

CREATE table 
 temp_insert_id 
(
temp_id INT ,
gunname VARCHAR(50) CHARACTER SET utf8mb4 collate  utf8mb4_unicode_ci
);

/*不要加 ";"把上面查詢註釋結果插入 ( INSERT subquery to table temp_insert_id)*/
INSERT INTO temp_insert_id
    (gunname
    )
SELECT
    A.gunname
FROM
    temp_number_and_lv A
    left join
        id_m_gunname B
        on
            A.gunname = B.gunname
WHERE
    B.gunname is NULL
;

/*export temp_insert_id,FTP至local*/
select *
from
    temp_insert_id
INTO
    OUTFILE '/var/lib/mysql-files/temp_insert_id.csv'
;

/*====================================================================================*/
/*二、update*/
/*下面為數量改變update */
/*SELECT A.gunname FROM temp_number_and_lv A inner join number_and_lv B on A.gunname = B.gunname ;*/
SELECT
    A.gunname
FROM
    temp_number_and_lv A
    inner join
        number_and_lv B
        on
            A.gunname = B.gunname
;

UPDATE
    temp_number_and_lv
    JOIN
        number_and_lv
using (gunname)
SET number_and_lv.Dummy_link  =temp_number_and_lv.Dummy_link
  , number_and_lv.inventory   =temp_number_and_lv.inventory
  , number_and_lv.LV          =temp_number_and_lv.LV
  , number_and_lv.MODIFICATION=temp_number_and_lv.MODIFICATION
;

/*=================================================================================================*/
/*三、insert*/
/*2次過濾*/
CREATE TABLE temp_insert_num(
  gunname VARCHAR(50) CHARACTER SET utf8mb4 collate  utf8mb4_unicode_ci,
 Dummy_link VARCHAR(50) CHARACTER SET utf8mb4 collate  utf8mb4_unicode_ci,
 inventory INT,
  LV INT,
 MODIFICATION VARCHAR(50) CHARACTER SET utf8mb4 collate  utf8mb4_unicode_ci
)
;

INSERT INTO temp_insert_num
SELECT
    A.gunname
  , A.Dummy_link
  , A.inventory
  , A.LV
  , A.MODIFICATION
FROM
    temp_number_and_lv A
    left join
        temp_insert_id B
        on
            A.gunname = B.gunname
WHERE
    B.gunname is NULL
;

INSERT INTO number_and_lv
    (gunname
      , Dummy_link
      , inventory
      , LV
      , MODIFICATION
    )
SELECT
    A.gunname
  , A.Dummy_link
  , A.inventory
  , A.LV
  , A.MODIFICATION
FROM
    temp_insert_num A
    left join
        number_and_lv B
        on
            A.gunname = B.gunname
WHERE
    B.gunname is NULL
;

SELECT *
FROM
    number_and_lv
INTO
    OUTFILE '/var/lib/mysql-files/number_and_lv.csv'
	FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n';
;

/*四、DROP temp tables*/
DROP TABLE temp_number_and_lv
;

DROP TABLE temp_insert_id
;

DROP TABLE temp_insert_num
;


/*五、確定TABLE*/
SHOW FULL TABLES;
SHOW TABLES;
