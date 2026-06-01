/**
 * CollectionsPractice.cls
 *
 * Purpose  : Demonstrates all three Apex collection types with
 *            real Salesforce data patterns
 * Developer: Firdos Rajnal
 * Date     : 1/06/2026
 *
 * Topics covered:
 *   1. List — declaration, CRUD operations, loops
 *   2. Set  — uniqueness, ID collection, List conversion
 *   3. Map  — key-value lookup, grouping, counting
 *   4. Combined patterns used in real Salesforce projects
 */
public with sharing class CollectionsPractice {

    // ================================================================
    // SECTION 1: LIST METHODS
    // ================================================================

    /**
     * Demonstrates basic List operations
     * Call from Execute Anonymous to see List behaviour
     */
    public static void demonstrateList() {
        System.debug('\n========== LIST DEMO ==========');

        // Declaration and initialisation
        List<String> skills = new List<String>{
            'Apex', 'SOQL', 'LWC', 'JavaScript', 'Flows'
        };

        System.debug('Initial list: ' + skills);
        System.debug('Size: ' + skills.size());
        System.debug('First item (index 0): ' + skills[0]);
        System.debug('Last item: ' + skills[skills.size() - 1]);

        // Add items
        skills.add('HTML');
        skills.add('CSS');
        System.debug('After adding HTML and CSS: ' + skills);

        // Check existence
        System.debug('Contains LWC: ' + skills.contains('LWC'));
        System.debug('Contains Python: ' + skills.contains('Python'));

        // Update item at index
        skills.set(0, 'Advanced Apex');
        System.debug('After updating index 0: ' + skills);

        // Remove by index
        skills.remove(0);
        System.debug('After removing index 0: ' + skills);

        // Loop with index
        System.debug('\n--- Loop with index ---');
        for (Integer i = 0; i < skills.size(); i++) {
            System.debug('Skill ' + (i + 1) + ': ' + skills[i]);
        }
    }


    /**
     * Real project pattern: query records into a List
     * and process them
     */
    public static void listWithSalesforceRecords() {
        System.debug('\n========== LIST WITH SF RECORDS ==========');

        List<Account> accounts = [
            SELECT Id, Name, Industry, AnnualRevenue, Phone
            FROM Account
            ORDER BY Name ASC
            LIMIT 10
        ];

        System.debug('Total accounts retrieved: ' + accounts.size());

        if (accounts.isEmpty()) {
            System.debug('No accounts found. Please load sample data.');
            return;
        }

        // Process each record
        Decimal totalRevenue = 0;
        for (Account acc : accounts) {
            System.debug(
                'Account: ' + acc.Name +
                ' | Industry: ' + acc.Industry +
                ' | Revenue: ' + acc.AnnualRevenue
            );
            if (acc.AnnualRevenue != null) {
                totalRevenue += acc.AnnualRevenue;
            }
        }

        System.debug('Combined annual revenue: $' + totalRevenue);
    }


    // ================================================================
    // SECTION 2: SET METHODS
    // ================================================================

    /**
     * Demonstrates Set uniqueness and basic operations
     */
    public static void demonstrateSet() {
        System.debug('\n========== SET DEMO ==========');

        // Sets automatically remove duplicates
        Set<String> uniqueCities = new Set<String>();
        uniqueCities.add('Mumbai');
        uniqueCities.add('Delhi');
        uniqueCities.add('Mumbai');   // duplicate — ignored
        uniqueCities.add('Chennai');
        uniqueCities.add('Delhi');    // duplicate — ignored
        uniqueCities.add('Bangalore');

        System.debug('Set contents: ' + uniqueCities);
        System.debug('Size: ' + uniqueCities.size());  // 4 not 6

        // Fast existence check
        System.debug('Contains Mumbai: ' + uniqueCities.contains('Mumbai'));
        System.debug('Contains Pune: '   + uniqueCities.contains('Pune'));

        // Remove
        uniqueCities.remove('Chennai');
        System.debug('After removing Chennai: ' + uniqueCities);

        // List with duplicates → Set → clean List
        System.debug('\n--- Deduplication pattern ---');
        List<String> rawData = new List<String>{
            'Apex', 'SOQL', 'Apex', 'LWC', 'SOQL', 'Flows', 'Apex'
        };
        System.debug('Raw list size: ' + rawData.size());  // 7

        Set<String> uniqueData = new Set<String>(rawData);
        System.debug('After dedup size: ' + uniqueData.size());  // 4

        List<String> cleanData = new List<String>(uniqueData);
        System.debug('Clean list: ' + cleanData);
    }


    /**
     * Real project pattern: collect unique IDs from one query
     * and use them in a second query
     */
    public static void setForIdCollection() {
        System.debug('\n========== SET FOR ID COLLECTION ==========');

        // Step 1: Get contacts
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, AccountId
            FROM Contact
            WHERE AccountId != null
            LIMIT 20
        ];

        if (contacts.isEmpty()) {
            System.debug('No contacts found.');
            return;
        }

        // Step 2: Collect unique Account IDs
        Set<Id> accountIds = new Set<Id>();
        for (Contact c : contacts) {
            accountIds.add(c.AccountId);
        }

        System.debug('Contacts found: ' + contacts.size());
        System.debug('Unique account IDs: ' + accountIds.size());

        // Step 3: Query those accounts with one SOQL query
        List<Account> relatedAccounts = [
            SELECT Id, Name, Industry
            FROM Account
            WHERE Id IN :accountIds
        ];

        System.debug('Related accounts retrieved: ' + relatedAccounts.size());
        for (Account acc : relatedAccounts) {
            System.debug('  Account: ' + acc.Name + ' | ' + acc.Industry);
        }
    }


    // ================================================================
    // SECTION 3: MAP METHODS
    // ================================================================

    /**
     * Demonstrates basic Map operations
     */
    public static void demonstrateMap() {
        System.debug('\n========== MAP DEMO ==========');

        // Map<String, String> — simple key-value
        Map<String, String> countryCapitals = new Map<String, String>();
        countryCapitals.put('Pakistan', 'Islamabad');
        countryCapitals.put('India',    'New Delhi');
        countryCapitals.put('UAE',      'Abu Dhabi');
        countryCapitals.put('UK',       'London');

        System.debug('Map size: ' + countryCapitals.size());

        // Get value by key
        System.debug('Capital of Pakistan: ' + countryCapitals.get('Pakistan'));
        System.debug('Capital of UAE: '      + countryCapitals.get('UAE'));

        // Safe get — check before accessing
        String country = 'Germany';
        if (countryCapitals.containsKey(country)) {
            System.debug('Capital: ' + countryCapitals.get(country));
        } else {
            System.debug(country + ' is not in our map');
        }

        // Get returns null if key does not exist — this does NOT throw an error
        String missing = countryCapitals.get('Brazil');
        System.debug('Brazil capital: ' + missing);  // null

        // Update existing key
        countryCapitals.put('UK', 'London, England');
        System.debug('Updated UK: ' + countryCapitals.get('UK'));

        // Loop through all entries
        System.debug('\n--- All entries ---');
        for (String countryName : countryCapitals.keySet()) {
            System.debug(countryName + ' → ' + countryCapitals.get(countryName));
        }

        // keySet() and values()
        System.debug('All keys: '   + countryCapitals.keySet());
        System.debug('All values: ' + countryCapitals.values());
    }


    /**
     * Real project pattern: Map<Id, SObject> for fast record lookup
     * This avoids looping through a list to find a record by ID
     */
    public static void mapForFastLookup() {
        System.debug('\n========== MAP FOR FAST LOOKUP ==========');

        // Query accounts into a Map directly — shortcut syntax
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Name, Industry, AnnualRevenue
            FROM Account
            LIMIT 10
        ]);

        System.debug('Accounts in map: ' + accountMap.size());

        // Now query contacts
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, AccountId
            FROM Contact
            WHERE AccountId IN :accountMap.keySet()
            LIMIT 20
        ];

        // For each contact, look up their account instantly using the Map
        for (Contact c : contacts) {
            Account parentAccount = accountMap.get(c.AccountId);
            if (parentAccount != null) {
                System.debug(
                    c.FirstName + ' ' + c.LastName +
                    ' works at ' + parentAccount.Name +
                    ' (' + parentAccount.Industry + ')'
                );
            }
        }
    }


    /**
     * Real project pattern: Map<Id, List<SObject>>
     * Group child records under their parent ID
     */
    public static void mapForGrouping() {
        System.debug('\n========== MAP FOR GROUPING ==========');

        // Get accounts
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            LIMIT 10
        ];

        if (accounts.isEmpty()) {
            System.debug('No accounts found.');
            return;
        }

        // Collect IDs
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        // Get all related contacts in one query
        List<Contact> allContacts = [
            SELECT Id, FirstName, LastName, Email, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
        ];

        // Group contacts by AccountId
        Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();
        for (Contact c : allContacts) {
            if (!contactsByAccount.containsKey(c.AccountId)) {
                contactsByAccount.put(c.AccountId, new List<Contact>());
            }
            contactsByAccount.get(c.AccountId).add(c);
        }

        // Print grouped results
        for (Account acc : accounts) {
            List<Contact> relatedContacts = contactsByAccount.get(acc.Id);
            Integer count = (relatedContacts != null) ? relatedContacts.size() : 0;
            System.debug('\nAccount: ' + acc.Name + ' | Contacts: ' + count);

            if (relatedContacts != null) {
                for (Contact c : relatedContacts) {
                    System.debug('   → ' + c.FirstName + ' ' + c.LastName +
                                 ' | ' + c.Email);
                }
            }
        }
    }


    /**
     * Real project pattern: Counting with a Map
     */
    public static void mapForCounting() {
        System.debug('\n========== MAP FOR COUNTING ==========');

        List<Account> accounts = [
            SELECT Id, Name, Industry
            FROM Account
            WHERE Industry != null
            LIMIT 100
        ];

        // Count accounts per industry
        Map<String, Integer> countByIndustry = new Map<String, Integer>();

        for (Account acc : accounts) {
            String industry = acc.Industry;

            if (!countByIndustry.containsKey(industry)) {
                countByIndustry.put(industry, 0);
            }
            countByIndustry.put(industry, countByIndustry.get(industry) + 1);
        }

        // Print the count summary
        System.debug('\n--- Accounts per Industry ---');
        for (String industry : countByIndustry.keySet()) {
            System.debug(industry + ': ' + countByIndustry.get(industry));
        }
    }


    // ================================================================
    // SECTION 4: RUN ALL DEMOS
    // ================================================================

    /**
     * Master method — call this from Execute Anonymous
     * to run every demo in one go
     */
    public static void runAllDemos() {
        demonstrateList();
        listWithSalesforceRecords();
        demonstrateSet();
        setForIdCollection();
        demonstrateMap();
        mapForFastLookup();
        mapForGrouping();
        mapForCounting();

        System.debug('\n========== ALL COLLECTION DEMOS COMPLETE ==========');
    }
}