public with sharing class OrderFlowControllerHelper {
    
    public class ResponseStructure {
            public List<String> charges;
        }
        
    public static ResponseStructure parse(String json) {
            return (ResponseStructure) System.JSON.deserialize(json, ResponseStructure.class);
        }
    
    public static ResponseStructure prepareRequestAndMakeCallout(string ProductCode){
            HttpRequest httpReq = new HttpRequest();
                        httpReq.setHeader('Content-Type','application/json');
                        httpReq.setEndpoint('callout:ChargesMockAPI');
                        httpReq.setMethod('POST');
                        List<requestStructure> rsList = new List<requestStructure>();
                        requestStructure rs = new requestStructure();
                        rs.product = ProductCode;
                        rs.quantity = '1';  //Assuming this is not a factor in response from Phoenix, currently mock throws invalid response for anything other than 1
                        rsList.add(rs);
                        string jsonBodyString = JSON.serialize(rsList);
                        httpReq.setBody(jsonBodyString);
                        Http htp = new Http();
                        HttpResponse httpRes = htp.send(httpReq);
                        system.debug('Response is '+httpRes.getBody());
                        ResponseStructure rss = parse(httpRes.getBody());
            return rss;
        }
    
        public class requestStructure
        {
            public String product;	//PRD-INS-001
		    public String quantity;	//1
        }
    
        public static Map<String,Product2> getChargeProduct()
        {
            List<Product2> chargeProducts = [select id, name,Charge_Category__c,ProductCode from Product2 where Charge_Category__c  IN:Constant.CHARGE_PRODUCTLIST_CATEGORIES];
            Map<String, Product2> chargeProductCategoryProductMap =  new Map<String,Product2>();
            for(Product2 pr : chargeProducts){
                chargeProductCategoryProductMap.put(pr.Charge_Category__c,pr);
            }
            return chargeProductCategoryProductMap;
        }
    
}