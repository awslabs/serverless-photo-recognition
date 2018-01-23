import React, { Component } from 'react';
import { S3Image } from 'aws-amplify-react';
import { Storage } from 'aws-amplify';
import "../styles/upload.css";
import preview from '../img/preview.jpg';


class Upload extends Component {
  constructor(props) {
    super(props);
    Storage.configure({ level: 'private', track: true });
    this.onChange = this.onChange.bind(this);
    this.onFormSubmit = this.onFormSubmit.bind(this);
  }

  onChange(e) {
  	this.setState({file:e.target.files[0]});
  	document.getElementById("file-input-container").className = document.getElementById("upload").className + " hidden";
  	document.getElementById("upload").className = document.getElementById("upload").className.replace("hidden", "");
  	
  	if(e.target.files[0].type.includes("image")) {
  		var reader = new FileReader();
	    reader.onload = function(){
	      var output = document.getElementById('preview');
	      output.src = reader.result;
	    };
	    reader.readAsDataURL(e.target.files[0])
  	}
  	document.getElementById("file-name").innerHTML = e.target.files[0].name;
  }

  onFormSubmit(e) {
  	e.preventDefault();
    Storage.put(this.state.file.name, this.state.file)
        .then (result => console.log(result))
        .catch(err => console.log(err));
  }

  render() {
    return (
    	<form onSubmit={this.onFormSubmit}>
    		<div className="preview-container">
    			<img id="preview" src={ preview }></img>
    			<h1 id="file-name"></h1>
    		</div>
			<label id="file-input-container" className="btn btn-lg btn-info btn-file">
			    Choose Photo or Video File <input id="file-input" type="file" accept="image/*, video/*" onChange={this.onChange}/>
			</label>
		    <button id="upload" className="hidden btn btn-success btn-lg" type="submit">Upload</button>
		</form>
    );
  }
}

export default Upload;

//<S3Image level="private" picker />

	  //      <div className="Upload">
      //	<input id="input-b1" name="input-b1" type="file" className="file" />
      //</div>