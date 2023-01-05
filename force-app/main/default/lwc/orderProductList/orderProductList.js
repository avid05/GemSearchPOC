import { LightningElement,api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityLineItems from '@salesforce/apex/OrderFlowController.getOpportunityLineItems';
import deleteOpportunityLineItem from '@salesforce/apex/OrderFlowController.deleteOpportunityLineItem';
export default class OrderProductList extends LightningElement {
    opportunityLineItems;
    @api oppid;
    @api products;
    isLoading = false;
    rowId;
    @api normalproducts;
    @api chargeproducts;


    customActions = [
        { label: 'Delete', name: 'delete',iconName: 'utility:delete'}
    ]

    ncolumns = [
        { label: 'Id', fieldName: 'Id'},
        { label: 'Name', fieldName: 'Name' },
        { label: 'Unit Price', fieldName: 'UnitPrice'},
        { label: 'Quantity', fieldName: 'Quantity'},
        { label: 'Total Price', fieldName: 'TotalPrice'},
        {
            type: 'action',
            typeAttributes: {
                rowActions: this.customActions,
                menuAlignment: 'right'
            }
        }
    ];

     ccolumns = [
        { label: 'Id', fieldName: 'Id'},
        { label: 'Name', fieldName: 'Name' },
        { label: 'Unit Price', fieldName: 'UnitPrice'},
        { label: 'Quantity', fieldName: 'Quantity'},
        { label: 'Total Price', fieldName: 'TotalPrice'},
    ];

    connectedCallback(){
        this.fetchlineItems();
    }

    get hasnormalProducts() {
		return (this.normalproducts?.length > 0);
	}

    get hasChargeProducts() {
		return (this.chargeproducts?.length > 0);
	}

    handleFilter() {
        this.normalproducts = this.products.filter(item => item.Product2.Product_Type__c.includes('Sell'));
        this.chargeproducts = this.products.filter(item => item.Product2.Product_Type__c.includes('Charge'));
      }

    @api
    fetchlineItems(){
        this.isLoading = true;
        getOpportunityLineItems({ opportunityId: this.oppid })
            .then(result => {
                this.products = result;
                this.handleFilter();
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
            });
    }
    
    /*handleDelete(event) {
        const opportunityLineItemId = event.target.dataset.opportunityLineItemId;
        deleteRecord(opportunityLineItemId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunity line item deleted',
                        variant: 'success',
                    })
                );
                // Refresh the list of opportunity line items
                this.getOpportunityLineItems();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting opportunity line item',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }*/

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if(actionName == 'delete'){
            this.delRow(row);
        }
    }

    delRow(currentRow) {
        this.isLoading = true;
        deleteOpportunityLineItem({ oppLineItemId: currentRow.Id })
        .then(result => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: currentRow.Name + ' deleted.',
                variant: 'success'
            }));
            this.fetchlineItems();
        }).catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: JSON.stringify(error),
                variant: 'error'
            }));
        });
    }

}