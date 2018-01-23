import React, { Component } from 'react';
import { SideMenu, Item } from 'react-sidemenu'
import { Auth } from 'aws-amplify'

import Upload from './Upload'
import '../styles/AppSignedIn.css'
import '../styles/SideBar.css'
import { Link } from 'react-router'
import PropTypes from 'prop-types'

class Layout extends Component {
  // constructor(props) {
  //   super(props);
  //   this.signOut = this.signOut.bind(this);
  // }

  // selectedMenuItem(item) {
  //   this.props.state.selectedMenuItem(item);
  // }

  signOut() {
    Auth.signOut()
      .then(data => console.log(data))
      .catch(err => console.log(err));
  }

  render() {
    if (this.props.authState !== 'signedIn') { return null; }

    // return (
    //   <div className="AppSignedIn">
    //     <SideMenu onMenuItemClick={(value) => this.props.selectedMenuItem = value}>
    //       <Item divider={true} label="Media Files" value="media-files"/>
    //         <Item label="Browse" value="browse" icon="fa-search"></Item>
    //         <Link to="/upload">
    //           <Item label="Upload" icon="fa-automobile"></Item>
    //         </Link>
    //       <Item divider={true} label="Rekognition" value="rekognition"/>
    //       <Item label="Labels" value="labels" icon="fa-bar-chart"/>
    //     </SideMenu>
    //     <div className="content">
    //       { this.props.children }
    //     </div>

    //   </div>
    // );

    return (
      <div className="AppSignedIn">
        <div className="row profile">
          <div className="col-sm-3 col-xs-5">
            <div className="profile-sidebar">
              <div className="profile-usertitle">
                <div className="profile-usertitle-name">
                  Test User
                </div>
                <div className="profile-usertitle-job">
                  Developer
                </div>
              </div>
              <div className="profile-userbuttons">
                <button onClick={ this.signOut } className="btn btn-info btn-sm">Sign Out</button>
              </div>
              <div className="profile-usermenu">
                <ul className="nav">
                  <li className="active">
                    <Link to="/upload">
                    <i className="glyphicon glyphicon-upload"></i>
                    Upload </Link>
                  </li>
                  <li>
                    <Link to="/browse">
                    <i className="glyphicon glyphicon-picture"></i>
                    Browse Files </Link>
                  </li>
                  <li>
                    <Link to="/labels">
                    <i className="glyphicon glyphicon-search"></i>
                    Rekognition Labels </Link>
                  </li>
              
                </ul>
              </div>
            </div>
          </div>
          <div className="col-sm-9 col-xs-7">
            <div className="profile-content">
              { this.props.children }
            </div>
          </div>
        </div>
      </div>
    );
  }
}

Layout.contextTypes = {
  router: PropTypes.object.isRequired
}

export default Layout;