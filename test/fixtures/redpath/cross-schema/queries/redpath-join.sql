-- Red-path fixture (foundation/03): a query touching both members of the
-- declared incompatible pair in ../pairs.json. Never executed.
SELECT l.id
FROM redpath_left.rows l
JOIN redpath_right.rows r ON r.id = l.id;
