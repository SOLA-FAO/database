﻿insert into system.br(id, technical_type_code, feedback) 
values('rrr-must-have-parties', 'sql', 'These rights (and restrictions) must have a recorded party (or parties)::::RRR per cui sono previste parti, le devono avere');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('rrr-must-have-parties', now(), 'infinity', 
'select count(*) = 0 as vl
from administrative.rrr r
where id= #{id} and type_code in (select code from administrative.rrr_type where party_required)
and (select count(*) from administrative.party_for_rrr where rrr_id= r.id) = 0');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('rrr-must-have-parties', 'critical', 'current', 'rrr', 3);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('rrr-shares-total-check', 'sql', 'The sum of the shares (in ownership rights) must total to 1::::Le quote non raggiungono 1',
 '#{id}(administrative.rrr.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('rrr-shares-total-check', now(), 'infinity', 
'select 
  sum(((select multiply_agg(rrrsh2.denominator) 
    from administrative.rrr_share rrrsh2 where rrrsh1.rrr_id = rrrsh2.rrr_id) /rrrsh1.denominator)*rrrsh1.nominator) = 
  (select multiply_agg(rrrsh2.denominator) 
    from administrative.rrr_share rrrsh2 where rrr_id = #{id}) as vl
from administrative.rrr_share rrrsh1 where rrr_id = #{id}');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('rrr-shares-total-check', 'critical', 'current', 'rrr', 16);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('ba_unit-has-several-mortgages-with-same-rank', 'sql', 'The rank of a new mortgage must not be the same as an existing mortgage registered on the same title::::Il titolo ha una ipoteca corrente con lo stesso grado di priorita',
 '#{id}(administrative.rrr.id) is requested.');
--delete from system.br_definition where br_id = 'ba_unit-has-several-mortgages-with-same-rank'
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('ba_unit-has-several-mortgages-with-same-rank', now(), 'infinity', 
'select not (rrr1.mortgage_ranking = rrr2.mortgage_ranking) as vl
from administrative.rrr rrr1 inner join administrative.rrr rrr2 on rrr1.ba_unit_id= rrr2.ba_unit_id
where rrr2.id= #{id} and rrr1.status_code=''current'' and rrr1.type_code=''mortgage'' and rrr1.nr!=rrr2.nr
order by 1
limit 1');

INSERT INTO system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
VALUES('ba_unit-has-several-mortgages-with-same-rank', 'critical', 'current', 'rrr', 19);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('ba_unit-has-caveat', 'sql', 'Title is not encumbered by a caveat.::::Il titolo ha un diritto di prelazione attivo',
 '#{id}(administrative.rrr.id) is requested.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('ba_unit-has-caveat', now(), 'infinity', 
'select not (rrr1.status_code = ''current'' 
  and (select count(*)=0 from administrative.rrr rrr3 inner join transaction.transaction t on rrr3.transaction_id = t.id 
  inner join application.service s on s.id= t.from_service_id
  inner join application.request_type rt on s.request_type_code= rt.code
  where (rrr3.ba_unit_id, rrr3.nr)= (rrr1.ba_unit_id, rrr1.nr) and rrr3.status_code=''pending'' and rt.type_action_code = ''cancel'')) as vl
from administrative.rrr rrr1 inner join administrative.rrr rrr2 on rrr1.ba_unit_id= rrr2.ba_unit_id
where rrr2.id= #{id} and rrr1.status_code in (''current'', ''pending'') and rrr1.nr!=rrr2.nr
and rrr1.type_code = ''caveat''
order by 1
limit 1');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('ba_unit-has-caveat', 'critical', 'current', 'rrr', 19);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('rrr-has-pending', 'sql', 'There are no other pending actions on the rights and restrictions being changed or removed on this application::::Non vi sono modifiche pendenti sul diritto, responsabilita o restrizione che si sta per cambiare o rimuovere',
 '#{id}(administrative.rrr.id) is requested. It checks if for the target rrr there is already a pending edit or record.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('rrr-has-pending', now(), 'infinity', 
'select count(*) = 0 as vl
from administrative.rrr rrr1 inner join administrative.rrr rrr2 on (rrr1.ba_unit_id, rrr1.nr) = (rrr2.ba_unit_id, rrr2.nr)
where rrr1.id = #{id} and rrr2.id!=rrr1.id and rrr2.status_code = ''pending''
');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('rrr-has-pending', 'critical', 'current', 'rrr', 1);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;

