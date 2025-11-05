import { LightningElement, track, wire,api } from 'lwc';
import getAvailableProducts from '@salesforce/apex/GetProductController.getAvailableProducts';
import createOrderProducts from '@salesforce/apex/GetProductController.createOrderProduct';
import { RefreshEvent } from 'lightning/refresh';
import LightningAlert from "lightning/alert";
import { updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class AvailableProducts extends LightningElement {
    @track products = [];
    @track error;
    @api recordId; // <-- This automatically receives the current record Id
    @track isOrderActivated;

    @wire(getAvailableProducts, { orderId: '$recordId' })
    wiredProducts({ error, data }) {
        if (data) {
            /*if(data[0].OrderStatus == 'Activated'){
                this.isOrderActivated = true;
            }
            else{
                this.isOrderActivated = false;
            }*/
           
            this.products = data;
            this.error = undefined;

            this.products = data.map(item => ({
            ...item,
            isDisabled: item.OrderStatus === 'Activated' // disable if inactive
            
        }));

        
            
        } else if (error) {
            this.error = error;
            this.products = [];
        }
    }

    // Optional: columns for lightning-datatable
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'List Price', fieldName: 'ListPrice', type: 'currency', typeAttributes: { currencyCode: 'EUR'}},
        {
            type: 'button',
            typeAttributes: {
                label: 'Add',
                name: 'add',
                title: 'Add product to order',
                variant: 'brand',
                iconName: 'utility:add',
                disabled: { fieldName: 'isDisabled' }
            }
        }
    ];

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'add') {
            var testing = this.recordId + '  ' + row.ProductId  + '   ' + row.ListPrice+ '  ' + row.Id;
            /*console.log(testing);+
            LightningAlert.open({
            message: testing,
            theme: "error", // a red theme intended for error states
            label: "Error!", // this is the header text
            });*/
            // Perform an action, like navigating to a record page
            createOrderProducts({orderId: this.recordId, productId: row.ProductId, priceBookEntryId: row.Id, unitPrice: row.ListPrice })
            //getRecordNotifyChange([{recordId: this.recordId}]);
            //this.dispatchEvent(new RefreshEvent());
            //eval("$A.get('e.force:refreshView').fire()");
            getRecordNotifyChange([{ recordId: this.recordId }]);
                console.log('Record updated and UI refreshed!');
        }
    }
}