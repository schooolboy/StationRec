CREATE TABLE модель_единицы (
	наименование		varchar(100) NOT NULL,
	стоимость_аренды	numeric(7,2) NOT NULL,
	стоимость_залога	numeric(7,2) NOT NULL,
	число_мест		integer NOT NULL,
	максимальная_скорость	integer NOT NULL,
	категория		varchar(50) NOT NULL
);
CREATE UNIQUE INDEX xpkмодель_единицы ON модель_единицы(наименование);
CREATE INDEX xie1модель_единицы ON модель_единицы(категория);

CREATE OR REPLACE PROCEDURE add_модель_единицы(на модель_единицы.наименование%TYPE,
стар модель_единицы.стоимость_аренды%TYPE,
стза модель_единицы.стоимость_залога%TYPE,
чиме модель_единицы.число_мест%TYPE,
маск модель_единицы.максимальная_скорость%TYPE,
ка модель_единицы.категория%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	insert into модель_единицы values(на, стар, стза, чиме, маск, ка); 
	commit; 
	end;
$$;

CREATE OR REPLACE PROCEDURE upd_модель_единицы(на модель_единицы.наименование%TYPE, 
стар модель_единицы.стоимость_аренды%TYPE, 
стза модель_единицы.стоимость_залога%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	numrows integer;
BEGIN
	select count(*) into numrows from модель_единицы where модель_единицы.наименование = на;
	IF (numrows = 0) THEN
		RAISE EXCEPTION 'Модели единицы с таким именем не существует';
	END IF;
	select count(*) into numrows from единица where единица.наименование_модели = на and арендована = true;
	IF (numrows != 0) THEN
		RAISE EXCEPTION 'Модель не может быть обновлена, так как есть арендованные единицы';
	END IF;
	update модель_единицы set (стоимость_аренды, стоимость_залога) = (стар, стза) where наименование = на;
	commit; 
END;
$$;

CREATE OR REPLACE PROCEDURE del_модель_единицы(на модель_единицы.наименование%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from модель_единицы where наименование = на;
	commit; 
	end;
$$;

CREATE OR REPLACE FUNCTION ft_модель_единицы() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
    BEGIN
	-- стоимость аренды и залога не меньше 0, стоимость залога не больше стоимости аренды
	-- число мест не меньше 1
	-- максимальная скорость не меньше 0
	-- категория не менее 4 символов (плот)
	IF (TG_OP != 'DELETE') THEN
		IF (new.стоимость_аренды < 1 OR new.стоимость_залога < 1 OR new.стоимость_аренды < new.стоимость_залога ) THEN
			RAISE EXCEPTION 'Неправильные значения стоимости' USING HINT = 'Выполнение операции невозможно';
		END IF;
	END IF;
        IF (TG_OP = 'INSERT') THEN
        	-- что делать при вставке
		IF (new.число_мест < 1) THEN
			RAISE EXCEPTION 'Число мест не может быть меньше 1' USING HINT = 'Выполнение операции невозможно';
		ELSIF (new.максимальная_скорость < 0) THEN
			RAISE EXCEPTION 'Максимальная скорость не может быть меньше 0' USING HINT = 'Выполнение операции невозможно';
		ELSIF (length(new.наименование) < 2) then
			RAISE EXCEPTION 'Наименование должно состоять из не менее 2 символов' USING HINT = 'Выполнение операции невозможно';
		ELSIF (length(new.категория) < 4) THEN
			RAISE EXCEPTION 'Категория единицы должна состоять не менее чем из 4 символов' USING HINT = 'Выполнение операции невозможно';
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
		select count(*) into numrows from единица where единица.наименование_модели = old.наименование;
		IF(numrows > 0) THEN
			--если есть зависимые записи в единицах (без разницы, т.к. изменяться может только стоимость) ??
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- что делать при удалении
		select count(*) into numrows from единица where единица.наименование_модели = old.наименование;
		IF(numrows > 0) THEN
			--если есть зависимые записи в единицах
			RAISE EXCEPTION 'Существуют зависимые записи' USING HINT = 'Удаление невозможно';
		END IF;
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_модель_единицы 
BEFORE INSERT OR UPDATE OR DELETE ON модель_единицы
FOR EACH ROW EXECUTE FUNCTION ft_модель_единицы();


--***
CREATE TABLE единица (
	инвентарный_номер	varchar(20) NOT NULL,
	наименование_модели	varchar(100) NOT NULL,
	арендована		boolean NOT NULL,
	пригодность		boolean NOT NULL,
	FOREIGN KEY (наименование_модели) REFERENCES модель_единицы (наименование)
);
CREATE UNIQUE INDEX xpkединица ON единица(инвентарный_номер);
CREATE INDEX xie1единица ON единица(наименование_модели);

CREATE OR REPLACE PROCEDURE add_единица(инно единица.инвентарный_номер%TYPE,
намо единица.наименование_модели%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	insert into единица values(инно, намо, false, true);
	commit; 
	end;
$$;

-- при поломке вызывается как есть, при возврате внутри другой процедуры
CREATE OR REPLACE PROCEDURE upd_единица(инно единица.инвентарный_номер%TYPE, ар единица.арендована%TYPE, пр единица.пригодность%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	state bool;
	numrows integer;
BEGIN
	select count(*) into numrows from единица where единица.инвентарный_номер = инно;
	select арендована into state from единица where единица.инвентарный_номер = инно;
	IF (numrows = 0) THEN
		RAISE EXCEPTION 'Единицы с таким инвентарным номером не существует';
	END IF;
	IF (state = true and ар = true and пр = false) THEN
		RAISE EXCEPTION 'Единица арендована и не может быть удалена в данный момент';
	END IF;
	update единица set (инвентарный_номер, арендована, пригодность) = (инно, ар, пр) where инвентарный_номер = инно;
END;
$$;

CREATE OR REPLACE PROCEDURE del_единица(инно единица.инвентарный_номер%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from единица where инвентарный_номер = инно;
	commit; 
	end;
$$;

CREATE OR REPLACE FUNCTION ft_единица() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
    BEGIN
	-- инвентарный номер содержит не менее 5 символов
	IF (TG_OP != 'DELETE') THEN
		IF (length(new.инвентарный_номер) < 5) THEN
			RAISE EXCEPTION 'Инвентарный номер должен содержать не менее 5 символов' USING HINT = 'Выполнение операции невозможно';
		END IF;
	END IF;
        IF (TG_OP = 'INSERT') THEN
        	-- что делать при вставке
		select count(*) into numrows from модель_единицы where модель_единицы.наименование = new.наименование_модели;
		IF(numrows = 0) THEN
			--если нет такой модели
			RAISE EXCEPTION 'Указанной модели единицы не существует' USING HINT = 'Запись невозможна';
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
        	-- что делать при обновлении (реализация не требуется, изменяться может только пригодность или флаг "арендована")
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- что делать при удалении
		select count(*) into numrows from единица_квитанция where единица_квитанция.инвентарный_номер = old.инвентарный_номер;
		IF(numrows > 0) THEN
			--если есть зависимые записи в единица_квитанция
			RAISE EXCEPTION 'Существуют зависимые записи' USING HINT = 'Удаление невозможно';
		END IF;
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_единица 
BEFORE INSERT OR UPDATE OR DELETE ON единица
FOR EACH ROW EXECUTE FUNCTION ft_единица();


--***
CREATE TABLE клиент (
	ид      integer NOT NULL,		
	номер_телефона	char(11) NOT NULL,
	фамилия		varchar(50) NOT NULL,
	имя		varchar(50) NOT NULL,
	отчество	varchar(50) NOT NULL,
	дата_рождения		date NOT NULL
);
CREATE UNIQUE INDEX xpkклиент ON клиент(ид);
CREATE UNIQUE INDEX xak1клиент ON клиент(номер_телефона);
CREATE INDEX xie1клиент ON клиент(фамилия, имя, отчество);

CREATE OR REPLACE PROCEDURE add_клиент(ноте клиент.номер_телефона%TYPE,
фа клиент.фамилия%TYPE,
им клиент.имя%TYPE,
от клиент.отчество%TYPE,
даро TEXT)
 LANGUAGE plpgsql
AS $$
	begin 
	insert into клиент values(0, ноте, фа, им, от, TO_DATE(даро, 'DD.MM.YYYY')); 
	commit; 
	end;
$$;

CREATE OR REPLACE PROCEDURE upd_клиент(и клиент.ид%TYPE, 
ноте клиент.номер_телефона%TYPE,
фа клиент.фамилия%TYPE,
им клиент.имя%TYPE,
от клиент.отчество%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	numrows integer;
BEGIN
	select count(*) into numrows from клиент where клиент.ид = и;
	IF (numrows = 0) THEN
		RAISE EXCEPTION 'Указанного клиента не существует';
	END IF;
	select count(*) into numrows from заказы_клиентов where ид_клиента = и;
	IF (numrows > 0) THEN
		RAISE EXCEPTION 'Нельзя менять данные клиента во время аренды';
	END IF;
	update клиент set (номер_телефона, фамилия, имя, отчество) = (ноте, фа, им, от) where ид = и; 
	commit;
END;
$$;

CREATE OR REPLACE PROCEDURE del_клиент(и клиент.ид%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from клиент where ид = и;
	commit; 
	end;
$$;

CREATE SEQUENCE клиент_seq;

CREATE OR REPLACE FUNCTION ft_клиент() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
    BEGIN
	-- номер телефона не менее 11 цифр
	-- фамилия имя и отчество длиной не менее 2 символа
	-- возраст не меньше 16 лет
	IF (TG_OP != 'DELETE') THEN
		IF (length(new.номер_телефона) < 11) THEN
			RAISE EXCEPTION 'Номер телефона должен состоять из 11 цифр' USING HINT = 'Выполнение операции невозможно';
		ELSIF (length(new.фамилия) < 2 OR length(new.имя) < 2 OR length(new.отчество) < 2) THEN
			RAISE EXCEPTION 'Фамилия имя и отчество должны состоять как минимум из 2 символа' USING HINT = 'Выполнение операции невозможно';
		END IF;
	END IF;
        IF (TG_OP = 'INSERT') THEN
        	-- что делать при вставке (описано выше)
		IF ((EXTRACT(year FROM age(new.дата_рождения))) < 16 ) THEN
			RAISE EXCEPTION 'Клиенты младше 16 лет не обслуживаются' USING HINT = 'Выполнение операции невозможно';
		END IF;
		new.ид = nextval('клиент_seq');
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
        	-- что делать при обновлении
		select count(*) into numrows from квитанция where квитанция.ид_клиента = old.ид;
		IF(numrows > 0) THEN
			--если есть зависимые записи в квитанциях (без разницы, т.к. изменяться могут только инициалы и номер телефона) ??
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- что делать при удалении
		select count(*) into numrows from квитанция where квитанция.ид_клиента = old.ид;
		IF(numrows > 0) THEN
			--если есть зависимые записи в квитанциях
			RAISE EXCEPTION 'Существуют зависимые записи' USING HINT = 'Удаление невозможно';
		END IF;
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_клиент
BEFORE INSERT OR UPDATE OR DELETE ON клиент
FOR EACH ROW EXECUTE FUNCTION ft_клиент();


--***
CREATE TABLE квитанция (
	номер_квитанции		integer NOT NULL,
	ид_клиента		integer NOT NULL,
	дата_оплаты 		timestamp NOT NULL, 		
	пометка_инструктажа	boolean NOT NULL,
	FOREIGN KEY (ид_клиента) REFERENCES клиент (ид)
);
CREATE UNIQUE INDEX xpkквитанция ON квитанция(номер_квитанции);

CREATE OR REPLACE PROCEDURE add_квитанция(идкл квитанция.ид_клиента%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	insert into квитанция values(0, идкл, current_timestamp, false);
	end;
$$;

--upd не требуется (отдельная опреация инструктажа)

CREATE OR REPLACE PROCEDURE del_квитанция(нокв квитанция.номер_квитанции%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from квитанция where номер_квитанции = нокв;
	end;
$$;

CREATE SEQUENCE квитанция_seq;

CREATE OR REPLACE FUNCTION ft_квитанция() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
    BEGIN
        IF (TG_OP = 'INSERT') THEN
		select count(*) into numrows from клиент where клиент.ид = new.ид_клиента;
		IF(numrows = 0) THEN
			--если нет такого клиента
			RAISE EXCEPTION 'Указанного клиента нет в базе' USING HINT = 'Запись невозможна';
		END IF;
		new.номер_квитанции = nextval('квитанция_seq');
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
        	-- что делать при обновлении (пометка инструктажа)
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- что делать при удалении
		select count(*) into numrows from единица_квитанция where единица_квитанция.номер_квитанции = old.номер_квитанции;
		IF(numrows > 0) THEN
			--если есть зависимые записи в единица_квитанция
			RAISE EXCEPTION 'Существуют зависимые записи' USING HINT = 'Удаление невозможно';
		END IF;
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_квитанция 
BEFORE INSERT OR UPDATE OR DELETE ON квитанция
FOR EACH ROW EXECUTE FUNCTION ft_квитанция();


--***
CREATE TABLE единица_квитанция (
	инвентарный_номер	varchar(20) NOT NULL,
	номер_квитанции		integer NOT NULL,
	время_выдачи		time NULL,
	время_аренды		time NOT NULL,
	время_сдачи		time NULL,
	стоимость		numeric(7,2) NOT NULL,
	залог		boolean NOT NULL,
	FOREIGN KEY (инвентарный_номер) REFERENCES единица (инвентарный_номер),
	FOREIGN KEY (номер_квитанции) REFERENCES квитанция (номер_квитанции)
);
CREATE UNIQUE INDEX xpkединица_квитанция 
ON единица_квитанция(инвентарный_номер, номер_квитанции);

CREATE OR REPLACE PROCEDURE add_единица_квитанция(инно единица_квитанция.инвентарный_номер%TYPE,
нокв единица_квитанция.номер_квитанции%TYPE,
врар единица_квитанция.время_аренды%TYPE,
intervals integer)
 LANGUAGE plpgsql
AS $$
DECLARE
	price1 numeric;
	price2 numeric;
BEGIN
	select стоимость_аренды into price1 from модель_единицы, единица where единица.инвентарный_номер = инно AND модель_единицы.наименование = единица.наименование_модели;
	select стоимость_залога into price2 from модель_единицы, единица where единица.инвентарный_номер = инно AND модель_единицы.наименование = единица.наименование_модели;
	insert into единица_квитанция values(инно, нокв, NULL, врар, NULL, (price1 + price2) * intervals / 30, false);
END;
$$;

CREATE OR REPLACE PROCEDURE del_единица_квитанция(нокв квитанция.номер_квитанции%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from квитанция where номер_квитанции = нокв;
	end;
$$;

CREATE OR REPLACE FUNCTION ft_единица_квитанция() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
	price2 numeric;
	time1 time;
	intervals integer;
    BEGIN
	IF (TG_OP != 'DELETE') THEN
		-- что делать при вставке
		select count(*) into numrows from единица where единица.инвентарный_номер = new.инвентарный_номер;
		IF(numrows = 0) THEN
			--если нет такого клиента
			RAISE EXCEPTION 'Указанной единицы нет в базе' USING HINT = 'Запись невозможна';
		END IF;
		select count(*) into numrows from квитанция where квитанция.номер_квитанции = new.номер_квитанции;
		IF(numrows = 0) THEN
			--если нет такой квитанции
			RAISE EXCEPTION 'Указанной квтанции нет в базе' USING HINT = 'Запись невозможна';
		END IF;
	END IF;
        IF (TG_OP = 'INSERT') THEN
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
        	-- что делать при обновлении (инструктаж, возврат)
		-- при инструктаже проверяем уложиться ли аренда в часы работы центра
		IF (old.время_выдачи IS NULL AND new.время_сдачи IS NULL) THEN
			IF (new.время_выдачи + old.время_аренды::interval < make_time(9, 0, 0) OR new.время_выдачи + old.время_аренды::interval > make_time(22, 0, 0)) THEN
				RAISE EXCEPTION 'Аренда должна укладываться в часы работы станции (с 9:00 до 22:00)' USING HINT = 'Выполнение операции невозможно';
			END IF;
		ELSE
			IF (old.время_выдачи IS NOT NULL) THEN 
				IF (old.время_сдачи IS NULL) THEN
					-- если клиент опоздал более чем нам 5 минут, залог оставляем
					IF (new.время_сдачи > old.время_выдачи + old.время_аренды::interval + make_interval(0, 0, 0, 0, 0, 5, 0)) THEN
						new.стоимость = old.стоимость;
						new.залог = false;
					ELSE
						intervals = (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('minute', old.время_аренды)) / 60 AS hours_diff);
						select стоимость_залога into price2 
						from модель_единицы, единица 
						where единица.инвентарный_номер = old.инвентарный_номер 
						and единица.наименование_модели = модель_единицы.наименование;
						new.стоимость = old.стоимость - price2 * div(intervals, 30)::integer;
						new.залог = true;
					END IF;
				ELSE
					-- повторный вызов процедуры возврата (ошибка)
					RAISE EXCEPTION 'Процесс аренды завершен. Повторный вызов невозможен.' USING HINT = 'Выполнение операции невозможно';
				END IF;
			ELSE
				RAISE EXCEPTION 'Неправильный порядок операций. Инструктаж происходит до возврата.' USING HINT = 'Выполнение операции невозможно';
			END IF;
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- что делать при удалении (ничего не нужно)
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_единица_квитанция
BEFORE INSERT OR UPDATE OR DELETE ON единица_квитанция
FOR EACH ROW EXECUTE FUNCTION ft_единица_квитанция();


-- главные процедуры

CREATE OR REPLACE PROCEDURE proc_инструктаж(нокв квитанция.номер_квитанции%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	numrows integer;
BEGIN
	select count(*) into numrows from квитанция where квитанция.номер_квитанции = нокв;
	IF (numrows = 0) THEN
		RAISE EXCEPTION 'Квитанции с таким номером не существует';
	END IF;
	update единица_квитанция set время_выдачи = current_time where номер_квитанции = нокв; -- время выдачи отмечается в квитанции при выдаче единиц инструктажером (как только пройден инструктаж)
	update квитанция set пометка_инструктажа = true where номер_квитанции = нокв; 
	EXCEPTION WHEN OTHERS  
		THEN
    		RAISE EXCEPTION '%', SQLERRM;
		ROLLBACK;
	commit;
END;
$$;

CREATE OR REPLACE PROCEDURE proc_возврат(инно единица_квитанция.инвентарный_номер%TYPE, пр единица.пригодность%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	state bool;
	numcheck integer;
BEGIN
	select арендована into state from единица where инвентарный_номер = инно;
	IF (state = false) THEN
		RAISE EXCEPTION 'На данный момент единица не арендована';
	END IF;
	select t1.номер_квитанции into numcheck from единица_квитанция t1, квитанция t2 where инвентарный_номер = инно and t1.номер_квитанции = t2.номер_квитанции order by t2.дата_оплаты desc;
	update единица_квитанция set время_сдачи = current_time where номер_квитанции = numcheck and инвентарный_номер = инно;
	call upd_единица(инно, false, пр);
	EXCEPTION WHEN OTHERS  
		THEN
    		RAISE EXCEPTION '%', SQLERRM;
		ROLLBACK;
	commit;
END;
$$;

CREATE OR REPLACE PROCEDURE proc_оплата(идкл квитанция.ид_клиента%TYPE, массивед TEXT, врар TEXT)
 LANGUAGE plpgsql
AS $$
DECLARE
    	arrunits varchar(20)[] = string_to_array(массивед, ',');
	numi integer;
	intervals numeric;
	duration time = TO_TIMESTAMP(врар, 'HH24:MI')::TIME;
BEGIN
	-- проверка времени работы
	-- принятие заказов до 21 00 и время аренды не более 12 часов
	IF (duration + current_time < make_time(9, 0, 0) OR duration + current_time > make_time(22, 0, 0) OR current_time > make_time(21, 0, 0) OR duration > make_time(12, 0, 0)) THEN
		RAISE EXCEPTION 'Аренда должна укладываться в часы работы станции (с 9:00 до 22:00). Центр заканчивает принимать заказы в 21:00';
	END IF;
	select count(*) into numi from заказы_клиентов where ид_клиента = идкл;
	-- проверка клиента
	IF (numi > 0) THEN
		RAISE EXCEPTION 'Клиент не может оформлять квитанции во время аренды';
	END IF;
	intervals = (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('minute', duration)) / 60 AS hours_diff);
	-- проверка на время
	IF (intervals / 30 < 1) THEN
		RAISE EXCEPTION 'Время аренды должно составлять не меньше 30 минут';
	ELSIF (intervals % 30 != 0) THEN
		RAISE EXCEPTION 'Аренда осуществляется по промежуткам в 30 минут';
	END IF;
	call add_квитанция(идкл);
	FOR numi IN 1..array_length(arrunits, 1) LOOP
		call add_единица_квитанция(arrunits[numi], currval('квитанция_seq')::integer, duration, intervals::integer);
		call upd_единица(arrunits[numi], true, true);
	END LOOP;
	EXCEPTION WHEN OTHERS  
		THEN
    		RAISE EXCEPTION '%', SQLERRM;
		ROLLBACK;
	commit;
END;
$$;

CREATE VIEW доступные_единицы 
AS SELECT инвентарный_номер, наименование_модели, категория, 
стоимость_аренды, стоимость_залога, максимальная_скорость, число_мест 
FROM модель_единицы, единица 
WHERE наименование = наименование_модели AND арендована = false AND пригодность = true;

CREATE VIEW квитанции
AS SELECT DISTINCT t1.номер_квитанции, номер_телефона,
дата_оплаты, ид_клиента, время_аренды
FROM клиент, квитанция t1, единица_квитанция t2
WHERE ид = ид_клиента and t1.номер_квитанции = t2.номер_квитанции;

CREATE VIEW единицы_квитанции
AS SELECT t1.наименование, t2.инвентарный_номер, 
t1.стоимость_аренды, t1.стоимость_залога, 
t3.стоимость as суммарная_стоимость, t3.время_выдачи, t3.время_сдачи, t3.залог, t3.номер_квитанции
FROM модель_единицы t1, единица t2, единица_квитанция t3
WHERE t1.наименование = t2.наименование_модели and t2.инвентарный_номер = t3.инвентарный_номер;

CREATE VIEW журнал_инструктажей 
AS SELECT номер_квитанции, фамилия, имя, отчество, 
дата_оплаты, пометка_инструктажа FROM клиент, квитанция 
WHERE ид = ид_клиента;

CREATE VIEW заказы_клиентов 
AS SELECT ид_клиента from квитанция t1, единица_квитанция t2
WHERE t1.номер_квитанции = t2.номер_квитанции AND t2.время_сдачи IS NULL;

CREATE USER instructor WITH PASSWORD '1111';
CREATE USER cashier WITH PASSWORD '2222';
CREATE USER client WITH PASSWORD '3333';

GRANT EXECUTE ON PROCEDURE proc_возврат, proc_инструктаж TO instructor;
GRANT EXECUTE ON PROCEDURE proc_оплата TO cashier, client;

GRANT INSERT ON клиент, квитанция, единица_квитанция TO cashier;
GRANT UPDATE ON единица, клиент TO cashier;

GRANT INSERT ON модель_единицы, единица TO instructor;
GRANT UPDATE ON единица, квитанция, единица_квитанция TO instructor;
GRANT DELETE ON модель_единицы TO instructor;

GRANT INSERT ON клиент, квитанция, единица_квитанция TO client;
GRANT UPDATE ON единица TO client;

GRANT SELECT ON  модель_единицы,единица,клиент,квитанция, 
единица_квитанция, доступные_единицы, квитанции, единицы_квитанции, заказы_клиентов 
TO cashier;

GRANT SELECT ON  модель_единицы,единица,клиент,квитанция, 
единица_квитанция, журнал_инструктажей TO instructor;

GRANT SELECT ON  модель_единицы,единица,клиент,квитанция, 
единица_квитанция, доступные_единицы, заказы_клиентов TO client;

GRANT USAGE, SELECT ON SEQUENCE клиент_seq, квитанция_seq TO cashier, client;

GRANT USAGE ON SCHEMA public to cashier;
GRANT USAGE ON SCHEMA public to client;
GRANT USAGE ON SCHEMA public to instructor;

/* *** удаление
DROP VIEW доступные_единицы;
DROP VIEW квитанции;
DROP VIEW единицы_квитанции;
DROP VIEW журнал_инструктажей;
DROP VIEW заказы_клиентов;
DROP TRIGGER IF EXISTS t_модель_единицы ON модель_единицы; 
DROP TRIGGER IF EXISTS t_единица ON единица;
DROP TRIGGER IF EXISTS t_клиент ON клиент;
DROP TRIGGER IF EXISTS t_квитанция ON квитанция;
DROP TRIGGER IF EXISTS t_единица_квитанция ON единица_квитанция;
DROP FUNCTION IF EXISTS ft_модель_единицы;
DROP FUNCTION IF EXISTS ft_единица;
DROP FUNCTION IF EXISTS ft_клиент;
DROP FUNCTION IF EXISTS ft_квитанция;
DROP FUNCTION IF EXISTS ft_единица_квитанция;
DROP TABLE единица_квитанция;
DROP TABLE квитанция;
DROP TABLE единица;
DROP TABLE клиент;
DROP TABLE модель_единицы;
DROP PROCEDURE IF EXISTS add_модель_единицы;
DROP PROCEDURE IF EXISTS upd_модель_единицы;
DROP PROCEDURE IF EXISTS del_модель_единицы;
DROP PROCEDURE IF EXISTS add_единица;
DROP PROCEDURE IF EXISTS upd_единица;
DROP PROCEDURE IF EXISTS del_единица;
DROP PROCEDURE IF EXISTS add_клиент;
DROP PROCEDURE IF EXISTS upd_клиент;
DROP PROCEDURE IF EXISTS del_клиент;
DROP PROCEDURE IF EXISTS add_квитанция;
DROP PROCEDURE IF EXISTS del_квитанция;
DROP PROCEDURE IF EXISTS add_единица_квитанция;
DROP PROCEDURE IF EXISTS del_единица_квитанция;
DROP PROCEDURE IF EXISTS proc_инструктаж;
DROP PROCEDURE IF EXISTS proc_возврат;
DROP PROCEDURE IF EXISTS proc_оплата;
DROP SEQUENCE IF EXISTS квитанция_seq;
DROP SEQUENCE IF EXISTS клиент_seq;
DROP ROLE client;
DROP ROLE cashier;
DROP ROLE instructor;
*/