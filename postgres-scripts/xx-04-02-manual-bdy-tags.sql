




-- fix 35 boatsheds
update gnaf_202202.address_principal_admin_boundaries
    set lga_pid = 'lgacbffb11990f2',
        lga_name = 'Hobart City'
where locality_pid = 'loc0f7a581b85b7'
    and lga_pid is null;

-- Missing LGAs - not fixed -- no LGA, oyster lease etc..., or small number of addresses
-- +-------------+---------------+--------------+--------+-----+
-- |address_count|locality_pid   |locality_name |postcode|state|
-- +-------------+---------------+--------------+--------+-----+
-- All of ACT
-- |2150         |locc15e0d2d6f2a|NORFOLK ISLAND|2899    |OT   |
-- |180          |loced195c315de9|JERVIS BAY    |2540    |OT   |
-- |51           |250190776      |THISTLE ISLAND|5606    |SA   |
-- |23           |loccf8be9dcdacd|SMOKY BAY     |5680    |SA   |
-- |8            |loc552bd3aef1b8|JENNINGS      |4383    |NSW  |
-- +-------------+---------------+--------------+--------+-----+


-- 106 localities with =< 4 addresses (mostly coastal, some mid-river)...


