import React, { Component } from 'react';
import AppContainer from "../containers/App"

class App extends Component {
	render(){
		return <AppContainer { ...this.props } />
	}	
}

export default App;
