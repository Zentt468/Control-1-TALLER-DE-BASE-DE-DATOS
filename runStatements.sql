--1. Presupuesto más caro realizado por año y valor total.
SELECT p.id_presupuesto, EXTRACT(YEAR FROM p.fecha) anio, p.monto_total
FROM Presupuesto p
INNER JOIN ( 
SELECT EXTRACT(YEAR FROM p_aux.fecha) anio, MAX(p_aux.monto_total) monto_max
	FROM Presupuesto p_aux
	GROUP BY EXTRACT(YEAR FROM p_aux.fecha)
) aux ON aux.anio = EXTRACT(YEAR FROM p.fecha)
	AND  aux.monto_max = p.monto_total
ORDER BY anio;

--2. Empleado que participó en más trabajos el 2020.
SELECT e.id_empleado, e.nombre_T, e.rut_T, e.correo_T, COUNT(*) trabajos
FROM Empleado e
INNER JOIN Detalle_Trabajo dt
ON e.id_empleado = dt.id_empleado
INNER JOIN Trabajo t
ON dt.id_trabajo = t.id_trabajo
WHERE EXTRACT(YEAR FROM t.fecha_inicio) = 2020
GROUP BY e.id_empleado, e.nombre_T, e.rut_T, e.correo_T
ORDER BY trabajos DESC
LIMIT 1;

--3. Trabajos finalizados por mes durante el 2020.
SELECT EXTRACT(MONTH FROM t.fecha_fin) mes, COUNT(*) trabajos
FROM Trabajo t
WHERE EXTRACT(YEAR FROM t.fecha_fin) = 2020
GROUP BY mes
ORDER BY trabajos DESC;

--4. Empleado con más presupuestos rechazados.
SELECT e.id_empleado, e.nombre_T, COUNT(*) presupuestos_rechazados
FROM Empleado e
INNER JOIN Presupuesto p 
ON p.id_empleado = e.id_empleado
INNER JOIN EstadoP ep
ON ep.id_estado_p = p.id_estado_p
WHERE ep.nombre_estado_p = 'RECHAZADO'
GROUP BY e.id_empleado, e.nombre_T
ORDER BY presupuestos_rechazados DESC
LIMIT 1;

--5. Tarea más realizada por trabajo.
SELECT DISTINCT ON (dt.id_trabajo) dt.id_trabajo, t.nombre_tarea, COUNT(*) AS veces FROM Detalle_Trabajo dt 
JOIN Tarea t ON t.id_tarea = dt.id_tarea
GROUP BY dt.id_trabajo, t.id_tarea, t.nombre_tarea
ORDER BY dt.id_trabajo, veces DESC; 

--6. Empleado con el mayor sueldo por cargo.
SELECT c.nombre_cargo, s.cantidad, e.id_empleado, e.nombre_T
FROM Empleado e
INNER JOIN Cargo c
ON c.id_cargo = e.id_cargo
INNER JOIN Sueldo s
ON s.id_empleado = e.id_empleado
INNER JOIN (
	SELECT e_aux.id_cargo, MAX(s_aux.cantidad) sueldo_max
	FROM Empleado e_aux
	INNER JOIN Sueldo s_aux
	ON s_aux.id_empleado = e_aux.id_empleado
	GROUP BY e_aux.id_cargo
) aux ON aux.id_cargo = e.id_cargo
	AND aux.sueldo_max = s.cantidad
ORDER BY c.nombre_cargo, e.nombre_T;

--7. Presupuesto con más actividades a realizar por mes en los últimos 2 años.
SELECT DISTINCT ON (EXTRACT(MONTH FROM p.fecha))
EXTRACT(MONTH FROM p.fecha) AS mes,
p.id_presupuesto,
p.monto_total,
COUNT(dp.id_detalle_presupuesto) AS total_actividades
FROM Presupuesto p
JOIN Detalle_Presupuesto dp ON p.id_presupuesto = dp.id_presupuesto
WHERE p.fecha >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY EXTRACT(MONTH FROM p.fecha), p.id_presupuesto, p.monto_total
ORDER BY EXTRACT(MONTH FROM p.fecha), total_actividades DESC;

--8. Trabajo más rápido finalizado por mes durante el 2021.
SELECT t.id_trabajo, EXTRACT(MONTH FROM t.fecha_fin) mes, t.fecha_fin - t.fecha_inicio total_dias
FROM Trabajo t
INNER JOIN (
	SELECT EXTRACT(MONTH FROM t_aux.fecha_fin) mes, MIN(t_aux.fecha_fin - t_aux.fecha_inicio) total_dias_min
	FROM Trabajo t_aux
	WHERE EXTRACT(YEAR FROM t_aux.fecha_fin) = 2021
	GROUP BY EXTRACT(MONTH FROM t_aux.fecha_fin)
) aux ON aux.mes = EXTRACT(MONTH FROM t.fecha_fin)
	AND aux.total_dias_min = t.fecha_fin - t.fecha_inicio
WHERE EXTRACT(YEAR FROM t.fecha_fin) = 2021
ORDER BY mes, t.id_trabajo;

--9. Vehículo con el mayor número de tareas realizadas sobre este.
SELECT v.id_vehiculo, v.patente, v.marca, v.modelo,
COUNT(dt.id_detalle_trabajo) AS total_tareas_realizadas
FROM Vehiculo v
JOIN Presupuesto p ON v.id_vehiculo = p.id_vehiculo
JOIN Trabajo t ON p.id_presupuesto = t.id_presupuesto
JOIN Detalle_Trabajo dt ON t.id_trabajo = dt.id_trabajo
GROUP BY v.id_vehiculo, v.patente, v.marca, v.modelo
ORDER BY total_tareas_realizadas DESC
LIMIT 1;

--10. Cantidad de presupuestos aceptados por local por mes, los últimos 5 años.
SELECT l.id_local, l.nombre_L, EXTRACT(YEAR FROM p.fecha) anio, EXTRACT(MONTH FROM p.fecha) mes, COUNT(*) presupuestos_aceptados
FROM Local l
INNER JOIN Presupuesto p
ON p.id_local = l.id_local
INNER JOIN EstadoP ep
ON ep.id_estado_p = p.id_estado_p
WHERE ep.nombre_estado_p = 'ACEPTADO'
AND p.fecha >= CURRENT_DATE - INTERVAL '5 years'
GROUP BY l.id_local, l.nombre_L, EXTRACT(YEAR FROM p.fecha), EXTRACT(MONTH FROM p.fecha)
ORDER BY l.id_local, anio, mes, presupuestos_aceptados;
