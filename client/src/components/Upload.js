import React, { Component } from 'react';
import { S3Image } from 'aws-amplify-react';
import { Storage } from 'aws-amplify';
import "../styles/upload.css"


class Upload extends Component {
  constructor(props) {
    super(props);
    Storage.configure({ level: 'private', track: true });
    this.onChange = this.onChange.bind(this);
  }

  onChange(e) {
  	this.setState({file:e.target.files[0]})
  }

  render() {
    return (
    	<S3Image level="private" picker />
    );
  }
}

export default Upload;

   //    	<form onSubmit={this.onFormSubmit}>

	  //       <label className="btn btn-default btn-file">
			//     Choose Photo or Video File <input type="file" onChange={this.onChange}/>
			// </label>
	  //       <button type="submit">Upload</button>
	  //     </form>

	  //      <div className="Upload">
      //	<input id="input-b1" name="input-b1" type="file" className="file" />
      //</div>