/*
Contains methods for uploading files to blob storage and running logicApp1 and logicApp2
*/

import { Injectable } from '@angular/core';
import {
  Aborter,
  BlobURL,
  BlockBlobURL,
  ContainerURL,
  ServiceURL,
  StorageURL,
  AnonymousCredential
} from '@azure/storage-blob';
import { HttpClient } from '@angular/common/http';
import { AccountService } from '../wb-home/account.service';


@Injectable({
  providedIn: 'root'
})

export class UploadBlobService {

  constructor(private http: HttpClient, private account: AccountService) { }

  // Uploads inputted file to blob storage and runs the file through logicApp1
  async upload(file: File, fileName: string, type: string, extension: string) {

    let container;

    if (type === 'w2') {
      container = 'w2-form';
    } else {
      container = 'financial-table';
    }
    const url = 'https://' + this.account.storageAccount + '.blob.core.windows.net/' + this.account.storageSas;
    const anonymousCredential = new AnonymousCredential();
    const pipeline = StorageURL.newPipeline(anonymousCredential);
    const serviceURL = new ServiceURL(
      url,
      pipeline
    );
    const containerURL = ContainerURL.fromServiceURL(serviceURL, container);
    const content = file;
    const blobName = fileName + extension;
    const blobURL = BlobURL.fromContainerURL(containerURL, blobName);
    const blockBlobURL = BlockBlobURL.fromBlobURL(blobURL);
    const uploadBlobResponse = await blockBlobURL.upload(
      Aborter.none,
      content,
      file.size
    );
    console.log(
      `Upload block blob ${blobName} successfully`,
      uploadBlobResponse.requestId
    );
    await this.triggerLogicApp1(type, blobName);
  }

  // Runs the inputted file through logicApp1
  async triggerLogicApp1(type: string, fileName: string) {
    const url = this.account.logicApp1Url;
    if (type === 'w2') {
      await this.http.post(url, { recordId: '/w2-form/' + fileName, modelId: this.account.modelW2, formType: 'W2' }).toPromise();
    } else {
      await this.http.post(url, { recordId: '/financial-table/' + fileName, modelId: this.account.modelFinancial, formType: 'Financial Table' }).toPromise();
    }
  }

  // Runs the inputted file through logicApp2
  async triggerLogicApp2(fileName: string) {
    const url = this.account.logicApp2Url;
    await this.http.post(url, { recordId: fileName }).toPromise();
  }

}

