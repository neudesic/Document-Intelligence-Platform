/*
Contains all of the methods for getting information (from CosmosDB) regarding a specific applicant
*/


import { Injectable } from '@angular/core';
import * as Crypto from 'crypto-js';
import { HttpClient } from '@angular/common/http';
import { HttpHeaders } from '@angular/common/http';
import { W2Form, FormW2, W2FormEnriched, ResultsW2, FinancialTable, FormFinancial, FinancialTableEnriched, ResultsFinancial, Processed, FormProcessed } from './applicant.model';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { AccountService } from '../wb-home/account.service';


@Injectable()
export class WbApplicationDetailService {

  private cosmosAccount = this.account.cosmosAccount;
  private storageAccount = this.account.storageAccount;
  private cosmosKey = this.account.cosmosKey;

  constructor(private http: HttpClient, private account: AccountService) {
  }

  // Calls CosmosDB REST api and returns observable containing document with id = "applicantId" from w2-form collection
  getW2(applicantId: string): Observable<FormW2> {
    return this.http.get<W2Form>(this.getCosmosUrl('w2-form', applicantId, this.cosmosAccount), this.setHeadersCosmos('w2-form', applicantId)).pipe(map(val => val['form']));
  }

  // Calls CosmosDB REST api and returns observable containing document with id = "applicantId" from w2-form-enriched collection
  getW2Enriched(applicantId: string): Observable<ResultsW2> {
    return this.http.get<W2FormEnriched>(this.getCosmosUrl('w2-form-enriched', applicantId, this.cosmosAccount), this.setHeadersCosmos('w2-form-enriched', applicantId)).pipe(map(val => val['results']));
  }

  // Calls CosmosDB REST api and returns observable containing document with id = "applicantId" from financial-table collection
  getFinancial(applicantId: string): Observable<FormFinancial> {
    return this.http.get<FinancialTable>(this.getCosmosUrl('financial-table', applicantId, this.cosmosAccount), this.setHeadersCosmos('financial-table', applicantId)).pipe(map(val => val['form']));
  }

  // Calls CosmosDB REST api and returns observable containing document with id = "applicantId" from financial-table-enriched collection
  getFinancialEnriched(applicantId: string): Observable<ResultsFinancial> {
    return this.http.get<FinancialTableEnriched>(this.getCosmosUrl('financial-table-enriched', applicantId, this.cosmosAccount), this.setHeadersCosmos('financial-table-enriched', applicantId)).pipe(map(val => val['results']));
  }

  // Calls CosmosDB REST api and returns observable containing document with id = "applicantId" from processed collection
  getProcessed(applicantId: string): Observable<FormProcessed> {
    return this.http.get<Processed>(this.getCosmosUrl('processed', applicantId, this.cosmosAccount), this.setHeadersCosmos('processed', applicantId)).pipe(map(val => val['form']));
  }

  // Calls Blob Storage REST api and returns blob with filename = "applicantId" from w2-form container
  getW2Blob(applicantId: string): any {
    return this.http.get(this.getBlobUrl(applicantId, 'w2-form', this.storageAccount), this.setHeadersBlob());
  }

  // Calls Blob Storage REST api and returns blob with filename = "applicantId" from financial-table container
  getFinancialBlob(applicantId: string): any {
    return this.http.get(this.getBlobUrl(applicantId, 'financial-table', this.storageAccount), this.setHeadersBlob());
  }

  // Returns HTTP header for Blob Rest api
  setHeadersBlob(): any {
    return {
      headers: new HttpHeaders({
        'x-ms-date': new Date().toUTCString(),
        'x-ms-version': '2018-03-28',
      }), responseType: 'blob'
    };
  }

  // Returns url for Blob REST api
  getBlobUrl(applicantId: string, collection: string, storageAccount: string): string {
    return 'https://cors-anywhere.herokuapp.com/https://' + storageAccount + '.blob.core.windows.net/' + collection + '/' + applicantId;
  }

  // Returns HTTP header for CosmosDB Rest api
  setHeadersCosmos(collection: string, applicantId: string): any {
    return {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': this.getAuthorization(collection, applicantId),
        'x-ms-date': new Date().toUTCString(),
        'x-ms-version': '2018-12-31',
        'x-ms-documentdb-partitionkey': '["' + applicantId + '"]'
      })
    };
  }

  // Returns authorization key for CosmosDB REST api
  getAuthorization(collection: string, applicantId: string): string {
    const resourceType = 'docs';
    const masterKey = this.cosmosKey;
    const resourceId = 'dbs/dip-github-db/colls/' + collection + '/docs/' + applicantId;
    const utcDate = new Date().toUTCString();
    const verb = 'GET';
    const text = (verb || '').toLowerCase() + '\n' + (resourceType || '').toLowerCase() + '\n' + (resourceId || '') + '\n' + utcDate.toLowerCase() + '\n' + '' + '\n';
    const key = Crypto.enc.Base64.parse(masterKey);
    const signature = Crypto.HmacSHA256(text, key).toString(Crypto.enc.Base64);
    const MasterToken = 'master';
    const TokenVersion = '1.0';
    const authToken = encodeURIComponent('type=' + MasterToken + '&ver=' + TokenVersion + '&sig=' + signature);
    return authToken;
  }

  // Returns url for Blob REST api
  getCosmosUrl(collection: string, applicantId: string, cosmosAccount: string): string {
    return 'https://cors-anywhere.herokuapp.com/https://' + cosmosAccount + '.documents.azure.com/dbs/dip-github-db/colls/' + collection + '/docs/' + applicantId;
  }

  // Return string containing a dollar sign and commas after every third digit
  numberBeautify(value: number): string {
    return '$' + value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  // Converts string to number: removes dollar sign/commas and casts to number
  removeDollarSignComma(value: any): number {
    return +String(value).replace('$', '').replace(',', '');
  }

}
