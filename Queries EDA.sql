/*
1. Desempenho de Vendas e Produtos 

Quais são as categorias de produtos eletrônicos com maior volume de vendas (purchased_last_month)? */

SELECT product_category,
SUM(purchased_last_month) AS total_sales
FROM products_sales_cleaned
GROUP BY product_category
ORDER BY total_sales DESC;

-- Qual é a relação entre vendas e classificação média (product_rating) — produtos mais bem avaliados vendem mais? 

SELECT 
	product_rating,
	AVG(purchased_last_month) as total_sales
FROM products_sales_cleaned
WHERE product_rating IS NOT NULL
GROUP BY product_rating
ORDER BY total_sales DESC;

-- Quais produtos são Best Sellers e por que (preço, desconto, avaliações, cupons)?

WITH base AS (
    SELECT 
        CASE 
            WHEN LOWER(is_best_seller) LIKE '%best seller%' THEN 'Best Seller'
            ELSE 'Others'
        END AS seller_group,
        product_rating,
        discount_percentage,
        original_price,
        discounted_price,
        has_coupon,
        purchased_last_month
    FROM products_sales_cleaned
)
SELECT 
    seller_group,
    ROUND(AVG(product_rating), 2) AS avg_rating,
    ROUND(AVG(discount_percentage), 2) AS avg_discount_pct,
    ROUND(AVG(original_price), 2) AS avg_original_price,
    ROUND(AVG(discounted_price), 2) AS avg_discounted_price,
    ROUND(AVG(purchased_last_month), 0) AS avg_sales_last_month,
    ROUND(SUM(CASE WHEN LOWER(has_coupon) LIKE '%coupon%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_with_coupon
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

ROUND(((original_price - discounted_price) / NULLIF (original_price, 0)) * 100, 0) AS discount_pct,
AVG (purchased_last_month) AS avg_sales

FROM products_sales_cleaned
WHERE discounted_price > 0 AND original_price > discounted_price
GROUP BY ROUND(((original_price - discounted_price) / NULLIF (original_price, 0)) * 100, 0)
ORDER BY discount_pct;

-- Qual é o impacto de cupons e descontos na conversão? 

SELECT 
	has_coupon,
	AVG(purchased_last_month) AS avg_sales,
	AVG(product_rating) AS avg_rating,
	COUNT(*) AS num_products
FROM products_sales_cleaned
GROUP BY has_coupon;

-- Quais categorias têm maior variação de preço médio em relação ao preço original (price elasticity)? 

SELECT
	product_category,
	AVG(original_price) AS avg_original,
	AVG(discounted_price) AS avg_discounted,
	ROUND((AVG(original_price) - AVG(discounted_price)) / AVG(original_price) * 100, 2) AS avg_discounted_pct
FROM products_sales_cleaned
GROUP BY product_category
ORDER BY avg_discounted_pct DESC;

-- Produtos com grandes descontos mantêm boas avaliações? 

SELECT
	CASE
		WHEN ((original_price - discounted_price) / original_price) * 100 >= 30 THEN 'High Discount (30%+)'
		ELSE 'Low/Medium Discount'
	END AS discount_group,
	AVG(product_rating) AS avg_rating
FROM products_sales_cleaned
WHERE original_price > 0 
GROUP BY discount_group;


-- 3. Comportamento do Cliente e Engajamento 

-- Quais categorias possuem maior número de reviews por produto — e isso indica engajamento real ou apenas volume de vendas? 

SELECT
	

-- Há uma tendência de melhores avaliações em produtos mais caros? 

-- O selo de Best Seller influencia a nota média dos produtos? 

-- 4. Insights Operacionais 

-- Qual é o percentual de produtos sem Buy Box disponível (indicando possível problema de estoque ou preço)? 

-- Existe diferença significativa de entregas estimadas entre categorias (impactando conversão)? 

-- Quais produtos ou categorias têm selo de sustentabilidade e como isso afeta suas vendas e avaliações? 

-- 5. Oportunidades Estratégicas 

-- Quais produtos ou categorias estão com alto rating e baixo volume de vendas (potencial de marketing)? 

-- Onde há descontos altos mas vendas baixas (possível problema de percepção ou competitividade)? 

-- Que produtos poderiam ser indicados para promoção ou destaque na home?


