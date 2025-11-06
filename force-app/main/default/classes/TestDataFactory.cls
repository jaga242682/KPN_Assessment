/**
 * Utility class for creating test data for Apex unit tests.
 * All methods insert records and return them for use in tests.
 */
@isTest
public with sharing class TestDataFactory {

    /**
     * Create and insert an Account record.
     */
    public static Account createAccount(String name) {
        Account acc = new Account(Name = String.isBlank(name) ? 'Test Account' : name);
        insert acc;
        return acc;
    }

    /**
     * Create and insert a Contact record linked to an Account.
     */
    public static Contact createContact(Id accountId, String firstName, String lastName) {
        Contact con = new Contact(
            FirstName = String.isBlank(firstName) ? 'Test' : firstName,
            LastName  = String.isBlank(lastName) ? 'Contact' : lastName,
            AccountId = accountId
        );
        insert con;
        return con;
    }

    /*
    // ✅ Create Product
    public static Product2 createProduct(String name) {
        Product2 prod = new Product2(
            Name = name != null ? name : 'Test Product',
            IsActive = true
        );
        insert prod;
        return prod;
    }

    // ✅ Create Standard PricebookEntry (required first!)
    public static PricebookEntry createStandardPricebookEntry(Product2 product, Decimal price) {
        //Pricebook2 stdPb = getStandardPricebook();
        //Pricebook2 stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Id stdPBId = Test.getStandardPricebookId();
        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = stdPBId,
            Product2Id   = product.Id,
            UnitPrice    = price != null ? price : 100,
            IsActive     = true
        );
        insert stdPbe;
        return stdPbe;
    }

    // ✅ Create a Custom Pricebook
    public static Pricebook2 createCustomPricebook(String name) {
        
        Id stdPBId = Test.getStandardPricebookId();
        Pricebook2 stdPb = [SELECT Id, Name, IsActive FROM Pricebook2 WHERE id =: stdPBId LIMIT 1];
        if (!stdPb.IsActive) {
            stdPb.IsActive = true;
            update stdPb;
        }
        
        Pricebook2 pb = new Pricebook2(
            Name = name != null ? name : 'Test Custom Pricebook',
            IsActive = true
        );
        insert pb;
        return pb;
    }

    // ✅ Create Pricebook + PricebookEntry
    public static PricebookEntry createPricebookEntry(Product2 product, Decimal unitPrice, Id pricebookId) {
        //Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        // Ensure standard price exists first
        createStandardPricebookEntry(product, unitPrice);
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id   = product.Id,
            UnitPrice    = unitPrice != null ? unitPrice : 99,
            IsActive     = true
        );
        insert pbe;
        return pbe;
    }
    */
    /**
     * Create and insert a Product, Standard PricebookEntry, Custom Pricebook, and Custom PricebookEntry.
     * Returns a map with keys: productId, pricebookId, pricebookEntryId.
     */
    public static Map<String,Id> createPricebookEntry() {
        Map<String,Id> pricebookMap = new Map<String,Id>();
        Id stdPBId = Test.getStandardPricebookId();

        Product2 prod = new Product2(
            Name = 'KPN Mobile 5G Plan',
            ProductCode = 'KPN-MBL-5G',
            Family = 'Mobile',
            IsActive = true
        );
        insert prod;
        pricebookMap.put('productId', prod.Id);

        PricebookEntry stdEntry = new PricebookEntry(
            Pricebook2Id = stdPBId,
            Product2Id = prod.Id,
            UnitPrice = 39.99,
            IsActive = true
        );
        insert stdEntry;
        //pricebookMap.put('pricebookId', stdPBId);
        //pricebookMap.put('pricebookEntryId', stdEntry.Id);

        Pricebook2 kpnRetail = new Pricebook2(
            Name = 'KPN Retail Pricebook',
            IsActive = true
        );
        insert kpnRetail;
        pricebookMap.put('pricebookId', kpnRetail.Id);

        PricebookEntry kpnEntry = new PricebookEntry(
            Pricebook2Id = kpnRetail.Id,
            Product2Id = prod.Id,
            UnitPrice = 35.99,
            IsActive = true
        );
        insert kpnEntry;
        pricebookMap.put('pricebookEntryId', kpnEntry.Id);

        return pricebookMap;
    }

    /**
     * Create and insert an Order record.
     */
    public static Order createOrder(Id accountId, Id pricebookId) {
        Order ord = new Order(
            Name = 'Test Order - ' + System.now().getTime(),
            Status = 'Draft',
            EffectiveDate = Date.today(),
            AccountId = accountId,
            Pricebook2Id = pricebookId
        );
        insert ord;
        return ord;
    }

    /**
     * Create and insert an OrderItem record.
     */
    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Decimal qty) {
        OrderItem oi = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pricebookEntryId,
            Quantity = qty == null ? 1 : qty,
            UnitPrice = 99
        );
        insert oi;
        return oi;
    }
}