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
@isTest(SeeAllData=true)
private class GetOrderProductController_Test {

    @isTest static void testGetAvailableOrderProducts() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
        Order ord = TestDataFactory.createOrder(acc.Id, pbe.Pricebook2Id);
        TestDataFactory.createOrderItem(ord.Id, pbe.Id, 3);

        List<GetOrderProductController.ProductWrapper> wrapperList = new List<GetOrderProductController.ProductWrapper>();
        
        Test.startTest();
            // Call Apex method
            wrapperList = GetOrderProductController.getAvailableOrderProducts(ord.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, wrapperList.size(), 'OrderItems should exist');
    }

    @isTest static void testActivateOrder() {
        // Setup test data using factory
        Account acc = TestDataFactory.createAccount('Acme Inc');
        Product2 prod = TestDataFactory.createProduct('Widget');
        Pricebook2 pb = TestDataFactory.createCustomPricebook('Test Pricebook');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod, 150, pb.Id);
        Order ord = TestDataFactory.createOrder(acc.Id, pbe.Pricebook2Id);
        TestDataFactory.createOrderItem(ord.Id, pbe.Id, 3);
        
        Test.startTest();
            // Call Apex method
            GetOrderProductController.activateOrder(ord.Id);
        Test.stopTest();

        List<Order> orders = [SELECT Id FROM Order WHERE Id = :ord.Id and Status = 'Activated'];
        System.Assert.areEqual(1, orders.size(), 'Order should be activated');
    }
}