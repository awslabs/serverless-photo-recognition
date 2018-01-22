import React, { Component } from 'react';
import { SideMenu, Item } from 'react-sidemenu'

import Upload from './Upload'
import '../styles/AppSignedIn.css'

class AppSignedIn extends Component {
  constructor(props) {
    super(props);
    this.selectedMenuItem = this.selectedMenuItem.bind(this);
  }

  selectedMenuItem(item) {
    this.props.state.selectedMenuItem(item);
  }

  render() {
    if (this.props.authState !== 'signedIn') { return null; }

    return (
      <div className="AppSignedIn">
        <SideMenu onMenuItemClick={(value) => this.props.selectedMenuItem = value}>
          <Item divider={true} label="Media Files" value="media-files"/>
            <Item label="Browse" value="browse" icon="fa-search"></Item>
            <Item label="Upload" value="upload" icon="fa-automobile"></Item>
          <Item divider={true} label="Rekognition" value="rekognition"/>
          <Item label="Labels" value="labels" icon="fa-bar-chart"/>
        </SideMenu>
        <div className="content">
          <Upload />
        </div>

      </div>
    );
  }
}

export default AppSignedIn;