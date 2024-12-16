/*
SQL DATA EXPLORATION


Denne analysen utforsker og analyserer data i to tabeller: **SalesTable** (salgsdata) og **RealEstateTable** (eiendomsdata). Følgende nøkkelpunkter er utført:

1. **Datainnsikt og Struktur**:
   - Tabellenes innhold og kolonnedetaljer er undersøkt.
   - Koblinger mellom tabellene er identifisert gjennom `address_id`.

2. **Deskriptiv Statistikk**:
   - Salgspriser analysert per år: gjennomsnitt, minimum, maksimum.
   - Antall transaksjoner analysert per år og per postnummer.
   - Gjennomsnittlig eiendomsareal gruppert etter postnummer.

3. **Sammenheng Mellom Egenskaper og Pris**:
   - Effekten av funksjoner som balkong, heis og antall soverom på salgspriser.
   - Sammenheng mellom energipoeng og salgspriser.

4. **Salgsprosess**:
   - Analyse av tid fra registrering til salg, inkludert kategorisering basert på salgsdager.
   - Gjennomsnittlig tid brukt på salg og fordeling av transaksjonstid.

5. **Prisendring over Tid**:
   - Prisendring for eiendommer analysert med prosentvis utvikling sammenlignet med første salgspris.
   - Antall år mellom første og påfølgende salg beregnet.

6. **Geografisk Analyse**:
   - Salgsdata analysert per postnummer og bygningstype.
   - Gjennomsnittlig bruksareal gruppert etter bygningstype.

Disse innsiktene gir et solid grunnlag for å forstå markedstrender, geografiske mønstre og eiendomsegenskaper som påvirker salgsprisene.
*/

--Undersøke SalesTable
SELECT TOP 1000 *
FROM PortfolioProject..SalesTable

--Undersøke RealEstateTable
SELECT TOP 1000 *
FROM PortfolioProject..RealEstateTable

--Se på datatyper og strukturer
EXEC sp_columns 'SalesTable';
EXEC sp_columns 'RealEstateTable';

----------------------------------

SELECT COUNT(*) as MatchCount
FROM PortfolioProject..SalesTable S
JOIN PortfolioProject..RealEstateTable R
ON S.address_id = R.id


-----------------------------------
--Fordeling av 'official_price' grouped by year: 
--gjennomsnitt, median, og spredning av offisielle salgspriser.

SELECT YEAR(official_date)
,ROUND(AVG(official_price), 0) AS AvgPrice
,MIN(official_price) AS MinPrice
,MAX(official_price) AS MaxPrice
FROM SalesTable
GROUP BY YEAR(official_date)
ORDER BY 1 

--Antall salg per år
SELECT 
    YEAR(official_date) AS SaleYear, 
    COUNT(*) AS SalesCount
FROM PortfolioProject.dbo.SalesTable
GROUP BY YEAR(official_date)
ORDER BY SaleYear;

--Året 2023 has transakjoner kun til 17.03.2023
SELECT official_date
FROM PortfolioProject.dbo.SalesTable
WHERE YEAR(official_date) = 2023
ORDER BY 1 DESC


--Gjennomsnittlig salgspris per år:
SELECT 
    YEAR(official_date) AS SaleYear, 
    ROUND(AVG(official_price), 0) AS AvgPrice
FROM PortfolioProject.dbo.SalesTable
GROUP BY YEAR(official_date)
ORDER BY SaleYear;


--Salgsdata gruppert etter postnummer (postnr)

SELECT 
    postnr, 
    COUNT(*) AS PropertyCount
FROM PortfolioProject.dbo.RealEstateTable
GROUP BY postnr
ORDER BY PropertyCount DESC;


--Gjennomsnittlig størrelse på eiendom per postnummer
SELECT 
    postnr, 
    ROUND(AVG(eiendomareal), 1) AS AvgPropertyArea
FROM PortfolioProject.dbo.RealEstateTable
GROUP BY postnr
ORDER BY AvgPropertyArea DESC;




--Sammenlign eiendomsareal med offisiell salgspris
SELECT 
    R.prom, 
    ROUND(AVG(S.official_price), 0) AS AvgPrice
FROM PortfolioProject.dbo.RealEstateTable R
JOIN PortfolioProject.dbo.SalesTable S ON R.id = S.address_id
GROUP BY R.prom
ORDER BY R.prom;


--Antall eiendommer per bygningstype:
SELECT 
    bygningstype, 
    COUNT(*) AS PropertyCount
FROM PortfolioProject.dbo.RealEstateTable
GROUP BY bygningstype
ORDER BY PropertyCount DESC;


--Gjennomsnittlig bruksareal per bygningstype:
SELECT 
    bygningstype, 
    ROUND(AVG(bruksarealbolig), 0) AS AvgUsableArea
FROM PortfolioProject.dbo.RealEstateTable
GROUP BY bygningstype
ORDER BY AvgUsableArea DESC;


