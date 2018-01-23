import { 
	SIGNED_IN
} from '../actions/app';

const INITIAL_STATE = {
	signedIn: 'false',
};

export default function(state=INITIAL_STATE, action){
	switch(action.type){
		case SIGNED_IN:
			return {
				...state,
				stream: action.payload
			};
			break;
		default:
			return state;
			break;
	}
};
