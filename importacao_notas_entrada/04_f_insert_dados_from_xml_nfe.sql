/*

-- Function: public.f_insert_dados_from_xml_nfe()
-- SELECT * FROM xml_nfe ORDER BY 1 DESC
-- DELETE from com_compras WHERE EXISTS (SELECT 1 FROM xml_nfe WHERE xml_nfe.id_compra = com_compras.id_compra);
-- DROP FUNCTION public.f_insert_dados_from_xml_nfe();

UPDATE xml_nfe SET id = id, status = 0, id_compra = NULL, codigo_empresa = NULL, codigo_filial = NULL WHERE status <> -1 AND tipo_documento = 2

UPDATE xml_nfe SET id = id, status = 0, id_compra = NULL, codigo_empresa = NULL, codigo_filial = NULL WHERE id = 914

SELECT * FROM xml_nfe WHERE status = 2

UPDATE xml_nfe SET escriturar = 1 WHERE id = 1839

AND id = 3935

SELECT * FROM v_xml_nfe WHERE chave_nfe = '53211008944556000148570010002959141858430466'

SELECT * FROM com_produtos_temp WHERE xml_nfe_id = 1836
DELETE FROM xml_nfe
DELETE  FROM com_produtos_temp 
f_py_get_cmd_bloco_cte_v2(xml_nfe),

SELECT v_xml_nfe.*, com_produtos_temp.* FROM v_xml_nfe LEFT JOIN com_produtos_temp On com_produtos_temp.xml_nfe_id = v_xml_nfe.id WHERE tipo_documento = 0 ORDER BY v_xml_nfe.id DESC 

WHERE id = 3929

UPDATE xml_nfe SET status = 1 WHERE id = 4293
SELECT * FROM xml_nfe ORDER BY 1 DESC  LIMIT 10
SELECT * FROM com_produtos_temp WHERE xml_nfe_id = 4293
-- DELETE FROM com_produtos_temp WHERE id = 3935


-- DELETE FROM xml_nfe WHERE id IN (3923, 3922,3921,3920,3919,3918)
-- xml_nfe.tipo_documento = 1 AND xml_nfe.codigo_empresa IS NULL;
-- ALTER TABLE com_compras DROP COLUMN id_conta_pagar;
-- UPDATE xml_nfe SET status = 0 WHERE id = 279
-- SELECT * FROM com_compras WHERE id_compra = 20677
SELECT tipo_documento, * FROM xml_nfe ORDER BY 2 DESC LIMIT 100 
WHERE id = 3929
SELECT * FROM com_produtos_temp WHERE xml_nfe_id = 3935
ORDER BY 1 DESC LIMIT 100
-- f_py_get_cmd_bloco_nfe_v2(NEW.xml_nfe::text)
--ORDER BY 1 DESC LIMIT 30
-- SELECT now()

DELETE FROM com_compras USING xml_nfe
WHERE com_compras.id_compra = xml_nfe.id_compra;

INSERT INTO xml_nfe (
				chave_nfe,
				xml_nfe )
			VALUES (
				'41220103913585000390550020000196191381717982',
				'PG5mZVByb2MgdmVyc2FvPSI0LjAwIiB4bWxucz0iaHR0cDovL3d3dy5wb3J0YWxmaXNjYWwuaW5mLmJyL25mZSI+PE5GZSB4bWxucz0iaHR0cDovL3d3dy5wb3J0YWxmaXNjYWwuaW5mLmJyL25mZSI+PGluZk5GZSBJZD0iTkZlNDEyMjAxMDM5MTM1ODUwMDAzOTA1NTAwMjAwMDAxOTYxOTEzODE3MTc5ODIiIHZlcnNhbz0iNC4wMCI+PGlkZT48Y1VGPjQxPC9jVUY+PGNORj4zODE3MTc5ODwvY05GPjxuYXRPcD5FbWlzc2FvIE5GLWUgZW0gc3Vic3QuIGRvY3MuIGRlIHZlbmRhPC9uYXRPcD48bW9kPjU1PC9tb2Q+PHNlcmllPjI8L3NlcmllPjxuTkY+MTk2MTk8L25ORj48ZGhFbWk+MjAyMi0wMS0xOFQxNjowOTo1Mi0wMzowMDwvZGhFbWk+PGRoU2FpRW50PjIwMjItMDEtMThUMTY6MDk6NTItMDM6MDA8L2RoU2FpRW50Pjx0cE5GPjE8L3RwTkY+PGlkRGVzdD4xPC9pZERlc3Q+PGNNdW5GRz40MTEwMDc4PC9jTXVuRkc+PHRwSW1wPjE8L3RwSW1wPjx0cEVtaXM+MTwvdHBFbWlzPjxjRFY+MjwvY0RWPjx0cEFtYj4xPC90cEFtYj48ZmluTkZlPjE8L2Zpbk5GZT48aW5kRmluYWw+MTwvaW5kRmluYWw+PGluZFByZXM+MTwvaW5kUHJlcz48cHJvY0VtaT4wPC9wcm9jRW1pPjx2ZXJQcm9jPk1vZE5GZTwvdmVyUHJvYz48TkZyZWY+PHJlZk5GZT40MTIyMDEwMzkxMzU4NTAwMDM5MDY1MDA1MDAwMTYxOTc0MTE1MzA1OTE2MDwvcmVmTkZlPjwvTkZyZWY+PC9pZGU+PGVtaXQ+PENOUEo+MDM5MTM1ODUwMDAzOTA8L0NOUEo+PHhOb21lPkNPU1RBIEJJU0NBSUEgJmFtcDsgQ0lBIExUREE8L3hOb21lPjx4RmFudD5SRURFIFBSTyBUT1JLIC0gUE9TVE8gRE8gQVZJQU88L3hGYW50PjxlbmRlckVtaXQ+PHhMZ3I+Uk9ET1ZJQSBETyBDQUZFPC94TGdyPjxucm8+U048L25ybz48eEJhaXJybz5LTSAzODQ8L3hCYWlycm8+PGNNdW4+NDExMDA3ODwvY011bj48eE11bj5JbWJhdTwveE11bj48VUY+UFI8L1VGPjxDRVA+ODQyNTAwMDA8L0NFUD48Y1BhaXM+MTA1ODwvY1BhaXM+PHhQYWlzPkJSQVNJTDwveFBhaXM+PC9lbmRlckVtaXQ+PElFPjkwNjc5ODQyNTg8L0lFPjxDUlQ+MzwvQ1JUPjwvZW1pdD48ZGVzdD48Q05QSj4wODk0NDU1NjAwMDE0ODwvQ05QSj48eE5vbWU+QlNCLURGIFRSQU5TUE9SVEVTIERFIENBUkdBUyBMVERBIE1FPC94Tm9tZT48ZW5kZXJEZXN0Pjx4TGdyPkFSRUEgREUgREVTRU5WT0xWSU1FTlRPIEVDT05PTUlDTzwveExncj48bnJvPjAyNzwvbnJvPjx4QmFpcnJvPkFHVUFTIENMQVJBUzwveEJhaXJybz48Y011bj41MzAwMTA4PC9jTXVuPjx4TXVuPkJyYXNpbGlhPC94TXVuPjxVRj5ERjwvVUY+PENFUD43MTk5MTAwMDwvQ0VQPjxjUGFpcz4xMDU4PC9jUGFpcz48eFBhaXM+QlJBU0lMPC94UGFpcz48Zm9uZT42MTk4MTU5MDc5NDwvZm9uZT48L2VuZGVyRGVzdD48aW5kSUVEZXN0PjE8L2luZElFRGVzdD48SUU+MDc0ODk3NjkwMDEzMDwvSUU+PGVtYWlsPnZhbGRlY3lic2JkZkBnbWFpbC5jb208L2VtYWlsPjwvZGVzdD48YXV0WE1MPjxDUEY+NDgzMDc3NDI5MDA8L0NQRj48L2F1dFhNTD48ZGV0IG5JdGVtPSIxIj48cHJvZD48Y1Byb2Q+MTM4NTwvY1Byb2Q+PGNFQU4+U0VNIEdUSU48L2NFQU4+PHhQcm9kPkRJRVNFTCBTMTA8L3hQcm9kPjxOQ00+MjcxMDE5MjE8L05DTT48Q0VTVD4wNjAwNjA1PC9DRVNUPjxDRk9QPjU5Mjk8L0NGT1A+PHVDb20+bDwvdUNvbT48cUNvbT41Ny44NDUwPC9xQ29tPjx2VW5Db20+NS4yOTAwMDAwMDAwPC92VW5Db20+PHZQcm9kPjMwNi4wMDwvdlByb2Q+PGNFQU5UcmliPlNFTSBHVElOPC9jRUFOVHJpYj48dVRyaWI+bDwvdVRyaWI+PHFUcmliPjU3Ljg0NTA8L3FUcmliPjx2VW5UcmliPjUuMjkwMDAwMDAwMDwvdlVuVHJpYj48aW5kVG90PjE8L2luZFRvdD48Y29tYj48Y1Byb2RBTlA+ODIwMTAxMDM0PC9jUHJvZEFOUD48ZGVzY0FOUD5PTEVPIERJRVNFTCBCIFMxMCBDT01VTTwvZGVzY0FOUD48VUZDb25zPlBSPC9VRkNvbnM+PC9jb21iPjwvcHJvZD48aW1wb3N0bz48dlRvdFRyaWI+NzcuODc8L3ZUb3RUcmliPjxJQ01TPjxJQ01TU1Q+PG9yaWc+MDwvb3JpZz48Q1NUPjYwPC9DU1Q+PHZCQ1NUUmV0PjI1NS42NzwvdkJDU1RSZXQ+PHBTVD4xMi4wMDAwPC9wU1Q+PHZJQ01TU1RSZXQ+MzAuNjg8L3ZJQ01TU1RSZXQ+PHZCQ1NURGVzdD4yNTUuNjc8L3ZCQ1NURGVzdD48dklDTVNTVERlc3Q+MzAuNjg8L3ZJQ01TU1REZXN0PjxwUmVkQkNFZmV0PjAuMDAwMDwvcFJlZEJDRWZldD48dkJDRWZldD4zMDYuMDA8L3ZCQ0VmZXQ+PHBJQ01TRWZldD4xMi4wMDAwPC9wSUNNU0VmZXQ+PHZJQ01TRWZldD4zNi43MjwvdklDTVNFZmV0PjwvSUNNU1NUPjwvSUNNUz48UElTPjxQSVNPdXRyPjxDU1Q+OTk8L0NTVD48dkJDPjAuMDA8L3ZCQz48cFBJUz4wLjAwMDA8L3BQSVM+PHZQSVM+MC4wMDwvdlBJUz48L1BJU091dHI+PC9QSVM+PENPRklOUz48Q09GSU5TT3V0cj48Q1NUPjk5PC9DU1Q+PHZCQz4wLjAwPC92QkM+PHBDT0ZJTlM+MC4wMDAwPC9wQ09GSU5TPjx2Q09GSU5TPjAuMDA8L3ZDT0ZJTlM+PC9DT0ZJTlNPdXRyPjwvQ09GSU5TPjwvaW1wb3N0bz48L2RldD48dG90YWw+PElDTVNUb3Q+PHZCQz4wLjAwPC92QkM+PHZJQ01TPjAuMDA8L3ZJQ01TPjx2SUNNU0Rlc29uPjAuMDA8L3ZJQ01TRGVzb24+PHZGQ1A+MC4wMDwvdkZDUD48dkJDU1Q+MC4wMDwvdkJDU1Q+PHZTVD4wLjAwPC92U1Q+PHZGQ1BTVD4wLjAwPC92RkNQU1Q+PHZGQ1BTVFJldD4wLjAwPC92RkNQU1RSZXQ+PHZQcm9kPjMwNi4wMDwvdlByb2Q+PHZGcmV0ZT4wLjAwPC92RnJldGU+PHZTZWc+MC4wMDwvdlNlZz48dkRlc2M+MC4wMDwvdkRlc2M+PHZJST4wLjAwPC92SUk+PHZJUEk+MC4wMDwvdklQST48dklQSURldm9sPjAuMDA8L3ZJUElEZXZvbD48dlBJUz4wLjAwPC92UElTPjx2Q09GSU5TPjAuMDA8L3ZDT0ZJTlM+PHZPdXRybz4wLjAwPC92T3V0cm8+PHZORj4zMDYuMDA8L3ZORj48dlRvdFRyaWI+NzcuODc8L3ZUb3RUcmliPjwvSUNNU1RvdD48L3RvdGFsPjx0cmFuc3A+PG1vZEZyZXRlPjk8L21vZEZyZXRlPjwvdHJhbnNwPjxwYWc+PGRldFBhZz48aW5kUGFnPjA8L2luZFBhZz48dFBhZz45MDwvdFBhZz48dlBhZz4wLjAwPC92UGFnPjwvZGV0UGFnPjwvcGFnPjxpbmZBZGljPjxpbmZDcGw+UmVmZXJlbnRlIGFvcyBkb2N1bWVudG9zOiBORkMtZSBzw6lyaWUgNSwgbnVtLiAxNjE5NzQuIFRyaWIgYXByb3ggUiQ6IDQxLDE1IEZlZGVyYWwgZSAzNiw3MiBFc3RhZHVhbF5Gb250ZTogSUJQVC9lbXByZXNvbWV0cm8uY29tLmJyIDQxQzYxNy4gUGxhY2E6IE9WUzg3NDYgS006IDM2MTYyOCBNb3RvcmlzdGE6IFZBTERFQ0kuIEJhc2UgSUNNUyBTVCByZXRpZG86IFIkIDI1NSw2Ny4gVmFsb3IgSUNNUyBTVCByZXRpZG86IFIkIDMwLDY4PC9pbmZDcGw+PC9pbmZBZGljPjxpbmZSZXNwVGVjPjxDTlBKPjg1MzA1NDMxMDAwMTE5PC9DTlBKPjx4Q29udGF0bz5FZGlzb24gTGluaGFyZXMgZGUgT2xpdmVpcmE8L3hDb250YXRvPjxlbWFpbD5zdXBvcnRlQG1vZHVsYS5jb20uYnI8L2VtYWlsPjxmb25lPjQ4MzI0ODQ4ODY8L2ZvbmU+PC9pbmZSZXNwVGVjPjwvaW5mTkZlPjxTaWduYXR1cmUgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyMiPjxTaWduZWRJbmZvPjxDYW5vbmljYWxpemF0aW9uTWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvVFIvMjAwMS9SRUMteG1sLWMxNG4tMjAwMTAzMTUiIC8+PFNpZ25hdHVyZU1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNyc2Etc2hhMSIgLz48UmVmZXJlbmNlIFVSST0iI05GZTQxMjIwMTAzOTEzNTg1MDAwMzkwNTUwMDIwMDAwMTk2MTkxMzgxNzE3OTgyIj48VHJhbnNmb3Jtcz48VHJhbnNmb3JtIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnI2VudmVsb3BlZC1zaWduYXR1cmUiIC8+PFRyYW5zZm9ybSBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnL1RSLzIwMDEvUkVDLXhtbC1jMTRuLTIwMDEwMzE1IiAvPjwvVHJhbnNmb3Jtcz48RGlnZXN0TWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnI3NoYTEiIC8+PERpZ2VzdFZhbHVlPkUwRkxLVUpTSGEzUGdjN3VVOFN6QThGRXFFVT08L0RpZ2VzdFZhbHVlPjwvUmVmZXJlbmNlPjwvU2lnbmVkSW5mbz48U2lnbmF0dXJlVmFsdWU+V1lsR1ZqWUJFa2IrRUlKK0tLQWJVV3hDKzJWbnFteGpvWUxMNlVSdTZVMnR4OStTa0pSZ2xwQU1JdkcrN2RNVmtEZlVTRGhUTXBORWpnOXVVcDAvQ0ZBWE5EemlhbHpqdUI4SXZBUTBYZXhicy9zNENMRzB3MjM5cDRTYnM2dmtNSnAxVE5BM0NEVzV2ZkhTRW96MjhjM3dsS0s3dGFJa1lTQmZpbThrRzVncDd5MmcrcjlZQWE0b2F2OGFLOE11RFVRN2FGcUZUZDBiNFArZlJNb2hpNFVnQWlLVUwySzhsS2FUeWxHY3R3U0tqY3NwMVRPdEVSSzhRYkJPWkhMZDVNaXFuUUFybjZ5S1FkendWbnF5a3Y5MkdDcVZXLzJmNUNBb0FmUHFWVjBkc01OQllMcUJFblAzU0lNTVlQM1J0dXF2ZkpmQjh5N2FNaGdyL05OUjNBPT08L1NpZ25hdHVyZVZhbHVlPjxLZXlJbmZvPjxYNTA5RGF0YT48WDUwOUNlcnRpZmljYXRlPk1JSUhTRENDQlRDZ0F3SUJBZ0lJWlh3aEJ4bHFwVW93RFFZSktvWklodmNOQVFFTEJRQXdXVEVMTUFrR0ExVUVCaE1DUWxJeEV6QVJCZ05WQkFvVENrbERVQzFDY21GemFXd3hGVEFUQmdOVkJBc1RERUZESUZOUFRGVlVTU0IyTlRFZU1Cd0dBMVVFQXhNVlFVTWdVMDlNVlZSSklFMTFiSFJwY0d4aElIWTFNQjRYRFRJeE1EY3lNREU0TWpJd01Gb1hEVEl5TURjeU1ERTRNakl3TUZvd2dkc3hDekFKQmdOVkJBWVRBa0pTTVJNd0VRWURWUVFLRXdwSlExQXRRbkpoYzJsc01Rc3dDUVlEVlFRSUV3SlFVakVPTUF3R0ExVUVCeE1GU1cxaVlYVXhIakFjQmdOVkJBc1RGVUZESUZOUFRGVlVTU0JOZFd4MGFYQnNZU0IyTlRFWE1CVUdBMVVFQ3hNT016YzJORFExTlRVd01EQXhPRFl4RXpBUkJnTlZCQXNUQ2xCeVpYTmxibU5wWVd3eEdqQVlCZ05WQkFzVEVVTmxjblJwWm1sallXUnZJRkJLSUVFeE1UQXdMZ1lEVlFRRERDZERUMU5VUVNCQ1NWTkRRVWxCSUNZZ1EwbEJJRXhVUkVFNk1ETTVNVE0xT0RVd01EQXpPVEF3Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRQ0JYVktUVVlSMVpXTE5yanlVR2ZrWGRSZ2hrUHhqWVFRQkRoNmJFTDFmb1g0NXVPYzNjYTdBanUveXc0ckxva2lyWnR5YVo4M3V0ZkVSM0tRdDZSQTF1dDJCRGppZGh0YmFEdWN0NnZVNno0WUNUa2VlR2tVQjljbFA2WUZ1am0xbUxWR2VWSFk1RkhjbDdwanNzSXU4cURGV3k0N2RFamdxd2RkUkE2TzJpVTdaVjJ0R0xXNXNjaTRHM0FXMVpKKzNvRDFNUDZ5TzZLU0xXait1T1c0cXZDK0dPS1RWV0hBVnBzeU5RTnNPSDdKSms0dk8vRS9Sb2xtbnQ4UjhLNmZ1OVViTmtyb2xLVmJ0TlRGOVUwYnFxOTM0NXJmanZNbWxzTXlSR1BKOWdkK21CM1p2aFl5SHhOQi9oYUUvWmZoMUluWnA2SnRtazlzMjB6aVNCK0VYQWdNQkFBR2pnZ0tQTUlJQ2l6QUpCZ05WSFJNRUFqQUFNQjhHQTFVZEl3UVlNQmFBRk1WUzdTV0FDZCtjZ3NpZlI4YmR0Rjh4M2JteE1GUUdDQ3NHQVFVRkJ3RUJCRWd3UmpCRUJnZ3JCZ0VGQlFjd0FvWTRhSFIwY0RvdkwyTmpaQzVoWTNOdmJIVjBhUzVqYjIwdVluSXZiR055TDJGakxYTnZiSFYwYVMxdGRXeDBhWEJzWVMxMk5TNXdOMkl3Z2NvR0ExVWRFUVNCd2pDQnY0RWJhbVZtWlhKemIyNUFaV0pqWTI5dWRHRmlhV3d1WTI5dExtSnlvQ3dHQldCTUFRTUNvQ01USVZOQlRrUlNRU0JOUVZKQklGSkpRa1ZKVWs4Z1EwOVRWRUVnUWtsVFEwRkpRYUFaQmdWZ1RBRURBNkFRRXc0d016a3hNelU0TlRBd01ETTVNS0ErQmdWZ1RBRURCS0ExRXpNeE5EQTBNVGsyTnpZek9Ua3hORFEyT1RnM01URTBNRGd3TlRVek5qSXdNREF3TURBd05ESTFOekF6TWpCVFJWTlFVRktnRndZRllFd0JBd2VnRGhNTU1EQXdNREF3TURBd01EQXdNRjBHQTFVZElBUldNRlF3VWdZR1lFd0JBZ0VtTUVnd1JnWUlLd1lCQlFVSEFnRVdPbWgwZEhBNkx5OWpZMlF1WVdOemIyeDFkR2t1WTI5dExtSnlMMlJ2WTNNdlpIQmpMV0ZqTFhOdmJIVjBhUzF0ZFd4MGFYQnNZUzV3WkdZd0hRWURWUjBsQkJZd0ZBWUlLd1lCQlFVSEF3SUdDQ3NHQVFVRkJ3TUVNSUdNQmdOVkhSOEVnWVF3Z1lFd1BxQThvRHFHT0doMGRIQTZMeTlqWTJRdVlXTnpiMngxZEdrdVkyOXRMbUp5TDJ4amNpOWhZeTF6YjJ4MWRHa3RiWFZzZEdsd2JHRXRkalV1WTNKc01EK2dQYUE3aGpsb2RIUndPaTh2WTJOa01pNWhZM052YkhWMGFTNWpiMjB1WW5JdmJHTnlMMkZqTFhOdmJIVjBhUzF0ZFd4MGFYQnNZUzEyTlM1amNtd3dIUVlEVlIwT0JCWUVGQ1pTRU5IUHFML3pOQlV3SGFTR2dzeTZlSXZxTUE0R0ExVWREd0VCL3dRRUF3SUY0REFOQmdrcWhraUc5dzBCQVFzRkFBT0NBZ0VBdEw5aWl6L1lpTGp4bWxHOHpmMUJHcEU0UHRjQkRrMGtDTHdGV0xqN2UvY2NEenV6RmdFVHdySkxudGJxdUhpclA4TGpxb3hXSmg2RTM1VFNCSi9yL3B1Nk1xazJiZHFXOUR4dVN0dHFwRkNsMG95WkNHVVI5SlN1b1hid2l5YkRNTGlGdVlqdWpQS2ViVjFyT1pHRnQ4K09BTWxScjFqdG03bHJXdWJaYkxXbnZMZkJyU2pIQ2owOXRSQzBFb0dWcXVTdXJnOHJzN04ySFZZaXFCOWxEM21kbi9Hb0g0MkVUQ3E4TVJJa1Ezc05iMWNId2JXRXNydmlxdHpoQXZqM2JybWt1SzdoeW16S2NtRlM1ZHpvek1kNGM3Z2g3Z1ZxODJpTnh3MVo1UnI5ZjB0YUFwenRTWTdBWEZKU0pqMURwQlNnVUtEOFlxcWNyMG84d3B2b0tGdTNMTHBna0h0M3VtUlZwSWt1VTN5bWFNZHdoeS9MK2pGZkZ0MEcvN1VtaDhUZTMydUdoNWQ2SFFHQnkvU3FlOXNkd281d0JtRGFJU3c1aTdnOEN6QlpkelFnQ280VWZvdTdDOHhzdEo1ekY4YnlLWEVENG1NRWxoWmFBUmpxSGpOVnBTbGRpakJzY2lPSFBOajN5UEl3YTJtMWNQSkF2b3pXLytRN1RHVk9sODlOdUMxUTZZSXVzb3FyUUVGYTVrNUpuZmpRdEhiUEdydGNESldybmZ0V1Vnd0k2YVN0MitOZ3ZTcnVLUFJubmFKRi91K0ZhcVlhRWVNZ1p6SG9hZ05XV1NIWkhEU2QwOHp2Q1JBdzMvVUhwNnZnczVyRkNCRUsybDFab0pVTnF2V1lIcW1Va0drZS95Vk1FNzZmZDVFK2RZWTgzNFNrbmpIaU16c1M5RmM9PC9YNTA5Q2VydGlmaWNhdGU+PC9YNTA5RGF0YT48L0tleUluZm8+PC9TaWduYXR1cmU+PC9ORmU+PHByb3RORmUgdmVyc2FvPSI0LjAwIj48aW5mUHJvdCBJZD0iSUQxNDEyMjAwMTI5NzAxNTAiPjx0cEFtYj4xPC90cEFtYj48dmVyQXBsaWM+UFItdjRfN181MDwvdmVyQXBsaWM+PGNoTkZlPjQxMjIwMTAzOTEzNTg1MDAwMzkwNTUwMDIwMDAwMTk2MTkxMzgxNzE3OTgyPC9jaE5GZT48ZGhSZWNidG8+MjAyMi0wMS0xOFQxNjowOTo1NC0wMzowMDwvZGhSZWNidG8+PG5Qcm90PjE0MTIyMDAxMjk3MDE1MDwvblByb3Q+PGRpZ1ZhbD5FMEZMS1VKU0hhM1BnYzd1VThTekE4RkVxRVU9PC9kaWdWYWw+PGNTdGF0PjEwMDwvY1N0YXQ+PHhNb3Rpdm8+QXV0b3JpemFkbyBvIHVzbyBkYSBORi1lPC94TW90aXZvPjwvaW5mUHJvdD48L3Byb3RORmU+PC9uZmVQcm9jPg==');


SELECT * FROM v_xml_nfe	
DELETE FROM xml_nfe WHERE id = 1
*/ 

