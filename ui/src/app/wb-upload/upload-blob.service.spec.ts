import { TestBed } from '@angular/core/testing';

import { UploadBlobService } from './upload-blob.service';

describe('UploadBlobService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: UploadBlobService = TestBed.get(UploadBlobService);
    expect(service).toBeTruthy();
  });
});
