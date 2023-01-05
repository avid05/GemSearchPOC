import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, wire,track,api } from 'lwc';
import searchProducts from '@salesforce/apex/OrderFlowController.searchProducts';
import searchProductswithinRange from '@salesforce/apex/OrderFlowController.searchProductsWithinRange';
import { publish, MessageContext } from 'lightning/messageService';
import PRODUCT_LIST_UPDATE_MESSAGE from '@salesforce/messageChannel/ProductListUpdate__c';
import Id from '@salesforce/user/Id';
import addProductsToOpportunity from '@salesforce/apex/OrderFlowController.addProductsToOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProductList extends NavigationMixin(LightningElement) {
	userId = Id;
	searchTerm = '';
	products;
	value = 0;
	@api oppid;
	selectedProducts = [];
	selectedLabel;
	selectButtonItem;
	@wire(MessageContext) messageContext;
	@wire(searchProducts, {searchTerm: '$searchTerm'})
	loadProducts({ error, data }) {
			if (data) {
			this.products = data;
			const message = {
				products: data
				};
				publish(this.messageContext, PRODUCT_LIST_UPDATE_MESSAGE, message);
		} else if (error) {
			console.log(error);
			this.error = error;
		}
	}

	get options() {
		return [
				{ label: 'All', value: 0 },
				{ label: 'Within 500km', value: 500 },
				{ label: 'Within 1000km', value: 1000 },
				{ label: 'Within 2000km', value: 2000 },
				{ label: 'Within 3000km', value: 3000 },
				{ label: 'Within 4000km', value: 4000 },
				{ label: 'Within 5000km', value: 5000 },
			];
	}

	get hasResults() {
		return (this.products.length > 0);
	}

		
	handleSearchTermChange(event) {
		window.clearTimeout(this.delayTimeout);
		const searchTerm = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.searchTerm = searchTerm;
		}, 300);
	}

	get showlabel() {
		return (this.value != 0);
	}

	handleChange(event) {
			this.value = event.target.value;
			searchProductswithinRange({ searchRange: this.value,userId : this.userId })
				.then(result => {
					this.products = result;
					const message = {
						products: result
						};
						publish(this.messageContext, PRODUCT_LIST_UPDATE_MESSAGE, message);
				})
				.catch(error => {
					this.error = error;
				});
	}

	handleProductSelection(event) {
		const selectedProductId = event.target.value;

		if (event.target.checked) {
		this.selectedProducts.push(selectedProductId);
		} else {
		this.selectedProducts = this.selectedProducts.filter(productId => productId !== selectedProductId);
		}
		const selectedEvent = new CustomEvent("productselected", {
			detail: this.selectedProducts
		});
		this.dispatchEvent(selectedEvent);
	}

	/*handleAddToOpportunity() {
		window.alert('Add to Opport');
		window.alert(this.selectedProducts.length);

		addProductsToOpportunity({ opportunityId: this.oppid, productIds: this.selectedProducts })
		.then(() => {
				const evt = new ShowToastEvent({
					title: 'Toast Success',
					message: 'Products added to Opportunity successfully',
					variant: 'success',
					mode: 'dismissable'
				});
				this.dispatchEvent(evt);
			
			this.selectedProducts = [];
			this.error = 'Products added to Opportunity successfully';
		})
		.catch(error => {
			this.error = error.message;
		});
	}*/

}