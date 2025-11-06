
# KPN Assessment Salesforce Project

This Salesforce DX project implements a custom Order and Product management solution using Lightning Web Components (LWC) and Apex. It demonstrates best practices for error handling, modular test data creation, and user-friendly UI feedback.

## Features

- **Order and Product Management**: Create, view, and activate Orders and related Products.
- **Lightning Web Components**:
	- `getProductsLWC`: Displays available products for an order and allows adding products to the order.
	- `orderProductsLWC`: Displays order products and allows activating the order.
- **Apex Controllers**:
	- `GetProductController`: Exposes product selection and order item creation logic to LWC.
	- `GetOrderProductController`: Exposes order product listing and order activation logic to LWC.
- **Robust Error Handling**: All Apex controllers use input validation, try/catch, and `AuraHandledException` to provide user-friendly error messages to the UI.
- **Test Data Factory**: Centralized test data creation for reliable and maintainable Apex tests.
- **User Feedback**: LWC components display toast notifications and error messages for all server-side errors.

## Project Structure

- `force-app/main/default/classes/`
	- Apex controllers, utility classes, and test classes
- `force-app/main/default/lwc/`
	- Lightning Web Components for product and order management
- `manifest/`
	- `package.xml` for metadata deployment
- `config/`
	- Scratch org definition


## Key Apex Classes & Design Decisions


## Apex Controller Methods Explained

### GetProductController.cls

- **getAvailableProducts(orderId)**
	- Returns a list of products that can be added to the specified order.
	- Validates the input, queries active products and pricebook entries for the order’s pricebook, and returns product details.

- **createOrderProduct(orderId, pricebookEntryId, quantity)**
	- Adds a product to the order as an order item.
	- Validates all inputs, creates a new OrderItem, and handles errors with AuraHandledException for user-friendly messages.

**Design Decisions:**
	- Using the orderId, I can find the PriceBookId.
	- Then search for all the available pricebook entries in that PriceBook
    -On click of the add button, I am searching for the orderIterm filterby productid. If there is an exsting record, increase the quantiy. Otherwise create a orderItem with quantity 1

### GetOrderProductController.cls

- **getAvailableOrderProducts(orderId)**
	- Returns a list of products already added to the specified order.
	- Validates the input, queries OrderItem records for the order, and returns order product details.

- **activateOrder(orderId)**
	- Activates the specified order.
	- Validates the input, updates the order’s status to “Activated”, and handles errors with AuraHandledException for user-friendly messages.

**Design Decisions:**
	- In the requirement, it was mentioed to update the status in both order and orderItem. But as per my understanding we dont need a separe status for order item. As a child record it should depend on the status of the parent object that is order record
	- 

- **TestDataFactory.cls**
	- Utility for creating all test data (Account, Product2, Pricebook, Order, OrderItem, etc.).
	- **Design Decisions:**
		- Centralizes test data creation for maintainability and DRY tests.
		- Allows tests to be independent of org data and repeatable in any environment.

- **QueryUtility.cls**
	- Utility for SOQL queries used by controllers.
	- **Design Decisions:**
		- Encapsulates all SOQL logic for reuse and to avoid duplication in controllers.
		- Makes it easier to update queries in one place if data model changes.


## Key Lightning Web Components & Design Decisions

- **getProductsLWC**
	- Shows available products for an order, allows adding products, and displays errors/toasts.
	- **Design Decisions:**
		- Uses `@wire` for reactive product loading and imperative Apex for add-to-order actions.
		- Handles all errors from Apex using a static error extraction helper, ensuring user-friendly messages.
		- On successful add, reloads the page to ensure all related components (including orderProductsLWC) reflect the latest data.
		- Uses toast notifications for all user feedback (success and error).
		- Disables add button for products if the order is already activated.

- **orderProductsLWC**
	- Shows order products, allows activating the order, and displays errors/toasts.
	- **Design Decisions:**
		- Uses `@wire` for reactive order product loading and imperative Apex for order activation.
		- Handles all errors from Apex using a static error extraction helper, ensuring user-friendly messages.
		- On successful activation, reloads the page to ensure UI reflects the new order status.
		- Uses toast notifications for all user feedback (success and error).
		- Dynamically disables the Activate Order button if the order is already activated or has no products.

## Error Handling

- All Apex methods validate input and throw `AuraHandledException` for user-facing errors.
- LWC components extract and display error messages from Apex exceptions.
- Full page reload is used after certain actions to ensure UI stays in sync.

## Improvements

- on click of add and activate order, i am refreshing the whole page. I need to find a way to update only these two components
- Make the look and feel of the UI more attractive
- Give option to remove or modify the order products component

## How to Deploy and Test

1. **Authorize a Dev Hub and Create a Scratch Org**
	 ```sh
	 sfdx auth:web:login --setdefaultdevhubusername
	 sfdx force:org:create -s -f config/project-scratch-def.json -a KPNAssessmentScratch
	 ```
2. **Push Source to Scratch Org**
	 ```sh
	 sfdx force:source:push
	 ```
3. **Assign Permission Set (if needed)**
	 ```sh
	 sfdx force:user:permset:assign -n <PermissionSetName>
	 ```
4. **Open the Org**
	 ```sh
	 sfdx force:org:open
	 ```
5. **Run Apex Tests**
	 ```sh
	 sfdx force:apex:test:run --resultformat human --wait 10
	 ```

## Usage

- Navigate to an Order record page in your org.
- The `getProductsLWC` and `orderProductsLWC` components should be available for placement on Lightning pages.
- Add products to an order and activate the order using the UI.
- Errors and success messages will be shown as toast notifications.

## Best Practices Used

- Input validation and error handling in all Apex controllers
- Use of `AuraHandledException` for user-friendly error messages
- Centralized test data factory for maintainable tests
- LWC error extraction and toast notifications
- Modular, reusable Apex and LWC code

## References

- [Salesforce Lightning Web Components](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
