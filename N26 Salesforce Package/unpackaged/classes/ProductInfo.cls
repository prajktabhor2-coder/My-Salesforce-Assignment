/**
 * Lightweight wrapper class used to return product pricing
 * information to LWC and the REST API.
 *
 * This object is intentionally simple — it mirrors the fields in 
 * Product_Pricing__mdt and provides a clean JSON‑serializable structure
 * for UI/API consumers.
 */
public class ProductInfo {
    @AuraEnabled public String  productName;
    @AuraEnabled public String  countryCode;
    @AuraEnabled public Decimal monthlyCost;
    @AuraEnabled public Decimal atmFee;
    @AuraEnabled public Decimal cardReplacementCost;
    @AuraEnabled public Boolean isDefault;

    public ProductInfo() {}

    public ProductInfo(String productName,
                       String countryCode,
                       Decimal monthlyCost,
                       Decimal atmFee,
                       Decimal cardReplacementCost,
                       Boolean isDefault) {
        this.productName         = productName;
        this.countryCode         = countryCode;
        this.monthlyCost         = monthlyCost;
        this.atmFee              = atmFee;
        this.cardReplacementCost = cardReplacementCost;
        this.isDefault           = isDefault;
    }

    public static ProductInfo empty(String productName, String countryCode) {
        return new ProductInfo(productName, countryCode, 0, 0, 0, false);
    }
}