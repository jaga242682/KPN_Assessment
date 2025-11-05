import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableOrderProducts from '@salesforce/apex/GetOrderProductController.getAvailableOrderProducts';
import activateOrder from '@salesforce/apex/GetOrderProductController.activateOrder';

export default class AvailableProducts extends LightningElement {
    @track products = [];
    @track errorMessage = '';
    @api recordId; // <-- This automatically receives the current record Id
    @track isOrderActivated ;

    @wire(getAvailableOrderProducts, { orderId: '$recordId' })
    wiredProducts({ error, data }) {
    if (data) {
            
            this.products = data;
            this.errorMessage = undefined;
            if ((data && data.length > 0 && data[0].OrderStatus == 'Activated') || (data && data.length == 0)) {
                this.isOrderActivated = true;
            } else {
                this.isOrderActivated = false;
            }
        } else if (error) {
            // Normalize the error and show it in the UI + toast
            this.errorMessage = AvailableProducts.extractError(error);
            this.products = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading order products',
                    message: this.errorMessage,
                    variant: 'error'
                })
            );
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
            
            // Perform an action, like navigating to a record page
            activateOrder({ orderId: this.recordId })
                .then(() => {
                    this.isOrderActivated = true;
                    this.errorMessage = undefined;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Order Activated',
                            message: 'Order has been activated successfully.',
                            variant: 'success'
                        })
                    );
                    // Reload the page so other components refresh their data.
                    // Small timeout gives the toast a moment to render before navigation.
                    try {
                        window.setTimeout(() => {
                            window.location.reload();
                        }, 400);
                    } catch (e) {
                        // If reload isn't permitted in the environment, log and continue
                        // eslint-disable-next-line no-console
                        console.debug('Could not reload page', e);
                    }
                })
                .catch((err) => {
                    const message = AvailableProducts.extractError(err);
                    this.errorMessage = message;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Failed to activate order',
                            message: message,
                            variant: 'error'
                        })
                    );
                });
            
        }

    // Utility to normalize Apex/LWC errors into a readable string
    static extractError(error) {
        if (!error) return 'Unknown error';

        if (Array.isArray(error)) {
            return error.map(e => AvailableProducts.extractError(e)).join(', ');
        }

        if (error.body) {
            // pageErrors
            if (Array.isArray(error.body.pageErrors) && error.body.pageErrors.length) {
                return error.body.pageErrors.map(pe => pe.message).join(' ');
            }

            // fieldErrors
            if (error.body.fieldErrors) {
                const fieldMsgs = [];
                Object.keys(error.body.fieldErrors).forEach(field => {
                    error.body.fieldErrors[field].forEach(fe => fieldMsgs.push(fe.message));
                });
                if (fieldMsgs.length) return fieldMsgs.join(' ');
            }

            if (error.body.message) return error.body.message;
        }

        if (error.message) return error.message;

        try {
            return JSON.stringify(error);
        } catch (e) {
            return String(error);
        }
    }
}