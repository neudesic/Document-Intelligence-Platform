import { TestBed } from '@angular/core/testing';

import { ApplicantStatusService } from './applicant-status.service';

describe('ApplicantStatusService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: ApplicantStatusService = TestBed.get(ApplicantStatusService);
    expect(service).toBeTruthy();
  });
});
