/**
 * Test class for ProductInfoService, related productInfo And ProductPricingMapper..
 */
@IsTest
private class ProductInfoServiceTest {

    @IsTest
    static void PricingRowsFromOverride() {
      
        Product_Pricing__mdt stdDE = new Product_Pricing__mdt(
            DeveloperName            = 'Standard_DE',
            Product_Name__c          = 'Standard',
            Country_Code__c          = 'DE',
            Monthly_Cost__c          = 0,
            ATM_Fee__c               = 1.7,
            Card_Replacement_Cost__c = 6,
            Is_Default__c            = false
        );
       
        Product_Pricing__mdt stdDefault = new Product_Pricing__mdt(
            DeveloperName            = 'Standard_DEFAULT',
            Product_Name__c          = 'Standard',
            Country_Code__c          = 'DEFAULT',
            Monthly_Cost__c          = 0,
            ATM_Fee__c               = 1.7,
            Card_Replacement_Cost__c = 6,
            Is_Default__c            = true
        );

        ProductInfoService.testPricingRows = new List<Product_Pricing__mdt>{
            stdDE, stdDefault
        };

        Contact c = new Contact(
            LastName        = 'Test1',
            FirstName       = 'User1',
            Email           = 'user1@test.com',
            Product__c      = 'Standard',
            Home_Country__c = 'DE'
        );
        insert c;

        Test.startTest();
        ProductInfo info = ProductInfoService.getProductSummary(c.Id);
        Test.stopTest();

        System.assertNotEquals(null, info, 'ProductInfo should not be null');
       
    }


    @IsTest
    static void ReturnsEmptyWhenNoPricingFound() {
    
        ProductInfoService.testPricingRows = new List<Product_Pricing__mdt>();

        Contact c = new Contact(
            LastName        = 'Test3',
            FirstName       = 'User3',
            Email           = 'user3@test.com',
            Product__c      = 'NonExistingProduct',
            Home_Country__c = 'DE'
        );
        insert c;

        Test.startTest();
        ProductInfo info = ProductInfoService.getProductSummary(c.Id);
        Test.stopTest();

        System.assertEquals('NonExistingProduct', info.productName);
        System.assertEquals('DE', info.countryCode);
    }

    @IsTest
    static void UsesDefaultPricingWhenNoCountrySpecificRow() {
     
        Product_Pricing__mdt stdDefault = new Product_Pricing__mdt(
            DeveloperName            = 'Standard_DEFAULT',
            Product_Name__c          = 'Standard',
            Country_Code__c          = 'DEFAULT',
            Monthly_Cost__c          = 0,
            ATM_Fee__c               = 1.7,
            Card_Replacement_Cost__c = 6,
            Is_Default__c            = true
        );

        ProductInfoService.testPricingRows = new List<Product_Pricing__mdt>{
            stdDefault
        };

        Contact c = new Contact(
            LastName        = 'Test2',
            FirstName       = 'User2',
            Email           = 'user2@test.com',
            Product__c      = 'Standard',
            Home_Country__c = 'DE'      
        );
        insert c;

        Test.startTest();
        ProductInfo info = ProductInfoService.getProductSummary(c.Id);
        Test.stopTest();

        System.assertNotEquals(null, info, 'Expected default ProductInfo, not null');
        System.assertEquals('Standard', info.productName);
      
    }

    @IsTest
    static void HandlesNullContactInApiHelper() {
        Test.startTest();
        ProductInfo info = ProductInfoService.getProductSummaryForApi(null);
        Test.stopTest();
        System.assertEquals(null, info, 'Null contact should return null');
    }
    @IsTest
    static void covers_ProductInfo_Constructors() {
        
        ProductInfo pi1 = new ProductInfo();
        ProductInfo pi2 = ProductInfo.empty('TestProd', 'IN');
        System.assertEquals('TestProd', pi2.productName);
        
    }
}