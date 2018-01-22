import React, { Component } from 'react';
import AppContainer from '../containers/AppContainer';
window.adapter = require('webrtc-adapter');

class App extends Component {
	render(){
		return(
			<AppContainer>
				{ this.props.children }
			</AppContainer>
		);
	}	
}

export default App;
