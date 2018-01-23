import React from 'react';
import { Router, Route, browserHistory } from 'react-router';

import App from './pages/App';
import Upload from './pages/Upload'
import NotFound from './pages/NotFound';


export default (
	<Router history={browserHistory}>
		<Route component={App}>
			<Route path="/" component={Upload}/>
			<Route path="/upload" component={Upload}/>
		</Route>
		<Route path="*" component={NotFound} />
	</Router>
);
