INSERT INTO gnaf.locality_neighbour_lookup
SELECT locality_pid, neighbour_locality_pid
  FROM raw_gnaf.locality_neighbour
  WHERE locality_pid <> neighbour_locality_pid;