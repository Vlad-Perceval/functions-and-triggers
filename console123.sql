create  table spec (
    id integer primary key,
    имя_таблицы text ,
    имя_столбца text ,
    текущее_максимальное_значение integer

);
insert into spec(id, имя_таблицы, имя_столбца, текущее_максимальное_значение) values (1,'spec','id',1);
create or replace function  check_c() returns trigger as $check_c$
    DECLARE
        x bigint;
        z bigint;
        begin
            execute format ('select MAX (%I) from %I',tg_argv[0],tg_table_name)
            into x;
            if x is null then
            x=1;
            end if;
             update spec set  текущее_максимальное_значение = x where имя_таблицы = tg_table_name and имя_столбца = tg_argv[0];
            return new;
    end;








    $check_c$language plpgsql;
drop function  xp;
CREATE OR REPLACE function  XP (table_name_1 TEXT,column_name_1 TEXT) RETURNS bigint AS $XP$
DECLARE
    x bigint;
    z bool;
    tmp text;
    t text;
    y bool;
    r bool;
    w bool;
    count bigint;
    c bool;
BEGIN
    select EXISTS(SELECT
    FROM
        information_schema.columns
    WHERE
        table_name = table_name_1 AND
        column_name = column_name_1)into y;
    if y is false then
        raise exception 'ошибка данной таблицы или столбца не существует ';
    end if;
     select EXISTS(SELECT
    FROM
        information_schema.columns
    WHERE
        data_type = 'integer' and
        table_name = table_name_1 AND
        column_name = column_name_1)into w;
    if w is false then
        raise exception 'ошибка неверный формат данных в таблице';
    end if;


            select exists(select true from spec where имя_столбца = column_name_1 and имя_таблицы =table_name_1 )
            into z;
            execute format ('select MAX (%I) from %I',column_name_1,table_name_1)
                into x;

            IF z is true then
                 x=x+1;
                update spec set  текущее_максимальное_значение = текущее_максимальное_значение + 1 where имя_таблицы = table_name_1  and имя_столбца = column_name_1;
                 select текущее_максимальное_значение from spec where имя_столбца=column_name_1 and имя_таблицы =table_name_1
                    into x;
            else
                 select count(distinct (trigger_name)) from information_schema.triggers
                    WHERE event_object_table=table_name_1 into count;
                 count = count + 1;

                t = gen_random_uuid();
                tmp = table_name_1 || '_'|| column_name_1 || '_'||count;
                 select EXISTS(SELECT *from information_schema.triggers
                    WHERE trigger_name = tmp) into c;
                 if c is true then
                     tmp = table_name_1 || '_'|| column_name_1 || '_'||count||t;
                 end if;

                execute format('create or replace trigger %I after update or delete or insert on %I
            for each row execute procedure check_c(%I)',tmp,table_name_1,column_name_1);

                if x is null then
                    x=0;
                end if;

                 x=x+1;
                execute 'insert into spec values($4,$1,$2,$3)'using  table_name_1,column_name_1,x,XP('spec','id');

            end if;

            return x;
END;
$XP$language plpgsql;
select * from XP('spec','id');
select *from spec;
select * from XP('spec','id');
select *from spec;
create table test(
    num integer
);
select * from XP('test','num');
select *from spec;
insert into test values (10);
select *from test;
select *from spec;
update test set num = 99;
select *from test;
select *from spec;
delete from test;
create table test2(
    num integer,
    id integer,
    ad text
);
insert into test2  values (10,15);
select * from XP('test2','num');

update test2 set num = 99;
select *from test2;
select *from spec;
select * from XP('test2','id');
select *from spec;

update test2 set id = 99;
select *from test2;
select *from spec;
update test2 set num = 150;
update test2 set id = 75;
select *from test2;
select *from spec;
delete from spec;
delete from test;
delete from test2;
drop function xp;
select * from XP('test3','id');
select * from XP('test2','lol');
select * from XP('test2','ad');

select * from pg_trigger;
create trigger  test_num_1 after  update on test2 execute function check_c();