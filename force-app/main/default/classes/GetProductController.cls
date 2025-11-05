public with sharing class GetProductController {

    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getAvailableProducts(Id orderId) {
        // Query pricebook id from the order
        Order orderObj = QueryUtility.getOrders(orderId)[0];
        Id pricebookId = orderObj.Pricebook2Id;
        String orderStatus = orderObj.Status;

        List<PriceBookEntry> products = QueryUtility.getPriceBookEntries(pricebookId);

        List<ProductWrapper> wrapperList = new List<ProductWrapper>();
        for(PriceBookEntry p : products) {
            wrapperList.add(new ProductWrapper(p.Id, p.Product2Id, p.Product2.Name, p.UnitPrice, orderStatus));
        }
        return wrapperList;
    }

    @AuraEnabled
    public static void createOrderProduct(Id orderId, Id productId, Id priceBookEntryId, Decimal unitPrice) {
        // Query order products from the product id
        List<OrderItem> existingProducts = QueryUtility.getOrderProductsById(productId);

        List<OrderItem> newProducts = new List<OrderItem>();
        if (existingProducts.size() == 0) {
            OrderItem newItem = new OrderItem();
            newItem.PricebookEntryId = priceBookEntryId;
            newItem.orderId = orderId;
            newItem.Quantity = 1;
            newItem.UnitPrice = unitPrice;

            newProducts.add(newItem);
        }
        else {
            OrderItem newItem = new OrderItem();
            newItem.Id = existingProducts[0].Id;
            newItem.Quantity = existingProducts[0].Quantity + 1;

            newProducts.add(newItem);
        }

        upsert newProducts;
    }

    // Wrapper class to structure data for LWC
    public class ProductWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String ProductId;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal ListPrice;
        @AuraEnabled public String OrderStatus;

        public ProductWrapper(String Id, String ProductId, String Name, Decimal ListPrice, String OrderStatus) {
            this.Id = Id;
            this.ProductId = ProductId;
            this.Name = Name;
            this.ListPrice = ListPrice;
            this.OrderStatus = OrderStatus;
        }
    }
}