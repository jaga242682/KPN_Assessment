import { LightningElement, track, wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableOrderProducts from '@salesforce/apex/GetOrderProductController.getAvailableOrderProducts';    
import activateOrder from '@salesforce/apex/GetOrderProductController.activateOrder';  
import LightningAlert from "lightning/alert";

export default class AvailableProducts extends LightningElement {
    @track products = [];
    @track error;
    @api recordId; // <-- This automatically receives the current record Id
    @track isOrderActivated ;

    @wire(getAvailableOrderProducts, { orderId: '$recordId' })
    wiredProducts({ error, data }) {
        if (data) {
            /*console.log(data);
            LightningAlert.open({
            message: data[0].Name,
            theme: "error", // a red theme intended for error states
            label: "Error!", // this is the header text
            });*/
            
            this.products = data;
            this.error = undefined;
            if(data[0].OrderStatus == 'Activated'){
                this.isOrderActivated = true;
            }
            else{
                this.isOrderActivated = false;
            }
        } else if (error) {
            this.error = error;
            this.products = [];
        }
    }

    // Optional: columns for lightning-datatable
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Unit Price', fieldName: 'UnitPrice' , type: 'currency', typeAttributes: { currencyCode: 'EUR', align: 'left'}},
        { label: 'Quantity', fieldName: 'Quantity' },
        { label: 'Total Price', fieldName: 'TotalPrice' , type: 'currency', typeAttributes: { currencyCode: 'EUR'}}
        
    ];
    

    // Handle order activation
    
    handleActivateOrder(event) {
            //const actionName = event.detail.action.name;
            //const row = event.detail.row;
    
            
            // Perform an action, like navigating to a record page
            activateOrder({orderId: this.recordId})
            .then(() => {
                new ShowToastEvent("Success!", "Order has been activated", "No error!");
                this.isOrderActivated = true;
            })
            .catch(error => {
                new ShowToastEvent("Error!", "error", "error");
                this.error = error;
            });
            //getRecordNotifyChange([{recordId: this.recordId}]);
            //this.dispatchEvent(new RefreshEvent());
            
        }
}