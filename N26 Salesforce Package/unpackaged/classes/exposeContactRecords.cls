/**
 * REST endpoint that exposes Contact + Product Pricing information
 * to external consumers.
 *
 * URL pattern:
 *    /services/apexrest/n26/v1/contactinfo/{uuid}
 *
 * Flow:
 *   1. Extract the Contact UUID from the URL
 *   2. Validate the request
 *   3. Look up the Contact using External_UUID__c
 *   4. Use ProductInfoService to fetch pricing details
 *   5. Build a lightweight response  (ContactInfoResponse)
 *   6. Serialize into JSON
 *
 * Error responses:
 *   • 400 → UUID missing
 *   • 404 → No matching Contact
 *   • 500 → System/Query exceptions
 */

@RestResource(urlMapping='/n26/v1/contactinfo/*')
global with sharing class exposeContactRecords {

    // -----wrapper used to structure the JSON response-----
    global class ContactInfoResponse {
        public String uuid;
        public String ContactfirstName;
        public String ContactlastName;
        public String email;
        public String product;      // Contact.Product__c
        public String countryCode;  // Contact.Home_Country__c
        public ProductInfo productInfo; 

        public ContactInfoResponse() {}
    }

    // ---- Get the Product Info ---
    @HttpGet
    global static void doGet() {
        try{
        RestRequest req = RestContext.request;
        String uuid = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        if (String.isBlank(uuid)) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{"error":"missing_uuid"}');
            return;
        }

        List<Contact> contacts = [ SELECT Id, FirstName, LastName, Email, Product__c, Home_Country__c, External_UUID__c
                                  FROM Contact
                                  WHERE External_UUID__c = :uuid
                                  LIMIT 1
                                 ];

        if (contacts.isEmpty()) {
            RestContext.response.statusCode = 404;
            RestContext.response.responseBody = Blob.valueOf('{"error":"not_found"}');
            return;
        }

        Contact c = contacts[0];

        // pricing info from service
        ProductInfo pricing = ProductInfoService.getProductSummaryForApi(c);
    
        ContactInfoResponse resp = new ContactInfoResponse();
        resp.uuid        = c.External_UUID__c;
        resp.ContactfirstName   = c.FirstName;
        resp.ContactlastName    = c.LastName;
        resp.email       = c.Email;
        resp.product     = c.Product__c;
        resp.countryCode = c.Home_Country__c;
        resp.productInfo = pricing;

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(resp));
         } catch (QueryException qe) {
            sendError(500, 'Exception', qe.getMessage());
        }
    }
    private static void sendError(Integer code, String type, String message) {
        RestContext.response.statusCode = code;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody =
            Blob.valueOf('{"error":"' + type + '","message":"' + message + '"}');
    }
}