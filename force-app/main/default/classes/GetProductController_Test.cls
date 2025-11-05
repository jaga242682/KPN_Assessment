@IsTest(SeeAllData=true)
public with sharing class GetProductController_Test {
    @isTest static void testGetAvailableProducts() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
        Order ord = TestDataFactory.createOrder(acc.Id, pbe.Pricebook2Id);
        TestDataFactory.createOrderItem(ord.Id, pbe.Id, 3);

        List<GetProductController.ProductWrapper> wrapperList = new List<GetProductController.ProductWrapper>();
        
        Test.startTest();
            // Call Apex method
            wrapperList = GetProductController.getAvailableProducts(ord.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, wrapperList.size(), 'Products should exist');
    }

    @isTest static void testCreateOrderProduct() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
        Order ord = TestDataFactory.createOrder(acc.Id, pbe.Pricebook2Id);
        
        Test.startTest();
            // Call Apex method
            GetProductController.createOrderProduct( ord.Id,prod.Id, pbe.Id, 30);
        Test.stopTest();

        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :ord.Id];
        System.Assert.areEqual(1, orderItems.size(), 'OrderItem should exist');
    }

    @isTest static void testCreateOrderProductExisting() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
        Order ord = TestDataFactory.createOrder(acc.Id, pbe.Pricebook2Id);
        TestDataFactory.createOrderItem(ord.Id, pbe.Id, 3);
        
        Test.startTest();
            // Call Apex method
            GetProductController.createOrderProduct( ord.Id,prod.Id, pbe.Id, 30);
        Test.stopTest();

        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :ord.Id];
        System.Assert.areEqual(1, orderItems.size(), 'OrderItem should exist');
    }
}