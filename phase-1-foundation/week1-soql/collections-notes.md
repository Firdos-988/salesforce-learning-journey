# Week 1 Day 3 — Apex Collections Notes

## The three collections and when to use each

| Collection | Allows Duplicates | Has Order | Access By |
|---|---|---|---|
| List | Yes | Yes | Index (0,1,2...) |
| Set | No | No | Loop only |
| Map | Keys unique | No | Key |

## List — key methods
- .add(item)           → add to end
- .add(index, item)    → insert at position
- .get(index)          → same as [index]
- .set(index, item)    → update at position
- .remove(index)       → delete at position
- .size()              → count of items
- .isEmpty()           → true if no items
- .contains(item)      → true/false
- .clear()             → remove all

## Set — key methods
- .add(item)           → adds only if not duplicate
- .remove(item)        → remove specific item
- .contains(item)      → very fast true/false check
- .size()              → count of unique items
- .isEmpty()           → true if no items

## Map — key methods
- .put(key, value)     → add or update
- .get(key)            → returns value or null
- .containsKey(key)    → check before get()
- .remove(key)         → delete entry
- .keySet()            → returns Set of all keys
- .values()            → returns List of all values
- .size()              → count of entries

## The patterns I must memorise
1. List → Set → List : removes duplicates
2. Set<Id> from loop → IN :setName in SOQL : safe bulk query
3. Map<Id, SObject> directly from query : fast record lookup
4. Map<Id, List<SObject>> with containsKey check : grouping records
5. Map<String, Integer> with get+1 pattern : counting occurrences

## My explanation of why Map is better than looping
The problem we are solving is connecting two separate lists efficiently - Accounts and Contacts - so we know which contacts belong to which account.
If we loop through all contacts for every account, the cost grows rapidly. With 200 accounts and 2,000 contacts, that is 400,000 comparisons. As data grows, this gets worse and can hit Salesforce CPU time governor limits.
Think of it like an email directory. Without organisation, finding someone's email means reading the entire list every time. With a Map - like a sorted directory - you go directly to the right entry in one step.
In Apex, the Map uses Account ID as the key and a list of related Contacts as the value. So contactsByAccount.get(acc.Id) gives us the right contacts instantly - one direct lookup instead of scanning thousands of records repeatedly.