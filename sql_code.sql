-- here we are going to clean a dirty dataset using SQL, SO lets follow

-- first we will make a copy of our data set

create table laptopdata2 like laptop_data;  # this will  create the strructure of table 

select * from  laptopdata2 

insert into laptopdata2 select * from laptop_data # this will insert all data from original table to backup table

select count(*) from laptop_data # so here we have 1272 rows 
-- I will drop this unnamed column and add index column in our table

ALTER TABLE laptopdata2
drop COLUMN `Unnamed: 0`;

ALTER TABLE laptopdata2
ADD COLUMN indexx;

CREATE INDEX indexxx ON laptopdata2 (indexx);

alter table laptopdata2 modify indexx int AUTO_INCREMENT



--  we will spend some time with memory comsumtion 


select DATA_LENGTH from information_schema.TABLES
where TABLE_SCHEMA = 'data_clean'
AND TABLE_NAME = 'laptopdata2'

-- The data length of our table is 262144 bites
use data_clean
 select * from laptopdata2

-- we will drop all null rows here

select * from laptopdata2 
where Company is null and TypeName is null and Inches is null and ScreenResolution is null and Cpu is null and Ram is null 
and Memory is null and Gpu is null and OpSys is null and Weight is null and Price is null


DELETE FROM laptopdata2 
WHERE `index` IN (SELECT `index` FROM laptops
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL
AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL
AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND
WEIGHT IS NULL AND Price IS NULL);

-- here we have successfully removed null values 

select count(*) from laptopdata2 # now we have remain 1272 rows 

-- here i have found 'Inches' column has TEXT data type so we have converted it to DECIMAL 



select * from laptopdata2

-- In 'RAM' column i'll remove GB part so i can convert it to int data typr 


 update laptopdata2 set RAM =REPLACE(RAM, 'GB', '');

select * from laptopdata2

alter table laptopdata2 modify  column RAM int # here i have modify RAM column datatype to integer 

-- We will do same as weight column 

 update laptopdata2 l1 set Weight =REPLACE(Weight, 'kg', '')

select * from laptopdata2

-- now am going to ROUND Price column and modify it from double to int

update laptopdata2 set Price = round(Price)

select * from laptopdata2

alter table laptopdata2 modify column Price int

-- Now we move to OpSys

select distinct(OpSys) from laptopdata2

/* We are filtering all rows and replace each name like if there is macOS then replace it ot mac,
 Windows 10 to windows,
 Android chrome to others */
 
update laptopdata2 l1 set OpSys =   case 
					when OpSys like '%mac%' then 'macos'
					when OpSys like '%windows%' then 'windows'
					when OpSys like 'Linux' then 'linux'
					when OpSys like 'No Os' then 'N/A'
					else 'other'
                    end 
 select * from laptopdata2

-- lets come in Gpu column, we will split Gpu column and make gpu_brand and gpu_name column 

alter table laptopdata2
add column gpu_brand varchar(255) after Gpu,
add column gpu_name varchar (255) after gpu_brand 

select * from laptopdata2

select gpu,substring_index(gpu,' ',1) from laptopdata2

update laptopdata2 l1 set gpu_brand =  substring_index(gpu,' ',1)

select * from laptopdata2

update laptopdata2 set gpu_name =   replace (gpu,gpu_brand,'')

alter table laptopdata2 drop column Gpu_name

select * from laptopdata2

-- Now we will going to pick Cpu column and split it to three column cpu_brand, cpu_name, cpu_speed

alter table laptopdata2
add column cpu_brand varchar(255) after Cpu,
add column cpu_name varchar(255) after cpu_brand,
add column cpu_speed decimal(10,1) after cpu_name


select * from laptopdata2

update laptopdata2 set cpu_brand =substring_index (cpu,' ', 1)

 
 update laptopdata2 set cpu_speed = cast(replace (substring_index(Cpu,' ',-1 ), 'GHz', '') as decimal(10,2)) 


select substring_index (cpu,' ', 3) from laptopdata2

update laptopdata2 set cpu_name = SUBSTRING(Cpu, 6);

alter table laptopdata2 drop column Cpu
select cpu_name, substring_index(cpu_name, ' ', -1) from laptopdata2

select cpu_name, substring_index(trim(cpu_name), ' ', 2) from laptopdata2

alter table laptopdata2 set cpu_nam1 = substring_index(trim(cpu_name), ' ', 2)

update laptopdata2 set cpu_nam = substring_index(trim(cpu_name), ' ', 2)

alter table laptopdata2 drop column cpu_name

-- Now we are doing with screenresolution column

select screenresolution ,
substring_index(substring_index(screenresolution,' ',-1),'x',1),
substring_index(substring_index(screenresolution,' ',-1),'x',-1) from laptopdata2

alter table laptopdata2
add column resolution_width integer after screenresolution,
add column resolution_height integer after resolution_width

alter table laptopdata2
add column touchscreen integer after resolution_height

select * from laptopdata2

update laptopdata2 set resolution_width = substring_index(substring_index(screenresolution,' ',-1),'x',1), 
 resolution_height = substring_index(substring_index(screenresolution,' ',-1),'x',1)


select screenresolution like '%Touch%' from laptopdata2

update laptopdata2 set touchscreen = screenresolution like '%Touch%' 

alter table laptopdata2 drop column screenresolution


-- So now we will last and very tricky column "Memory"
-- we'll break  this cloumn into  three column -> memory type | primary-storage | secondary storage

alter table  laptopdata2 add column memory_type varchar(255) after Memory,
add column primary_storage varchar(255) after memory_type,
add column secondary_storage varchar(255) after primary_storage


select Memory,case
					when memory like "%SSD%" and memory like "%HDD%" then 'Hybride'
                    when memory like "%SSD%"  then 'SDD'
                    when memory like "%HDD%" then 'HDD'
                    when memory like "%Flash Storage%" then 'Flash Storage'
                    when memory like "%Flash Storage%" and memory like "%HDD%" then 'Hybride'
                    when memory like "%Hybride%" then 'Hybride' 
                    
                    else null
				end as 'memory_type'
                    from laptopdata2
                    
update laptopdata2 set memory_type = case
					when memory like "%SSD%" and memory like "%HDD%" then 'Hybride'
                    when memory like "%SSD%"  then 'SDD'
                    when memory like "%HDD%" then 'HDD'
                    when memory like "%Flash Storage%" then 'Flash Storage'
                    when memory like "%Flash Storage%" and memory like "%HDD%" then 'Hybride'
                    when memory like "%Hybride%" then 'Hybride' 
                    
                    else null
				end


select Memory, regexp_substr(substring_index(memory,'+',1),'[0-9]+'),
		case when memory like '%+%' then  regexp_substr(substring_index (memory,'+',-1), '[0-9]+') else 0 end  
 from laptopdata2

update laptopdata2 set primary_storage = regexp_substr(substring_index(memory,'+',1),'[0-9]+'),
secondary_storage = case when memory like '%+%' then  regexp_substr(substring_index (memory,'+',-1), '[0-9]+') else 0 end 


select * from laptopdata2

select  primary_storage,
	case when primary_storage <=2 then primary_storage* 1024 else primary_storage end , secondary_storage,
	case when secondary_storage <=2 then secondary_storage* 1024 else secondary_storage end  from laptopdata2


update laptopdata2 set primary_storage = case when primary_storage <=2 then primary_storage* 1024 else primary_storage end, 
update laptopdata2 set secondary_storage = case when secondary_storage <=2 then secondary_storage* 1024 else secondary_storage end

 
 use data_clean
select * from laptopdata2



