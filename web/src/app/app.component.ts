import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { catchError, map, Observable, of } from 'rxjs';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  public counter: number = 0;

  form: FormGroup;
  thankYouMessage: string;

  constructor(
    private _formBuilder: FormBuilder,
    private httpClient: HttpClient,
    ) {}
  
  ngOnInit(): void {
    this.createForm();
    // https://blog.jscrambler.com/working-with-angular-local-storage/
    const counterString = localStorage.getItem('counter');
    if (counterString) {
      this.counter = +counterString;
    }
  }

  createForm() {
    this.form = this._formBuilder.group({
      'usersName': [],
      'occasion': [],
      'gift': [],
    });
  }

  public increment():void {
    this.counter++;
    localStorage.setItem('counter', `${this.counter}`);
  }

  onSubmit(form: any)  {
    this.makeRequest().subscribe(x => {
      this.thankYouMessage = x.choices[0].text;
      console.log(this.thankYouMessage);
    });
    // this.thankYouMessage = "thanks!";
  };

  makeRequest(): Observable<any> {
    // var body = {
    //   usersName: this.form.controls['usersName'].value,
    //   occasion: this.form.controls['occasion'].value,
    //   gift: this.form.controls['gift'].value,
    // }
    // console.log(body);
    const config = { headers: new HttpHeaders().set('Content-Type', 'application/json')};
    return this.httpClient.post<any>("http://localhost:8080", { UsersName: 'stephen', Occasion: 'Wedding', Gift: 'iPhone' }, config)
    .pipe(
      catchError(e => of(console.log(e)))
    );
  }

  copyText(): string {
    // this.clipboard.write(this.thankYouMessage);
    return "copied";
  }
}
