import { TestBed } from '@angular/core/testing';

import { WbApplicationDetailService } from './wb-application-detail.service';

describe('WbApplicationDetailService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: WbApplicationDetailService = TestBed.get(WbApplicationDetailService);
    expect(service).toBeTruthy();
  });
});
