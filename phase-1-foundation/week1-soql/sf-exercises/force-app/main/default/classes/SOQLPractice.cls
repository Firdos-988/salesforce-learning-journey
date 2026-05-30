/**
 * SOQLPractice.cls
 * 
 * Purpose  : Practice class demonstrating SOQL patterns for Week 1 Day 2
 * Developer: Firdos Rajanl
 * Date     : 30/5/2026
 * 
 * Topics covered:
 *   1. Basic SELECT queries
 *   2. WHERE clause filtering
 *   3. ORDER BY and LIMIT
 *   4. Child-to-parent relationship queries
 *   5. Parent-to-child subqueries
 *   6. Aggregate queries
 *   7. Bulkified query pattern (no SOQL in loops)
 *   8. Dynamic SOQL
 */
public with sharing class SOQLPractice {

    //  get accounts by industry
    public static List<Account> getAccountsByIndustry(String industry) {
        List<Account> accounts = [
            SELECT Id, Name, Industry, Phone, AnnualRevenue
            FROM Account
            WHERE Industry = :industry
            ORDER BY Name ASC
        ];
        return accounts;
    }
    // WHERE  with multiple conditions
    public static List<Opportunity> getLargeOpenOpportunities(Decimal minAmount) {
        List<Opportunity> opps = [
            SELECT Id, Name, Amount, StageName, CloseDate, Account.Name
            FROM Opportunity
            WHERE Amount > :minAmount
            AND IsClosed = false
            ORDER BY Amount DESC
            LIMIT 50
        ];
        return opps;
    }

    // Child-to-parent relationship query
    // Get contacts and their parent Account details
    public static List<Contact> getContactsWithAccountInfo() {
        List<Contact> contacts = [
            SELECT Id,FirstName,LastName,Email,Phone,Account.Name,Account.Industry,Account.Phone
            FROM Contact
            WHERE Account.Industry = 'Technology'
            ORDER BY LastName ASC
            LIMIT 20
        ];
        return contacts;
    }
    // Parent-to-child subquery
    // Get accounts along with all their related contacts
    public static List<Account> getAccountsWithContacts() {
        List<Account> accounts = [
            SELECT Id,
                   Name,
                   Industry,
                   (SELECT Id, FirstName, LastName, Email, Phone
                    FROM Contacts
                    ORDER BY LastName ASC)
            FROM Account
            WHERE Industry = 'Technology'
            LIMIT 10
        ];
        return accounts;
    }
    // Aggregate query
    // Summarise opportunities by stage
    public static void printOpportunitySummary() {
        List<AggregateResult> results = [
            SELECT StageName,
                   COUNT(Id) totalDeals,
                   SUM(Amount) totalAmount,
                   AVG(Amount) avgAmount
            FROM Opportunity
            GROUP BY StageName
            ORDER BY SUM(Amount) DESC
        ];

        System.debug('Opportunity Summary by Stage');
        for (AggregateResult ar : results) {
            String stage       = (String)  ar.get('StageName');
            Integer totalDeals = (Integer) ar.get('totalDeals');
            Decimal totalAmt   = (Decimal) ar.get('totalAmount');
            Decimal avgAmt     = (Decimal) ar.get('avgAmount');

            System.debug('Stage: ' + stage +' | Deals: ' + totalDeals +' | Total: $' + totalAmt +' | Avg: $' + avgAmt);
        }
    }
    //Bulkified pattern
    // Get contacts for a list of account
    public static Map<Id, List<Contact>> getContactsForAccounts(List<Id> accountIds) {

        // Single query for all contacts at once
        List<Contact> allContacts = [
            SELECT Id, FirstName, LastName, Email, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            ORDER BY LastName ASC
        ];

        Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();

        for (Contact c : allContacts) {
            if (!contactsByAccount.containsKey(c.AccountId)) {
                contactsByAccount.put(c.AccountId, new List<Contact>());
            }
            contactsByAccount.get(c.AccountId).add(c);
        }

        return contactsByAccount;
    }


    // Dynamic SOQL
    // Build a query dynamically based on parameters
    public static List<SObject> dynamicQuery(String objectName, String filterField, String filterValue) {
 
        // Build the query string
        String query = 'SELECT Id, Name' +
                       ' FROM ' + objectName +
                       ' WHERE ' + filterField + ' = :filterValue' +
                       ' LIMIT 50';

        // Database.query() runs a dynamic SOQL string
        List<SObject> results = Database.query(query);
        return results;
    }


    // Demonstration method     
    public static void runAllDemos() {

        System.debug('\n\n========================================');
        System.debug('DEMO 1: Basic Query - Technology Accounts');
        System.debug('========================================');
        List<Account> techAccounts = getAccountsByIndustry('Technology');
        System.debug('Found ' + techAccounts.size() + ' Technology accounts');
        for (Account a : techAccounts) {
            System.debug('  -> ' + a.Name + ' | Revenue: ' + a.AnnualRevenue);
        }

        System.debug('\n========================================');
        System.debug('DEMO 2: Large Open Opportunities (> $50,000)');
        System.debug('========================================');
        List<Opportunity> bigOpps = getLargeOpenOpportunities(50000);
        System.debug('Found ' + bigOpps.size() + ' large open opportunities');
        for (Opportunity o : bigOpps) {
            System.debug('  -> ' + o.Name + ' | $' + o.Amount + ' | Stage: ' + o.StageName);
        }

        System.debug('\n========================================');
        System.debug('DEMO 3: Contacts with Account Info');
        System.debug('========================================');
        List<Contact> contacts = getContactsWithAccountInfo();
        System.debug('Found ' + contacts.size() + ' contacts in Technology industry');
        for (Contact c : contacts) {
            System.debug('  -> ' + c.FirstName + ' ' + c.LastName + ' at ' + c.Account.Name);
        }

        System.debug('\n========================================');
        System.debug('DEMO 4: Accounts with their Contacts');
        System.debug('========================================');
        List<Account> accsWithContacts = getAccountsWithContacts();
        for (Account a : accsWithContacts) {
            System.debug('Account: ' + a.Name);
            if (a.Contacts != null) {
                for (Contact c : a.Contacts) {
                    System.debug('   Contact: ' + c.FirstName + ' ' + c.LastName);
                }
            }
        }

        System.debug('\n========================================');
        System.debug('DEMO 5: Opportunity Summary');
        System.debug('========================================');
        printOpportunitySummary();

        System.debug('\n========================================');
        System.debug('DEMO 6: Bulkified Pattern Demo');
        System.debug('========================================');
        List<Account> someAccounts = [SELECT Id, Name FROM Account LIMIT 5];
        List<Id> ids = new List<Id>();
        for (Account a : someAccounts) { ids.add(a.Id); }

        Map<Id, List<Contact>> contactMap = getContactsForAccounts(ids);
        System.debug('Contact map has entries for ' + contactMap.size() + ' accounts');
        for (Account a : someAccounts) {
            List<Contact> relatedContacts = contactMap.get(a.Id);
            Integer count = (relatedContacts != null) ? relatedContacts.size() : 0;
            System.debug('  ' + a.Name + ' -> ' + count + ' contacts');
        }

        System.debug('\n========================================');
        System.debug('ALL DEMOS COMPLETE');
        System.debug('========================================\n');
    }
}