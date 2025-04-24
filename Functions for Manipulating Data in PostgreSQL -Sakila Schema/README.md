### 📊 Functions for Manipulating Data in PostgreSQL - Sakila Schema

#### 📁 Dataset
> This project uses the Sakila Schema database from Datacamp

#### 🎯 Objective
- use built-in PostgreSQL functions in your SQL queries
- manipulate different types of data including strings, character, numeric and date/time
- Use robust full-text search capabilities which provides a powerful tool for indexing and matching keywords in a PostgreSQL document.

#### 🧠 Key Skills Applied
- Common data types in PostgreSQL
- Date/time functions and operators
- Parsing and manipulating text
- PostgreSQL Extensions and full-text search 
- Concatenation: `|| (operator)`, `CONCAT(string1, string2, ...)`, 
- Case Manipulation:`UPPER(string)`, `LOWER(string)`, `INITCAP(string)` 
- String Modification: `REPLACE(string, substring, replacement)`, `REVERSE(string)`
- String Extraction: `LEFT(string, length)`, `RIGHT(string, length)`, `SUBSTRING(string, start, length)`, `SUBSTR(string, start, length)` 
- String Trimming: `TRIM([leading | trailing | both] [characters] FROM string)`, `LTRIM(string)`, `RTRIM(string)`
- String Measurement: `CHAR_LENGTH(string)`, `LENGTH(string)`
- String Padding: `LPAD(string, length, [pad_character])`, `RPAD(string, length, [pad_character])`  
- String Position:`POSITION(substring IN string)`, `STRPOS(string, substring)`
- Date/Time Functions: `AGE(timestamp, timestamp)` `NOW()` `CURRENT_TIMESTAMP` `CURRENT_DATE` `CURRENT_TIME` `EXTRACT(field FROM source)``DATE_PART(field, source)` `DATE_TRUNC(field, source)`
- Full-Text Search Functions: `to_tsvector(title)`, `to_tsquery('elf')`  
- Extension Related Functions: `levenshtein(string1, string2)` `similarity(string1, string2)`  


#### 🧾 File Descriptions
| File | Description |
|------|-------------|
| [`Queries.sql`](https://github.com/nalapalu/SQL_Projects/blob/main/Functions%20for%20Manipulating%20Data%20in%20PostgreSQL%20-Sakila%20Schema/Queries.sql) | Contains all SQL queries used in the analysis |
| `postgres-sakila-incremental-schema_06172019.sql` | The dataset used for the project |


#### 💭 Future Ideas / Improvements
- Use window functions to analyze monthly trends  
- Build a dashboard in Power BI  
- Compare year-over-year changes if time-series data is available
