@isTest
private class QueryUtility_Test {
    @testSetup
    static void setupData() {
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        TestDataFactory.createOrderItem(ord.Id, priceBookMap.get('pricebookEntryId'), 3);
    }

    @isTest static void testGetOrderProducts_Positive() {
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        Test.startTest();
        List<OrderItem> orderItems = QueryUtility.getOrderProducts(orderId);
        Test.stopTest();
        System.assertEquals(1, orderItems.size(), 'OrderItem should exist');
        System.assertEquals(3, Integer.valueOf(orderItems[0].Quantity), 'Quantity should match');
    }

    @isTest static void testGetOrderProducts_InvalidOrderId() {
        Test.startTest();
        List<OrderItem> orderItems = QueryUtility.getOrderProducts('801000000000000AAA');
        Test.stopTest();
        System.assertEquals(0, orderItems.size(), 'Should return empty for non-existent order');
    }
    
    @isTest static void testGetOrderProductsById_Positive() {
        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Test.startTest();
        List<OrderItem> orderItems = QueryUtility.getOrderProductsById(productId);
        Test.stopTest();
        System.assertEquals(1, orderItems.size(), 'OrderItem should exist');
        System.assertEquals(3, Integer.valueOf(orderItems[0].Quantity), 'Quantity should match');
    }

    @isTest static void testGetOrderProductsById_InvalidProductId() {
        Test.startTest();
        List<OrderItem> orderItems = QueryUtility.getOrderProductsById('01t000000000000AAA');
        Test.stopTest();
        System.assertEquals(0, orderItems.size(), 'Should return empty for non-existent product');
    }

    @isTest static void testGetOrders_Positive() {
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        Test.startTest();
        List<Order> orders = QueryUtility.getOrders(orderId);
        Test.stopTest();
        System.assertEquals(1, orders.size(), 'Order should exist');
        System.assertEquals(orderId, orders[0].Id, 'Order Id should match');
    }

    @isTest static void testGetOrders_InvalidOrderId() {
        Test.startTest();
        List<Order> orders = QueryUtility.getOrders('801000000000000AAA');
        Test.stopTest();
        System.assertEquals(0, orders.size(), 'Should return empty for non-existent order');
    }

    @isTest static void testGetPriceBookEntries_Positive() {
        Id pricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = false LIMIT 1].Id;
        Id pricebookEntryId = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :pricebookId LIMIT 1].Id;
        Test.startTest();
        List<PricebookEntry> pricebookEntries = QueryUtility.getPriceBookEntries(pricebookId);
        Test.stopTest();
        System.assertEquals(1, pricebookEntries.size(), 'PricebookEntry should exist');
        System.assertEquals(pricebookEntryId, pricebookEntries[0].Id, 'PricebookEntry Id should match');
    }

    @isTest static void testGetPriceBookEntries_InvalidPricebookId() {
        Test.startTest();
        List<PricebookEntry> pricebookEntries = QueryUtility.getPriceBookEntries('01s000000000000AAA');
        Test.stopTest();
        System.assertEquals(0, pricebookEntries.size(), 'Should return empty for non-existent pricebook');
    }
}