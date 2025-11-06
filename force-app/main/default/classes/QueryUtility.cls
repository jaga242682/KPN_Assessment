public with sharing class QueryUtility {
    //get list of order products from order
    public static List<OrderItem> getOrderProducts(id orderId) {
        return [SELECT Id, Product2.Name,Quantity, UnitPrice, TotalPrice,Order.Status FROM OrderItem WHERE OrderId =: orderId];
    }

    //get list of order products from product id
    public static List<OrderItem> getOrderProductsById(id productId) {
        return [SELECT Id, Product2.Name,Quantity, UnitPrice, TotalPrice FROM OrderItem WHERE Product2Id =: productId limit 1];
    }

    //get pricebook id from order
    public static List<Order> getOrders(id orderId) {
        return [SELECT Id, Pricebook2Id, Status FROM Order WHERE Id = :orderId  LIMIT 1];
    }

    //get pricebook entries from pricebookid
    public static List<PricebookEntry> getPriceBookEntries(id Pricebook2Id) {
        return [SELECT Id, Product2Id, Product2.Name,UnitPrice FROM PricebookEntry WHERE Pricebook2Id=:Pricebook2Id];
    }
}