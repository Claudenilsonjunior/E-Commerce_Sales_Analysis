

/*
1. Desempenho de Vendas e Produtos 

Quais são as categorias de produtos eletrônicos com maior volume de vendas (purchased_last_month)? */

SELECT product_category,
SUM(purchased_last_month) AS total_sales
FROM products_sales_cleaned
GROUP BY product_category
ORDER BY total_sales DESC;

/* 

Análise executiva dos resultados
1. Domínio absoluto de “Power & Batteries”

Total: 26.151.450 unidades vendidas — quase 7x mais que o segundo lugar.

Isso sugere que produtos dessa categoria (baterias, powerbanks, carregadores universais, etc.) são itens de reposição e compra recorrente, com alta frequência e baixo ticket médio.

Indica elasticidade de demanda alta (clientes compram mais quando há preço competitivo) e dependência operacional de volume.

2. “Phones”, “Other Electronics” e “Laptops” — o núcleo premium

“Phones” (3.729.550) e “Laptops” (3.416.450) ocupam o núcleo de receita por ticket alto, embora com volume menor.

São produtos de decisão mais longa, impactados por promoções sazonais (Black Friday, lançamentos).

Estratégias de marketing aqui devem focar em diferenciação de valor, não apenas desconto.

3. “Cameras”, “Chargers & Cables”, “Wearables” e “TV & Display”

Faixa intermediária: 700k a 800k unidades.

Mostram um equilíbrio entre volume e valor agregado, geralmente com bom potencial de upsell (ex: acessórios de câmera, upgrades de smartwatch).

4. Cauda longa: “Storage”, “Printers”, “Networking”, “Headphones”, “Speakers”, “Gaming”, “Smart Home”

Menor volume de vendas, mas alto potencial de margem, especialmente em “Gaming” e “Smart Home”, que são categorias aspiracionais.

Produtos de nicho, com público segmentado, muitas vezes com alta fidelidade à marca e disposição a pagar mais.

Conclusão Estratégica
Categoria	Interpretação Estratégica
Power & Batteries	Categoria de alto giro e grande dependência de volume. Otimizar logística e estoques é essencial.
Phones & Laptops	Segmentos de alto valor. Estratégias de marketing e bundling (ex: acessórios, garantias) aumentam margens.
Wearables & Displays	Segmentos de crescimento emergente — ótimo foco para promoções cruzadas.
Smart Home & Gaming	Nichos com margem alta e potencial de marketing. Focar em awareness e reviews de qualidade.

Nosso crescimento é sustentado por produtos de alto giro como baterias, mas o verdadeiro ganho de margem virá de categorias de ticket alto e alta diferenciação — especialmente em Laptops, Phones e Smart Devices. Precisamos equilibrar volume operacional e valor agregado.
*/

-- Qual é a relação entre vendas e classificação média (product_rating) — produtos mais bem avaliados vendem mais? 

SELECT 
	product_rating,
	AVG(purchased_last_month) as total_sales
FROM products_sales_cleaned
WHERE product_rating IS NOT NULL
GROUP BY product_rating
ORDER BY total_sales DESC;

/*
Correlação positiva até 4.8:
Produtos bem avaliados vendem significativamente mais. A nota 4.8 domina o ranking, com volume 8x maior que a média das demais faixas.
Isso indica que reputação e confiança são motores de venda — reviews são o novo "boca a boca digital".

Queda abrupta após 4.5:
Mesmo uma pequena queda de rating (ex: 4.8 → 4.6) já impacta fortemente a conversão.
Isso sugere sensibilidade extrema do consumidor a avaliações, especialmente em categorias competitivas.

Produtos 5.0 vendendo pouco:
Nota perfeita não garante volume — pode indicar produtos novos (poucos reviews) ou nicho especializado.
Aqui o foco deve ser aumentar visibilidade e awareness, não desconto.

Ratings baixos (<3.5):
Esses produtos praticamente não vendem — devem ser revistos ou retirados.
Estratégias de melhoria de qualidade ou substituição são mais eficazes que tentar empurrar via preço.*/

