USE netflix_db;

SELECT * FROM netflix;

----------------------------------------------------------------------------------------------------------------
-- 1. Conte o número de filmes e séries de TV.
----------------------------------------------------------------------------------------------------------------

SELECT
	[type],
	COUNT(show_id) AS contagem_total
FROM
	netflix
GROUP BY
	[type];


----------------------------------------------------------------------------------------------------------------
-- 2. Encontre a classificação indicativa mais comum para filmes e séries de TV.
----------------------------------------------------------------------------------------------------------------

SELECT
	[type],
	rating,
	contagem
FROM
	(SELECT
		[type],
		rating,
		COUNT(*) AS contagem,
		RANK() OVER(PARTITION BY [type] ORDER BY COUNT(*) DESC) AS ranking
	FROM
		netflix
	GROUP BY
		[type], rating
	) AS tabela
WHERE
	ranking = 1;


----------------------------------------------------------------------------------------------------------------
-- 3. Liste todos os filmes lançados em um ano específico (Exemplo: 2020).
----------------------------------------------------------------------------------------------------------------

SELECT
	*
FROM
	netflix
WHERE
	[type] = 'Movie'
	AND
	release_year = 2020;


----------------------------------------------------------------------------------------------------------------
-- 4. Encontre os 5 principais países com mais conteúdos na Netflix.
----------------------------------------------------------------------------------------------------------------

SELECT TOP 5 -- exibe apenas as 5 primeiras linhas
    TRIM(value) AS país, -- remove os espaços em branco da coluna value, que é retornada pela função STRING_SPLIT()
    COUNT(*) as contagem_total -- contagem de registros por país
FROM
	netflix
CROSS APPLY STRING_SPLIT(country, ',') -- divide o texto onde tem vírgula e expande uma linha em várias linhas
WHERE
	value IS NOT NULL -- remove linhas nulas
GROUP BY
	TRIM(value) -- agrupa por país (country)
ORDER BY
	contagem_total DESC; -- ordena em ordem decrescente


----------------------------------------------------------------------------------------------------------------
-- 5. Identifique o filme de maior duração (mais longo).
----------------------------------------------------------------------------------------------------------------

SELECT
	[type],
	title,
	CONVERT(INT, REPLACE(duration, ' min', '')) AS duration_minutes -- substitui ' min' por '' para ficar apenas os números e depois converte em INT para classificar
FROM
	netflix
WHERE
	[type] = 'Movie'
	AND
	duration IS NOT NULL
ORDER BY
	duration_minutes DESC;


----------------------------------------------------------------------------------------------------------------
-- 6. Encontre os conteúdos adicionados nos últimos 5 anos.
----------------------------------------------------------------------------------------------------------------

SELECT
	*
FROM
	netflix
WHERE
	date_added >= DATEADD(YEAR, -5, CAST(GETDATE() AS DATE))
	-- GETDATE() obtém a data e hora atual do sistema
	-- CAST(GETDATE() AS DATE) converte em data sem hora
	-- DATEADD(YEAR, -5, ...) subtrai 5 anos da data de hoje


----------------------------------------------------------------------------------------------------------------
-- 7. Encontre todos os filmes/séries de TV do diretor 'Rajiv Chilaka'!
----------------------------------------------------------------------------------------------------------------

SELECT
	*
FROM
	netflix
WHERE
	director LIKE '%Rajiv Chilaka%'


----------------------------------------------------------------------------------------------------------------
-- 8. Liste todas as séries de TV com mais de 5 temporadas.
----------------------------------------------------------------------------------------------------------------

SELECT
	*
FROM
	netflix
WHERE
	[type] = 'TV Show' AND
	CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5

	
----------------------------------------------------------------------------------------------------------------
-- 9. Conte o número de itens de conteúdo em cada gênero.
----------------------------------------------------------------------------------------------------------------

SELECT
	TRIM(value) AS genero,
	COUNT(show_id) AS contagem
FROM
	netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY
	TRIM(value)
ORDER BY
	contagem DESC;


----------------------------------------------------------------------------------------------------------------
/*
   10. ncontrar em cada ano, o número de lançamentos de conteúdo na Índia na Netflix. Retornar os 5 anos com o
   maior percentual de lançamentos de conteúdo!
*/
----------------------------------------------------------------------------------------------------------------

SELECT TOP 5
    YEAR(CAST(date_added AS DATE)) AS ano,
	COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%') AS porcentagem_do_total
FROM
    netflix
WHERE
    country LIKE '%India%'
    AND date_added IS NOT NULL
GROUP BY
    YEAR(CAST(date_added AS DATE))
ORDER BY
    porcentagem_do_total DESC;
	

----------------------------------------------------------------------------------------------------------------
-- 11. Liste todos os filmes que são documentários.
----------------------------------------------------------------------------------------------------------------

SELECT
	*
FROM
	netflix
WHERE
	[type] = 'Movie'
	AND
	listed_in LIKE '%Documentaries%'


----------------------------------------------------------------------------------------------------------------
-- 12. Encontre todos os conteúdos sem diretor.
----------------------------------------------------------------------------------------------------------------

SELECT
	*
FROM
	netflix
WHERE
	director IS NULL OR director = ''


----------------------------------------------------------------------------------------------------------------
-- 13. Descubra em quantos filmes o ator 'Salman Khan' apareceu nos últimos 10 anos!
----------------------------------------------------------------------------------------------------------------

SELECT
	COUNT(*) AS total_filmes
FROM
	netflix
WHERE
	[type] = 'Movie'
	AND release_year >= YEAR(DATEADD(YEAR, -10, CAST(GETDATE() AS DATE)))
	AND [cast] LIKE '%Salman Khan%'


----------------------------------------------------------------------------------------------------------------
-- 14. Encontre os 10 atores que apareceram no maior número de filmes produzidos na Índia.
----------------------------------------------------------------------------------------------------------------

SELECT TOP 10
	TRIM(value) AS atores,
	COUNT(*) AS filmes
FROM
	netflix
CROSS APPLY STRING_SPLIT([cast], ',')
WHERE
	[type] = 'Movie'
	AND
	country LIKE '%India%'
GROUP BY
	TRIM(value)
ORDER BY
	filmes DESC


----------------------------------------------------------------------------------------------------------------
/*
   15. Categorizar o conteúdo com base na presença das palavras-chave 'kill' (matar) e 'violence' (violência) no
   campo de descrição. Rotular o conteúdo que contém essas palavras-chave como 'Bad' (Ruim) e todo o restante do
   conteúdo como 'Good' (Bom). Contar quantos itens se enquadram em cada categoria.
*/
----------------------------------------------------------------------------------------------------------------

SELECT
	categoria,
	COUNT(*) AS quantidade
FROM
    (
        SELECT
            CASE
                WHEN description LIKE '% kill %' OR description LIKE '% violence %' THEN 'Bad'
                ELSE 'Good'
            END AS categoria
        FROM
            netflix
    ) AS tabela
GROUP BY
	categoria;