CREATE OR REPLACE FUNCTION public.f_insert_dados_from_xml_nfe()
  RETURNS trigger AS
$BODY$
DECLARE
        v_xml 		text;        
        v_comandos 	text[];
        v_cmd 		text;

        vIdFornecedor 	integer;
        vIdNf 		integer;
        vQt 		integer;
        vQtNf 		integer;
        vCodigoProduto 	integer;
        vIdProduto 	integer;
        vIdProdFor	integer;
        vIdFat		integer;
	vCodIntegracao  text;
	vCfopEnt	text;
	
	vCstICMS	text;
	vCstPIS		text;	
	vCstCOFINS	text;
	vTipoItem	text;
	
	vCodCli 	text;
	vEspecieProd	text;
	vCondPag	text;
	vTipo		text;

	cTemp 		refcursor;
	crsdadosnfe 	refcursor;
	crsemitente 	refcursor;
	crsremetente 	refcursor;
	crsdestinatario refcursor;
	crsexpedidor 	refcursor;
	crsrecebedor  	refcursor;
	crsoutros	refcursor;	
	crsitens 	refcursor;
	crsfat 		refcursor;
	crsctecompl	refcursor;
	v_prod_temp	refcursor;
	
        vNFe 		t_xml_notas_fiscais_v2%rowtype;
        vItem 		t_xml_notas_itens_v2%rowtype;
        vFornecedor 	t_xml_pessoas_v2%rowtype;
        vRemetente 	t_xml_pessoas_v2%rowtype;
        vDestinatario 	t_xml_pessoas_v2%rowtype; 
        vExpedidor	t_xml_pessoas_v2%rowtype;
        vRecebedor	t_xml_pessoas_v2%rowtype;
        vOutros		t_xml_pessoas_v2%rowtype;
        vFaturas 	t_xml_faturas_v2%rowtype;   
        vCteCompl	t_xml_cte_complementar_v2%rowtype;   
        vProdutosTemp	com_produtos_temp%rowtype;
                
        vTipoDoc	integer;    

        vIdCidade	integer;

        vNumeroCompra	text;
        vModFiscal	text;

        vCadastrado 	integer;
        vParametrizado	integer;
        vTemCfopParametrizado integer;
        vParametroAutomatico integer;

	
	v_fk_codigo_produto text; 
	v_fk_id_produto integer; 
	v_id_produtos_for integer;
	v_com_produtos_empresa_fornecedor_id  integer;
	v_cadastrado integer;
	v_parametrizado integer;
	v_id_almoxarifado integer;

	vCodigoEmpresa text;
	vCodigoFilial text;

	vIdUnidade integer;
	vUn text;

	vTomador character(14);

	vIdServico integer;
	

	vCursor refcursor;
	v_id_produto_temp integer;

	v_cod_produto_serv text;

	ind_frete character(1);

	

	