-- Quais produtos são Best Sellers e por que (preço, desconto, avaliações, cupons)?


WITH base AS (
    SELECT 
        CASE 
            WHEN LOWER(is_best_seller) LIKE '%best seller%' 
                 OR LOWER(is_best_seller) LIKE '%amazon%' 
            THEN 'Best Seller'
            ELSE 'Others'
        END AS seller_group,
        CAST(product_rating AS FLOAT) / 10 AS product_rating,
        CAST(discount_percentage AS FLOAT) / 100 AS discount_percentage,
        original_price,
        discounted_price,
        has_coupon,
        purchased_last_month
    FROM products_sales_cleaned
)
SELECT 
    seller_group,
    ROUND(AVG(product_rating), 2) AS avg_rating,
    ROUND(AVG(discount_percentage), 2) / 100 AS avg_discount_pct,
    ROUND(AVG(original_price), 2) AS avg_original_price,
    ROUND(AVG(discounted_price), 2) AS avg_discounted_price,
    ROUND(AVG(purchased_last_month), 0) AS avg_sales_last_month,
    ROUND(
        SUM(CASE 
                WHEN LOWER(has_coupon) NOT LIKE '%no coupon%' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(*),
    2) / 100 AS pct_with_coupon
FROM base
GROUP BY seller_group
ORDER BY seller_group DESC;






/* 1. Qualidade percebida (Rating médio)

Os Best Sellers apresentam rating médio 3% superior (45,32 vs 43,99).
Isso pode parecer modesto, mas em marketplaces com milhares de produtos, diferenças pequenas em avaliação têm impacto enorme na taxa de conversão.
Um produto que ultrapassa 4,5⭐ tende a aparecer mais nos rankings e recomendações automáticas da Amazon, alimentando um efeito de visibilidade exponencial.

➡️ Conclusão: produtos Best Seller não apenas vendem mais — eles são consistentemente mais bem avaliados, indicando excelência de experiência e entrega de valor.

2. Estratégia de preço e desconto

O preço original médio dos Best Sellers (US$ 8.154,82) é menos da metade dos demais (US$ 17.338,18).
Isso revela que os produtos mais vendidos não são os mais caros, e sim os que atingem um ponto de preço competitivo dentro da faixa de eletrônicos.

Apesar disso, o desconto médio é mais alto entre os Best Sellers (1.401 vs 577).
Isso sugere que o gatilho de promoção é fundamental: a percepção de oportunidade (mesmo que o preço final não seja o mais baixo absoluto) impulsiona a conversão.

➡️ Conclusão: o selo “Best Seller” está fortemente relacionado a preço percebido como vantajoso, não necessariamente ao menor preço real.
O consumidor responde mais à estratégia de valor inteligente do que ao desconto bruto.

3. Desempenho de vendas

A diferença aqui é brutal:

Best Sellers vendem, em média, 9.228 unidades,

enquanto “Others” vendem apenas 1.226 unidades.

Isso significa que os Best Sellers vendem cerca de 7,5x mais — um resultado que reforça a importância do ciclo rating → visibilidade → vendas → mais rating.

➡️ Conclusão: o selo de destaque amplifica a visibilidade e solidifica um efeito de dominância de mercado, criando um círculo virtuoso entre qualidade e volume.

💼 Síntese Executiva
Ponto-Chave	Insight Estratégico
Qualidade	Best Sellers têm notas ligeiramente mais altas — foco em excelência gera confiança e conversão.
Preço	Preço original mais acessível e descontos inteligentes impulsionam o volume.
Vendas	Volume de vendas 7x maior cria efeito de dominância e reforça o ciclo de visibilidade.

🚀 Recomendações para o Diretor

Replicar o modelo de preço e desconto dos Best Sellers em produtos de bom rating, mas baixo volume.

Incentivar reviews e fidelização em categorias com rating bom e vendas médias — o crescimento em avaliações pode desencadear o ciclo de crescimento.

Auditar cupons ativos e priorizar os que geram real percepção de economia (em vez de pequenas porcentagens sem apelo).

Criar um cluster “Emerging Best Sellers”: produtos com alto rating, desconto estratégico e boa conversão inicial — e dar destaque a eles no front da loja.
*/

-- 2. Estratégia de Preços e Descontos 

-- Existe uma correlação entre desconto (%) e aumento de vendas? 

SELECT
	discount_percentage,
	AVG (purchased_last_month) AS avg_sales
FROM products_sales_cleaned
WHERE discounted_price > 0 AND original_price > discounted_price
GROUP BY discount_percentage
ORDER BY discount_percentage;

/* Descontos moderados impulsionam vendas com maior eficiência.
Faixas em torno de 40–45% parecem o ponto de maior elasticidade de demanda.

Descontos muito altos perdem eficiência marginal.
A partir de 50%, o retorno em volume de vendas não cresce proporcionalmente.

Preço não é o único fator de conversão.
Produtos com alto desconto mas baixa venda podem carecer de confiança (nota baixa, poucos reviews) ou relevância de marca.

Sugestão de política de desconto inteligente:
Priorizar descontos médios em produtos bem avaliados para maximizar ROI de promoções.*/


-- Qual é o impacto de cupons e descontos na conversão? 

SELECT 
	has_coupon,
	AVG(purchased_last_month) AS avg_sales,
	AVG(product_rating) AS avg_rating,
	COUNT(*) AS num_products
FROM products_sales_cleaned
GROUP BY has_coupon;

/*Interpretação executiva

Os resultados mostram que a simples presença de cupons não garante maior volume de vendas.
Apesar de existir uma variedade enorme de tipos de cupons (“Save $...”, “Save %...”), o desempenho médio em vendas varia muito — e a maioria apresenta médias abaixo ou próximas do grupo “No Coupon” (sem cupom), que registrou cerca de 1.313 vendas médias com nota média 44 e mais de 40 mil produtos (base dominante).

Isso indica que:

Produtos sem cupom continuam dominando o volume total de vendas — sugerindo que o desconto isolado não é o principal gatilho de compra.

Cupons específicos em valor fixo baixo (ex: “Save $0.33”, “Save $2.00”, “Save $6.00”) às vezes apresentam picos localizados de vendas muito maiores (ex: até 20.000 em um caso), mas isso se deve mais a produtos pontuais de alto giro do que à política de cupom em si.

Cupons percentuais (“Save 10%”, “Save 20%”, “Save 50%”) mostram desempenho mediano ou baixo, sem padrão claro de aumento de vendas proporcional ao desconto.

A avaliação média dos produtos com cupom tende a permanecer próxima da média geral (entre 43 e 46), o que indica que o uso de cupom não afeta diretamente a satisfação do cliente.*/

-- Quais categorias têm maior variação de preço médio em relação ao preço original (price elasticity)? 

SELECT
    product_category,
    ROUND(AVG(((original_price - discounted_price) / NULLIF(original_price, 0)) * 100), 2) AS avg_price_variation_pct,
    ROUND(AVG(original_price), 2) AS avg_original_price,
    ROUND(AVG(discounted_price), 2) AS avg_discounted_price,
    COUNT(*) AS product_count
FROM products_sales_cleaned
WHERE original_price > 0
GROUP BY product_category
ORDER BY avg_price_variation_pct DESC;

/*Interpretação executiva

Os resultados revelam um cenário heterogêneo de elasticidade de preços entre categorias, indicando que nem todos os produtos eletrônicos reagem da mesma forma a descontos.

Categorias mais elásticas (variação positiva alta):

Speakers (+11,75%), Storage (+10,62%) e Chargers & Cables (+9,6%) apresentam os maiores níveis de variação média de preço — sinal de ajustes dinâmicos e competitivos.
Isso normalmente indica que essas categorias respondem bem a descontos, possivelmente por serem itens complementares e com alta sensibilidade a preço.
Pequenas reduções de preço tendem a estimular a compra imediata, especialmente em acessórios e produtos de reposição.

Categorias com elasticidade moderada:

Gaming (+5,36%) e Power & Batteries (+4,76%) mostram variação controlada, o que pode indicar equilíbrio entre oferta, demanda e valor percebido.
Nessas categorias, o preço é importante, mas a marca e o desempenho técnico ainda pesam fortemente na decisão de compra.

Categorias inelásticas (variação próxima de zero ou negativa):

Wearables (+2,92%), Smart Home (+1,88%), e especialmente as categorias com valores negativos, como Phones (-8,66%), Laptops (-13,95%), Networking (-31,13%) e TV & Display (-40,75%), revelam baixa elasticidade de preço.
Ou seja: mesmo com descontos, o impacto nas vendas é limitado.
Esses produtos costumam ter alto valor agregado, marcas fortes e ciclos de compra mais longos — fatores que reduzem a sensibilidade ao preço.

Anomalia crítica:

A categoria Printers & Scanners (-74,69%) mostra uma variação negativa extrema — o preço médio com desconto é maior que o preço original, o que indica dados inconsistentes ou erros de cadastro (ex: inversão entre “original_price” e “discounted_price”).
Isso merece auditoria de dados imediata, pois distorce qualquer análise de elasticidade.*/

-- Produtos com grandes descontos mantêm boas avaliações? 

SELECT
	CASE
		WHEN discount_percentage >= 30 THEN 'High Discount (30%+)'
		ELSE 'Low/Medium Discount'
	END AS discount_group,
	AVG(product_rating) AS avg_rating
FROM products_sales_cleaned
WHERE original_price > 0 
GROUP BY 	
	CASE
		WHEN discount_percentage >= 30 THEN 'High Discount (30%+)'
		ELSE 'Low/Medium Discount'
	END
ORDER BY avg_rating DESC;

/*Os resultados mostram uma diferença muito pequena entre as avaliações médias:

Grupo de desconto	Avaliação média
High Discount (30%+)	44,31
Low/Medium Discount	44,01

Essa diferença de apenas 0,3 pontos (numa escala de 0 a 50) é estatisticamente irrelevante — ou seja, os produtos com grandes descontos não têm avaliações significativamente melhores nem piores que os demais.*/

-- 3. Comportamento do Cliente e Engajamento 

-- Quais categorias possuem maior número de reviews por produto — e isso indica engajamento real ou apenas volume de vendas? 

SELECT
	product_category,
	AVG(total_reviews) AS avg_reviews,
	AVG(purchased_last_month) AS avg_sales,
	ROUND(AVG(total_reviews) / NULLIF(AVG(purchased_last_month),0), 2) AS review_to_sales_ratio
FROM products_sales_cleaned
GROUP BY product_category
ORDER BY review_to_sales_ratio DESC;

/*Gaming e Headphones lideram em engajamento desproporcional.
Ambas as categorias têm altíssimo volume de reviews em relação às vendas, com mais de 250 avaliações para cada venda média recente.
Isso indica um nível de engajamento atípico, possivelmente resultado de:

Comunidades muito ativas (gamers e audiófilos tendem a comentar e comparar produtos).

Produtos antigos com longos históricos de vendas, acumulando reviews.

Maior propensão à recomendação boca a boca.

Smart Home e Storage aparecem como intermediárias.
São categorias com engajamento considerável — cada produto recebe dezenas de reviews para cada venda média — sugerindo interesse crescente, mas menor fidelidade emocional do consumidor.

Power & Batteries e Wearables têm o menor engajamento relativo.
Apesar de alto volume de vendas, essas categorias têm baixo número de reviews por unidade vendida (7,7 e 13,5 respectivamente).
Isso indica um padrão de consumo utilitário, em que o cliente compra e esquece, sem grande envolvimento com a marca.

Correlação inversa: alto volume de vendas tende a reduzir o engajamento por unidade.
Produtos mais massificados (como baterias e cabos) geram menos avaliações por compra — o que é natural, pois o consumidor só comenta quando algo surpreende (positiva ou negativamente).*/
	

-- Há uma tendência de melhores avaliações em produtos mais caros? 

WITH price_distribution AS (
    SELECT 
        product_title,
        discounted_price,
        product_rating,
        PERCENTILE_CONT(0.75) 
            WITHIN GROUP (ORDER BY discounted_price) 
            OVER () AS price_75th
    FROM products_sales_cleaned
)
SELECT 
    CASE 
        WHEN discounted_price >= price_75th THEN 'High Price'
        ELSE 'Normal/Low Price'
    END AS price_segment,
    AVG(product_rating) AS avg_rating
FROM price_distribution
GROUP BY 
    CASE 
        WHEN discounted_price >= price_75th THEN 'High Price'
        ELSE 'Normal/Low Price'
    END
ORDER BY avg_rating DESC;


-- O selo de Best Seller influencia a nota média dos produtos? 

SELECT
	is_best_seller,
	AVG(product_rating) AS avg_rating
FROM products_sales_cleaned
GROUP BY is_best_seller;

/*
Produtos com selos de confiança (“Best Seller”, “Amazon’s”) ou promoções exclusivas e limitadas tendem a apresentar avaliações mais altas.
Isso sugere que:

O selo pode aumentar a percepção de qualidade, mesmo que o produto não tenha características intrinsecamente melhores.

Há um efeito psicológico de validação social (“se é Best Seller, deve ser bom”).

Por outro lado, descontos comuns não aumentam a nota — o consumidor pode associá-los à tentativa de escoar estoque.
*/

-- 4. Oportunidades Estratégicas 

-- Quais produtos ou categorias estão com alto rating e baixo volume de vendas (potencial de marketing)? 

WITH avg_sales AS(
SELECT
	AVG(purchased_last_month) AS avg_sales_last_month
FROM products_sales_cleaned
)

SELECT DISTINCT
	p.product_title,
	p.product_category,
	p.product_rating,
	p.purchased_last_month
FROM products_sales_cleaned AS p
CROSS JOIN avg_sales AS s
WHERE p.product_rating >= 4.5
	AND p.purchased_last_month < s.avg_sales_last_month
ORDER BY p.product_rating DESC;

/*
Esses produtos combinam alta qualidade percebida com baixa tração comercial, o que os torna perfeitos para estratégias de alavancagem de marketing direcionado:

Investir em campanhas de awareness para produtos com avaliação máxima e baixa exposição (ex: Zenbook, Bose QuietComfort Ultra).

Explorar storytelling de qualidade — mostrar reviews reais, uso prático e diferenciais técnicos.

Segmentar anúncios para nichos específicos: gamers, criadores de conteúdo, profissionais criativos, etc.

Testar bundling — combinar produtos de baixa venda com best-sellers da mesma categoria.

Verificar o ROI potencial com uma métrica de “Elasticidade de Marketing”: quantas vendas adicionais são necessárias para justificar a promoção de cada produto.
*/

-- Onde há descontos altos mas vendas baixas (possível problema de percepção ou competitividade)? 

WITH avg_sales AS(
SELECT
	AVG(purchased_last_month) AS avg_sales_last_month
FROM products_sales_cleaned
)

SELECT DISTINCT
	p.product_title,
	p.product_category,
	p.discount_percentage,
	p.purchased_last_month
FROM products_sales_cleaned AS p
CROSS JOIN avg_sales AS s
WHERE p.discount_percentage >= 30
	AND p.purchased_last_month < s.avg_sales_last_month
ORDER BY p.discount_percentage DESC;

-- Que produtos poderiam ser indicados para promoção ou destaque na home?

WITH avg_sales AS (
    SELECT AVG(purchased_last_month) AS avg_sales_last_month
    FROM products_sales_cleaned
)
SELECT DISTINCT
    p.product_title, 
    p.product_category, 
    p.product_rating, 
    p.purchased_last_month
FROM products_sales_cleaned AS p
CROSS JOIN avg_sales
WHERE p.product_rating >= 4.2 
  AND p.purchased_last_month BETWEEN 
      (avg_sales.avg_sales_last_month * 0.5) AND avg_sales.avg_sales_last_month
ORDER BY p.product_rating DESC;

