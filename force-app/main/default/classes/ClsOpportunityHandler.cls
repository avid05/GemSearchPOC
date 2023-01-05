/**
 * Class ClsOpportunityHandler
 *
 * Trigger Handler for the Lead sObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class ClsOpportunityHandler implements ITrigger{


    /**
     * bulkBefore
     *
     * This method is called for before trigger
     */
    public void bulkBefore() {
        if(Trigger.isInsert) {
        }
        if(Trigger.isUpdate){
        }

    }

    public void bulkAfter()	{

    }

    public void beforeInsert(SObject so) {
    }

    public void beforeUpdate(SObject oldSo, SObject so) {

    }
    
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so) {
    }

    public void afterInsert(SObject so) {
    }

    public void afterUpdate(SObject oldSo, SObject so) {
    }

    public void afterDelete(SObject so) {
    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {
    }
}