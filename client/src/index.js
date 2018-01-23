import React from 'react';
import './styles/index.css';
import './styles/bootstrap-css/bootstrap.min.css'
import { render } from 'react-dom';
import { Provider } from 'react-redux';
import configureStore from './store/configureStore';
import registerServiceWorker from './register';
import router from './routes';
const store = configureStore();
registerServiceWorker();

render(
	<Provider store={store}>
		{ router }
	</Provider>,
	document.getElementById("root")
);
