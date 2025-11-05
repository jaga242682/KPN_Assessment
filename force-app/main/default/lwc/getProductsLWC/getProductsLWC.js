import { LightningElement, track, wire, api } from 'lwc';
import getAvailableProducts from '@salesforce/apex/GetProductController.getAvailableProducts';
import createOrderProducts from '@salesforce/apex/GetProductController.createOrderProduct';
import { RefreshEvent } from 'lightning/refresh';
import LightningAlert from 'lightning/alert';
import { updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AvailableProducts extends LightningElement {
    @track products = [];
    @track errorMessage = '';
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
            // Extract a user-friendly message from the wire error
            this.errorMessage = AvailableProducts.extractError(error);
            this.products = [];
            // Optionally show a toast for immediate feedback
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading products',
                    message: this.errorMessage,
                    variant: 'error'
                })
            );
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
            
            // Perform an action, like navigating to a record page
            createOrderProducts({ orderId: this.recordId, productId: row.ProductId, priceBookEntryId: row.Id, unitPrice: row.ListPrice })
                .then(() => {
                    // Notify record change so other components update
                    getRecordNotifyChange([{ recordId: this.recordId }]);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Product added',
                            message: 'Product added to the order successfully.',
                            variant: 'success'
                        })
                    );
                    // Reload the full page so other components refresh their data.
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
                            title: 'Failed to add product',
                            message: message,
                            variant: 'error'
                        })
                    );
                });
        }
    }

    // Utility to normalize Apex/LWC errors into a readable string
    static extractError(error) {
        if (!error) {
            return 'Unknown error';
        }

        // Apex wire error structure
        if (Array.isArray(error)) {
            return error.map(e => AvailableProducts.extractError(e)).join(', ');
        }

        // If error.body exists, extract message(s)
        if (error.body) {
            // Page errors
            if (Array.isArray(error.body.pageErrors) && error.body.pageErrors.length > 0) {
                return error.body.pageErrors.map(pe => pe.message).join(' ');
            }

            // Field errors
            if (error.body.fieldErrors) {
                const fieldMsgs = [];
                Object.keys(error.body.fieldErrors).forEach(field => {
                    error.body.fieldErrors[field].forEach(fe => fieldMsgs.push(fe.message));
                });
                if (fieldMsgs.length) return fieldMsgs.join(' ');
            }

            // Generic message
            if (error.body.message) return error.body.message;
        }

        // error.message for Promise rejections
        if (error.message) return error.message;

        // Fallback to stringified error
        return JSON.stringify(error);
    }
}