/*
Contains class representing response from the CosmosDB REST api
*/

// Model for cosmosDB api response for all collections
export interface Applicant {
    _rid: string;
    Documents?: (DocumentsEntity)[] | null;
    _count: number;
  }
  export interface DocumentsEntity {
    form: Form;
    id: string;
    _rid: string;
    _self: string;
    _etag: string;
    _attachments: string;
    _ts: number;
  }
  export interface Form {
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
