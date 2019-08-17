import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WbUploadComponent } from './wb-upload.component';

describe('WbUploadComponent', () => {
  let component: WbUploadComponent;
  let fixture: ComponentFixture<WbUploadComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WbUploadComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WbUploadComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
