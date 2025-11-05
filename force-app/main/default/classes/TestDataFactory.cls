@isTest
public with sharing class TestDataFactory {

    // ✅ Create Account
    public static Account createAccount(String name) {
        Account acc = new Account(
            Name = name != null ? name : 'Test Account'
        );
        insert acc;
        return acc;
    }

    // ✅ Create Contact
    public static Contact createContact(Id accountId, String firstName, String lastName) {
        Contact con = new Contact(
            FirstName = firstName != null ? firstName : 'Test',
            LastName  = lastName != null ? lastName : 'Contact',
            AccountId = accountId
        );
        insert con;
        return con;
    }

    
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
        Pricebook2 stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = stdPb.Id,
            Product2Id   = product.Id,
            UnitPrice    = price != null ? price : 100,
            IsActive     = true
        );
        insert stdPbe;
        return stdPbe;
    }

    // ✅ Create a Custom Pricebook
    public static Pricebook2 createCustomPricebook(String name) {
        Pricebook2 stdPb = [SELECT Id, Name, IsActive FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
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

    // ✅ Create Order with Line Item
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

    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Decimal qty) {
        OrderItem oi = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pricebookEntryId,
            Quantity = qty != null ? qty : 1,
            UnitPrice = 99
        );
        insert oi;
        return oi;
    }
}