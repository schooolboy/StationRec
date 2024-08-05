CREATE TABLE ������_������� (
	������������		varchar(100) NOT NULL,
	���������_������	numeric(7,2) NOT NULL,
	���������_������	numeric(7,2) NOT NULL,
	�����_����		integer NOT NULL,
	������������_��������	integer NOT NULL,
	���������		varchar(50) NOT NULL
);
CREATE UNIQUE INDEX xpk������_������� ON ������_�������(������������);
CREATE INDEX xie1������_������� ON ������_�������(���������);

CREATE OR REPLACE PROCEDURE add_������_�������(�� ������_�������.������������%TYPE,
���� ������_�������.���������_������%TYPE,
���� ������_�������.���������_������%TYPE,
���� ������_�������.�����_����%TYPE,
���� ������_�������.������������_��������%TYPE,
�� ������_�������.���������%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	insert into ������_������� values(��, ����, ����, ����, ����, ��); 
	commit; 
	end;
$$;

CREATE OR REPLACE PROCEDURE upd_������_�������(�� ������_�������.������������%TYPE, 
���� ������_�������.���������_������%TYPE, 
���� ������_�������.���������_������%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	numrows integer;
BEGIN
	select count(*) into numrows from ������_������� where ������_�������.������������ = ��;
	IF (numrows = 0) THEN
		RAISE EXCEPTION '������ ������� � ����� ������ �� ����������';
	END IF;
	select count(*) into numrows from ������� where �������.������������_������ = �� and ���������� = true;
	IF (numrows != 0) THEN
		RAISE EXCEPTION '������ �� ����� ���� ���������, ��� ��� ���� ������������ �������';
	END IF;
	update ������_������� set (���������_������, ���������_������) = (����, ����) where ������������ = ��;
	commit; 
END;
$$;

CREATE OR REPLACE PROCEDURE del_������_�������(�� ������_�������.������������%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from ������_������� where ������������ = ��;
	commit; 
	end;
$$;

CREATE OR REPLACE FUNCTION ft_������_�������() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
    BEGIN
	-- ��������� ������ � ������ �� ������ 0, ��������� ������ �� ������ ��������� ������
	-- ����� ���� �� ������ 1
	-- ������������ �������� �� ������ 0
	-- ��������� �� ����� 4 �������� (����)
	IF (TG_OP != 'DELETE') THEN
		IF (new.���������_������ < 1 OR new.���������_������ < 1 OR new.���������_������ < new.���������_������ ) THEN
			RAISE EXCEPTION '������������ �������� ���������' USING HINT = '���������� �������� ����������';
		END IF;
	END IF;
        IF (TG_OP = 'INSERT') THEN
        	-- ��� ������ ��� �������
		IF (new.�����_���� < 1) THEN
			RAISE EXCEPTION '����� ���� �� ����� ���� ������ 1' USING HINT = '���������� �������� ����������';
		ELSIF (new.������������_�������� < 0) THEN
			RAISE EXCEPTION '������������ �������� �� ����� ���� ������ 0' USING HINT = '���������� �������� ����������';
		ELSIF (length(new.������������) < 2) then
			RAISE EXCEPTION '������������ ������ �������� �� �� ����� 2 ��������' USING HINT = '���������� �������� ����������';
		ELSIF (length(new.���������) < 4) THEN
			RAISE EXCEPTION '��������� ������� ������ �������� �� ����� ��� �� 4 ��������' USING HINT = '���������� �������� ����������';
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
		select count(*) into numrows from ������� where �������.������������_������ = old.������������;
		IF(numrows > 0) THEN
			--���� ���� ��������� ������ � �������� (��� �������, �.�. ���������� ����� ������ ���������) ??
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- ��� ������ ��� ��������
		select count(*) into numrows from ������� where �������.������������_������ = old.������������;
		IF(numrows > 0) THEN
			--���� ���� ��������� ������ � ��������
			RAISE EXCEPTION '���������� ��������� ������' USING HINT = '�������� ����������';
		END IF;
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_������_������� 
BEFORE INSERT OR UPDATE OR DELETE ON ������_�������
FOR EACH ROW EXECUTE FUNCTION ft_������_�������();


--***
CREATE TABLE ������� (
	�����������_�����	varchar(20) NOT NULL,
	������������_������	varchar(100) NOT NULL,
	����������		boolean NOT NULL,
	�����������		boolean NOT NULL,
	FOREIGN KEY (������������_������) REFERENCES ������_������� (������������)
);
CREATE UNIQUE INDEX xpk������� ON �������(�����������_�����);
CREATE INDEX xie1������� ON �������(������������_������);

CREATE OR REPLACE PROCEDURE add_�������(���� �������.�����������_�����%TYPE,
���� �������.������������_������%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	insert into ������� values(����, ����, false, true);
	commit; 
	end;
$$;

-- ��� ������� ���������� ��� ����, ��� �������� ������ ������ ���������
CREATE OR REPLACE PROCEDURE upd_�������(���� �������.�����������_�����%TYPE, �� �������.����������%TYPE, �� �������.�����������%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	state bool;
	numrows integer;
BEGIN
	select count(*) into numrows from ������� where �������.�����������_����� = ����;
	select ���������� into state from ������� where �������.�����������_����� = ����;
	IF (numrows = 0) THEN
		RAISE EXCEPTION '������� � ����� ����������� ������� �� ����������';
	END IF;
	IF (state = true and �� = true and �� = false) THEN
		RAISE EXCEPTION '������� ���������� � �� ����� ���� ������� � ������ ������';
	END IF;
	update ������� set (�����������_�����, ����������, �����������) = (����, ��, ��) where �����������_����� = ����;
END;
$$;

CREATE OR REPLACE PROCEDURE del_�������(���� �������.�����������_�����%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from ������� where �����������_����� = ����;
	commit; 
	end;
$$;

CREATE OR REPLACE FUNCTION ft_�������() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
    BEGIN
	-- ����������� ����� �������� �� ����� 5 ��������
	IF (TG_OP != 'DELETE') THEN
		IF (length(new.�����������_�����) < 5) THEN
			RAISE EXCEPTION '����������� ����� ������ ��������� �� ����� 5 ��������' USING HINT = '���������� �������� ����������';
		END IF;
	END IF;
        IF (TG_OP = 'INSERT') THEN
        	-- ��� ������ ��� �������
		select count(*) into numrows from ������_������� where ������_�������.������������ = new.������������_������;
		IF(numrows = 0) THEN
			--���� ��� ����� ������
			RAISE EXCEPTION '��������� ������ ������� �� ����������' USING HINT = '������ ����������';
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
        	-- ��� ������ ��� ���������� (���������� �� ���������, ���������� ����� ������ ����������� ��� ���� "����������")
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- ��� ������ ��� ��������
		select count(*) into numrows from �������_��������� where �������_���������.�����������_����� = old.�����������_�����;
		IF(numrows > 0) THEN
			--���� ���� ��������� ������ � �������_���������
			RAISE EXCEPTION '���������� ��������� ������' USING HINT = '�������� ����������';
		END IF;
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_������� 
BEFORE INSERT OR UPDATE OR DELETE ON �������
FOR EACH ROW EXECUTE FUNCTION ft_�������();


--***
CREATE TABLE ������ (
	��      integer NOT NULL,		
	�����_��������	char(11) NOT NULL,
	�������		varchar(50) NOT NULL,
	���		varchar(50) NOT NULL,
	��������	varchar(50) NOT NULL,
	����_��������		date NOT NULL
);
CREATE UNIQUE INDEX xpk������ ON ������(��);
CREATE UNIQUE INDEX xak1������ ON ������(�����_��������);
CREATE INDEX xie1������ ON ������(�������, ���, ��������);

CREATE OR REPLACE PROCEDURE add_������(���� ������.�����_��������%TYPE,
�� ������.�������%TYPE,
�� ������.���%TYPE,
�� ������.��������%TYPE,
���� TEXT)
 LANGUAGE plpgsql
AS $$
	begin 
	insert into ������ values(0, ����, ��, ��, ��, TO_DATE(����, 'DD.MM.YYYY')); 
	commit; 
	end;
$$;

CREATE OR REPLACE PROCEDURE upd_������(� ������.��%TYPE, 
���� ������.�����_��������%TYPE,
�� ������.�������%TYPE,
�� ������.���%TYPE,
�� ������.��������%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	numrows integer;
BEGIN
	select count(*) into numrows from ������ where ������.�� = �;
	IF (numrows = 0) THEN
		RAISE EXCEPTION '���������� ������� �� ����������';
	END IF;
	select count(*) into numrows from ������_�������� where ��_������� = �;
	IF (numrows > 0) THEN
		RAISE EXCEPTION '������ ������ ������ ������� �� ����� ������';
	END IF;
	update ������ set (�����_��������, �������, ���, ��������) = (����, ��, ��, ��) where �� = �; 
	commit;
END;
$$;

CREATE OR REPLACE PROCEDURE del_������(� ������.��%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from ������ where �� = �;
	commit; 
	end;
$$;

CREATE SEQUENCE ������_seq;

CREATE OR REPLACE FUNCTION ft_������() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
    BEGIN
	-- ����� �������� �� ����� 11 ����
	-- ������� ��� � �������� ������ �� ����� 2 �������
	-- ������� �� ������ 16 ���
	IF (TG_OP != 'DELETE') THEN
		IF (length(new.�����_��������) < 11) THEN
			RAISE EXCEPTION '����� �������� ������ �������� �� 11 ����' USING HINT = '���������� �������� ����������';
		ELSIF (length(new.�������) < 2 OR length(new.���) < 2 OR length(new.��������) < 2) THEN
			RAISE EXCEPTION '������� ��� � �������� ������ �������� ��� ������� �� 2 �������' USING HINT = '���������� �������� ����������';
		END IF;
	END IF;
        IF (TG_OP = 'INSERT') THEN
        	-- ��� ������ ��� ������� (������� ����)
		IF ((EXTRACT(year FROM age(new.����_��������))) < 16 ) THEN
			RAISE EXCEPTION '������� ������ 16 ��� �� �������������' USING HINT = '���������� �������� ����������';
		END IF;
		new.�� = nextval('������_seq');
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
        	-- ��� ������ ��� ����������
		select count(*) into numrows from ��������� where ���������.��_������� = old.��;
		IF(numrows > 0) THEN
			--���� ���� ��������� ������ � ���������� (��� �������, �.�. ���������� ����� ������ �������� � ����� ��������) ??
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- ��� ������ ��� ��������
		select count(*) into numrows from ��������� where ���������.��_������� = old.��;
		IF(numrows > 0) THEN
			--���� ���� ��������� ������ � ����������
			RAISE EXCEPTION '���������� ��������� ������' USING HINT = '�������� ����������';
		END IF;
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_������
BEFORE INSERT OR UPDATE OR DELETE ON ������
FOR EACH ROW EXECUTE FUNCTION ft_������();


--***
CREATE TABLE ��������� (
	�����_���������		integer NOT NULL,
	��_�������		integer NOT NULL,
	����_������ 		timestamp NOT NULL, 		
	�������_�����������	boolean NOT NULL,
	FOREIGN KEY (��_�������) REFERENCES ������ (��)
);
CREATE UNIQUE INDEX xpk��������� ON ���������(�����_���������);

CREATE OR REPLACE PROCEDURE add_���������(���� ���������.��_�������%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	insert into ��������� values(0, ����, current_timestamp, false);
	end;
$$;

--upd �� ��������� (��������� �������� �����������)

CREATE OR REPLACE PROCEDURE del_���������(���� ���������.�����_���������%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from ��������� where �����_��������� = ����;
	end;
$$;

CREATE SEQUENCE ���������_seq;

CREATE OR REPLACE FUNCTION ft_���������() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
    BEGIN
        IF (TG_OP = 'INSERT') THEN
		select count(*) into numrows from ������ where ������.�� = new.��_�������;
		IF(numrows = 0) THEN
			--���� ��� ������ �������
			RAISE EXCEPTION '���������� ������� ��� � ����' USING HINT = '������ ����������';
		END IF;
		new.�����_��������� = nextval('���������_seq');
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
        	-- ��� ������ ��� ���������� (������� �����������)
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- ��� ������ ��� ��������
		select count(*) into numrows from �������_��������� where �������_���������.�����_��������� = old.�����_���������;
		IF(numrows > 0) THEN
			--���� ���� ��������� ������ � �������_���������
			RAISE EXCEPTION '���������� ��������� ������' USING HINT = '�������� ����������';
		END IF;
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_��������� 
BEFORE INSERT OR UPDATE OR DELETE ON ���������
FOR EACH ROW EXECUTE FUNCTION ft_���������();


--***
CREATE TABLE �������_��������� (
	�����������_�����	varchar(20) NOT NULL,
	�����_���������		integer NOT NULL,
	�����_������		time NULL,
	�����_������		time NOT NULL,
	�����_�����		time NULL,
	���������		numeric(7,2) NOT NULL,
	�����		boolean NOT NULL,
	FOREIGN KEY (�����������_�����) REFERENCES ������� (�����������_�����),
	FOREIGN KEY (�����_���������) REFERENCES ��������� (�����_���������)
);
CREATE UNIQUE INDEX xpk�������_��������� 
ON �������_���������(�����������_�����, �����_���������);

CREATE OR REPLACE PROCEDURE add_�������_���������(���� �������_���������.�����������_�����%TYPE,
���� �������_���������.�����_���������%TYPE,
���� �������_���������.�����_������%TYPE,
intervals integer)
 LANGUAGE plpgsql
AS $$
DECLARE
	price1 numeric;
	price2 numeric;
BEGIN
	select ���������_������ into price1 from ������_�������, ������� where �������.�����������_����� = ���� AND ������_�������.������������ = �������.������������_������;
	select ���������_������ into price2 from ������_�������, ������� where �������.�����������_����� = ���� AND ������_�������.������������ = �������.������������_������;
	insert into �������_��������� values(����, ����, NULL, ����, NULL, (price1 + price2) * intervals / 30, false);
END;
$$;

CREATE OR REPLACE PROCEDURE del_�������_���������(���� ���������.�����_���������%TYPE)
 LANGUAGE plpgsql
AS $$
	begin 
	delete from ��������� where �����_��������� = ����;
	end;
$$;

CREATE OR REPLACE FUNCTION ft_�������_���������() RETURNS TRIGGER AS $$
    DECLARE
    	numrows	integer;
	price2 numeric;
	time1 time;
	intervals integer;
    BEGIN
	IF (TG_OP != 'DELETE') THEN
		-- ��� ������ ��� �������
		select count(*) into numrows from ������� where �������.�����������_����� = new.�����������_�����;
		IF(numrows = 0) THEN
			--���� ��� ������ �������
			RAISE EXCEPTION '��������� ������� ��� � ����' USING HINT = '������ ����������';
		END IF;
		select count(*) into numrows from ��������� where ���������.�����_��������� = new.�����_���������;
		IF(numrows = 0) THEN
			--���� ��� ����� ���������
			RAISE EXCEPTION '��������� �������� ��� � ����' USING HINT = '������ ����������';
		END IF;
	END IF;
        IF (TG_OP = 'INSERT') THEN
		RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
        	-- ��� ������ ��� ���������� (����������, �������)
		-- ��� ����������� ��������� ��������� �� ������ � ���� ������ ������
		IF (old.�����_������ IS NULL AND new.�����_����� IS NULL) THEN
			IF (new.�����_������ + old.�����_������::interval < make_time(9, 0, 0) OR new.�����_������ + old.�����_������::interval > make_time(22, 0, 0)) THEN
				RAISE EXCEPTION '������ ������ ������������ � ���� ������ ������� (� 9:00 �� 22:00)' USING HINT = '���������� �������� ����������';
			END IF;
		ELSE
			IF (old.�����_������ IS NOT NULL) THEN 
				IF (old.�����_����� IS NULL) THEN
					-- ���� ������ ������� ����� ��� ��� 5 �����, ����� ���������
					IF (new.�����_����� > old.�����_������ + old.�����_������::interval + make_interval(0, 0, 0, 0, 0, 5, 0)) THEN
						new.��������� = old.���������;
						new.����� = false;
					ELSE
						intervals = (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('minute', old.�����_������)) / 60 AS hours_diff);
						select ���������_������ into price2 
						from ������_�������, ������� 
						where �������.�����������_����� = old.�����������_����� 
						and �������.������������_������ = ������_�������.������������;
						new.��������� = old.��������� - price2 * div(intervals, 30)::integer;
						new.����� = true;
					END IF;
				ELSE
					-- ��������� ����� ��������� �������� (������)
					RAISE EXCEPTION '������� ������ ��������. ��������� ����� ����������.' USING HINT = '���������� �������� ����������';
				END IF;
			ELSE
				RAISE EXCEPTION '������������ ������� ��������. ���������� ���������� �� ��������.' USING HINT = '���������� �������� ����������';
			END IF;
		END IF;
		RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
		-- ��� ������ ��� �������� (������ �� �����)
		RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_�������_���������
BEFORE INSERT OR UPDATE OR DELETE ON �������_���������
FOR EACH ROW EXECUTE FUNCTION ft_�������_���������();


-- ������� ���������

CREATE OR REPLACE PROCEDURE proc_����������(���� ���������.�����_���������%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	numrows integer;
BEGIN
	select count(*) into numrows from ��������� where ���������.�����_��������� = ����;
	IF (numrows = 0) THEN
		RAISE EXCEPTION '��������� � ����� ������� �� ����������';
	END IF;
	update �������_��������� set �����_������ = current_time where �����_��������� = ����; -- ����� ������ ���������� � ��������� ��� ������ ������ �������������� (��� ������ ������� ����������)
	update ��������� set �������_����������� = true where �����_��������� = ����; 
	EXCEPTION WHEN OTHERS  
		THEN
    		RAISE EXCEPTION '%', SQLERRM;
		ROLLBACK;
	commit;
END;
$$;

CREATE OR REPLACE PROCEDURE proc_�������(���� �������_���������.�����������_�����%TYPE, �� �������.�����������%TYPE)
 LANGUAGE plpgsql
AS $$
DECLARE
	state bool;
	numcheck integer;
BEGIN
	select ���������� into state from ������� where �����������_����� = ����;
	IF (state = false) THEN
		RAISE EXCEPTION '�� ������ ������ ������� �� ����������';
	END IF;
	select t1.�����_��������� into numcheck from �������_��������� t1, ��������� t2 where �����������_����� = ���� and t1.�����_��������� = t2.�����_��������� order by t2.����_������ desc;
	update �������_��������� set �����_����� = current_time where �����_��������� = numcheck and �����������_����� = ����;
	call upd_�������(����, false, ��);
	EXCEPTION WHEN OTHERS  
		THEN
    		RAISE EXCEPTION '%', SQLERRM;
		ROLLBACK;
	commit;
END;
$$;

CREATE OR REPLACE PROCEDURE proc_������(���� ���������.��_�������%TYPE, �������� TEXT, ���� TEXT)
 LANGUAGE plpgsql
AS $$
DECLARE
    	arrunits varchar(20)[] = string_to_array(��������, ',');
	numi integer;
	intervals numeric;
	duration time = TO_TIMESTAMP(����, 'HH24:MI')::TIME;
BEGIN
	-- �������� ������� ������
	-- �������� ������� �� 21 00 � ����� ������ �� ����� 12 �����
	IF (duration + current_time < make_time(9, 0, 0) OR duration + current_time > make_time(22, 0, 0) OR current_time > make_time(21, 0, 0) OR duration > make_time(12, 0, 0)) THEN
		RAISE EXCEPTION '������ ������ ������������ � ���� ������ ������� (� 9:00 �� 22:00). ����� ����������� ��������� ������ � 21:00';
	END IF;
	select count(*) into numi from ������_�������� where ��_������� = ����;
	-- �������� �������
	IF (numi > 0) THEN
		RAISE EXCEPTION '������ �� ����� ��������� ��������� �� ����� ������';
	END IF;
	intervals = (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('minute', duration)) / 60 AS hours_diff);
	-- �������� �� �����
	IF (intervals / 30 < 1) THEN
		RAISE EXCEPTION '����� ������ ������ ���������� �� ������ 30 �����';
	ELSIF (intervals % 30 != 0) THEN
		RAISE EXCEPTION '������ �������������� �� ����������� � 30 �����';
	END IF;
	call add_���������(����);
	FOR numi IN 1..array_length(arrunits, 1) LOOP
		call add_�������_���������(arrunits[numi], currval('���������_seq')::integer, duration, intervals::integer);
		call upd_�������(arrunits[numi], true, true);
	END LOOP;
	EXCEPTION WHEN OTHERS  
		THEN
    		RAISE EXCEPTION '%', SQLERRM;
		ROLLBACK;
	commit;
END;
$$;

CREATE VIEW ���������_������� 
AS SELECT �����������_�����, ������������_������, ���������, 
���������_������, ���������_������, ������������_��������, �����_���� 
FROM ������_�������, ������� 
WHERE ������������ = ������������_������ AND ���������� = false AND ����������� = true;

CREATE VIEW ���������
AS SELECT DISTINCT t1.�����_���������, �����_��������,
����_������, ��_�������, �����_������
FROM ������, ��������� t1, �������_��������� t2
WHERE �� = ��_������� and t1.�����_��������� = t2.�����_���������;

CREATE VIEW �������_���������
AS SELECT t1.������������, t2.�����������_�����, 
t1.���������_������, t1.���������_������, 
t3.��������� as ���������_���������, t3.�����_������, t3.�����_�����, t3.�����, t3.�����_���������
FROM ������_������� t1, ������� t2, �������_��������� t3
WHERE t1.������������ = t2.������������_������ and t2.�����������_����� = t3.�����������_�����;

CREATE VIEW ������_������������ 
AS SELECT �����_���������, �������, ���, ��������, 
����_������, �������_����������� FROM ������, ��������� 
WHERE �� = ��_�������;

CREATE VIEW ������_�������� 
AS SELECT ��_������� from ��������� t1, �������_��������� t2
WHERE t1.�����_��������� = t2.�����_��������� AND t2.�����_����� IS NULL;

CREATE USER instructor WITH PASSWORD '1111';
CREATE USER cashier WITH PASSWORD '2222';
CREATE USER client WITH PASSWORD '3333';

GRANT EXECUTE ON PROCEDURE proc_�������, proc_���������� TO instructor;
GRANT EXECUTE ON PROCEDURE proc_������ TO cashier, client;

GRANT INSERT ON ������, ���������, �������_��������� TO cashier;
GRANT UPDATE ON �������, ������ TO cashier;

GRANT INSERT ON ������_�������, ������� TO instructor;
GRANT UPDATE ON �������, ���������, �������_��������� TO instructor;
GRANT DELETE ON ������_������� TO instructor;

GRANT INSERT ON ������, ���������, �������_��������� TO client;
GRANT UPDATE ON ������� TO client;

GRANT SELECT ON  ������_�������,�������,������,���������, 
�������_���������, ���������_�������, ���������, �������_���������, ������_�������� 
TO cashier;

GRANT SELECT ON  ������_�������,�������,������,���������, 
�������_���������, ������_������������ TO instructor;

GRANT SELECT ON  ������_�������,�������,������,���������, 
�������_���������, ���������_�������, ������_�������� TO client;

GRANT USAGE, SELECT ON SEQUENCE ������_seq, ���������_seq TO cashier, client;

GRANT USAGE ON SCHEMA public to cashier;
GRANT USAGE ON SCHEMA public to client;
GRANT USAGE ON SCHEMA public to instructor;

/* *** ��������
DROP VIEW ���������_�������;
DROP VIEW ���������;
DROP VIEW �������_���������;
DROP VIEW ������_������������;
DROP VIEW ������_��������;
DROP TRIGGER IF EXISTS t_������_������� ON ������_�������; 
DROP TRIGGER IF EXISTS t_������� ON �������;
DROP TRIGGER IF EXISTS t_������ ON ������;
DROP TRIGGER IF EXISTS t_��������� ON ���������;
DROP TRIGGER IF EXISTS t_�������_��������� ON �������_���������;
DROP FUNCTION IF EXISTS ft_������_�������;
DROP FUNCTION IF EXISTS ft_�������;
DROP FUNCTION IF EXISTS ft_������;
DROP FUNCTION IF EXISTS ft_���������;
DROP FUNCTION IF EXISTS ft_�������_���������;
DROP TABLE �������_���������;
DROP TABLE ���������;
DROP TABLE �������;
DROP TABLE ������;
DROP TABLE ������_�������;
DROP PROCEDURE IF EXISTS add_������_�������;
DROP PROCEDURE IF EXISTS upd_������_�������;
DROP PROCEDURE IF EXISTS del_������_�������;
DROP PROCEDURE IF EXISTS add_�������;
DROP PROCEDURE IF EXISTS upd_�������;
DROP PROCEDURE IF EXISTS del_�������;
DROP PROCEDURE IF EXISTS add_������;
DROP PROCEDURE IF EXISTS upd_������;
DROP PROCEDURE IF EXISTS del_������;
DROP PROCEDURE IF EXISTS add_���������;
DROP PROCEDURE IF EXISTS del_���������;
DROP PROCEDURE IF EXISTS add_�������_���������;
DROP PROCEDURE IF EXISTS del_�������_���������;
DROP PROCEDURE IF EXISTS proc_����������;
DROP PROCEDURE IF EXISTS proc_�������;
DROP PROCEDURE IF EXISTS proc_������;
DROP SEQUENCE IF EXISTS ���������_seq;
DROP SEQUENCE IF EXISTS ������_seq;
DROP ROLE client;
DROP ROLE cashier;
DROP ROLE instructor;
*/