BEGIN
	/*
		UPDATE xml_nfe SET id = id WHERE id = 27;
	*/

	BEGIN 
		

		IF NEW.status = 2 THEN 
			RETURN NEW;
		END IF;
		IF NEW.xml_nfe IS NULL THEN 
			RETURN NEW;
		END IF;

		--NFe
		--RAISE NOTICE 'XML TAG %',  position('</' in NEW.xml_nfe);
		IF TG_OP = 'INSERT' OR position('</' in NEW.xml_nfe) = 0 THEN 

			--RAISE NOTICE 'Decodificar Base 64';
			
			NEW.xml_nfe = fpy_decode_base64(NEW.xml_nfe);
			
			IF position('<infNFe' in NEW.xml_nfe) > 0 THEN 
				--RAISE NOTICE 'NFE';
				NEW.tipo_documento = 1;			
			END IF;

			--CTe
			IF position('<infCte' in NEW.xml_nfe) > 0 THEN 				
				--RAISE NOTICE 'CTE';
				NEW.tipo_documento = 2;
			END IF;
			
		END IF;


		IF NEW.tipo_documento = 1 THEN 
				vTipoDoc = 1;
				vModFiscal = '55';
		END IF;

		IF NEW.tipo_documento = 2 THEN 
			vTipoDoc = 2;
			vModFiscal = '57';

		END IF;

		
		--RAISE NOTICE 'Modelo Fiscal %', vModFiscal;

		

		-- IF NEW.status < 2 THEN
