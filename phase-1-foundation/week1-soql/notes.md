# Week 1 — SOQL Notes

## What SOQL is
Salesforce Object Query Language. Used inside Apex to retrieve 
data from Salesforce objects. Similar to SQL but works only 
within Salesforce.

## Core syntax
SELECT field1, field2 FROM ObjectName WHERE condition ORDER BY field LIMIT n

## Key rules I must never forget
1. Never write SELECT * — always name your fields
2. Never put SOQL inside a for loop — governor limit is 100 queries
3. Always use bind variables (:variableName) not string concatenation
4. Use Map pattern to work with related records without extra queries

## Relationship queries
- Child to Parent: Use dot notation — Account.Name inside Contact query
- Parent to Child: Use subquery — (SELECT Id FROM Contacts) inside Account query
- Custom lookup relationships use __r suffix instead of object name

## Aggregate functions
- COUNT(Id) — count records
- SUM(Amount) — add up values  
- AVG(Amount) — calculate average
- MAX / MIN — highest and lowest value
- Must use AggregateResult type and cast each value

## Governor limits (SOQL)
- Maximum 100 SOQL queries per transaction
- Maximum 50,000 rows returned per transaction
- Maximum 1 subquery result set of 50,000 rowscf

## Interview questions I can now answer
1. What is SOQL and how is it different from SQL?
2. What is a bind variable and why should you use it?
3. What is the difference between child-to-parent and parent-to-child queries?
4. Why should you never write SOQL inside a for loop?
5. What is AggregateResult and how do you use it?