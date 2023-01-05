trigger Opportunity_Trigger on Opportunity (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	TriggerFactory.createAndExecuteHandler(ClsOpportunityHandler.class);
}