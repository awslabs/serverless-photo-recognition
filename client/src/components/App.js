import React, { Component } from 'react';
import Amplify from 'aws-amplify';
import { Auth } from 'aws-amplify';
import { withAuthenticator } from 'aws-amplify-react';
import { Authenticator, SignIn, SignUp, ConfirmSignUp, Greetings } from 'aws-amplify-react';
import { Storage } from 'aws-amplify';
//import { PhotoPicker } from 'aws-amplify-react';
// import AppSignedIn from './AppSignedIn';
import Layout from './Layout'
import '../styles/app.css'

Amplify.configure({
    Auth: {
        region: 'us-east-1', // REQUIRED - Amazon Cognito Region
        userPoolId: 'us-east-1_BIhRQnDpw', //OPTIONAL - Amazon Cognito User Pool ID
        userPoolWebClientId: '50pf7h51rkp395d9aonsgq311b', //OPTIONAL - Amazon Cognito Web Client ID
        identityPoolId: 'us-east-1:7c645d65-b18e-4db0-b84f-d137ce5d236f', //REQUIRED - Amazon Cognito Identity Pool ID
    }, 
    Storage: {
        bucket: 'rekognition-20180119151350/usercontent', //REQUIRED -  Amazon S3 bucket
        region: 'us-east-1', //OPTIONAL -  Amazon service region
        identityPoolId: 'us-east-1:7c645d65-b18e-4db0-b84f-d137ce5d236f'
    }
});

// const AlwaysOn = (props) => {
//     return (
//         <div>
//             <div>I am always here to show current auth state: {props.authState}</div>
//             <button onClick={() => props.onStateChange('signUp')}>Show Sign Up</button>
//         </div>
//     );
// }

class App extends Component {
  // constructor(){
  //   super();
  //   this.signedIn = this.signedIn.bind(this);
  // }

  // signedIn(signedIn){
  //   this.props.state.signedIn(signedIn);
  // }

  // handleAuthStateChange(state) {
  //     if (state === 'signedIn') { 
  //       this.signedIn(true);
  //     }
  // }

  // signIn() {
  //   var username = document.getElementById("username").value;
  //   var password = document.getElementById("password").value;
  //   var self = this;
  //   Auth.signIn(username, password)
  //   .then(function(user) {
  //     console.log(user);
  //     self.signedIn(true);
  //   }).catch(err => console.log(err));
  // }

  // render() {
  //     return (
  //         <Authenticator hideDefault={true} onStateChange={this.handleAuthStateChange}>
  //             <div className="container col-sm-offset-2 col-sm-8">
  //               <div className="col-sm-offset-3 col-sm-6">
  //                 <input id="username" placeholder="Username" type="text" />
  //               </div>
  //               <div className="col-sm-offset-3 col-sm-6">
  //                 <input id="password" placeholder="Password" type="password" />
  //               </div>
  //               <div className="col-sm-offset-3 col-sm-6">
  //                 <button className="btn btn-info btn-lg" onClick={this.signIn}>Sign In</button>
  //               </div>
  //               <div className="col-sm-offset-3 col-sm-6">
  //                 <button className="helper-button">Sign Up</button>
  //                 <button className="helper-button" id="forgot-password">Forgot Password</button>
  //               </div>
  //             </div>
  //               <div>
  //                 <Layout { ...this.props } />
  //               </div>
  //         </Authenticator>

  //     )
  // }

  render(){
    return (
      <div>
        <Layout { ...this.props } />
      </div>
    );
  }

}

export default withAuthenticator(App, { includeGreetings: true });
// export default App;