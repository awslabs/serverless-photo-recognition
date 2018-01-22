import React, { Component } from 'react';
import { S3Image } from 'aws-amplify-react';


class Upload extends Component {
  render() {
  	//if (this.props.state.selectedMenuItem !== 'upload') { return null; }
    return (
      <div className="Upload">
        <S3Image picker />
      </div>
    );
  }
}

export default Upload;