--Eiendomsfunksjoner som Påvirker Pris
--Sammenheng mellom balkong og pris:

SELECT 
    R.balkong, 
    ROUND(AVG(S.official_price), 0) AS AvgPrice
FROM PortfolioProject.dbo.RealEstateTable R
JOIN PortfolioProject.dbo.SalesTable S ON R.id = S.address_id
GROUP BY R.balkong;

--Effekten av heis (harheis) på salgspris:
SELECT 
    R.harheis, 
    ROUND(AVG(S.official_price), 0) AS AvgPrice
FROM PortfolioProject.dbo.RealEstateTable R
JOIN PortfolioProject.dbo.SalesTable S ON R.id = S.address_id
GROUP BY R.harheis;


--Dager til Salg Analyse
--Gjennomsnittlig tid fra registrering til salg:

SELECT 
    AVG(days_diff) AS AvgDaysToSell, 
    MIN(days_diff) AS MinDaysToSell, 
    MAX(days_diff) AS MaxDaysToSell
FROM PortfolioProject.dbo.SalesTable;


--Fordeling av salg basert på dager til salg:

SELECT 
    CASE 
        WHEN days_diff < 30 THEN 'Under 30 dager'
        WHEN days_diff BETWEEN 30 AND 60 THEN '30-60 dager'
        WHEN days_diff BETWEEN 60 AND 90 THEN '60-90 dager'
        ELSE 'Over 90 dager'
    END AS DaysCategory,
    COUNT(*) AS SalesCount
FROM PortfolioProject.dbo.SalesTable
GROUP BY 
    CASE 
        WHEN days_diff < 30 THEN 'Under 30 dager'
        WHEN days_diff BETWEEN 30 AND 60 THEN '30-60 dager'
        WHEN days_diff BETWEEN 60 AND 90 THEN '60-90 dager'
        ELSE 'Over 90 dager'
    END;


--Analyse av Energipoeng (RealEstateTable)
SELECT 
    R.energy_score, 
    ROUND(AVG(S.official_price), 0) AS AvgPrice
FROM PortfolioProject.dbo.RealEstateTable R
JOIN PortfolioProject.dbo.SalesTable S ON R.id = S.address_id
GROUP BY R.energy_score
ORDER BY 2 DESC;


--Fordeling av eiendommer etter energipoeng:

SELECT 
    energy_score, 
    COUNT(*) AS PropertyCount
FROM PortfolioProject.dbo.RealEstateTable
GROUP BY energy_score
ORDER BY energy_score;



--Analyse av sammenheng mellom Antall Soverom og Salgspris
WITH PropertySales AS (
    SELECT 
        R.soverom AS Bedrooms,
        S.official_price AS SalePrice
    FROM PortfolioProject.dbo.RealEstateTable R
    JOIN PortfolioProject.dbo.SalesTable S
    ON R.id = S.address_id
    WHERE S.official_price IS NOT NULL AND R.soverom IS NOT NULL
)
-- Utfør analysen på CTE
SELECT 
    Bedrooms,
    COUNT(*) AS PropertyCount,
    AVG(SalePrice) AS AvgSalePrice,
    MIN(SalePrice) AS MinSalePrice,
    MAX(SalePrice) AS MaxSalePrice
FROM PropertySales
GROUP BY Bedrooms
ORDER BY Bedrooms;



--Analyser hvordan prisene endret seg med årene med å vise prisutviklingen i prosent.

-- CTE for å finne den første salgsprisen og datoen for hver eiendom basert på official_date
WITH FirstSalePrice AS (
    SELECT 
        address_id,
        MIN(official_date) AS FirstSaleDate,
        MIN(official_price) AS FirstPrice
    FROM PortfolioProject.dbo.SalesTable
    WHERE official_price IS NOT NULL AND official_date IS NOT NULL
    GROUP BY address_id
),
PriceDevelopment AS (
    SELECT 
        s.address_id,
        s.official_date,
        s.official_price AS CurrentPrice,
        f.FirstPrice,
        DATEDIFF(YEAR, f.FirstSaleDate, s.official_date) AS YearsSinceFirstSale, -- Ny kolonne
        ROUND(
            ((s.official_price - f.FirstPrice) * 100.0) / f.FirstPrice, 
            2
        ) AS PriceChangePercent
    FROM PortfolioProject.dbo.SalesTable s
    INNER JOIN FirstSalePrice f
        ON s.address_id = f.address_id
    WHERE s.official_price IS NOT NULL AND s.official_date IS NOT NULL
)

-- Resultatet viser prisutviklingen i prosent og år siden første salg
SELECT 
    address_id,
    official_date,
    CurrentPrice,
    FirstPrice,
    YearsSinceFirstSale, -- Kolonne for antall år
    PriceChangePercent
FROM PriceDevelopment
ORDER BY address_id, official_date;

