import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import PRODUCT_LIST_UPDATE_MESSAGE from '@salesforce/messageChannel/ProductListUpdate__c';
export default class ProductMap extends LightningElement {
  mapMarkers = [];
  subscription = null;
  @wire(MessageContext)
  messageContext;


  connectedCallback() {
    this.subscription = subscribe(
        this.messageContext,
        PRODUCT_LIST_UPDATE_MESSAGE,
        (message) => {
            this.handleProductListUpdate(message);
        });
  }
  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }
  handleProductListUpdate(message) {
    this.mapMarkers = message.products.map(product => {
      const Latitude = product.Product_Mining_Location__Latitude__s;
      const Longitude = product.Product_Mining_Location__Longitude__s;
      return {
        location: { Latitude, Longitude },
        title: product.Name,
        description: `Location of Gem: ${Latitude}, ${Longitude}`,
        icon: 'custom:custom43'
      };
    });
  }
}