@IsTest(SeeAllData=true)
private class QueryUtility_Test {
    @isTest static void testGetOrderProducts() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
        Order ord = TestDataFactory.createOrder(acc.Id, pbe.Pricebook2Id);
        TestDataFactory.createOrderItem(ord.Id, pbe.Id, 3);

        List<OrderItem> orderItems = new List<OrderItem>();
        
        Test.startTest();
            // Call Apex method
            orderItems = QueryUtility.getOrderProducts(ord.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, orderItems.size(), 'OrderItem should exist');
    }
    
    @isTest static void testGetOrderProductsById() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
        Order ord = TestDataFactory.createOrder(acc.Id, pbe.Pricebook2Id);
        TestDataFactory.createOrderItem(ord.Id, pbe.Id, 3);

        List<OrderItem> orderItems = new List<OrderItem>();
        
        Test.startTest();
            // Call Apex method
            orderItems = QueryUtility.getOrderProductsById(prod.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, orderItems.size(), 'OrderItem should exist');
    }

    @isTest static void testGetOrders() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
        Order ord = TestDataFactory.createOrder(acc.Id, pbe.Pricebook2Id);

        List<Order> orders = new List<Order>();
        
        Test.startTest();
            // Call Apex method
            orders = QueryUtility.getOrders(ord.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, orders.size(), 'order should exist');
    }

    @isTest static void testGetPriceBookEntries() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
      
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        
        Test.startTest();
            // Call Apex method
            pricebookEntries = QueryUtility.getPriceBookEntries(pb.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, pricebookEntries.size(), 'pricebookEntries should exist');
    }
}