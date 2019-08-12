/*
Contains class representing response from the Azure Search REST api
*/

// Model for Azure Search api response
export interface Search {
    // @odata.context: string;
    value?: (ValueEntity)[] | null;
  }
  export interface ValueEntity {
    // @search.score: number;
    id: string;
    content: string;
    keyPhrases?: (string)[] | null;
    organizations?: (string)[] | null;
    persons?: (string)[] | null;
    locations?: (string | null)[] | null;
    metadata_storage_path: string;
    metadata_storage_name?: null;
  }
