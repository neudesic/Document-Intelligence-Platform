/*
Contains classes representing various responses from the CosmosDB REST api
*/

// Model for cosmosDB api response for w2-form collection
export interface W2Form {
    form: FormW2;
    id: string;
    _rid: string;
    _self: string;
    _etag: string;
    _attachments: string;
    _ts: number;
}
export interface FormW2 {
    ss: string;
    identificationNumber: string;
    compensation: string;
    federalIncomeTaxWithheld: string;
    employerInformation: string;
    ssWages: string;
    ssTaxWithheld: string;
    medicareWages: string;
    medicareTaxWithheld: string;
    ssTips: string;
    controlNumber: string;
    dependentCareBenifits: string;
    employeeInformation: string;
}

// Model for cosmosDB api response for w2-form-enriched collection
export interface W2FormEnriched {
    id: string;
    results: ResultsW2;
    _rid: string;
    _self: string;
    _etag: string;
    _attachments: string;
    _ts: number;
}
export interface ResultsW2 {
    disposableIncome: string;
}

// Model for cosmosDB api response for financial-table collection
export interface FinancialTable {
    form: FormFinancial;
    id: string;
    _rid: string;
    _self: string;
    _etag: string;
    _attachments: string;
    _ts: number;
}
export interface FormFinancial {
    income: string;
    extraIncome: string;
    totalMonthlyIncome: string;
    mortgageOrRent: string;
    phone: string;
    electricity: string;
    housingSubtotal: string;
    personal: string;
    student: string;
    creditCard: string;
    loansSubtotal: string;
    home: string;
    health: string;
    insuranceSubtotal: string;
    totalActualCost: string;
    actualBalance: string;
    life?: null;
}

// Model for cosmosDB api response for financial-table-enriched collection
export interface FinancialTableEnriched {
    id: string;
    results: ResultsFinancial;
    _rid: string;
    _self: string;
    _etag: string;
    _attachments: string;
    _ts: number;
}
export interface ResultsFinancial {
    debtIncomeRatio: string;
    debtIncomeRatioRating: string;
    insuranceRating: string;
    utilityRating: string;
    mortgageRating: string;
}

// Model for cosmosDB api response for processed collection
export interface Processed {
    form: FormProcessed;
    id: string;
    _rid: string;
    _self: string;
    _etag: string;
    _attachments: string;
    _ts: number;
}
export interface FormProcessed {
    yearlyMortageForecast: string;
    yearlyUtilityForecast: string;
    yearlyLoansForecast: string;
    yearlyInsuranceForecast: string;
    yearlyNetForecast: string;
}
