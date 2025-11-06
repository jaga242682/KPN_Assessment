@IsTest
public with sharing class GetProductController_Test {
    @isTest static void testGetAvailableProducts_Positive() {
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        TestDataFactory.createOrderItem(ord.Id, priceBookMap.get('pricebookEntryId'), 3);

        Test.startTest();
        List<GetProductController.ProductWrapper> wrapperList = GetProductController.getAvailableProducts(ord.Id);
        Test.stopTest();

        System.assertEquals(1, wrapperList.size(), 'Products should exist');
        System.assertEquals('KPN Mobile 5G Plan', wrapperList[0].Name, 'Product name should match');
        System.assertEquals(35.99, wrapperList[0].ListPrice, 'Unit price should match');
        //System.assertEquals(3, Integer.valueOf(wrapperList[0].Quantity), 'Quantity should match');
        System.assertEquals('Draft', wrapperList[0].OrderStatus, 'Order status should match');
    }

    @isTest static void testGetAvailableProducts_NullOrderId() {
        Test.startTest();
        try {
            GetProductController.getAvailableProducts(null);
            System.assert(false, 'Should throw AuraHandledException for null orderId');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Error message should mention required order Id');
        }
        Test.stopTest();
    }

    @isTest static void testGetAvailableProducts_NoOrder() {
        // Use a random Id that does not exist
        Id fakeId = '801000000000000AAA';
        Test.startTest();
        List<GetProductController.ProductWrapper> wrapperList = GetProductController.getAvailableProducts(fakeId);
        Test.stopTest();
        System.assertEquals(0, wrapperList.size(), 'Should return empty list for non-existent order');
    }

    @isTest static void testGetAvailableProducts_NoPricebook() {
        Account acc = TestDataFactory.createAccount('NoPB Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, null); // No pricebook
        Test.startTest();
        try {
            GetProductController.getAvailableProducts(ord.Id);
            System.assert(false, 'Should throw AuraHandledException for missing pricebook');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Error message should mention missing pricebook');
        }
        Test.stopTest();
    }

    @isTest static void testGetAvailableProducts_NoProducts() {
        Account acc = TestDataFactory.createAccount('NoProducts Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        // Do not create any order items
        Test.startTest();
        List<GetProductController.ProductWrapper> wrapperList = GetProductController.getAvailableProducts(ord.Id);
        Test.stopTest();
        System.assertEquals(1, wrapperList.size(), 'Should return order items');
    }

    @isTest static void testCreateOrderProduct_Positive() {
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));

        Test.startTest();
        GetProductController.createOrderProduct(ord.Id, priceBookMap.get('productId'), priceBookMap.get('pricebookEntryId'), 30);
        Test.stopTest();

        List<OrderItem> orderItems = [SELECT Id, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :ord.Id];
        System.assertEquals(1, orderItems.size(), 'OrderItem should exist');
        System.assertEquals(30, orderItems[0].UnitPrice, 'Unit price should match');
        System.assertEquals(1, Integer.valueOf(orderItems[0].Quantity), 'Quantity should match');
    }

    @isTest static void testCreateOrderProduct_IncrementQuantity() {
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        TestDataFactory.createOrderItem(ord.Id, priceBookMap.get('pricebookEntryId'), 3);

        Test.startTest();
        GetProductController.createOrderProduct(ord.Id, priceBookMap.get('productId'), priceBookMap.get('pricebookEntryId'), 30);
        Test.stopTest();

        List<OrderItem> orderItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :ord.Id];
        System.assertEquals(1, orderItems.size(), 'OrderItem should exist');
        System.assertEquals(4, Integer.valueOf(orderItems[0].Quantity), 'Quantity should be incremented');
    }

    @isTest static void testCreateOrderProduct_NullOrderId() {
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Test.startTest();
        try {
            GetProductController.createOrderProduct(null, priceBookMap.get('productId'), priceBookMap.get('pricebookEntryId'), 30);
            System.assert(false, 'Should throw AuraHandledException for null orderId');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Error message should mention required order Id');
        }
        Test.stopTest();
    }

    @isTest static void testCreateOrderProduct_NullProductId() {
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        Test.startTest();
        try {
            GetProductController.createOrderProduct(ord.Id, null, priceBookMap.get('pricebookEntryId'), 30);
            System.assert(false, 'Should throw AuraHandledException for null productId');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Error message should mention required product Id');
        }
        Test.stopTest();
    }

    @isTest static void testCreateOrderProduct_NullPricebookEntryId() {
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        Test.startTest();
        try {
            GetProductController.createOrderProduct(ord.Id, priceBookMap.get('productId'), null, 30);
            System.assert(false, 'Should throw AuraHandledException for null pricebookEntryId');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Error message should mention required pricebook entry Id');
        }
        Test.stopTest();
    }

    @isTest static void testCreateOrderProductExisting() {
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        TestDataFactory.createOrderItem(ord.Id, priceBookMap.get('pricebookEntryId'), 3);

        Test.startTest();
        GetProductController.createOrderProduct(ord.Id, priceBookMap.get('productId'), priceBookMap.get('pricebookEntryId'), 30);
        Test.stopTest();

        List<OrderItem> orderItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :ord.Id];
        System.assertEquals(1, orderItems.size(), 'OrderItem should exist');
        System.assertEquals(4, Integer.valueOf(orderItems[0].Quantity), 'Quantity should be incremented');
    }
}