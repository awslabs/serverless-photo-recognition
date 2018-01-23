import React, { Component } from 'react';
import Amplify from 'aws-amplify';
import { withAuthenticator } from 'aws-amplify-react';
import { Storage } from 'aws-amplify';
//import { PhotoPicker } from 'aws-amplify-react';
// import AppSignedIn from './AppSignedIn';
import Layout from './Layout'

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


class App extends Component {
  render(){
    return (
      <div>
        <Layout { ...this.props } />
      </div>
    );
  }

}

export default withAuthenticator(App, { includeGreetings: true });
