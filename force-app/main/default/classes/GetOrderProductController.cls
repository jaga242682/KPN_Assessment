public with sharing class GetOrderProductController {
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getAvailableOrderProducts(Id orderId) {
        // Query order products from the order id
        List<OrderItem> products = QueryUtility.getOrderProducts(orderId);

        List<ProductWrapper> wrapperList = new List<ProductWrapper>();
        for(OrderItem p : products) {
            wrapperList.add(new ProductWrapper(p.Id, p.Product2.Name, p.UnitPrice, p.Quantity, p.TotalPrice, p.Order.Status));
    
        }
        return wrapperList;
    }

    @AuraEnabled
    public static void activateOrder(Id orderId) {
        // Change the status of the order to Activated
        Order order = new Order(Id = orderId, Status = 'Activated');
        update order;

        // Change the status of the orderitem to activated
        /*List<OrderItem> orderItems = QueryUtility.getOrderProducts(orderId);

        for(OrderItem p : orderItems) {
            p.Status__c = 'Activated';
        }
        update orderItems;*/
    }

    // Wrapper class to structure data for LWC
    public class ProductWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal UnitPrice;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public Decimal TotalPrice;
        @AuraEnabled public String OrderStatus;

        public ProductWrapper(String Id, String Name, Decimal UnitPrice, Decimal Quantity, Decimal TotalPrice, String OrderStatus) {
            this.Id = Id;
            this.Name = Name;
            this.UnitPrice = UnitPrice;
            this.Quantity = Quantity;
            this.TotalPrice = TotalPrice;
            this.OrderStatus = OrderStatus;
        }
    }
}