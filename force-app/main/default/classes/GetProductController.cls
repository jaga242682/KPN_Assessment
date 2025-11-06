public with sharing class GetProductController {

    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getAvailableProducts(Id orderId) {
        // Validate input
        if (orderId == null) {
            throw new AuraHandledException('Order Id is required.');
        }

        try {
            // Query order and guard against missing data
            List<Order> orders = QueryUtility.getOrders(orderId);
            if (orders == null || orders.isEmpty()) {
                return new List<ProductWrapper>();
            }

            Order orderObj = orders[0];
            Id pricebookId = orderObj.Pricebook2Id;
            String orderStatus = orderObj.Status;

            if (pricebookId == null) {
                // No pricebook associated with order; nothing to return
                //return new List<ProductWrapper>();
                throw new AuraHandledException('Add price book into the order to select products.');
            }

            List<PriceBookEntry> products = QueryUtility.getPriceBookEntries(pricebookId);
            List<ProductWrapper> wrapperList = new List<ProductWrapper>();

            if (products == null || products.isEmpty()) {
                return wrapperList;
            }

            for (PriceBookEntry p : products) {
                String pName = (p.Product2 != null) ? p.Product2.Name : null;
                wrapperList.add(new ProductWrapper(String.valueOf(p.Id), String.valueOf(p.Product2Id), pName, p.UnitPrice, orderStatus));
            }

            return wrapperList;
        } catch (QueryException qex) {
            System.debug('QueryException in getAvailableProducts: ' + qex);
            throw new AuraHandledException('Unable to retrieve products for the order.');
        } catch (AuraHandledException aex) {
            // Preserve intentional user-facing exceptions
            System.debug('AuraHandledException in getAvailableProducts: ' + aex);
            throw aex;
        } catch (Exception ex) {
            System.debug('Exception in getAvailableProducts: ' + ex);
            throw new AuraHandledException('An unexpected error occurred while retrieving products.');
        }
    }

    @AuraEnabled
    public static void createOrderProduct(Id orderId, Id productId, Id priceBookEntryId, Decimal unitPrice) {
        // Validate inputs
        if (orderId == null) {
            throw new AuraHandledException('Order Id is required.');
        }
        if (productId == null) {
            throw new AuraHandledException('Product Id is required.');
        }
        if (priceBookEntryId == null) {
            throw new AuraHandledException('Pricebook Entry Id is required.');
        }

        try {
            // Query existing order items for this product
            List<OrderItem> existingProducts = QueryUtility.getOrderProductsById(productId);

            List<OrderItem> newProducts = new List<OrderItem>();
            if (existingProducts == null || existingProducts.isEmpty()) {
                OrderItem newItem = new OrderItem();
                newItem.PricebookEntryId = priceBookEntryId;
                newItem.OrderId = orderId;
                newItem.Quantity = 1;
                newItem.UnitPrice = unitPrice;

                newProducts.add(newItem);
            } else {
                // Update the quantity on the existing item
                OrderItem newItem = new OrderItem();
                newItem.Id = existingProducts[0].Id;
                newItem.Quantity = existingProducts[0].Quantity + 1;

                newProducts.add(newItem);
            }

            if (!newProducts.isEmpty()) {
                try {
                    upsert newProducts;
                } catch (DmlException dmlex) {
                    System.debug('DmlException in createOrderProduct upsert: ' + dmlex);
                    throw new AuraHandledException('Failed to create or update order product: ' + dmlex.getMessage());
                }
            }
        } catch (Exception ex) {
            System.debug('Exception in createOrderProduct: ' + ex);
            throw new AuraHandledException('An unexpected error occurred while creating the order product.');
        }
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