public with sharing class OrderFlowController {
        
        @AuraEnabled(cacheable=true scope='global')
        public static Product2[] getAllProducts() {
            return [
                SELECT
                    Id,
                    Name,
                    ProductCode,
                    Family,
                    Product_Type__c,
                    Description,
                    Charge_Category__c,
                    Product_Mining_Location__Latitude__s,
                    Product_Mining_Location__Longitude__s
                FROM Product2
                WHERE Product_Type__c ='Sellable Products'
                AND IsActive = true
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 50
            ];
        }
    
        @AuraEnabled(cacheable=true scope='global')
        public static Product2[] searchProducts(String searchTerm) {
            // Return all products when no search term
            searchTerm = searchTerm.trim();
            if (searchTerm == '') {
                return getAllProducts();
            }
            // Prepare query paramters
            searchTerm = '%' + searchTerm + '%';
            // Execute search query
            return [
                SELECT
                    Id,
                    Name,
                    ProductCode,
                    Family,
                    Product_Type__c,
                    Description,
                    Charge_Category__c,
                    Product_Mining_Location__Latitude__s,
                    Product_Mining_Location__Longitude__s
                FROM Product2
                WHERE Name LIKE :searchTerm
                AND Product_Type__c ='Sellable Products'
                AND IsActive = true
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 50
            ];
        }
    
        @AuraEnabled(cacheable=true scope='global')
        public static Product2[] searchProductsWithinRange(integer searchRange,Id userId) {
            system.debug('searchRange is ' +searchRange);
            system.debug('userId is ' +userId);
            user u = [select id, name,Location__c from User where id=:userId LIMIT 1];
            if (searchRange == 0) {
                return getAllProducts();
            }
            return[
                SELECT
                    Id,
                    Name,
                    ProductCode,
                    Family,
                    Product_Type__c,
                    Description,
                    Charge_Category__c,
                    Product_Mining_Location__c,
                    Product_Mining_Location__Latitude__s,
                    Product_Mining_Location__Longitude__s
                FROM Product2
                WHERE DISTANCE(Product_Mining_Location__c,:u.Location__c,'km') < :searchRange
                AND Product_Type__c ='Sellable Products'
                AND IsActive = true
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 50
            ];
            
        }
        
        @AuraEnabled
        public static void addProductsToOpportunity(Id opportunityId, List<Id> productIds) {
            system.debug('oppidd is ' +opportunityId);
            system.debug('productIds is ' +productIds);
            try
            {
                 List<Product2> products = [
                    SELECT
                    Id,
                    Name,
                    Description,
                    IsActive,
                    ProductCode,
                    Charge_Category__c,
                    Product_Type__c
                    FROM Product2
                    WHERE Id IN :productIds
                    WITH SECURITY_ENFORCED
                ];
                
                /*Set<String> chargesToBeAddedToOpp = checkForChargeProductsOnOpportunity(products,opportunityId);
                system.debug('chargesToBeAddedToOpp is ' +chargesToBeAddedToOpp);

                Opportunity opp = getoppApliedCharges(opportunityId);
        		Map<String,Product2> chargeKeyProductMap = getChargeProduct();
                
                //Only add the charge to opportunity if it is not already existing
                for(string charge : chargesToBeAddedToOpp){
                                     system.debug('charge is ' +charge);

                    if(!opp.Has_Insurance_Charge__c  && charge == 'insurance'){
                        products.add(chargeKeyProductMap.get(charge));
                        opp.Has_Insurance_Charge__c  = true;
                        system.debug('insurance added' +products);

                    }
                    if(!opp.Has_Equipment_Charge__c && charge == 'equipment'){
                        products.add(chargeKeyProductMap.get(charge));
                        opp.Has_Equipment_Charge__c = true;
                         system.debug('Equip is ' +productIds);
                    }
                    if(!opp.Has_Pollution_Charge__c && charge == 'pollution'){
                        products.add(chargeKeyProductMap.get(charge));
                        opp.Has_Pollution_Charge__c = true;
                         system.debug('Polluton is ' +productIds);
                    }
                }*/
                
                Map<Id, List<Product2>> productIdChargeProductMap = checkForChargeProducts(products);
                system.debug('productIdChargeProductMap is ' +productIdChargeProductMap);
               
                // Create a list of OLIs to insert
                List<OpportunityLineItem> olisToInsert = new List<OpportunityLineItem>();
                for (Product2 product : products) {
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = opportunityId;
                    oli.Product2Id = product.Id;
                    oli.Quantity = 1;
                    oli.UnitPrice = 50;
                    olisToInsert.add(oli);
                }

                for(Id mainProductID : productIdChargeProductMap.keySet()){
                    for (Product2 product : productIdChargeProductMap.get(mainProductID)) {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.OpportunityId = opportunityId;
                        oli.Product2Id = product.Id;
                        oli.Linked_Product_ID__c = mainProductID;
                        oli.Quantity = 1;
                        oli.UnitPrice = 50;
                        olisToInsert.add(oli);
                    }
                }
        
                // Insert the OLIs
                insert olisToInsert;
                //update opp;
            }
            catch(Exception e)
            {
                system.debug('Error is ' +e.getMessage());

            }
        }
    
        @AuraEnabled
        public static List<OpportunityLineItem> getOpportunityLineItems(Id opportunityId) {
            system.debug('opportunityId is ' +opportunityId);
            return [
                SELECT
                Id,
                Name,
                Product2.ProductCode,
                UnitPrice,
                Quantity,
                TotalPrice,
                Product2.Product_Type__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
                WITH SECURITY_ENFORCED
            ];
        }
    
        public static void checkChargeProductsForOpportunity(List<Id> oppIDList){
		
            List<OpportunityLineItem> listOppLineItem = [Select id, name,OpportunityId,Product2Id 
                                                         from OpportunityLineItem
                                                         where OpportunityId IN :oppIDList
                                                         WITH SECURITY_ENFORCED];
            Map<Id, List<Id>> mapOppIDListProductIDMap = new Map<Id, List<Id>>();
            for(opportunityLineItem oli : listOppLineItem){
                
                if(mapOppIDListProductIDMap.containsKey(oli.OpportunityId)){
                     mapOppIDListProductIDMap.get(oli.OpportunityId).add(oli.Product2Id);
                }
                else{
                   mapOppIDListProductIDMap.put(oli.OpportunityId, new List<Id>{oli.Product2Id});
                }
            }
        }
    
        public static opportunity getoppApliedCharges(id oppId){
            return [select id, name, Has_Pollution_Charge__c , Has_Equipment_Charge__c , Has_Insurance_Charge__c
                    from Opportunity
                    where id=:oppId
                    WITH SECURITY_ENFORCED];
        }
		
    	/*
        public static Set<String> checkForChargeProductsOnOpportunity(List<Product2> selectedProducts,Id OppId){
            Set<String> applicableChargeProducts =  new Set<String>();
            Map<Id,Set<String>> productIDRelatedChargeProductsMap =  new Map<Id,Set<String>>();
            Map<Id,Set<String>> OppIDRelatedChargeProductsMap =  new Map<Id,Set<String>>();
			Set<String> applicableCharges = new Set<String>();
            for(Product2 product : selectedProducts)
            {
                Set<String> applicableChargeProductsPerProduct =  new Set<String>();
                HttpRequest httpReq = new HttpRequest();
                    httpReq.setHeader('Content-Type','application/json');
                    httpReq.setEndpoint('callout:ChargesMockAPI');
                    httpReq.setMethod('POST');
                    List<requestStructure> rsList = new List<requestStructure>();
                    requestStructure rs = new requestStructure();
                    rs.product = product.ProductCode;
                    rs.quantity = '1';  //Is this a factor in response from Phoenix, currently mock throws invalid response for anything other than 1, so 
                    rsList.add(rs);
                    string jsonBodyString = JSON.serialize(rsList);
                    system.debug('jsonBodyString is '+jsonBodyString);
                    httpReq.setBody(jsonBodyString);
            		Http htp = new Http();
            		HttpResponse httpRes = htp.send(httpReq);
            		system.debug('Response is '+httpRes.getBody());
                    ResponseStructure rss = parse(httpRes.getBody());
                    if(rss != null){
                        system.debug('Response is '+rss.charges);
                        if(rss.charges != null){
                                for(string chargeCategory : Constant.CHARGE_PRODUCTLIST_CATEGORIES){
                                    if(rss.charges.contains(chargeCategory)){
                                       applicableCharges.add(chargeCategory); 
                                }
                            }
                        }
                    }	
            }
            	system.debug('applicableCharges is '+applicableCharges);
                return applicableCharges;
        }*/
    
        private static Map<Id,List<Product2>> checkForChargeProducts(List<Product2> selectedProducts){
            Map<String, Product2> chargeProductCategoryProductMap = OrderFlowControllerHelper.getChargeProduct();
            Map<Id, List<Product2>> productIdChargeProductMap = new Map<Id, List<Product2>>();

            for(Product2 product : selectedProducts)
            {
                OrderFlowControllerHelper.ResponseStructure rss = OrderFlowControllerHelper.prepareRequestAndMakeCallout(product.ProductCode);
                 if(rss != null){
                        system.debug('Response is '+rss.charges);
                        if(rss.charges != null){
                                for(string chargeCategory : Constant.CHARGE_PRODUCTLIST_CATEGORIES){
                                    if(rss.charges.contains(chargeCategory)){
                                    if(productIdChargeProductMap.containsKey(product.Id)){
                                            productIdChargeProductMap.get(product.Id).add(chargeProductCategoryProductMap.get(chargeCategory));
                                    }
                                    else{
                                        productIdChargeProductMap.put(product.Id, new List<Product2>{chargeProductCategoryProductMap.get(chargeCategory)});
                                    }
                                }
                            }
                        }
                    }	
            }
            system.debug('productIdChargeProductMap is '+productIdChargeProductMap);
            return productIdChargeProductMap;
        }
       
    /*
     * called from component to delete a product and its related charges
	*/
        @AuraEnabled
        public static void deleteOpportunityLineItem(Id oppLineItemId){
           system.debug('oppLineItem is '+oppLineItemId);
            List<OpportunityLineItem> toBeDeletedOLI = new List<OpportunityLineItem>();
            
            OpportunityLineItem oli = [
                SELECT Id, Name, Quantity, TotalPrice,Linked_Product_ID__c,Product2Id
                FROM OpportunityLineItem
                WHERE Id =:oppLineItemId];
            toBeDeletedOLI.add(oli);
            
            if(oli.Product2Id != null){
            	List<OpportunityLineItem> chargeProductoli = [SELECT Id, Name, Quantity, TotalPrice,Linked_Product_ID__c,Product2Id
                											  FROM OpportunityLineItem
                											  WHERE Linked_Product_ID__c =:oli.Product2Id
                											  WITH SECURITY_ENFORCED];

                if(chargeProductoli.size() > 0){
                    toBeDeletedOLI.addAll(chargeProductoli);    
                }
                
            }
            delete toBeDeletedOLI;
        }

        @AuraEnabled
        public static void updateStepOnOpportunity(string Step, Id OpportunityId){
            Opportunity opp =  new Opportunity(Id = OpportunityId, Current_Step__c =Step);
            update opp;
        }

        @AuraEnabled(cacheable=true)
        public static Opportunity getOpportunityDetails(Id OpportunityId){

            return [Select Id, Current_Step__c from Opportunity where Id = :OpportunityId];
        }        
}