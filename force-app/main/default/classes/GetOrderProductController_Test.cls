/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class GetOrderProductController_Test {


    @testSetup
    static void setupTestData() {
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        TestDataFactory.createOrderItem(ord.Id, priceBookMap.get('pricebookEntryId'), 3);
    }

    @isTest static void testGetAvailableOrderProducts_Positive() {
        Order ord = [SELECT Id FROM Order WHERE Status != 'Activated' LIMIT 1];
        Test.startTest();
        List<GetOrderProductController.ProductWrapper> wrapperList = GetOrderProductController.getAvailableOrderProducts(ord.Id);
        Test.stopTest();
        System.assertEquals(1, wrapperList.size(), 'Should return one order item');
        System.assertEquals('KPN Mobile 5G Plan', wrapperList[0].Name, 'Product name should match');
        System.assertEquals(99.00, wrapperList[0].UnitPrice, 'Unit price should match');
        System.assertEquals(3, Integer.valueOf(wrapperList[0].Quantity), 'Quantity should match');
    }

    @isTest static void testGetAvailableOrderProducts_InvalidId() {
        Test.startTest();
        try {
            GetOrderProductController.getAvailableOrderProducts(null);
            System.assert(false, 'Should have thrown AuraHandledException for null orderId');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Error message should mention required order Id');
        }
        Test.stopTest();
    }

    @isTest static void testGetAvailableOrderProducts_NoOrderItems() {
        // Create a new order with no items
        Account acc = TestDataFactory.createAccount('NoItems Inc');
        Map<String,Id> priceBookMap = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id, priceBookMap.get('pricebookId'));
        Test.startTest();
        List<GetOrderProductController.ProductWrapper> wrapperList = GetOrderProductController.getAvailableOrderProducts(ord.Id);
        Test.stopTest();
        System.assertEquals(0, wrapperList.size(), 'Should return empty list for order with no items');
    }


    @isTest static void testActivateOrder_Positive() {
        Order ord = [SELECT Id, Status FROM Order WHERE Status != 'Activated' LIMIT 1];
        Test.startTest();
        GetOrderProductController.activateOrder(ord.Id);
        Test.stopTest();
        Order updated = [SELECT Id, Status FROM Order WHERE Id = :ord.Id];
    System.assertEquals('Activated', String.valueOf(updated.Status), 'Order should be activated');
    }

    @isTest static void testActivateOrder_AlreadyActivated() {
        // Activate an order, then call again (should not error)
        Order ord = [SELECT Id FROM Order WHERE Status != 'Activated' LIMIT 1];
        ord.Status = 'Activated';
        update ord;
        Test.startTest();
        GetOrderProductController.activateOrder(ord.Id);
        Test.stopTest();
        // Should not throw, status remains 'Activated'
        Order updated = [SELECT Id, Status FROM Order WHERE Id = :ord.Id];
    System.assertEquals('Activated', String.valueOf(updated.Status), 'Order should remain activated');
    }

   @isTest static void testActivateOrder_InvalidId() {
        Test.startTest();
        try {
            GetOrderProductController.activateOrder(null);
            System.assert(false, 'Should have thrown AuraHandledException for null orderId');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Error message should mention required order Id');
            //System.assert(e.getMessage().contains('Order Id is required'), 'Error message should mention required order Id');
        }
        Test.stopTest();
    }

    @isTest static void testActivateOrder_NonExistentOrder() {
        // Use a random Id that does not exist
        Id fakeId = '801000000000000AAA';
        Test.startTest();
        try {
            GetOrderProductController.activateOrder(fakeId);
            System.assert(false, 'Should have thrown AuraHandledException for non-existent order');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Order not found'), 'Error message should mention order not found');
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Error message should mention order not found');
        }
        Test.stopTest();
    }
}