/**
* Service class responsible for resolving product pricing information
* for a given Contact. 
*
* This class is used by:
*  • LWC (getProductSummary)
*  • REST API (getProductSummaryForApi)
*
* Logic flow:
*  1. Read the Contact’s Product__c + Home_Country__c
*  2. Match with the pricing table (Custom Metadata)
*  3. If no country match → fall back to product default pricing
*  4. If nothing matches → return an “empty” product info 
*/
public with sharing class ProductInfoService {
    
    @testVisible
    static List<Product_Pricing__mdt> testPricingRows;
    
    @AuraEnabled(cacheable=true)
    public static ProductInfo getProductSummary(Id contactId) {
        if (contactId == null) return null;
        
        try{
            if(!Schema.sObjectType.Contact.fields.Product__c.isAccessible() || !Schema.sObjectType.Contact.fields.Home_Country__c.isAccessible()) {
                return null;
            }
            
            List<Contact> contacts = [
                SELECT Id, Product__c, Home_Country__c
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
            ];
            
            return buildProductInfo(contacts[0].Product__c, contacts[0].Home_Country__c);
        }catch (QueryException qe) {
            
            throw new AuraHandledException('Failed to retrieve Contact: ' + qe.getMessage());
        }
    }
    
    public static ProductInfo getProductSummaryForApi(Contact c){
        if(c == null) return null;
        return buildProductInfo(c.Product__c, c.Home_Country__c);
    }
    
    private static ProductInfo buildProductInfo(String product, String country) {
        if (String.isBlank(product) || String.isBlank(country)) {
            return ProductInfo.empty(product, country);
        }
        
        List<Product_Pricing__mdt> all = getPricingRows();
        
        for (Product_Pricing__mdt row : all) {
            if (row.Product_Name__c == product && row.Country_Code__c == country) {
                return ProductPricingMapper.toDTO(row);
            }
        }      
        for (Product_Pricing__mdt row : all) {
            if (row.Product_Name__c == product && row.Is_Default__c == true) {
                return ProductPricingMapper.toDTO(row);
            }
        }
        return ProductInfo.empty(product, country);
    }
    
    private static List<Product_Pricing__mdt> getPricingRows() {
        if (Test.isRunningTest() && testPricingRows != null) {
            return testPricingRows;
        }
        return [
            SELECT DeveloperName, Product_Name__c, Country_Code__c,
            Monthly_Cost__c, ATM_Fee__c, Card_Replacement_Cost__c, Is_Default__c
            FROM Product_Pricing__mdt
        ];
    }
}