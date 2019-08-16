/*
Component representing upload page
*/

import { Component, OnInit } from '@angular/core';
import { UploadBlobService } from './upload-blob.service';
import { ListService } from '../wb-listview/list.service';


@Component({
  selector: 'app-wb-upload',
  templateUrl: './wb-upload.component.html',
  styleUrls: ['./wb-upload.component.css']
})


export class WbUploadComponent {

  w2File: File = null;
  financialFile: File = null;
  w2Status = '';
  financialStatus = '';
  fileNameStatus = '';
  fileName = '';
  extensionStatus = '';
  sameExtension = '';
  loading = '';
  error = '';

  constructor(private blobUpload: UploadBlobService, private list: ListService) { }

  // Loads chosen W2 file
  handleFileInputW2(files: FileList) {
    this.w2File = files.item(0);
    this.loading = '';
  }

  // Loads chosen Financial Table file
  handleFileInputFinancial(files: FileList) {
    this.financialFile = files.item(0);
    this.loading = '';
  }

  // Loads inputted file name
  nameFile(event) {
    this.fileName = event.target.value;
    this.loading = '';
  }

  // Uploads the selected documents to blob storage and runs them through logicApp1 and logicApp2
  async submit() {
    // await this.blobUpload.upload(this.w2File, this.fileName, 'w2', '.pdf');
    // return;
    this.error = '';
    if (this.w2File == null) {
      this.w2Status = 'pending';
    } else {
      this.w2Status = '';
    }
    if (this.financialFile == null) {
      this.financialStatus = 'pending';
    } else {
      this.financialStatus = '';
    }
    if (this.fileName === '') {
      this.fileNameStatus = 'pending';
    } else {
      this.fileNameStatus = '';
    }

    if (this.w2File != null && this.financialFile != null && this.fileName !== '') {
      const w2Extension = this.getExtension(this.w2File);
      const financialExtension = this.getExtension(this.financialFile);
      if (w2Extension !== financialExtension) {
        this.sameExtension = 'invalid';
      }
      if (this.extensionStatus !== 'invalid' && w2Extension === financialExtension) {
        this.loading = 'loading';
        try {
          await this.blobUpload.upload(this.w2File, this.fileName, 'w2', w2Extension);
          await this.blobUpload.upload(this.financialFile, this.fileName, 'financial', financialExtension);
          await this.blobUpload.triggerLogicApp2(this.fileName + w2Extension);
          this.loading = 'finished';
          this.list.getApplicants('upload');
        } catch {
          this.error = 'error';
          this.loading = '';
        }
      }
    }
  }

  // Retrieves the extension of the inputted files
  getExtension(file: File): string {
    let extension;
    if (file.type === 'application/pdf') {
      extension = '.pdf';
    } else if (file.type === 'image/png') {
      extension = '.png';
    } else if (file.type === 'image/jpeg') {
      extension = '.jpg';
    } else {
      this.extensionStatus = 'invalid';
    }
    return extension;
  }


}

