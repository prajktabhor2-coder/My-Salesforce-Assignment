/**
 * Test class for exposeContactRecords,related productInfo And ProductPricingMapper.
 */
@IsTest
private class ExposeContactRecordsTest {

    @IsTest
    static void WhenUuidExists_Returns200AndPayload() {
        Contact c = new Contact(
            LastName         = 'Lopez',
            FirstName        = 'Carla',
            Email            = 'carla.lopez@test.com',
            Product__c       = 'Metal',
            Home_Country__c  = 'DE',
            External_UUID__c = 'UUID-TEST-123'
        );
        insert c;

        RestRequest req = new RestRequest();
        req.requestUri  = '/services/apexrest/n26/v1/contactinfo/UUID-TEST-123';
        req.httpMethod  = 'GET';

        RestResponse res = new RestResponse();
        RestContext.request  = req;
        RestContext.response = res;

        Test.startTest();
        exposeContactRecords.doGet();
        Test.stopTest();

        
        String body = RestContext.response.responseBody.toString();
        System.assert(body.contains('"uuid":"UUID-TEST-123"'));
        System.assert(body.contains('"productInfo"'));
    }

    @IsTest
    static void WhenUuidMissing_Returns400BadRequest() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/n26/v1/contactinfo/';
        req.httpMethod = 'GET';

        RestResponse res = new RestResponse();
        RestContext.request  = req;
        RestContext.response = res;

        Test.startTest();
        exposeContactRecords.doGet();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('missing_uuid'));
    }

    @IsTest
    static void WhenUuidNotFound_Returns404NotFound() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/n26/v1/contactinfo/UUID-NOT-EXIST';
        req.httpMethod = 'GET';

        RestResponse res = new RestResponse();
        RestContext.request  = req;
        RestContext.response = res;

        Test.startTest();
        exposeContactRecords.doGet();
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('not_found'));
    }
@IsTest
static void Returns400AndUsesSendError() {
    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/n26/v1/contactinfo/'; 
    req.httpMethod = 'GET';

    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    exposeContactRecords.doGet();
    Test.stopTest();

    System.assertEquals(400, RestContext.response.statusCode);
    System.assert(RestContext.response.responseBody.toString().contains('"error":"missing_uuid"'));
}
}