# Análise de dados de filmes e séries da Netflix usando SQL

![Netflix](https://img.shields.io/badge/Netflix-E50914?style=flat&logo=netflix&logoColor=white)
![NMicrosoft SQL Server](https://img.shields.io/badge/Microsoft_SQL_Server-CC2927)

Análise exploratória de dados da **Netflix** desenvolvida como resolução do desafio do canal [Zero Analyst](https://www.youtube.com/@zero_analyst) ([Advanced SQL Project - Series #4/10](https://youtu.be/-7cT0651_lw?si=eGjm6gYbbbuFHGYe)). Utilizando a base de dados [Netflix Movies and TV Shows](https://www.kaggle.com/datasets/shivamb/netflix-shows) do **Kaggle**, o projeto responde a diversas perguntas de negócio. O grande diferencial desta entrega é a migração de tecnologia: todo o escopo, originalmente feito em PostgreSQL, foi traduzido e adaptado para as particularidades e funções do **Microsoft SQL Server**.

---

### 1. Conte o número de filmes e séries de TV.

```sql
SELECT
	[type],
	COUNT(show_id) AS contagem_total
FROM
	netflix
GROUP BY
	[type];
```

### 2. Encontre a classificação indicativa mais comum para filmes e séries de TV.

```sql
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
```

### 3. Liste todos os filmes lançados em um ano específico (Exemplo: 2020).

```sql
SELECT
	*
FROM
	netflix
WHERE
	[type] = 'Movie'
	AND
	release_year = 2020;
```

### 4. Encontre os 5 principais países com mais conteúdos na Netflix.

```sql
SELECT TOP 5
    TRIM(value) AS país,
    COUNT(*) as contagem_total
FROM
	netflix
CROSS APPLY STRING_SPLIT(country, ',')
WHERE
	value IS NOT NULL
GROUP BY
	TRIM(value)
ORDER BY
	contagem_total DESC;
```

### 5. Identifique o filme de maior duração (mais longo).

```sql
SELECT
	[type],
	title,
	CONVERT(INT, REPLACE(duration, ' min', '')) AS duration_minutes
FROM
	netflix
WHERE
	[type] = 'Movie'
	AND
	duration IS NOT NULL
ORDER BY
	duration_minutes DESC;
```

### 6. Encontre os conteúdos adicionados nos últimos 5 anos.

```sql
SELECT
	*
FROM
	netflix
WHERE
	date_added >= DATEADD(YEAR, -5, CAST(GETDATE() AS DATE))
```

### 7. Encontre todos os filmes/séries de TV do diretor 'Rajiv Chilaka'!


```sql
SELECT
	*
FROM
	netflix
WHERE
	director LIKE '%Rajiv Chilaka%'
```

### 8. Liste todas as séries de TV com mais de 5 temporadas.

```sql
SELECT
	*
FROM
	netflix
WHERE
	[type] = 'TV Show' AND
	CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5
```

### 9. Conte o número de itens de conteúdo em cada gênero.

```sql
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
```

### 10. Encontrar em cada ano, o número de lançamentos de conteúdo na Índia na Netflix. Retornar os 5 anos com o maior percentual de lançamentos de conteúdo!

```sql
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
```

> 💡 **Observação sobre o Exercício 10:**
> o enunciado original disponibilizado pelo [Zero Analyst](https://www.youtube.com/@zero_analyst) pede a "média" de lançamentos por ano. No entanto, optei por adaptar a resolução para calcular o **percentual de lançamentos** em relação ao total histórico, pois essa métrica se enquadra melhor para responder à pergunta de negócio proposta do que uma média aritmética isolada.

### 11. Liste todos os filmes que são documentários.

```sql
SELECT
	*
FROM
	netflix
WHERE
	[type] = 'Movie'
	AND
	listed_in LIKE '%Documentaries%'
```

### 12. Encontre todos os conteúdos sem diretor.

```sql
SELECT
	*
FROM
	netflix
WHERE
	director IS NULL OR director = ''
```

### 13. Descubra em quantos filmes o ator 'Salman Khan' apareceu nos últimos 10 anos!

```sql
SELECT
	COUNT(*) AS total_filmes
FROM
	netflix
WHERE
	[type] = 'Movie'
	AND release_year >= YEAR(DATEADD(YEAR, -10, CAST(GETDATE() AS DATE)))
	AND [cast] LIKE '%Salman Khan%'
```

### 14. Encontre os 10 atores que apareceram no maior número de filmes produzidos na Índia.

```sql
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
```

### 15. Categorizar o conteúdo com base na presença das palavras-chave 'kill' (matar) e 'violence' (violência) no campo de descrição. Rotular o conteúdo que contém essas palavras-chave como 'Bad' (Ruim) e todo o restante do conteúdo como 'Good' (Bom). Contar quantos itens se enquadram em cada categoria.

```sql
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
```

---

## 👤 Autor - Willian Mateus Batista Oliveira

* > **Linkedin:** [clique aqui para acessar](https://www.linkedin.com/in/willianmateus/)
* > **Portfólio:** [clique aqui para acessar](https://willianmateus.lovable.app/)