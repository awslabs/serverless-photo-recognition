import React, { Component } from 'react';
import UploadContainer from "../containers/Upload"

class Upload extends Component {
	render(){
		return <UploadContainer { ...this.props } />
	}	
}

export default Upload;
