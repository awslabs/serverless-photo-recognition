import React, { Component } from 'react';
import { S3Image } from 'aws-amplify-react';
import { Storage } from 'aws-amplify';


class Upload extends Component {
  constructor(props) {
    super(props);
    Storage.configure({ level: 'private', track: true })
  }

  render() {
  	if (this.props.authState !== 'signedIn') { return null; }
    return (
      <div className="Upload">
        <S3Image level="private" picker />
      </div>
    );
  }
}

export default Upload;