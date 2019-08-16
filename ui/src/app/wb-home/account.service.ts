/*
Retrieves authentication information for CosmosDB, Blob and Azure Search REST apis
*/

import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})

export class AccountService {
  cosmosAccount;
  storageAccount;
  cosmosKey;
  searchAccount;
  searchKey;
  logicApp1Url;
  logicApp2Url;
  modelW2;
  modelFinancial;
  storageSas;


  constructor(private http: HttpClient) {
    this.getInfo();
  }

  async getInfo() {
    // For production
    await this.http.get('../../config.json').subscribe(val => this.cosmosAccount = String(val['cosmosAccount']));
    await this.http.get('../../config.json').subscribe(val => this.storageAccount = String(val['storageAccount']));
    await this.http.get('../../config.json').subscribe(val => this.cosmosKey = String(val['cosmosAccessKey']));
    await this.http.get('../../config.json').subscribe(val => this.searchAccount = String(val['searchAccount']));
    await this.http.get('../../config.json').subscribe(val => this.searchKey = String(val['searchKey']));
    await this.http.get('../../config.json').subscribe(val => this.logicApp1Url = String(val['logicAppTrigger1']));
    await this.http.get('../../config.json').subscribe(val => this.logicApp2Url = String(val['logicAppTrigger2']));
    await this.http.get('../../config.json').subscribe(val => this.modelW2 = String(val['w2Model']));
    await this.http.get('../../config.json').subscribe(val => this.modelFinancial = String(val['financialModel']));
    await this.http.get('../../config.json').subscribe(val => this.storageSas = String(val['storageSas']));

    // For local testing
    // await this.http.get('../../assets/config.json').subscribe(val => this.cosmosAccount = String(val['cosmosAccount']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.storageAccount = String(val['storageAccount']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.cosmosKey = String(val['cosmosAccessKey']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.searchAccount = String(val['searchAccount']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.searchKey = String(val['searchKey']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.logicApp1Url = String(val['logicAppTrigger1']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.logicApp2Url = String(val['logicAppTrigger2']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.modelW2 = String(val['w2Model']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.modelFinancial = String(val['financialModel']));
    // await this.http.get('../../assets/config.json').subscribe(val => this.storageSas = String(val['storageSas']));
  }

}
