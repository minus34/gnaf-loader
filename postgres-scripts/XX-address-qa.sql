select Count(*) from address_detail where confidence > -1; -- 13845688


select Count(*) from addresses; -- 13845687

select *
  from address_detail where confidence > -1
  and address_detail_pid NOT IN (select gnaf_pid from addresses);





select *
  from address_detail as adr
  left outer join addresses as adr2 on adr.address_detail_pid = adr2.gnaf_pid
  where adr.confidence > -1
  and adr2.gnaf_pid IS NULL;



select * from address_detail where address_detail_pid = 'GAVIC420465249'; -- P
select * from address_default_geocode where address_detail_pid = 'GAVIC420465249'; -- STL -37.82986370, 144.98787794


select * from address_principals where gnaf_pid = 'GAVIC420465249';

select * from address_aliases where gnaf_pid = 'GAVIC420465249';





select * from temp_addresses where gnaf_pid = 'GAVIC420465249';






  