import React, { Component } from 'react';
import LayoutContainer from '../containers/Layout'

export default class Layout extends Component {
	render(){
		return(
			<LayoutContainer { ...this.props } > 
				{ this.props.children }
			</LayoutContainer>
		);
	}	
}