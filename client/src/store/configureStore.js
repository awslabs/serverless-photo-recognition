import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import { logger } from 'redux-logger';
import reducers from '../reducers';

export default function configureStore(){
	return createStore(
		reducers,
		{},
		applyMiddleware(thunk, logger)
	);
};

