import { LightningElement,api } from 'lwc';
import addProductsToOpportunity from '@salesforce/apex/OrderFlowController.addProductsToOpportunity';

export default class OrderFlow extends LightningElement {

    @api recordId;
    productsSelection;
    currentStep = '1';
    isLoading = false;
    olis;
    error;
 
    get isStepOne() {
        return this.currentStep === "1";
    }
 
    get isStepTwo() {
        return this.currentStep === "2";
    }
 
    get isEnableNext() {
        return this.currentStep != "2" && this.productsSelection?.length > 0;
    }
 
    get isEnablePrev() {
        return this.currentStep != "1";
    }

    hanldeProductSelectionChange(event) {
        this.productsSelection = event.detail;
    }
 
    handleNext(){

        this.isLoading = true;
        this.handleAddToOpportunity();
    }
 
    handlePrev(){
        if(this.currentStep == "3"){
            this.currentStep = "2";
        }
        else if(this.currentStep = "2"){
            this.currentStep = "1";
        }
    }
 
     handleAddToOpportunity() {

		addProductsToOpportunity({ opportunityId: this.recordId, productIds: this.productsSelection })
		.then(() => {
			this.isLoading = false;
            if(this.currentStep == "1"){
                this.currentStep = "2";
            }
			this.productsSelection = [];
		})
		.catch(error => {
			this.error = error.message;
		});
	}
}