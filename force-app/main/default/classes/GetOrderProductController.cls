public with sharing class GetOrderProductController {
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getAvailableOrderProducts(Id orderId) {
        // Validate input
        if (orderId == null) {
            throw new AuraHandledException('Order Id is required.');
        }

        try {
            // Query order products from the order id
            List<OrderItem> products = QueryUtility.getOrderProducts(orderId);

            List<ProductWrapper> wrapperList = new List<ProductWrapper>();
            if (products == null || products.isEmpty()) {
                return wrapperList;
            }

            for (OrderItem p : products) {
                // Guard against null related records
                String prodName = (p.Product2 != null) ? p.Product2.Name : null;
                String orderStatus = (p.Order != null) ? p.Order.Status : null;

                wrapperList.add(new ProductWrapper(String.valueOf(p.Id), prodName, p.UnitPrice, p.Quantity, p.TotalPrice, orderStatus));
            }

            return wrapperList;
        } catch (Exception ex) {
            // Log and return a user-friendly error to the client
            System.debug('Error in getAvailableOrderProducts: ' + ex);
            throw new AuraHandledException('Unable to retrieve order products. ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static void activateOrder(Id orderId) {
        // Input validation
        if (orderId == null) {
            throw new AuraHandledException('Order Id is required.');
        }

        try {
            ord.Status = 'Activated';
            update ord;

            // If you later need to change OrderItem status, re-enable and handle possible DML failures.
            /*List<OrderItem> orderItems = QueryUtility.getOrderProducts(orderId);

            for (OrderItem p : orderItems) {
                p.Status__c = 'Activated';
            }
            update orderItems;*/
        } catch (DmlException dmlex) {
            System.debug('DmlException in activateOrder: ' + dmlex);
            throw new AuraHandledException('Failed to activate order: ' + dmlex.getMessage());
        } catch (Exception ex) {
            System.debug('Exception in activateOrder: ' + ex);
            throw new AuraHandledException('An unexpected error occurred while activating the order.');
        }
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