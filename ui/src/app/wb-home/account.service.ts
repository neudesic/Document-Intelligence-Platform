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

  constructor(private http: HttpClient) {
    this.getInfo();
  }

  async getInfo() {
    // await this.http.get('../../config.json').subscribe(val => this.cosmosAccount = String(val['cosmosAccount']));
    // await this.http.get('../../config.json').subscribe(val => this.storageAccount = String(val['storageAccount']));
    // await this.http.get('../../config.json').subscribe(val => this.cosmosKey = String(val['cosmosAccessKey']));
    // await this.http.get('../../config.json').subscribe(val => this.searchAccount = String(val['searchAccount']));
    // await this.http.get('../../config.json').subscribe(val => this.searchKey = String(val['searchKey']));
    await this.http.get('../../assets/config.json').subscribe(val => this.cosmosAccount = String(val['cosmosAccount']));
    await this.http.get('../../assets/config.json').subscribe(val => this.storageAccount = String(val['storageAccount']));
    await this.http.get('../../assets/config.json').subscribe(val => this.cosmosKey = String(val['cosmosAccessKey']));
    await this.http.get('../../assets/config.json').subscribe(val => this.searchAccount = String(val['searchAccount']));
    await this.http.get('../../assets/config.json').subscribe(val => this.searchKey = String(val['searchKey']));
  }

}