-- 			RETURN NEW;
-- 		END IF;
-- 
-- 
-- 		IF NEW.status > 2 THEN
-- 			RETURN NEW;
-- 		END IF;
		------------------------------------------------------------------------------
		-- 1 - ENTRADA DE DADOS
		------------------------------------------------------------------------------
		--SELECT xml_nfe::text  INTO v_xml FROM xml_nfe WHERE chave_nfe = NEW.chave_nfe;

		--RAISE NOTICE '%', v_xml;
		--RAISE NOTICE '%', v_xml;
		IF vTipoDoc = 1 THEN 
			v_comandos = string_to_array(f_py_get_cmd_bloco_nfe_v2(NEW.xml_nfe::text),'###');
		END IF;

		IF vTipoDoc = 2 THEN 
			v_comandos = string_to_array(f_py_get_cmd_bloco_cte_v2(NEW.xml_nfe::text),'###');
		END IF;

		
		--RAISE NOTICE 'Comandos %', v_comandos;
		--Criação dos cursores e coleta de dados para os registros
		--  que serão lidos
		
		--Cursor de dados da nfe
		v_cmd = v_comandos[1];
		RAISE NOTICE 'COmando %', v_cmd;
		OPEN crsdadosnfe FOR EXECUTE v_cmd;
		FETCH crsdadosnfe INTO vNFe;
		RAISE NOTICE 'Nota Fiscal % Valor %', vNFe.chave, vNFe.vlr_nf;
		CLOSE crsdadosnfe;        


		NEW.chave_nfe = vNFe.chave;


		SELECT COUNT(*)
		INTO vQt
		FROM xml_nfe
		WHERE xml_nfe.chave_nfe = NEW.chave_nfe AND xml_nfe.id <> NEW.id;

		IF vQt > 0 THEN 
			RETURN NULL;
		END IF;
		
		SELECT 
			COALESCE(count(*),0),
			id_compra
		INTO 
			vQtNf,
			vIdNf
		FROM 
			com_compras
		WHERE 
			chave_nfe = NEW.chave_nfe
		GROUP BY id_compra
		ORDER BY id_compra LIMIT 1;

		vQtNf = COALESCE(vQtNf,0);
				
		RAISE NOTICE 'QT Lancto %: %', NEW.chave_nfe, vQtNf;		
		

		--Cursor de dados do emitente
		v_cmd = v_comandos[2];
		--RAISE NOTICE 'Comando %', v_cmd;
		OPEN crsemitente FOR EXECUTE v_cmd;
		FETCH crsemitente INTO vFornecedor;
		CLOSE crsemitente;
		

		--Cursor de dados do destinatario
		
		v_cmd = v_comandos[3];
		IF trim(v_cmd) <> '' THEN
			OPEN crsdestinatario FOR EXECUTE v_cmd;
			FETCH crsdestinatario INTO vDestinatario;
			CLOSE crsdestinatario;
		END IF;
		--NFe
		IF vTipoDoc = 1 THEN 	
			--Cursor de dados dos itens                
			v_cmd = v_comandos[4];
			OPEN crsitens FOR EXECUTE v_cmd;
			--FETCH crsitens INTO vItem;
			--CLOSE crsitens;
			
			--Cria cursor de dados das faturas
			v_cmd = v_comandos[5];
			OPEN crsfat FOR EXECUTE v_cmd;
			--FETCH crsfat INTO vFaturas;     
			--CLOSE crsfat;
		END IF;

		--CTe
		--Cursor de dados do remetente
		IF vTipoDoc = 2 THEN 
			v_cmd = v_comandos[6];
			IF v_cmd <> '' THEN 
				OPEN crsremetente FOR EXECUTE v_cmd;
				FETCH crsremetente INTO vRemetente;
				CLOSE crsremetente;
			END IF;

			v_cmd = v_comandos[7];

			IF trim(v_cmd) <> '' THEN
				OPEN crsexpedidor FOR EXECUTE v_cmd;
				FETCH crsexpedidor INTO vExpedidor;
				CLOSE crsexpedidor;
			END IF;
			
			v_cmd = v_comandos[8];
			IF trim(v_cmd) <> '' THEN
				OPEN crsrecebedor FOR EXECUTE v_cmd;
				FETCH crsrecebedor INTO vRecebedor;
				CLOSE crsrecebedor;
			END IF;


			v_cmd = v_comandos[9];
			IF trim(v_cmd) <> '' THEN
				OPEN crsoutros FOR EXECUTE v_cmd;
				FETCH crsoutros INTO vOutros;
				CLOSE crsoutros;
			END IF;

			v_cmd = v_comandos[10];
			RAISE NOTICE '%', v_cmd;
			OPEN crsctecompl FOR EXECUTE v_cmd;
			FETCH crsctecompl INTO vCteCompl;
			CLOSE crsctecompl;



		END IF;
		------------------------------------------------------------------------------
		-- 2 - PROCESSAMENTO DOS DADOS
		------------------------------------------------------------------------------

		IF vTipoDoc = 1 THEN 
			SELECT codigo_empresa, codigo_filial
			INTO vCodigoEmpresa, vCodigoFilial
			FROM filial 
			WHERE cnpj = vDestinatario.cnpjcpf AND tipo_unidade IN (1,2);
			ind_frete = NULL;
		END IF;

		IF vTipoDoc = 2 THEN
			IF vCteCompl.tomador = '0' THEN 
				--RAISE NOTICE 'Tomador Remetente';
				vTomador = vRemetente.cnpjcpf;
				ind_frete = '1';
			END IF;

			IF vCteCompl.tomador = '1' THEN 
				--RAISE NOTICE 'Tomador Expedidor';
				vTomador = vExpedidor.cnpjcpf;
				ind_frete = '2';
			END IF;


			IF vCteCompl.tomador = '2' THEN 
				--RAISE NOTICE 'Tomador Recebedor';
				vTomador = vRecebedor.cnpjcpf;
				ind_frete = '2';
			END IF;

			IF vCteCompl.tomador = '3' THEN 
				--RAISE NOTICE 'Tomador Destinatario';
				vTomador = vDestinatario.cnpjcpf;
				ind_frete = '1';
			END IF;
			

			IF vCteCompl.tomador = '4' THEN 
				--RAISE NOTICE 'Tomador Outros';
				vTomador = vOutros.cnpjcpf;
				ind_frete = '2';
			END IF;

			
			SELECT filial.codigo_empresa, filial.codigo_filial, cod_item_1400_sped_fiscal 
			INTO vCodigoEmpresa, vCodigoFilial, vIdServico
			FROM 
				filial 
			WHERE cnpj = vTomador AND tipo_unidade IN (1,2);

			vIdServico = NULL;
		
		END IF;

		RAISE NOTICE 'Filial %,%', vCodigoEmpresa, vCodigoFilial;
		IF vCodigoEmpresa IS NULL THEN 

			RAISE NOTICE 'Documento de Terceiros';
			
			NEW.status = -1;
			
			RETURN NEW;
		END IF;

		
		NEW.gera_escrituracao = 1;
		NEW.codigo_empresa = COALESCE(vCodigoEmpresa,'001');
		NEW.codigo_filial = COALESCE(vCodigoFilial, '001');		
	
		
		
		SELECT id_almoxarifado
		INTO v_id_almoxarifado 
		FROM almoxarifado 
		WHERE 
			cod_empresa = NEW.codigo_empresa
			AND 
			cod_filial = NEW.codigo_filial
			AND 
			ativo = 1
		ORDER BY 1 ASC LIMIT 1;

		RAISE NOTICE 'Destinatario % - %', vDestinatario.cnpjcpf, vDestinatario.nomerazao;		
		RAISE NOTICE 'FILIAL %-%', NEW.codigo_empresa, NEW.codigo_filial;
		RAISE NOTICE 'ALMOXARIFADO %', v_id_almoxarifado;
		
		
		-- 2.1 -- Processamento do Terceiro
		SELECT 	id_fornecedor
		INTO 	vIdFornecedor
		FROM 	fornecedores
		WHERE 	cnpj_cpf = vFornecedor.cnpjcpf;


		---------------------------------------------- Configuracao Fornecedor  ----------------------------------------------------
		IF vIdFornecedor IS NULL THEN 
			RAISE NOTICE 'Fornecedor Nao Existe';


			--Encontrar Cidade 
			SELECT 
				id_cidade
			INTO 
				vIdCidade
			FROM 
				cidades 
			WHERE 
				cod_ibge = vFornecedor.codmunicipio;
				
			--SELECT numero, * FROM fornecedores LIMIT 1

			OPEN cTemp FOR 
			INSERT INTO fornecedores (
				cnpj_cpf, --1
				nome_razao, --2
				fantasia, --3
				endereco, --4
				numero, --5
				bairro, --6
				id_cidade, --7			
				cep, --9
				telefone1, --10
				iest --11

			) VALUES (
				trim(vFornecedor.cnpjcpf), --1
				retira_acento(fpy_limpa_caracteres(left(upper(trim(vFornecedor.nomerazao)),50))), --2
				retira_acento(fpy_limpa_caracteres(left(upper(trim(vFornecedor.nomerazao)),40))), --3
				retira_acento(fpy_limpa_caracteres(left(upper(trim(vFornecedor.endereco)),50))), --4
				left(trim(vFornecedor.numero),10), --5
				retira_acento(fpy_limpa_caracteres(left(upper(trim(vFornecedor.bairro)),30))), --6
				vIdCidade, --7			
				trim(vFornecedor.cep), --9
				fpy_extrai_numero(LEFT(trim(vFornecedor.telefone),8)), --10
				fpy_extrai_numero(LEFT(trim(vFornecedor.iestadual),15)) --11
			)
			RETURNING id_fornecedor;

			FETCH cTemp INTO vIdFornecedor;

			CLOSE cTemp;

		END IF;
		--RAISE NOTICE 'Fornecedor Cadastrado';

		NEW.fornecedor_id = vIdFornecedor;
		NEW.inscr_estadual = vFornecedor.iestadual;
		NEW.data_emissao = vNFe.data_emissao::date;
		NEW.numero = vNFe.numeronf;
		NEW.serie = vNFe.serie;
		NEW.valor_total = COALESCE(vNFe.vlr_nf,0.00);	

		IF vQtNf > 0 THEN 
			RAISE NOTICE 'Docummento ja escriturado';
			NEW.id_compra = vIdNf;
			NEW.status = 2;
			RETURN NEW;
		END IF;

		
		---------------------------------------------- Cadastrar Itens em Com Produtos Temp ------------------------------------
		IF NEW.status = 0 THEN 

			-- Deleta Configuracao Anterior De Documentos Nao Escriturados ainda. (Muito utilizado em tempo de desenvolvimento);
			DELETE FROM com_produtos_temp WHERE xml_nfe_id = NEW.id;
			
			/*
				Configuracao de Itens de Produtos. Verifica se ja tem CFOP Saida/Entrada parametrizado e Produto cadastrado e parametrizado.
				ALTERNATIVAS
					1 - Caso Produto nao esteja cadastrado, usuario podera usar interface para associar a um existente, ja parametrizado.
					2 - Caso Produto nao esteja cadastrado, usuario podera usar interface para parametrizar e criar um novo produto na base de dados.
					3 - Caso Produto nao esteja cadastrado, usuario podera escriturar, deixando a rotina de escrituracao 
					criar novo produto e parametrizar usando configuracoes gerais de CFOP.			

			*/
			--RAISE NOTICE 'Tipo Documento %', vTipoDoc;
			IF vTipoDoc = 1 THEN 
				
				LOOP

					FETCH IN crsitens INTO vItem;

					--Sai do loop se chegou ao fim do cursor
					EXIT WHEN NOT FOUND;

					
					--SELECT id INTo v_id_produto_temp FROM com_produtos_temp WHERE cod_prod_for = vItem.cod_pro  AND xml_nfe_id = NEW.id;

					--CONTINUE WHEN v_id_produto_temp IS NOT NULL;
						
					
					--RAISE NOTICE 'Item %', vItem;
					--Recupera id da unidade
					SELECT 	id_unidade
					INTO 	vIdUnidade
					FROM 	efd_unidades_medida 
					WHERE 	UPPER(trim(unidade)) = trim(vItem.und);

					vUn = vItem.und;
					IF vIdUnidade IS NULL THEN 
						SELECT 	id_unidade
						INTO 	vIdUnidade
						FROM 	efd_unidades_medida 
						WHERE 	UPPER(trim(unidade)) = 'UN';
						vUn = 'UN';
					END IF;	
					


					--Verifica se Produto esta cadastrado associado com o fornecedor
					SELECT 				
						fk_codigo_produto, 
						fk_id_produto, 
						com_produtos_empresa_fornecedor.id 
					INTO 
						v_fk_codigo_produto,
						v_fk_id_produto,
						vIdProdFor
					FROM 
						com_produtos_empresa_fornecedor 
					WHERE 
						fk_id_fornecedor = vIdFornecedor 
						AND 
						codigo_produto_fornecedor = vItem.cod_prod;

					
					--Se o produto nao esta cadastrado, gera apenas o codigo sequencial do produto e marca pendencias.
					IF v_fk_id_produto IS NULL THEN 
												
						vCadastrado = 0;
						vParametrizado = 0;	
								
						--v_fk_codigo_produto = trim(to_char(proximo_numero_sequencia('com_produtos_codigo_produto_seq')::integer,'00000000'));			
						RAISE NOTICE 'Produto Nao Cadastrado';
						
					ELSE 	
						RAISE NOTICE 'Produto Cadastrado';		
						vCadastrado = 1;	
							
						--Se estiver cadastrado, verifica se esta parametrizado, marcando pendencia caso negativo.
						SELECT 	cfop_entrada, cst_icms, cst_pis, cst_cofins
						INTO	vCfopEnt, vCstICMS, vCstPIS, vCstCOFINS
						FROM    com_produtos_sugestao_cfop_cst 									 
						WHERE 	fk_com_produtos_empresa_fornecedor_id = vIdProdFor;
											
						SELECT tipo_item INTO vTipoItem FROM com_produtos WHERE id_produto = v_fk_id_produto;
						
						IF vCfopEnt IS NULL THEN 
							vParametrizado = 0;						
						END IF;
						vParametrizado = 1;
						
							
					END IF;

					
					--Se nao tem parametrizacao, converte CFOP SAIDA para CFOP ENTRADA, para encontrar sugestoes genericas de CFOP. Se nao encontrar marca pendencia
					IF vParametrizado = 0 THEN 
						RAISE NOTICE 'CFOP SAIDA %', vItem.cfop_for;
						SELECT 	fk_codigo_cfop_entrada
						INTO 	vCfopEnt
						FROM 	com_compras_cfop_saida_entrada
						WHERE	
							CASE 
								WHEN fk_codigo_cfop_saida IS NOT NULL AND id_fornecedor IS NOT NULL THEN fk_codigo_cfop_saida = vItem.cfop_for AND id_fornecedor = vIdFornecedor 
								WHEN fk_codigo_cfop_saida IS NULL AND id_fornecedor IS NOT NULL THEN id_fornecedor = vIdFornecedor 				
								WHEN fk_codigo_cfop_saida IS NOT NULL AND id_fornecedor IS NULL THEN fk_codigo_cfop_saida = vItem.cfop_for 
								ELSE false
							END;


						IF vCfopEnt IS NOT NULL THEN
							
							SELECT 	tipo_item, cst_icms, cst_pis, cst_cofins
							INTO	vTipoItem, vCstICMS, vCstPIS, vCstCOFINS
							FROM 	com_compras_sugestao_cfop_cst 			
							WHERE 	fk_codigo_cfop = vCfopEnt;	

							--Se nao tem parametrizacao geral de CFOP, entao marca pendencia
							IF vCstICMS IS NULL THEN 							
								vTemCfopParametrizado = 0;
								vCfopEnt = NULL;
							ELSE
								vTemCfopParametrizado = 1;
							END IF;				
																		
						ELSE
							vTemCfopParametrizado = 0;
						END IF;
					ELSE
						vTemCfopParametrizado = 1;						
					END IF;

					--SELECT * FROM com_produtos_temp LIMIT 1
					RAISE NOTICE 'Paramtrizado %', vParametrizado;
					
					--Insere o Produto na tabela Temporaria para escrituracao					
					INSERT INTO public.com_produtos_temp(
						cod_prod_for, --2
						ncm, --3
						descricao, --4
						cfop_for, --5
						unidade, --6
						quantidade, --7
						vl_item, --8
						vl_total, --9
						aliquota_ipi,--10 
						vl_ipi, --11
						valor_base_icms_st, --12
						valor_icms_st, --13
						vl_frete, --14
						empresa,--15
						id_fornecedor,--16
						id_unidade,--17
						codigo_produto,--18 
						id_produto,--19
						cadastrado,--20
						cfop,--21
						cst_icms,--22
						cst_pis,--23
						cst_cofins,--24
						parametrizado, --25
						xml_nfe_id, --26
						tipo_item, --27
						parametro_cfop --28
					) VALUES (
						vItem.cod_prod, --2
						vItem.ncm, --3
						vItem.descricao, --4
						vItem.cfop_for, --5				
						vUn, --6
						vItem.qtd, --7
						vItem.unit, --8
						vItem.total, --9
						vItem.aliq_ipi, --10
						vItem.valor_ipi, --11
						vItem.bcst, --12
						vItem.icmsst, --13
						vItem.frete, --14
						NEW.codigo_empresa, --15
						vIdFornecedor, --16				
						vIdUnidade, --17
						v_fk_codigo_produto, --18
						v_fk_id_produto, --19
						vCadastrado, --20
						vCfopEnt, --21
						vCstICMS, --22
						vCstPIS, --23
						vCstCOFINS, --24
						vParametrizado, --25
						NEW.id, --26
						vTipoItem, --27
						vTemCfopParametrizado --28
						
					);
				END LOOP;
			END IF;
		
			------------------------------------------------------------------------------------------------------------------------
			/*
				Configuracao de Itens de Servico de Transporte. Verifica se ja tem CFOP Saida/Entrada parametrizado e Servico cadastrado e parametrizado.
				 Se o mesmo nao existir, nao permitir usar escrituracao.
			
				ALTERNATIVAS				
				
					1 - Caso Servico nao esteja parametrizado, usuario deverar usar interface para parametrizar.
					3 - Caso Servico nao esteja parametrizado, usuario podera escriturar, deixando a rotina de escrituracao 
					criar novo servico e parametrizar usando configuracoes gerais de CFOP.		
						

			*/

			IF vTipoDoc = 2 THEN 
			
				RAISE NOTICE 'Configuracao Servico';
				v_cod_produto_serv =   vCteCompl.cfop || rpad(vIdFornecedor::text,7,'0');
					
				--SELECT id INTo v_id_produto_temp FROM com_produtos_temp WHERE cod_prod_for = vIdFornecedor::text AND xml_nfe_id = NEW.id;

				--CONTINUE WHEN v_id_produto_temp IS NOT NULL;
				

				--Recupera id da unidade
				IF vIdUnidade IS NULL THEN 
					SELECT 	id_unidade
					INTO 	vIdUnidade
					FROM 	efd_unidades_medida 
					WHERE 	UPPER(trim(unidade)) = 'UN';
					vUn = 'UN';
				END IF;						


				--Verifica se Produto esta cadastrado associado com o fornecedor
				SELECT 				
					fk_codigo_produto, 
					fk_id_produto, 
					com_produtos_empresa_fornecedor.id 
				INTO 
					v_fk_codigo_produto,
					v_fk_id_produto,
					vIdProdFor
				FROM 
					com_produtos_empresa_fornecedor 
				WHERE 
					fk_id_fornecedor = vIdFornecedor 
					AND 
					codigo_produto_fornecedor = v_cod_produto_serv;
				
				--Se o produto nao esta cadastrado, verifica se associa ao Servico de Transporte e  marca pendencias.
				IF v_fk_id_produto IS NULL THEN

					--v_fk_codigo_produto = trim(to_char(proximo_numero_sequencia('com_produtos_codigo_produto_seq')::integer,'00000000'));	

					--vIdServico existindo (servico de transporte), associa o mesmo ao fornecedor
					IF vIdServico IS NOT NULL THEN 
						
						OPEN cTemp FOR
						INSERT INTO com_produtos_empresa_fornecedor (							
							fk_id_fornecedor,
							codigo_produto_fornecedor,
							fk_codigo_produto,
							fk_id_produto
						) 
						SELECT
							vIdFornecedor,							
							vIdFornecedor::text,
							v_fk_codigo_produto,
							vIdServico					
						WHERE NOT EXISTS (SELECT 1
								 FROM com_produtos_empresa_fornecedor
								 WHERE fk_id_fornecedor = vIdFornecedor
									AND fk_id_produto = vIdServico
						) RETURNING id, fk_codigo_produto, fk_id_produto ;

						FETCH cTemp INTO vIdProdFor, v_fk_codigo_produto, v_fk_id_produto;

						CLOSE cTemp;						
						

						vCadastrado = 1;
						vParametrizado = 0;						
						
					ELSE 							
						
						vCadastrado = 0;
						vParametrizado = 0;								
						
					END IF;
				ELSE
					vCadastrado = 1;					
				END IF;

				IF vCadastrado = 1 THEN 
						
					--Se estiver cadastrado, verifica se esta parametrizado, marcando pendencia caso negativo.
					SELECT 	cfop_entrada, cst_icms, cst_pis, cst_cofins
					INTO	vCfopEnt, vCstICMS, vCstPIS, vCstCOFINS 
					FROM    com_produtos_sugestao_cfop_cst 									 
					WHERE 	fk_com_produtos_empresa_fornecedor_id = vIdProdFor;
					
					SELECT tipo_item INTO vTipoItem FROM com_produtos WHERE id_produto = v_fk_id_produto;
										
					IF vCfopEnt IS NULL THEN
						vParametrizado = 0;
					ELSE 
						vParametrizado = 1;
					END IF;
										
				END IF;
				
				--Se nao tiver parametrizado, verifica se tem configuracao de CFOP Entrada Generico			
				IF vParametrizado = 0 THEN 
				
					RAISE NOTICE 'CFOP SAIDA %', vCteCompl.cfop;
					
					SELECT 	fk_codigo_cfop_entrada
					INTO 	vCfopEnt
					FROM 	com_compras_cfop_saida_entrada
					WHERE	
						CASE 
							WHEN fk_codigo_cfop_saida IS NOT NULL AND id_fornecedor IS NOT NULL THEN fk_codigo_cfop_saida = vCteCompl.cfop AND id_fornecedor = vIdFornecedor 
							WHEN fk_codigo_cfop_saida IS NULL AND id_fornecedor IS NOT NULL THEN id_fornecedor = vIdFornecedor 				
							WHEN fk_codigo_cfop_saida IS NOT NULL AND id_fornecedor IS NULL THEN fk_codigo_cfop_saida =  vCteCompl.cfop
							ELSE false
						END;

					
					IF vCfopEnt IS NOT NULL THEN	
	
						SELECT 	tipo_item, cst_icms, cst_pis, cst_cofins
						INTO	vTipoItem, vCstICMS, vCstPIS, vCstCOFINS
						FROM 	com_compras_sugestao_cfop_cst 			
						WHERE 	fk_codigo_cfop = vCfopEnt;										
				
					
						IF vCstICMS IS NULL THEN								
							vTemCfopParametrizado = 0;								
							vCfopEnt = NULL;
						ELSE 
							vTemCfopParametrizado = 1;
						END IF;
					ELSE
						vTemCfopParametrizado = 0;
					END IF;
				ELSE
					vTemCfopParametrizado = 1;
				END IF;			
				

				--SELECT * FROM com_produtos_temp LIMIT 1				
				--Insere o Produto na tabela Temporaria para escrituracao	
				
				INSERT INTO public.com_produtos_temp(
					cod_prod_for, --2
					ncm, --3
					descricao, --4
					cfop_for, --5
					unidade, --6
					quantidade, --7
					vl_item, --8
					vl_total, --9
					aliquota_ipi,--10 
					vl_ipi, --11
					valor_base_icms_st, --12
					valor_icms_st, --13
					vl_frete, --14
					empresa,--15
					id_fornecedor,--16
					id_unidade,--17
					codigo_produto,--18 
					id_produto,--19
					cadastrado,--20
					cfop,--21
					cst_icms,--22
					cst_pis,--23
					cst_cofins,--24
					parametrizado, --25
					xml_nfe_id, --26
					tipo_item, --27
					parametro_cfop --28
				) VALUES (
					v_cod_produto_serv, --2
					'0000000', --3
					'SERVICO DE TRANSPORTE', --4
					vCteCompl.cfop, --5				
					vUn, --6
					1, --7
					vNFe.vlr_nf, --8
					vNFe.vlr_nf, --9
					0.00, --10
					0.00, --11
					0.00, --12
					0.00, --13
					0.00, --14
					NEW.codigo_empresa, --15
					vIdFornecedor, --16				
					vIdUnidade, --17
					v_fk_codigo_produto, --18
					v_fk_id_produto, --19
					vCadastrado, --20
					vCfopEnt, --21
					vCstICMS, --22
					vCstPIS, --23
					vCstCOFINS, --24
					vParametrizado, --25
					NEW.id, --26
					vTipoItem, --27					
					vTemCfopParametrizado --28
				);
				
			END IF;

			--Altera status de 0 para 1, interrompe execucao da rotina de escrituracao, para uma nova etapa.
			NEW.status = 1;			
			RETURN NEW;
		END IF;

		--Notas Fiscais
		--Procede com escrituracao do Documento
		IF NEW.escriturar = 1 AND NEW.status = 1 THEN 
			RAISE NOTICE 'Escriturando Documento %', NEW.chave_nfe;
			-- UPDATE xml_nfe SET escriturar = 1, status =1  WHERE id = 338
			vParametroAutomatico = 0;
			--SELECT * FROM xml_nfe LIMIT 1
			--SELECT * FROM com_compras LIMIT 1
			
			--2.2 INSERIR Nota Fiscal			
			-- Definir numero da compra
			vNumeroCompra =    NEW.codigo_empresa 			
					|| NEW.codigo_filial
					|| lpad(proximo_numero_sequencia('com_compras_' || NEW.codigo_empresa || '_' || NEW.codigo_filial)::text, 7, '0');
		
			
			
			OPEN cTemp FOR
			INSERT INTO com_compras (
				numero_compra, --1
				codigo_empresa, --2
				codigo_filial, --3
				cnpj_fornecedor, --4
				modelo_doc_fiscal, --5
				status, --6
				data_emissao, --7
				data_entrada, --8
				vl_base_calculo, --9
				vl_icms, --10
				vl_base_calculo_st, --11
				vl_icms_st, --12
				vl_frete, --13
				vl_desconto, --14
				vl_seguro, --15
				vl_outras_despesas, --16
				vl_ipi, --17
				vl_pis, --18
				vl_confins, --19
				vl_mercadoria, --20
				vl_total, --21
				tipo_pagamento, --22
				tipo_frete, --23
				chave_nfe, --24
				serie_doc, --25
				numero_documento, --26
				placa_veiculo--27
				
				
			) VALUES (				
				vNumeroCompra, --1
				NEW.codigo_empresa, --2
				NEW.codigo_filial, --3
				vFornecedor.cnpjcpf, --4
				vModFiscal, --5
				1, --6
				vNFe.data_emissao, --7
				now(), --8
				vNFe.vlr_bc, --9
				vNFe.vlr_icms, --10
				vNFe.vlr_bcst, --11
				vNFe.vlr_st, --12
				vNFe.vlr_frete, --13
				vNFe.vlr_desc, --14
				vNFe.vlr_seg, --15
				vNFe.vlr_outro, --16
				vNFe.vlr_ipi, --17
				vNFe.vlr_pis, --18
				vNFe.vlr_cofins, --19
				vNFe.vlr_prod, --20
				vNFe.vlr_nf, --21
				COALESCE(vNFe.indpag,'2'), --22
				COALESCE(ind_frete,vNFe.modfrete), --23
				NEW.chave_nfe, --24
				vNFe.serie, --25
				vNFe.numeronf, --26
				NULL --27
			)
			RETURNING id_compra;
			
			
			FETCH cTemp INTO vIdNf;

			CLOSE cTemp;


			INSERT INTO com_compras_log_atividades (
				id_compra, 
				data_hora, 
				atividade_executada, 
				usuario
			) 
			SELECT
				vIdNf,
				now(),
				'INCLUIDO VIA IMPORTACAO LOTE',
				COALESCE(fp_get_session('pst_login'),'suporte')
			;
			

			RAISE NOTICE 'Nota Fiscal Escriturada %', vIdNf;
			--2.3 -- Gravacao dos Itens da Nota

			-- Fazer loop no cursor de itens "crsitens"
			-- Semelhante ao SCAN do VFP
			--NFe
			OPEN v_prod_temp FOR
			SELECT * FROM com_produtos_temp WHERE xml_nfe_id = NEW.id;
			
			LOOP
				
				FETCH IN v_prod_temp INTO vProdutosTemp;

				--Sai do loop se chegou ao fim do cursor
				EXIT WHEN NOT FOUND;
				

				/*
					Buscar na tabela "com_produtos_empresa_fornecedor" se existe registro 
				para o fornecedor. Com esse fornecedor com esse item 
				(código_produto_for) do fornecedor e com o cfop_fornecedor (cfop_fornecedor), 
				retornando os campos cfop_entrada, cst_icms, código_cli e id
				*/
				
				RAISE NOTICE 'Lancando Item %', vProdutosTemp.cod_prod_for;			

				/*
					Se produto nao tiver nesta tabela, fazer inclusao do mesmo 
					na tabela com_produtos e depois cadastrar na tabela 
					com_produtos_empresa_fornecedor
				*/	

				--Parametriza de forma automatica o produto, criando um novo e usando parametros gerais do cfop de entrada. 
				--So e possivel, pq CFOP de Entrada esta parametrizado de modo Geral.
				IF vProdutosTemp.id_produto IS NULL THEN 
					vParametroAutomatico = 1;
					RAISE NOTICE 'Produto Inexistente'; 
					--Busca configuracoes do CFOP ENTRADA					
					
					--SELECT * FROM com_produtos LIMIT 1
					OPEN cTemp FOR
					INSERT INTO com_produtos 
						(
							codigo_produto, --1
							descr_item, --2
							id_unidade, --3
							tipo_item, --4
							codigo_mercosul, --5
							cst_icms, --6
							aliquota_icms, --7
							cfop, --8
							cst_ipi, --9
							aliquota_ipi, --10
							cst_pis, --11
							aliquota_pis, --12
							cst_confins, --13
							aliquota_confins, --14
							data_cadastro, --15
							usuario_cadastro, --16
							valor_custo, --17
							valor_venda --18
						) VALUES (
							NULL, --1
							vProdutosTemp.descricao, --2
							vProdutosTemp.id_unidade, --3
							COALESCE(vProdutosTemp.tipo_item,'07'), --4
							LEFT(vProdutosTemp.ncm,8), --5
							vProdutosTemp.cst_icms, --6
							CASE WHEN vProdutosTemp.tipo_item = '07' THEN 0.00 ELSE vProdutosTemp.aliquota_icms END, --7
							vProdutosTemp.cfop, --8
							NULL, --9 Depois ver valor Padrao
							0.00, --10
							vProdutosTemp.cst_pis, --11
							vProdutosTemp.aliquota_pis, --12 Depois ver como funciona no Lucro Real
							vProdutosTemp.cst_cofins, --13
							vProdutosTemp.aliquota_cofins,
							current_timestamp,
							COALESCE(fp_get_session('pst_login'),'suporte'),
							0.00,
							0.00
						)
					RETURNING id_produto;

					FETCH cTemp INTO v_fk_id_produto;

					CLOSE cTemp;
					--SELECT * FROM fd_dados_tabela('com_produtos') ORDER BY 4
					OPEN vCursor FOR
					INSERT INTO com_produtos_empresa_fornecedor (							
						fk_id_fornecedor,
						codigo_produto_fornecedor,
						fk_codigo_produto,
						fk_id_produto
					) VALUES (
						vIdFornecedor,							
						vProdutosTemp.cod_prod_for,
						vProdutosTemp.codigo_produto,
						v_fk_id_produto
					) RETURNING id;
					
					FETCH vCursor INTO v_com_produtos_empresa_fornecedor_id;
					CLOSE vCursor;						

												
					INSERT INTO com_produtos_sugestao_cfop_cst (
						fk_com_produtos_empresa_fornecedor_id,
						cfop_fornecedor, 
						cfop_entrada,
						cst_icms,
						cst_pis,
						cst_cofins
					) VALUES (
						v_com_produtos_empresa_fornecedor_id,
						vProdutosTemp.cfop_for,
						vProdutosTemp.cfop,
						vProdutosTemp.cst_icms,
						vProdutosTemp.cst_pis,
						vProdutosTemp.cst_cofins
					);

					UPDATE com_produtos_temp SET id_produto = v_fk_id_produto WHERE id_produto = vProdutosTemp.id;					
					RAISE NOTICE 'Produto Cadastrado %', v_fk_id_produto;
					
				ELSE
					v_fk_id_produto = vProdutosTemp.id_produto;
				END IF;

				


			
				--Insere os itens
				INSERT INTO public.com_compras_itens(
					id_compra, --1				
					descricao_complementar, --3
					quantidade, --4
					unidade, --5
					vl_item, --6
					vl_desconto, --7 
					movimentacao_fisica, --8
					cst_icms, --9
					cfop, --10
					vl_base_icms, --12
					aliquota_icms, --13
					valor_icms, --14
					valor_base_icms_st, --15
					aliquota_icms_st, --16
					valor_icms_st, --17
					cst_ipi, --18				
					vl_base_ipi, --20
					aliquota_ipi, --21
					vl_ipi, --22
					cst_pis, --23
					vl_base_pis, --24
					aliquota_pis_perc, --25
					quantidade_base_pis, --26
					vl_aliquota_pis, --27
					valor_pis, --28
					cst_cofins, --29
					valor_base_cofins, --30
					aliquota_cofins_perc, --31
					quantidade_base_cofins, --32
					vl_aliquota_cofins, --33
					vl_cofins, --34
					vl_total, --35				
					id_produto, --37
					vl_frete, --38
					id_almoxarifado --39
					
				) VALUES (
					vIdNf, --1				
					left(trim(vProdutosTemp.descricao),50),--3
					vProdutosTemp.quantidade, --4
					vProdutosTemp.unidade, --5
					vProdutosTemp.vl_item, --6
					vProdutosTemp.vl_desconto, --7
					0, --8
					vProdutosTemp.cst_icms,--9
					vProdutosTemp.cfop, --10						
					CASE WHEN vProdutosTemp.cst_icms = '000' THEN 
						vProdutosTemp.vl_base_icms
					ELSE 
						0.00
					END, --12
					CASE WHEN vProdutosTemp.cst_icms = '000' THEN 
						vProdutosTemp.aliquota_icms
					ELSE
						0.00
					END, --13
					CASE WHEN vProdutosTemp.cst_icms = '000' THEN 
						vProdutosTemp.valor_icms
					ELSE
						0.00
					END, --14
					0.00, --15
					0.00, --16
					0.00, --17
					'02', --18
					0.00, --20
					0.00, --21
					0.00, --22
					vProdutosTemp.cst_pis, --23
					0.00, --24
					0.00, --25
					0.00, --26
					0.00, --27
					0.00, --28
					vProdutosTemp.cst_cofins, --29
					0.00, --30
					0.00, --31
					0.00, --32
					0.00, --33
					0.00, --34
					vProdutosTemp.vl_total, --35
					v_fk_id_produto, --37
					vProdutosTemp.vl_frete, --38
					v_id_almoxarifado --39
				);	
				
			END LOOP;	
			
			CLOSE v_prod_temp;
			
			IF vTipoDoc = 1 THEN 
				RAISE NOTICE 'Cadastrando Faturas ';
				LOOP
					
					FETCH IN crsfat INTO vFaturas;
					--Sai do loop se chegou ao fim do cursor
					EXIT WHEN NOT FOUND;

					
					INSERT INTO public.com_compras_faturas(
						id_compra, --1
						numero, --2
						data_vencimento, --3
						valor, --4				
						flg_lancamento_contas_pagar --5
					) VALUES (
						vIdNf,
						vFaturas.fk_notas_fiscais_numeronf,
						vFaturas.data_vencimento,
						vFaturas.valor_fatura,
						0
					);	

				END LOOP;
				
				CLOSE crsfat;
			END IF;

			

			NEW.id_compra = vIdNf;
			
			NEW.status = 2;
			NEW.data_escrituracao = now();			


			/*
				Caso Produto Tenha sido criado automaticamente, 
				reprocessa documentos nao escriturados deste fornecedor, para poder receber configuracoes.
			*/
			WITH t AS (
			SELECT 
				id_produto, 
				ncm, 
				id_unidade, 
				cst_icms, 
				cfop, 
				cfop_for, 
				cst_ipi, 
				cst_pis,
				cst_cofins, 
				cod_prod_for, 
				id_fornecedor,
				tipo_item
			FROM 
				com_produtos_temp 
			WHERE 
				xml_nfe_id = NEW.id
			)	
			UPDATE com_produtos_temp SET 
				id_produto = t.id_produto,
				ncm = t.ncm,
				id_unidade = t.id_unidade,
				cst_icms = t.cst_icms,
				cfop = t.cfop,
				cfop_for = t.cfop_for,
				cst_ipi = t.cst_ipi,
				cst_pis = t.cst_pis,
				cst_cofins = t.cst_cofins,		
				tipo_item = t.tipo_item,
				parametrizado = 1,
				cadastrado = 1,
				parametro_cfop = 1
			FROM
				t, xml_nfe
			WHERE 
				t.id_fornecedor = com_produtos_temp.id_fornecedor
				AND t.cod_prod_for = com_produtos_temp.cod_prod_for
				AND xml_nfe.id = com_produtos_temp.xml_nfe_id		
				AND xml_nfe.status = 1 AND com_produtos_temp.id_produto IS NULL
				AND xml_nfe.id <> NEW.id;

		END IF;
		
        EXCEPTION WHEN OTHERS THEN 
		RAISE NOTICE 'REGISTO % ERRO  %', NEW.id, SQLERRM;       
        END;
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
